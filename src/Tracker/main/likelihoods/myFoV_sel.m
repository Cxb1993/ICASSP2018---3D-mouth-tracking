function FoV=myFoV_sel(Xest,i,Mic_c,Xest_Img,ImgSize,camData)
% Description:
%   define whether the target is inside FoV using the audio information
% Date: 28/09/2017
%  Input:
%   SSLc: sound source localisation
%   i: current time index
% Xest: estimated target states from 1:i

% FoV=false;
% if(i>4)
% Xmean=mean(Xest(:,i-4:i),2);
% Estsph=myParticle_cart2sph(Xmean,Mic_c);
% EstTh=Estsph(1);
% FoV=(EstTh<-95)&&(EstTh>-175); % estimated target inside FoV
% end

pct=0.1;
% image height range
Ih(1)=ImgSize(1)*pct/2; 
Ih(2)=ImgSize(1)-ImgSize(1)*pct/2; 

% image width range
Iw(1)=ImgSize(2)*pct/2;  
Iw(2)=ImgSize(2)-ImgSize(2)*pct/2;  % image height range

FoV=false;
if(i>2)
XImgmean=mean(Xest_Img(:,i-2:i),2);
X3Dmean= mean(Xest(:,i-2:i),2);                           

if ~isInFrustum(X3Dmean, camData, 0.5, ImgSize(2), ImgSize(1)) 
   return  % if est not in front of camera
end

FoV=(XImgmean(1)>=Iw(1))&&(XImgmean(1)<=Iw(2))&&(XImgmean(2)>=Ih(1))&&(XImgmean(2)<=Ih(2)); % estimated target inside FoV

end



end