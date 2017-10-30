% Description
% display the convex polygon created on image plane
% Date 17/09/2017
% Author: XQ

clear all
close all
clc

dbstop if error


addpath(genpath(fullfile('..','..', '..',  '..','Data')));
addpath(genpath(fullfile('..', '..','..','src')));

seq_name='seq20';

% parameters
fv=15;
nfft=2^15;
fa=96000;
dataset='FBK';
cam=5;

% read camera data
load(['C5.mat']);
camData.dataset='FBK';
camData.Cam_pos=-camData.R'*camData.T;  % need to be removed AX


% create grid
step=0.05;
X_g=0:step:2.5;
Y_g=0:step:3.73;
Z_g=0:step:4;
GN=length(X_g)*length(Y_g)*length(Z_g); % # grid point
Gridcart=zeros(3,GN);
Gi=1;
for x=1:length(X_g)
    for y=1:length(Y_g)
        for z=1:length(Z_g)
            Gridcart(1,Gi)=X_g(x);
            Gridcart(2,Gi)=Y_g(y);
            Gridcart(3,Gi)=Z_g(z);
            Gi=Gi+1;
        end
    end
end
GridImg=myproject([Gridcart;ones(1,GN)], camData); % top-left corner point


[GTimg, GT3d, Afr, Vfr,Vg] = myAVsync_AV163(seq_name, 5, fv, nfft, fa,dataset);

NbMtx=[-1 -1 -1 -1 1 1 1 1; -1 -1 1 1 -1 -1 1 1; -1 1 -1 1 -1 1 -1 1];  % neiboring 8 points matrix

s = get(0, 'ScreenSize');
figure('Position', [0 0 s(3) s(4)]);
for i=84:length(Vg)
    if(Vg(i))
        gt3d=GT3d(i,:)';
        Nb8p=gt3d*ones(1,8)-step*NbMtx; % 8 neiboring points
        Nb8pImg=myproject([Nb8p;ones(1,8)], camData); % top-left corner point
        Nb8pImg(3,:)=[];
        Nbmid=mean(Nb8pImg,2);
        [~,Iisd]=sort(abs(sum((Nb8pImg-Nbmid).^2))); % grid points inside the 6-polygen
        NbImg=Nb8pImg(:,Iisd(3:end));
        
        
        th=cart2pol(NbImg(1,:)-Nbmid(1),NbImg(2,:)-Nbmid(2));
        [~,Ith]=sort(th);
        NbImg=NbImg(:,Ith);
        
        [in,on] = inpolygon(GridImg(1,:),GridImg(2,:),NbImg(1,:),NbImg(2,:));
        
        subplot(1,2,1)
        Y_k = imread(fullfile(seq_name,['cam' num2str(cam)], ...
            [ num2str(i+Vfr(1)-1,'%06d') '.jpg']));
        imshow(Y_k)
        hold on
        plot(GTimg(i,1),GTimg(i,2),'r*')
        plot(Nb8pImg(1,Iisd(1:2)),Nb8pImg(2,Iisd(1:2)),'m*')
        plot(Nb8pImg(1,Iisd(3:end)),Nb8pImg(2,Iisd(3:end)),'g*')
        title(['Fr-',num2str(i),':   Convex Polygon from GT (3D cell)'])
        
        subplot(1,2,2)
        imshow(Y_k)
        hold on
        plot(GridImg(1,in),GridImg(2,in),'m.')
        title(['Fr-',num2str(i),':   Image points inside Convex Polygon'])

        %         plot(GridImg(1,~in),GridImg(2,~in),'b+')
        
        
        pause(0.01)
        
    end
end
