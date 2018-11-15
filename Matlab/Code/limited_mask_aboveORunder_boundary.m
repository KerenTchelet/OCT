function limited_Mask=limited_mask_aboveORunder_boundary(segmentedMask,flag)
% if flag=1,the function crops the mask above the segmented boundary else, it
% crops it under
    [m,n]=size(segmentedMask);
    limited_Mask=zeros(m,n);
    for c=1:n
      lim=find(segmentedMask(:,c),1,'first');
      if flag==1%above
       limited_Mask(1:lim-5,c)=1;% in the artical was said 20 pixels above
      else      %under
       limited_Mask(lim+30:end,c)=1;  
      end
    end
    limited_Mask=limited_Mask(1:end-2,:);
    limited_Mask=[limited_Mask(:,1),limited_Mask,limited_Mask(:,n)];%duplicate margins 
end