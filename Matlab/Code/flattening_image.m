
function [imOut,flatten_ROI,gap,angle,tf_Rot,tf_flt]=flattening_image(I0,ROI,UP,frame)
%ROI=a binary mask of estimated retina's region, I0=original gray image,
%UP=upper boundary indexes (raws coardinatons),frame= the index(order number) of image in the OCT scan
%Output: flatten retina image- grey image and binary flatten ROI , also ABS_C=absolute curvature of the retina
% ref=the refference row , gap=vector contains the original gap from ref for each colomn

%defaultive values
linear=0;angle=0;tf_Rot=0;tf_flt=0;gap=[];
imOut=I0;flatten_ROI=ROI;

I=ROI;
[m,n]=size(I);
Vitreous=zeros(1,n);
MaskVit=UP;

for j=1:n
        Vitreous(j) = find(UP(:,j), 1, 'first' );
end

old=I0;
oldVit=Vitreous;
oldMaskVit=MaskVit;
oldROI=I;
%% rotate image if necassary
    % Get properties.
    prop = regionprops(oldROI, {'Orientation'});
    angle=prop.Orientation;
    if abs(angle)>3
        I0= imrotate(old,(-1*angle),'bilinear','crop');%'bicubic'/'nearest'/'bilinear'
        I=imrotate(oldROI,(-1*angle),'bilinear','crop');
        %figure(51);imshowpair(old,I0,'montage');title('Left:original image, right:Rotated image');
        %figure(52);imshowpair(oldROI,I,'montage');
        %new Vitreouse segmentation
        MaskVit=zeros(m,n);
        Vitreous=[];
        I=I>0;
        empty=[];
        
        for j=1:n
          if sum(I(:,j))==0 
              Vitreous(j)=1;%random row just for making the vector length valid (n)
              empty=[empty,j];
              continue
          end
          Vitreous(j)=find(I(:,j),1,'first');
          MaskVit(Vitreous(j),j)=1;
        end
        
         % The rotation can eliminate some colomns from margins, 
          %so we replicate the nearest colomn for continuose boundary
         if length(empty)>0
            vec=MaskVit(:,length(empty)+1);
            MaskVit(:,1:length(empty))= repmat(vec,1,length(empty));
         end
         
        % fix margins artifacts
        dis1=diff(Vitreous(1:10));jump1=find(abs(dis1)>1);
        while ~isempty(jump1)
            lastjump=find(abs(dis1)>1,1,'last');
            Vitreous(lastjump)=Vitreous(lastjump+1);
            temp=zeros(1,m);temp(Vitreous(lastjump))=1;
            MaskVit(:,lastjump)=temp;
            dis1=diff(Vitreous(1:10));jump1=find(abs(dis1)>1);
        end
        dis2=diff(Vitreous(end-10:end));jump2=find(abs(dis2)>1);
         while ~isempty(jump2)
            firstjump=find(abs(dis2)>1,1,'first');
            Vitreous(n-(10-firstjump))=Vitreous(n-(10-firstjump+1));
            temp=zeros(1,m);temp(Vitreous(n-(10-firstjump)))=1;
            MaskVit(:,n-(10-firstjump))=temp;
            dis2=diff(Vitreous(end-10:end));jump2=find(abs(dis2)>1);
         end 
         
        %figure(53);imshowpair(oldMaskVit,MaskVit,'montage');
        tf_Rot=1;
    end
   imOut=I0;flatten_ROI=I;

%% Upper boundary curve fitting
    col=1:n;
    cut=80;%% if downsampling should be less than 80, othrwise 100
    [p,S] = polyfit(col',Vitreous',2);
    if abs(p(1))<0.0004 % 0.0009
         linear=1;
         MAX=0;MIN=0;
    else
            x=col;
            y=Vitreous;
            f=p(1)*x.^2+p(2)*x+p(3); 
            error=f-Vitreous;
            AvgError=mean(abs(error));
            if AvgError>7 && frame>9 && frame <17 && linear==0
               x=cut:n-cut;
               y=Vitreous(cut:n-cut);
              [p,S] = polyfit(x',y',2);  
              %f=p(1)*x.^10+p(2)*x.^9+p(3)*x.^8+p(4)*x.^7+p(5)*x.^6+p(6)*x.^5+p(7)*x.^4+p(8)*x.^3+p(9)*x.^2+p(10)*x+p(11);
              f=p(1)*x.^2+p(2)*x+p(3); 
              error=f-Vitreous(cut:n-cut);
              deriv=diff(f);
              deriv2=diff(f,2); 
              [val ind]=min(abs(deriv));
               MAX=0;MIN=0;
              if ind~=1 && (deriv(ind-1)*deriv(ind+1))<0%there is a local minimamaxima point in the upper curve
                 MAX=deriv(ind+1)>0;%Because oposit y axis in image, a local maximum is defined by f'(x)=0 and f''(x)>0
                 MIN=deriv(ind+1)<0;
              end    
              ind=ind+cut;
            else
              deriv=diff(f);
              deriv2=diff(deriv); 
              [val ind]=min(abs(deriv));
              AvgError=mean(abs(error));
               MAX=0;MIN=0;
              if ind~=1 &&(deriv(ind-1)*deriv(ind+1))<0%there is a local minimamaxima point in the upper curve
                 MAX=deriv(ind+1)>0;%Because oposit y axis in image, a local maximum is defined by f'(x)=0 and f''(x)>0
                 MIN=deriv(ind+1)<0;
              end    
            end

        %figure(50);
       % plot(col,Vitreous);hold on;plot(x,f);%imshowpair(MaskVit,I0,'montage');title(['2nd order polinom=' num2str(p(1)) 'x^2+'  num2str(p(2)) 'x+' num2str(p(3)) ]);
        %title(['mean error='  AvgError]);
    end


