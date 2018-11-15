function Downsampled_Im=Im_downsampling(Im,percentage)
  Downsampled_Im=imresize(Im, percentage/100, 'bilinear');
end