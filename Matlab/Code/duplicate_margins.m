function IM= duplicate_margins(IM)
% Duplicate margins at both sides of image for automatic initialization
         [mC,nC]=size(IM);
         leftCol=IM(:,1);
         rightCol=IM(:,nC);
         IM=[leftCol,IM,rightCol];
end