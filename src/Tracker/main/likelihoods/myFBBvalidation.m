function [Mimg,M3d,fbb,detn,fd]=myFBBvalidation(Xest_Img,mouthImg,i,i0,detN,mouth3D,FBB,fd)
% Description:
%   valid the face detection bounding box according to our current
%   estimated target state
% Date: 12/10/2017
% Author: XQ
% Input:
% Xest_Img: estimated target on image plane 2 by Fr
% mouthImg: mouth from FBB   6 by Fr
% mouth3D:  9 by Fr
% FBB: Fr by 12
% i: current frame

Mimg=zeros(size(mouthImg,1),1);
M3d=zeros(size(mouth3D,1),1);
fbb=zeros(1,size(FBB,2));

% take the last 3 frames
if(i-i0>=3)&&(detN(i)>0)
    Xest_img=mean(Xest_Img(:,i-3:i-1),2); % avg.est on Img
    est=Xest_img*ones(1,detN(i));
else
    Mimg=mouthImg(:,i);
    M3d=mouth3D(:,i);
    fbb=FBB(i,:);
    detn=detN(i);
    fd=fd(i);
    return
end

fbb_W=FBB(i,3:4:end);
fbb_H=FBB(i,4:4:end);
fbb_S=sqrt(fbb_W.^2+ fbb_H.^2); % size
fbb_S=max(fbb_S);

mimg=mouthImg(1:2*detN(i),i);
mimg=reshape(mimg,[2 detN(i)]);
ErImg=sqrt(sum((est-mimg).^2)); % er on image plane

lambda=2.5;
Fi=find(ErImg<=lambda*fbb_S);

detn=length(Fi);

if(detn<detN(i))
    disp(['FBB-validation:  remove ',num2str(detN(i)-detn),'   FPs'])
end

for d=1:detn
    fi=Fi(d);
    Mimg(2*(d-1)+1:2*(d-1)+2)=mouthImg(2*(fi-1)+1:2*(fi-1)+2,i);
    M3d(3*(d-1)+1:3*(d-1)+3)=mouth3D(3*(fi-1)+1:3*(fi-1)+3,i);
    fbb(4*(d-1)+1:4*(d-1)+4)=FBB(i,4*(fi-1)+1:4*(fi-1)+4);
end

fd=detn>0; % det?

end