function [Mask,boundary]=Boundary_Mask(Im,UPorDown,disk)
% The function detects estimated boundary of the retina. Inputes: Im=gray image,
% UPorDown=1/2; 1-upper boundary 2-bottom boundary. disk=size of
% morphological SE
[m,n]=size(Im);
 Mask=zeros(m,n);
 switch UPorDown
     case 1
        [L,Lbw]=K_Means(Im,2);
        bw=imbinarize(Lbw);
        se1 = strel('disk',disk);
        bw=imclose(bw,se1);
        % denising artifacts, based on image properties.
        bw = bwpropfilt(bw, 'Area', [5000 + eps(5000), Inf]);
        bw = imopen(bw,se1); 
        firstORlast='first';
     case 2
       [L,Lbw]=K_Means(Im,3);
       bw=imbinarize(Lbw);
       se1 = strel('disk',disk);
       bw=imdilate(bw,se1);
       bw=imclose(bw,se1);
       firstORlast='last';
 end
 
% denoising artifacts, based on image properties.
bw = bwpropfilt(bw, 'Area', [5000 + eps(5000), Inf]);  

 %check that there is a continuose segmentation
vec=sum(bw);
flag=find(vec==0);
r=10;%initial SE size for fixation of the boundary
while ~isempty(flag)
    r=r+2;
    se2 = strel('disk',r);
    bw=imclose(bw,se2);
    % denising artifacts, based on image properties.
    bw = bwpropfilt(bw, 'Area', [5000 + eps(5000), Inf]);
    %figure(3);imshow(bw);
    vec=sum(bw);
    flag=find(vec==0);
    
end

for j=1:n
        boundary(j) = find(bw(:,j), 1, firstORlast );
        Mask(boundary(j),j)=1;
end
% fix margins artifacts
    dis1=diff(boundary);jump=find(abs(dis1)>1);
    r=10;
       while ~isempty(jump)
          r=r+2;
          se3 = strel('disk',r);
          bw=imdilate(bw,se1);
          MaskUP=zeros(m,n);
          for j=1:n
            UP(j) = find(bw(:,j), 1, firstORlast );
            MaskUP(UP(j),j)=1;
          end
           dis1=diff(UP);jump=find(abs(dis1)>1);
       end
end