%% curve analysis
 
if (frame<10 || frame>17 || (MAX==0 && MIN==0) )&& linear==0
    % deviding the curve into 2 : 
      cut_col=round((n+1)/2);
      col=1:cut_col;
     [p1,S1] = polyfit(col',Vitreous(1:cut_col)',2); 
      col=cut_col+1:n;
     [p2,S2] = polyfit(col',Vitreous(cut_col+1:end)',2);
     if abs(p1(1))<0.0002 && abs(p1(2))<0.1
         ref=Vitreous(round((n+1)/4));
     elseif abs(p2(1))<0.0002 && abs(p2(2))<0.1
         ref=Vitreous(round((n+1)*0.75));
     else
         %devide the curve into 3 regions:
         cut_col1=round((n+1)/3);cut_col2=cut_col1*2;
         col=1:cut_col1;
         [p1,S1] = polyfit(col',Vitreous(1:cut_col1)',2); 
         col=cut_col1+1:cut_col2;
         [p2,S2] = polyfit(col',Vitreous(cut_col1+1:cut_col2)',2);
         col=cut_col2+1:n;
         [p3,S3] = polyfit(col',Vitreous(cut_col2+1:end)',2);
          if abs(p1(1))<0.0002 && abs(p1(2))<0.1
             ref=Vitreous(round((n+1)/6));
          elseif abs(p2(1))<0.0002 && abs(p2(2))<0.1
             ref=Vitreous(round((n+1)/2));
          elseif abs(p3(1))<0.0002 && abs(p3(2))<0.1
             ref=Vitreous(round((n+1)*5/6));
          else
              %find linear fit:
              col=1:cut_col1;
              [p1,S1] = polyfit(col',Vitreous(1:cut_col1)',1); 
              col=cut_col1+1:cut_col2;
              [p2,S2] = polyfit(col',Vitreous(cut_col1+1:cut_col2)',1);
              col=cut_col2+1:n;
              [p3,S3] = polyfit(col',Vitreous(cut_col2+1:end)',1);
              [minM,region]=min([abs(p1(1)),abs(p2(1)),abs(p3(1))]);
             switch region
                 case 1
                   ref=Vitreous(round((n+1)/6));
                 case 2
                   ref=Vitreous(round((n+1)/2));
                 case 3
                   ref=Vitreous(round((n+1)*5/6));
             end
          end
     end 


%% flattening the Rethina
   
  %if linear==1 || frame<10 ||frame>17 || (MAX==0 && MIN==0)
      flatten=zeros(m,n);
      for col=1:n
        gap(col)=ref-Vitreous(col);
        if gap(col)>0
          temp1=zeros(gap(col),1);
          temp2=imOut(1:end-gap(col),col);
          temp3=flatten_ROI(1:end-gap(col),col);
          flatten(:,col)=[temp1;temp2];
          flatten_ROI(:,col)=[temp1;temp3];
        elseif gap(col)<0
          temp1=zeros(abs(gap(col)),1);
          temp2=imOut(abs(gap(col))+1:end,col);
          temp3=flatten_ROI(abs(gap(col))+1:end,col);
          flatten(:,col)=[temp2;temp1];
          flatten_ROI(:,col)=[temp3;temp1];
        else
            flatten(:,col)=imOut(:,col);
        end
     end
       
    %figure(54);imshowpair(old,flatten,'montage');
    %figure(55);imshowpair(oldROI,flatten_ROI,'montage');
    tf_flt=1;
    imOut=flatten;
 end
end
    