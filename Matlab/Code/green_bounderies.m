function GIm=green_bounderies(grayIm,BW)
% Create r, g, and b channels.
redImage = grayIm; greenImage = grayIm;blueImage =grayIm;
% Change the colors for the pixels that are suspected as 'edge'.
redImage(BW==1) = 0;
greenImage(BW==1) = 255;
blueImage(BW==1) = 0;
% Combine into a new RGB image.
GIm = cat(3, redImage, greenImage, blueImage);
end