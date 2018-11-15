function filteredIm=vertical_smooth(I)
 [m,n]=size(I);
 % denoising
 H=fspecial('average',[3,5]);
 filteredIm=imfilter(I,H);
end