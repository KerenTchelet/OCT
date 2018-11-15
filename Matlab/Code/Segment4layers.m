function [finalSegmented,seg_vit_NFL,seg_IS_OS,seg_RPE_choroid,seg_OPL_ONL]=Segment4layers(cropped_I,normG1,normG2,edge1,edge2)
 %segmentation of 4 retinal layers, based Dijkstra graph searching with
 %intesity gradient weights
 %input:flatten retina image,vertical gradiented masks and there
 %normalizations
 %output:BW masks with sepearte segmented layer and all 4 together
 
     [m,n]=size(cropped_I);
     seg1=Dijkstra_graph_searching(edge2,normG2(:));
     seg1=seg1(:,2:end-1);% cutting the temporal added colomns
     
     % check if it is vitreouse-NFL or IS-OS
     [IS_OS,vit_NFL]=detect_upperORlower_layer(seg1,cropped_I);
     if  IS_OS==1
            seg_IS_OS=seg1;
            limited_ROI=limited_mask_aboveORunder_boundary(seg1,IS_OS);  
     else
            seg_vit_NFL=seg1;  
            limited_ROI=limited_mask_aboveORunder_boundary(seg1,IS_OS);  
     end
     
     %2nd segmentation
     limited_normG2=normG2(:).*(limited_ROI(:));
     seg2=Dijkstra_graph_searching(edge2,limited_normG2(:));
     seg2=seg2(:,2:end-1);% cutting the temporal added colomns
     if  IS_OS==1
            seg_vit_NFL=seg2;
     else
            seg_IS_OS=seg2;
     end
     
     % Third segmentation :RPE-choroid 
      limited_ROI2=zeros(size(seg1));
      limited_ROI3=zeros(size(seg1));
      for c=1:n
        lim=find(seg_IS_OS(:,c),1,'first');
        limited_ROI2(lim+3:end,c)=1;% the distance can be changed
        lim2=find(seg_vit_NFL(:,c),1,'first');
        dist=(lim2-lim)/2;
        limited_ROI3(lim+round(dist):lim2-2,c)=1;% the distance can be changed
      end
      limited_ROI2=limited_ROI2(1:end-2,:);
      limited_ROI2=[limited_ROI2(:,1),limited_ROI2,limited_ROI2(:,n)]; 
      limited_ROI3=limited_ROI3(1:end-2,:);
      limited_ROI3=[limited_ROI3(:,1),limited_ROI3,limited_ROI3(:,n)];
      %limited_normG1=normG1;
      limited_normG1=normG1(:).*(limited_ROI2(:));
      seg3=Dijkstra_graph_searching(edge1,limited_normG1(:));    
      seg3=seg3(:,2:end-1);% cutting the temporal added colomns
      seg_RPE_choroid=seg3;
      
     % Fourth segmentation :OPL-ONL
      limited_normG1=limited_normG1(:).*(limited_ROI3(:));
      seg4=Dijkstra_graph_searching(edge1,limited_normG1(:));
      seg4=seg4(:,2:end-1);% cutting the temporal added colomns
      seg_OPL_ONL=seg4;
      
     % Merging all 4 segmented layers
      finalSegmented=seg_IS_OS+seg_vit_NFL+seg_RPE_choroid+seg_OPL_ONL;
end