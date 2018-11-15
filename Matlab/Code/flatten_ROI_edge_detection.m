function [edge1,edge2,normG1,normG2,cropped_I]=flatten_ROI_edge_detection(flatten_gray,flatten_ROI)
 flatten_gray=double(flatten_gray);
 [m,n]=size(flatten_gray);
  for j=1:m
     row=flatten_ROI(j,:);
     if sum(row)>0
         upper_border=j;
         break;
     end
   end
   for j=m:-1:1
         row=flatten_ROI(j,:);
         if sum(row)>0
             lower_border=j;
             break;
         end
    end
    cropped_I=flatten_gray(upper_border-20:lower_border+20,:);
    
    %more smoothing
    H0=fspecial('average',[5,15]);
    smoothed_im=imfilter(cropped_I,H0);
    
    %automatic initialization
    IM= duplicate_margins(smoothed_im);
        %% Applying vertical gradients

        % Image vertical gradients
        H1=[1;-1];%light to dark
        H2=[-1;1];%dark to light
        edge1=imfilter(IM,H1);edge1=edge1(1:end-2,:);% cut last 2 rows that has the highest gradients 
        edge2=imfilter(IM,H2);edge2=edge2(1:end-2,:);
       % figure(31); imshowpair(edge1,edge2,'montage');title('left: light to dark,  right: dark to light');

        % Normalization of gradients 0-1
        %grad1=edge1(:);
        gmin=min(edge1(:));
        g1=edge1-gmin;
        gmax=max(g1(:));
        normG1=((g1)./gmax);

        %grad2=edge2(:);
        gmin=min(edge2(:));
        g2=edge2-gmin;
        gmax=max(g2(:));
        normG2=((g2)./gmax);
       
end
