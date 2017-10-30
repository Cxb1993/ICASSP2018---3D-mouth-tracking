function [H,mu,sigma,Nc]=myHist(Img,nBins,Nind,hmode,spatio,RefSize)

% Input:
%   spatio: whether compute the spatiograme
% RefSize: ref image size


if(strcmp(hmode,'hog')) % histogram of gradient
    Img=imresize(Img(:,:,:),[RefSize(1),RefSize(2)]);
    H=extractHOGFeatures(Img);  % HoG feature vector
    H=double(H);
    mu=[];
    sigma=[];
    Nc=length(H);
    return
end



Nc=nBins^3;
if(nargin<5)
    spatio=0;
end

if(strcmp(hmode,'hsv'))
    Ih = rgb2hsv(Img);
    Img=uint8(Ih*255);
end

switch spatio
    case 0  % normal histogram
        H=rgbhist(Img,nBins,Nind);
        mu=[];
        sigma=[];
    case 1 % spatio gram code download online
        Img=double(Img);
        [H,mu,sigma] = getPatchSpatiogram_fast(Img,nBins);
%     case 2  % self-developped spatiogram code : easystanza.it/account/messages/inbox
%         Img=double(Img);
%         [H,mu,sigma]=mySpatiogram(Img,nBins);
end

end
