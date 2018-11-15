%%graph_searching: Calculate Minimum Costs and Paths using Dijkstra's Algorithm
function [mask]=Dijkstra_graph_searching(edge1,normG1)
% the function get image vertical gradient of the smoothed , flattened and cropped
% image called edge1: a matrix with the resulted gradients, normG1:a vector
% contains all the normalized gradients
%s,t=start and end points in the search
%% Create an Edges Table
[m,n]=size(edge1);
wmin=10^(-5);
% define 4 possible neighbours for a pixel: diagonal N-E, right, diagonal
% S-E, down
vec=1:(m*n);
indxMat=vec2mat(vec,m).';

Right=indxMat(:,2:end);Right=[Right,zeros(m,1)];
NE=[zeros(1,n);[indxMat(1:end-1,2:end),zeros(m-1,1)]];
SE=[[indxMat(2:end,2:end),zeros(m-1,1)]; zeros(1,n)];
Down=[indxMat(2:end,:);zeros(1,n)];

Edges=[m*n m*n];
Weights=[2];
grad=normG1;
for k=1:m*n
  nodeR=Right(k);
  nodeNE=NE(k);
  nodeSE=SE(k);
  nodeD=Down(k);

   if nodeR~=0 && nodeNE~=0 && nodeSE~=0 && nodeD~=0
       w1=2-(grad(k)+grad(Right(k)))-wmin;
       w2=2-(grad(k)+grad(SE(k)))-wmin;
       w3=2-(grad(k)+grad(NE(k)))-wmin;
       w4=2-(grad(k)+grad(Down(k)))-wmin;
       if k<=m || k>m*(n-1) % Defining the minimal weights for the 2 added temporal colomns
           w4=wmin;
       end
       Edges=[Edges;k Right(k); k NE(k); k SE(k); k Down(k)];
       Weights=[Weights; w1; w3; w2; w4];
   elseif nodeR~=0 && nodeD~=0 && nodeSE~=0 
        w1=2-(grad(k)+grad(Right(k)))-wmin;
        w2=2-(grad(k)+grad(SE(k)))-wmin;
        w4=2-(grad(k)+grad(Down(k)))-wmin;
        if k<=m || k>m*(n-1) % Defining the minimal weights for the 2 added temporal colomns
           w4=wmin;
        end
        Edges=[Edges;k Right(k); k Down(k); k SE(k)];
        Weights=[Weights; w1; w4; w2];
   elseif nodeR~=0 && nodeNE~=0    
        w1=2-(grad(k)+grad(Right(k)))-wmin;
        w3=2-(grad(k)+grad(NE(k)))-wmin;
        Edges=[Edges;k Right(k); k NE(k)];
        Weights=[Weights; w1; w3];
   elseif nodeD~=0    
     % This case happens only at the last colomn (right edge), and there
     % are no neighbors, except "down"
        w4=wmin;
        Edges=[Edges;k Down(k)];
        Weights=[Weights; w4];
   end

end
EdgeTable = table(Edges,Weights);
DG = sparse(Edges(:,1),Edges(:,2),Weights);
%% Implementation dijkstra graph
[dist,path,pred] = graphshortestpath(DG,1,m*n);%default='directed',true,'Method', 'Dijkstra'
mask=zeros(size(edge1));    
mask(ind2sub([m,n],path))=1;
mask=[mask;zeros(2,n)];
end