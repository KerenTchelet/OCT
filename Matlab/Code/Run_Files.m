
close all;clear all;clc;
Images=Files_List('C:\Users\keren\Desktop\final_proj - new\Code\ExtractedScans','jpg');
 path='C:\Users\keren\Desktop\final_proj - new\Code';
 path1='C:\Users\keren\Desktop\final_proj - new\Code\ExtractedScans';
 path2='C:\Users\keren\Desktop\final_proj - new\Code\ROI_Segmentation';
 path3='C:\Users\keren\Desktop\final_proj - new\Code\flatten';
 path4='C:\Users\keren\Desktop\final_proj - new\Code\edge1&2';
 path5='C:\Users\keren\Desktop\final_proj - new\Code\flatten_segmented_layers';

 errors=0;
for i=1:length(Images)
  
    fullpath=Images{i};
    ix=strfind(Images{i},'\');
    filename=Images{i}(ix(end)+1:end);
    try
    [GROI,flatten_gray,normG1,normG2,edge1,edge2,cropped_I]=OCT_image_pre_processing(filename,path1);
    catch ME
         fprintf([filename 'file had an error!\n']);
         FID = fopen(fullfile(path, 'LogFile.txt'), 'a');
         fprintf(FID, '%s\r\n', [filename '  file had an error!']);
         fprintf(FID,'%s\r\n',ME.message);
         fclose(FID);
         errors=errors+1;
         continue;  % Jump to next iteration 
    end
     
%     write_images(GROI,path2,filename,'_GROI.jpg');
%     write_images(flatten_gray,path3,filename,'_flatten.jpg');
%     write_images(normG1,path4,filename,'_flatten_normG1.jpg');
%     write_images(normG2,path4,filename,'_flatten_normG2.jpg');

     %segmentation of 4 layers with graph search
    [finalSegmented,seg_vit_NFL,seg_IS_OS,seg_RPE_choroid,seg_OPL_ONL]=Segment4layers(cropped_I,normG1,normG2,edge1,edge2);
    write_images(green_bounderies(cropped_I,seg_vit_NFL),path5,filename,'_seg_vit_NFL.jpg');
    write_images(green_bounderies(cropped_I,seg_IS_OS),path5,filename,'_seg_IS_OS.jpg');
    write_images(green_bounderies(cropped_I,seg_RPE_choroid),path5,filename,'_seg_RPE_choroid.jpg');
    write_images(green_bounderies(cropped_I,seg_OPL_ONL),path5,filename,'_seg_OPL_ONL.jpg');

end
