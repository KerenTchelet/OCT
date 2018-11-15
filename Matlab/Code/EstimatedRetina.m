function [UpMask,BotMask,initial_ROI]=EstimatedRetina(I)
% Estimation of the ROI, preparing for flattening and the graph search. The
% function gets gray image and returns initial ROI=region of interest,Upper
% boundary mask and bottom boundary mask
[m,n]=size(I);

%searching for upper boundary of the retina
[UpMask UpVec]=Boundary_Mask(I,1,12);

%searching for bottom boundary of the retina
[BotMask BotVec]=Boundary_Mask(I,2,8);

% Merging 2 borders for one new ROI- the retina region estimation
initial_ROI=UpMask+BotMask;
initial_ROI(UpVec(1):BotVec(1),1)=1;
initial_ROI(UpVec(n):BotVec(n),n)=1;

% Fixation of boundary discontinuities
 
    for c1 = 2:length(BotVec)
        gap = BotVec(c1)-BotVec(c1-1);
        if gap <(-1)
             initial_ROI((BotVec(c1):BotVec(c1)-gap),c1)=1;
        end
        if gap>1
             initial_ROI((BotVec(c1-1):BotVec(c1-1)+gap),c1)=1;
        end
    end   
    for c2 = 2:length(UpVec)
        gap = UpVec(c2)-UpVec(c2-1);
        if gap <(-1)
              initial_ROI((UpVec(c2):UpVec(c2)-gap),c2)=1;
        end
        if gap>1
              initial_ROI((UpVec(c2-1):UpVec(c2-1)+gap),c2)=1;
        end
    end

end