function [GROI,flatten_gray,normG1,normG2,edge1,edge2,cropped_I]=OCT_image_pre_processing(filename,path1)

 Im=imread(fullfile(path1,filename));
 I=Im(:,10:end-9);%cut 10 columns from the margins cause some scans have a lot of noise there 
 smoothedI=vertical_smooth(I) ; 
 %figure;imshowpair(I,smoothedI,'montage');
 [UP,Bot,initial_ROI]=EstimatedRetina(smoothedI);
 GROI=green_bounderies(I,initial_ROI);

 filled_ROI=imfill(initial_ROI);
 %extracting number of frame
  a=strfind(filename,'scan');
  b=strfind(filename,'_');
  frame=str2num(filename((a+4):(b(2)-1)));
  
  %flattening the retina
 [flatten_gray,flatten_ROI,gap,angle,tf_Rot,tf_flt]=flattening_image(I,filled_ROI,UP,frame);
 flatten_gray=mat2gray(flatten_gray);
 
 %preparing for graph searching- minimizing ROI and edge detection
 [edge1,edge2,normG1,normG2,cropped_I]=flatten_ROI_edge_detection(flatten_gray,flatten_ROI);
end