function [wv,Zp,fdstr,Vmap,Hr,RefImg]=myVL(X,detN,mouth3D,fd,i,Zp,vlmode,hmode,X_g,Y_g,Upstd,FBB,seq_name,Vfr,Hr,Xest,Face3DSz,camData,RefImg,FoV,flag,Xest_Img,mouthImg,fmt)
% Descrition:
% visual likelihood
% Date: 22/09/2017
% Author: XQ
% Input:
% fd: face detection
% vlmode:
%   0: det selected from GT
%   1: multi-variate Gaussian
%   2: sph coordinates
%   3: select  1 detection w.r.t. 3D estimation
%   4: select 1 detection w.r.t. image estimation
% FBB,detN,Conf: from MXNet detection results
% Xest: 3D estimated target state at previous frame
% aFoV: object inside FoV flag (from audio)
% Generated reference image
% Xest_Img: estimated mouth position projected to image plane

X=X(1:3,:);
N=size(X,2);
crd='cart';

if(flag==1)  % audio only
    fdstr=[];
    Vmap=1;
    wv=ones(1,N);
    return
end


%% Generate Reference Image
if (i>1)&&fd(i-1)&&(i<length(fd))&&~fd(i) 
    Nbins=8;
    disp('Generate Ref Image')
    Y_k = imread(fullfile(seq_name,fmt{1}, [fmt{2} num2str(i-1+Vfr(1)-1,fmt{3}) fmt{4}]));
    disp('read image')
    fbb=reshape(FBB(i-1,~isnan(FBB(i-1,:))),[4,sum(~isnan(FBB(i-1,:)))/4])'; % face bounding box for current frame
    fi=myCloestMouthImage(Xest_Img,mouthImg,i-1);
    fbb=round(max([fbb(fi,:);1 1 0 0]));
    
    RefImg=Y_k(fbb(2):fbb(2)+fbb(4),fbb(1):fbb(1)+fbb(3),:); % current detection results
    
    spatio=~isempty(hmode(4:end));
    if(spatio)
        [H,mu,sigma]=myHist(RefImg,Nbins,1,hmode(1:3),spatio,size(RefImg));
        Hr.H=H/sum(H);
        Hr.mu=mu;
        Hr.sigma=sigma;
    else
        hle=min([3,length(hmode)]);
        Hr=myHist(RefImg,Nbins,1,hmode(1:hle),spatio,size(RefImg));
    end
    disp('Finsih generating ref image')
end

%% Vide likelihood

if(fd(i)) % face detection
    switch vlmode
        case 0 % multiple detections selected by GT
            detN=1;
            fdstr='  det from GT';
        case 1 % multivariate Gaussian
            fdstr=[' ',num2str(detN),' dets'];
        case 2 % 'sph coordinates'
            crd='sph';
            fdstr=[' ',num2str(detN),' dets'];
        case 3 % only 1 detection results whose backprojection is cloest w.r.t est
            if(detN>1)
                fi=myCloestMouth3d(Xest,mouth3D,i,detN);
                mouth3D(1:3,i)=mouth3D(3*(fi-1)+1:3*fi,i);
                detN=1;
            end
            fdstr='  closest det-    3D';
        case 4
            if(detN>1)
                fi=myCloestMouthImage(Xest_Img,mouthImg,i,detN);
                mouth3D(1:3,i)=mouth3D(3*(fi-1)+1:3*fi,i);
                detN=1;
            end
            fdstr='  closest det-    Image plane';
    end
    
    % compute visual likelihood and map
    wv=zeros(1,N);
    Vmap=0;
    Zp=zeros(1,detN);
    for d=1:detN
        mouth=mouth3D(3*(d-1)+1:3*d,i);
        Zp(d)=mouth(3);
        GridZ=CreateGrid_GTZ(Zp(d),X_g,Y_g);
        wv=wv+myVideo_Gaussian(X,mouth,Upstd,crd,camData.Cam_pos);
        Vmap=Vmap+myVideo_Gaussian(GridZ,mouth,Upstd,crd,camData.Cam_pos);
    end
    Vmap=reshape(Vmap,[length(Y_g), length(X_g)]);
    
    
else

