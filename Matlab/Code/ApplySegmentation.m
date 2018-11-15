function [flag, GROI]=ApplySegmentation(Im,initial_ROI)
  flag=0;%indicator for succeful segmentation: 0-succeeded 1-failed
  try
     
     [seg_IS_OS,seg_vit_NFL,seg_RPE_choroid,seg_OPL_ONL,GIm,greyIm,Unflatten,GUnflatten]=prepare_for_graph(I,initial_ROI,UP,frame);
     
  catch ME
   flag=1;
   continue;  
  end
end