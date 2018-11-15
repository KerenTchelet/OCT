function save_frames(path1,path2,disorder)
 % function get path1:folder with videos,path2: target folder to save there the cut frames,
 %disorder:classification label (doctor's).
% example: path1='C:\Users\keren\Desktop\final_proj - new\firstOCTmovieFiles\AMD';
% path2='C:\Users\keren\Desktop\final_proj - new\Code\ExtractedScans';
% disorder=3;

l=Files_List(path1,'avi');
 for ind=1:length(l)
   vid=VideoReader(l{ind});
   n= vid.NumberOfFrames;
   for iFrame=1:n
    frame = rgb2gray(read(vid, iFrame));
       %cut left side
       diff=frame(:,2:end)-frame(:,1:end-1);%first vertical deriviation 
       s=sum(diff);
       m=max(s);
       cut_col=find(s==m);%assuming the cut is where the 2 images conected
       frame=frame(:,cut_col:end);
       % cut the scale from the bottom corner
       %assume that the scale is the same size in all OCT images
       frame=frame(1:end-70,:);
    imwrite(frame, fullfile(path2, ['I', num2str(ind),'_scan',num2str(iFrame),'_',num2str(disorder), '.jpg']));
   end
 end
end