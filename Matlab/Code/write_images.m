function write_images(im,path,filename,sufix)
 imwrite(im, fullfile(path, [filename(1:(end-4)),sufix]));
end