%% when no detection, use colour information
    
    if(strcmp(hmode,'0'))  % not use colour histogram
        fdstr='  no action';
        wv=ones(1,N);
        Vmap=ones(length(Y_g),length(X_g));
        return
    end
    
    if(isempty(Hr)||~FoV) % use hmode, but Obj outside FoV
        fdstr='No det & Obj out FoV';
        wv=ones(1,N);
        Vmap=ones(length(Y_g),length(X_g));
        return
    end
    
    Y_k = imread(fullfile(seq_name,fmt{1}, [fmt{2} num2str(i+Vfr(1)-1,fmt{3}) fmt{4}]));
    switch hmode
        case 'hog'
            [wv,fdstr] = visualLikelihood_HoG(Y_k, X, camData, Face3DSz, Hr,0,'hog',size(RefImg));  % face
        case 'hsv'  %Bh distance
            [wv,fdstr] = visualLikelihood_BD(Y_k, X, camData, Face3DSz, Hr,0,'hsv');  % face
        case 'rgb' % spatiogram
            [wv,fdstr] = visualLikelihood_BD(Y_k, X, camData, Face3DSz, Hr,0,'rgb');  % face
        case 'hsvspatio'
            [wv,fdstr] = visualLikelihood_Spatio(Y_k, X, camData, Face3DSz,Hr,0,'hsv');
        case 'rgbspatio'
            [wv,fdstr] = visualLikelihood_Spatio(Y_k, X, camData, Face3DSz,Hr,0,'rgb');
    end
    Vmap=[];
end

if(sum(wv)==0)
   wv=1/N*ones(1,N); 
end


end

%% Other functions
function [fi,Er3d]=myCloestMouth3d(Xest,mouth3D,i,detN)

if(i>5)
Xest=mean(Xest(:,i-5:i-1),2); % avg.est on Img
else
    fi=1;
    Er3d=NaN;
   return 
end

est=Xest*ones(1,detN);
m3d=reshape(mouth3D(1:3*detN,i),[3,detN]);
Er3d=sqrt(sum((est-m3d).^2));
[~,fi]=min(Er3d);
end

function [fi,ErImg]=myCloestMouthImage(Xest_Img,mouthImg,i)
% 12/10/2017
% if there are mutliple detection exists, choose the one cloeset to the
% previous estimation

detN=sum(mouthImg(:,i)>0)/2;
% take the last 5 frames
if(i>5)
Xest_img=mean(Xest_Img(:,i-5:i-1),2); % avg.est on Img
est=Xest_img*ones(1,detN);
else
    fi=1;
    ErImg=NaN;
   return 
end

Mimg=mouthImg(1:2*detN,i);  % mouth (from 3D projection) on image plane
Mimg=reshape(Mimg,[2 detN]);
   
ErImg=sqrt(sum((est-Mimg).^2));
[~,fi]=min(ErImg);
end





%% Colour histogram %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% wv = visualLikelihood_BD(Y_k, Xcart, C, Face3DSz, lambda, RefImg_hist)
%
%
% Parameters:
%   - Y_k: image at frame k.
%   - Xcart: particle states in cartesian coordinates.
%   - C:
%   - Face3DSz: size of the 3D face rectangle.
%   - lambda:
%   - Hr: RGB color histogram of the reference image.
%
% Author: Alessio Xompero
%   Date: 2017/07/13
% modified by XQ
% Date: 27/09/2017
function [wv,fdstr] = visualLikelihood_BD(Y_k, Xcart, C, Face3DSz, Hr,bodypart,cspace)
disp(' - Search-based visual likelihood..');

d0 = 0.9;
lambda=70;

if(nargin<6)
    bodypart=0;
end

N = size(Xcart,2); % Number of particles
Nbins = 8; % Number of bins for the color histogram

Fw = Face3DSz(1);
Fh = Face3DSz(2);

Ih = size(Y_k,1); % Image width
Iw = size(Y_k,2); % Image height

% Initialise all Bhattacharyya distances as out of field of fiew (oFoV)
Bh = d0 * ones(1,N);

% For each particle state create a 3D face rectangle and project it onto the
% image
[bboxes, idx] = myVirtualBoxCreation(Xcart, C, Fw, Fh, Iw, Ih, bodypart);

if sum(idx) == 0
    disp('All particles outside FoV!')
end

% Compute Color Histograms and the square of the Bhattacharrya distance for
% all bounding boxes within the FoV
for i=1:N
    if idx(i) == 0
        continue
    end
    
    x1 = bboxes(2,i);
    x2 = bboxes(2,i) + bboxes(4, i);
    
    y1 = bboxes(1,i);
    y2 = bboxes(1,i) + bboxes(3, i);
    
    if prod([x1,y1,x2,y2] ~= 0)==0
        disp('Zero size!!!')
        continue
    end
    
    im_patch = Y_k(x1:x2,y1:y2,:);
    Ht =myHist(im_patch,Nbins,1,cspace,0);
    Bh(i) = 1 - sum(sqrt(Ht .* Hr),2);   % square of the Bhattacharyya distance
