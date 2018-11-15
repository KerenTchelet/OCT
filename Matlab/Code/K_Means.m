function [classified,Lbw]=K_Means(Im,k)



%Im=rgb2gray(Im);
[r,c]=size(Im);
Im=double(Im);
vec_Im=Im(:);
M=max(vec_Im)+1;
clusters=zeros(1,M);
h_Im=hist(vec_Im+1,256);%convert grey scale from0-255 to 1-256

%The algorithm devide all pixels to k clusters and and initializing their
%centers, by choosing the mean of gray levels in each cluster

Ck=(1:k).*(M)/(k+1);

OldCk=Ck+1;
% stop statemnt is when the centers don't change enymore
while(Ck~=OldCk)
   OldCk=Ck; 
   % old classification 
   for i=1:length(h_Im)
      diff=abs(Ck-i);
      closestCk=find(diff==min(diff));
      clusters(i)=closestCk(1);%add cluster label 1-k, to each gray level, considering closest center(gray level)  
   end
   %belonging all pixels after their classification to their centers
   for i=1:k
       ind=find(clusters==i);%find all pixels that classified to cluster i
       %updating the new centers by calculating the mean value of the gray levels of the cluster i
       Ck(i)=sum(ind.*h_Im(ind))/sum(h_Im(ind));
   end
end

%Classified image construction
classified=zeros(r,c);
for i=1:r
    for j=1:c
        diff2=abs(Ck-Im(i,j)+1);
        closestGreyCluster=find(diff2==min(diff2));
        classified(i,j)=closestGreyCluster;
    end
end

%% C- connected component labeling
%creating binary classification vector
bw( classified==k)=1;
bw( classified~=k)=0;
% constructing binary image
bw=reshape(bw,r,c);
Lbw=bwlabel(bw,8);

end