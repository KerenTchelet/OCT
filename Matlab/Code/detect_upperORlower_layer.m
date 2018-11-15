function [lower,upper]=detect_upperORlower_layer(segmentedMask,cropped_I)
%the function input is a binary mask of a segmented boundary, that we would
%like to discover if it is the upper or the lower layer. The decission is
%based on bright intesity probability above the segmented boundary.
 lower=0;upper=0;
 smoothed=imgaussfilt(cropped_I, 1);
 % Normalize input data to range in [0,1].
  minLim = min(smoothed(:));maxLim = max(smoothed(:));
  Nsmoothed = (smoothed -minLim) ./ (maxLim - minLim);
 % Threshold image - global threshold
  BW = imbinarize(Nsmoothed);
 %check if there is another reflective layer above the segmented layer
  sum_bright_pix_above=0;sum_all_pix_above=0;
  for j=1:size(segmentedMask)
     lim=find(segmentedMask(:,j),1,'first');
     sum_all_pix_above=sum_all_pix_above+lim-1;
     sum_bright_pix_above=sum_bright_pix_above+sum(BW(1:lim,j));
  end
  if (sum_bright_pix_above/sum_all_pix_above)>0.06
    lower=1;        
  else
    upper=1;       
  end
end