end

% Compute visual likelihood based on the Bhattacharyya distance
wv = exp(- lambda * Bh) - exp(- lambda);

disp([cspace,' color histogram! '])
fdstr='  No det BUT hist! ';
end

%% spatiogram video likelihood
function [wv,fdstr] = visualLikelihood_Spatio(Y_k, Xcart, C, Face3DSz,Hr,bodypart,cspace)
disp(' - Search-based visual likelihood..');

if(nargin<6)
    bodypart=0;
end

N = size(Xcart,2); % Number of particles

% Number of bins for the color histogram
Nbins = 8;

%
Fw = Face3DSz(1);
Fh = Face3DSz(2);

%
Ih = size(Y_k,1); % Image width
Iw = size(Y_k,2); % Image height

% For each particle state create a 3D face rectangle and project it onto the
% image
[bboxes, idx] = myVirtualBoxCreation(Xcart, C, Fw, Fh, Iw, Ih, bodypart);

if sum(idx) == 0
    disp('All particles outside FoV!')
end

% Compute RGB Color Histograms and the square of the Bhattacharrya distance for
% all bounding boxes within the FoV
wv=zeros(1,N);
for i=1:N
    if idx(i) == 0
        continue
    end
    
    x1 = bboxes(2,i);
    x2 = bboxes(2,i) + bboxes(4, i);
    
    y1 = bboxes(1,i);
    y2 = bboxes(1,i) + bboxes(3, i);
    
    if prod([x1,y1,x2,y2] ~= 0)==0
        disp('Zero size!!!')
        continue
    end
    
    im_patch = Y_k(x1:x2,y1:y2,:);
    [HtF,muF,sigmaF]=myHist(im_patch,Nbins,1,cspace,1);
    wv(i)= compareSpatiograms_new_fast(HtF,muF,sigmaF,Hr.H,Hr.mu,Hr.sigma);
    clear HtF muF sigmaF
end

disp([cspace,' spatiogram! '])
fdstr='  No det BUT spatiogram! ';

end




%% Colour histogram %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% wv = visualLikelihood_BD(Y_k, Xcart, C, Face3DSz, lambda, RefImg_hist)
%
%
% Parameters:
%   - Y_k: image at frame k.
%   - Xcart: particle states in cartesian coordinates.
%   - C:
%   - Face3DSz: size of the 3D face rectangle.
%   - lambda:
%   - Hr: RGB color histogram of the reference image.
%
% Author: Alessio Xompero
%   Date: 2017/07/13
% modified by XQ
% Date: 27/09/2017
function [wv,fdstr] = visualLikelihood_HoG(Y_k, Xcart, C, Face3DSz, Hr,bodypart,cspace,RefSize)
disp(' - Search-based visual likelihood..');

d0 = 0.9;
lambda=70;

if(nargin<6)
    bodypart=0;
end

N = size(Xcart,2); % Number of particles
Nbins = 8; % Number of bins for the color histogram

Fw = Face3DSz(1);
Fh = Face3DSz(2);

Ih = size(Y_k,1); % Image width
Iw = size(Y_k,2); % Image height

% Initialise all Bhattacharyya distances as out of field of fiew (oFoV)
Bh = d0 * ones(1,N);

% For each particle state create a 3D face rectangle and project it onto the
% image
[bboxes, idx] = myVirtualBoxCreation(Xcart, C, Fw, Fh, Iw, Ih, bodypart);

if sum(idx) == 0
    disp('All particles outside FoV!')
end

% Compute Color Histograms and the square of the Bhattacharrya distance for
% all bounding boxes within the FoV
wv=zeros(1,N);
for i=1:N
    if idx(i) == 0
        continue
    end
    
    x1 = bboxes(2,i);
    x2 = bboxes(2,i) + bboxes(4, i);
    
    y1 = bboxes(1,i);
    y2 = bboxes(1,i) + bboxes(3, i);
    
    if prod([x1,y1,x2,y2] ~= 0)==0
        disp('Zero size!!!')
        continue
    end
    
    im_patch = Y_k(x1:x2,y1:y2,:);
    Ht =myHist(im_patch,Nbins,1,cspace,0,RefSize);
    er=sqrt(sum((Ht-Hr).^2,2));
    wv(i) = exp(-er);   % square of the Bhattacharyya distance
end

% Compute visual likelihood based on the Bhattacharyya distance

disp([cspace,' color histogram! '])
fdstr='  No det BUT hist! ';
end


