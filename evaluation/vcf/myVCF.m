function myVCF(faceFlag,hmode,Fid,spatio)
% Description:
%   compute the VCF
% Date: 12/09/2017
% Author: XQ
% create Cartesian grid and then project back on image plane
%  Input:
% hmode: hsv or rgb
% Fid: figure ID
% spatio: wether using spatiogram


addpath(genpath(fullfile('..', '..',  '..','Data')));
addpath(genpath(fullfile('..', '..','src')));
addpath(genpath(fullfile('ConvexPolygon')));
addpath(genpath(fullfile('..', '..','evaluation','VisualFeatures','spatiogram')));


SavDir=fullfile('..','..','..','Results','FBK_CHIL','VCF');

if(~exist(SavDir,'dir'))
    mkdir(SavDir)
end

cam=5;
Face3DSz=[0.17 0.17];
Fw = Face3DSz(1);
Fh = Face3DSz(2);
Nbins=8;
load('RefAX')
gt3d=Ref.gt3d';

switch Fid
    case 0 % use refernece image
        Img=imread(Ref.Img); % ref img for VCF generation
    case 1
        Img=imread('seq17_fr198.jpg');
    case 2
        Img=imread('seq17_fr223.jpg');
    case 3
        Img=imread('seq17_fr391.jpg');
    case 4
        Img=imread('seq17_fr455.jpg');
    case 5
        Img=imread('seq17_fr530.jpg');
    case 6
        Img=imread('seq17_fr697.jpg');
end
Ih = size(Img,1); % Image height
Iw = size(Img,2); % Image width

% load camera data
load(['C' num2str(cam) '.mat']);
camData.dataset='FBK';
camData.Cam_pos=-camData.R'*camData.T;  % need to be removed AX
camPos=camData.Cam_pos;

step=0.1;
% X_g=0:step:2.5;
% Y_g=0:step:3.73;
% Z_g=0:step:4;

X_g=camPos(1)-max(camPos):step:camPos(1);
Y_g=camPos(2)-max(camPos):step:camPos(2);
Z_g=0:step:4;


% create grid for VCF
disp('create grid for VCF')
Gridcart=zeros(3,length(X_g)*length(Y_g)*length(Z_g));

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

GridSph=myParticle_cart2sph(Gridcart,camPos);
Rvalid=(GridSph(3,:)>0.3)&(GridSph(3,:)<max(camPos));
Gridcart=Gridcart(:,Rvalid);
GN=size(Gridcart,2); % # grid point

% figure
% plot3(Gridcart(1,:),Gridcart(2,:),Gridcart(3,:),'r.')
% hold on
% plot3(camPos(1),camPos(2),camPos(3),'k*')
% xlabel('X')
% ylabel('Y')
% daspect([1 1 1])

% create visual box Face
disp('create visual box Face ')

if(faceFlag)  % reference image
    [Fbb,Vg]=myVirtualBoxCreation(Gridcart, camData, Fw, Fh, Iw, Ih, 0); % face
    Refimg=imread(Ref.ImgRefF);
    RefSize=round(size(Refimg)/3);
    [Hr,mur,sigmar,Nc] = myHist(Refimg,Nbins,1,hmode,spatio,RefSize);
    Hstr='Face';
else
    [Fbb,Vg]= myVirtualBoxCreation(Gridcart, camData, Fw, Fh, Iw, Ih, 1); % torso
    Refimg=imread(Ref.ImgRefT);
    RefSize=round(size(Refimg)/3);
    [Hr,mur,sigmar,Nc] =myHist(Refimg,Nbins,1,hmode,spatio,RefSize);
    Hstr='Torso';
end

% figure
% imshow(Ref)
% title('reference image')


% create VCF
disp('create VCF')
if(strcmp(hmode,'edist'))
    
    Imgrgb=imread(Ref.Img);
    Img=rgb2gray(Imgrgb);
    Sob = edge(Img,'sobel');
    Sobdt=bwdist(Sob,'quasi-euclidean');
    
    figure
    subplot(2,2,1)
    imshow(Imgrgb)
    title('RGB image')
    subplot(2,2,2)
    imshow(Img)
    title('Greyscale image')
    subplot(2,2,3)
    imshow(Sob)
    title('Sobel edge detector')
    subplot(2,2,4)
    imshow(Sobdt)
    title('Distance Transform')
    
    Bh=zeros(GN,1)*NaN;
    for i=1:GN  % for each 3D grid point
        if(Vg(i))  % bbox valid
            disp(['edistcomputing:   ',num2str(i),'/',num2str(GN)])
            reg=Sobdt(Fbb(2,i):Fbb(2,i)+Fbb(4,i),Fbb(1,i):Fbb(1,i)+Fbb(3,i),:);
            Bh(i)=sum(reg(:));
        end
    end
    
    
else
    
    HtF=NaN*ones(GN,Nc); % histogram matrix for 3D grids of VCF
    if(spatio)
        disp('create muF/sigmaF')
        muF=cell(GN,1); % histogram matrix for 3D grids of VCF
        sigmaF=cell(GN,1); % histogram matrix for 3D grids of VCF
    end
    
    for i=1:GN  % for each 3D grid point
        if(Vg(i))  % bbox valid
            disp(['Histogram computing:   ',num2str(i),'/',num2str(GN)])
            Face=Img(Fbb(2,i):Fbb(2,i)+Fbb(4,i),Fbb(1,i):Fbb(1,i)+Fbb(3,i),:);
            if(spatio)
                [HtF(i,1:Nc),muF{i},sigmaF{i}]=myHist(Face,Nbins,1,hmode,spatio,[]);
            else
                HtF(i,1:Nc)=myHist(Face,Nbins,1,hmode,spatio,RefSize);
            end
        end
    end
    
    
    Bh=zeros(GN,1);  % compute score
    if(strcmp(hmode,'hog'))
        Bh=sqrt(sum((HtF-ones(GN,1)*Hr).^2,2));  % Euclidean distance
    else
        switch spatio
            case 0
                Bh=sqrt( 1 - sum(sqrt(HtF * Hr'),2));
            case 1
                for i=1:GN
                    if(Vg(i))
                        Bh(i) = compareSpatiograms_new_fast(HtF(i,1:Nc),muF{i},sigmaF{i},Hr,mur,sigmar);
                        disp(['spatiogram computing: Bh(',num2str(i),'/',num2str(GN),')=',num2str(Bh(i))])
                    end
                end
        end
        
    end
    
    
end

% Conf=(1-Bh)/max(1-Bh);  % visual confidence

% create VCFimg
VCFindex=zeros(2,Ih*Iw);
disp('create VCFimg')
index=1;
for h=1:Ih
    for w=1:Iw
        VCFindex(1,index)=w;
        VCFindex(2,index)=h;
        index=index+1;
    end
end

disp('Finish creating VCFimg')
VCFimg_max=NaN*zeros(Ih,Iw);
VCFimg_min=NaN*zeros(Ih,Iw);
VCFimg_mean=zeros(Ih,Iw);
VCFimg_meanN=zeros(Ih,Iw); % cumulative number of VCFimg_mean

disp('associate VCF')
for g=1:GN  % for each 3D grid point
    %                 Vout = insertObjectAnnotation(Img,'rectangle',Fbb(:,i)', 'face');
    if(~isnan(Bh(g)))
        CPimg=myConvexPolygon(Gridcart(:,g),step,VCFindex,camData);
        
        for vcf=1:size(CPimg,2)
            x=CPimg(1,vcf); % image width index
            y=CPimg(2,vcf); % image column index
            disp(['3D Grid Points-',num2str(g),'/',num2str(GN),'     (',num2str(vcf),'/',num2str(size(CPimg,2)),')','   Bh=',num2str(Bh(g)),'  x=',num2str(x),'   y=',num2str(y)])
            
            VCFimg_max(y,x)=max(VCFimg_max(y,x),Bh(g));
            VCFimg_min(y,x)=min(VCFimg_min(y,x),Bh(g));
            VCFimg_mean(y,x)=VCFimg_mean(y,x)+Bh(g);
            VCFimg_meanN(y,x)=VCFimg_meanN(y,x)+1;
        end
    end
    
end


VCFimg_mean=VCFimg_mean./VCFimg_meanN;

disp('Finish computing')





% % vitualisation - image plane
% GridImg=myproject([Gridcart;ones(1,GN)], camData); % top-left corner point
% GridImg(3,:)=[];
% GridImg=round(GridImg);
%
% VCFimg=zeros(Ih,Iw);
% index=1;
% for c=1:Iw % width
%     for r=1:Ih  % height
%         Gi=(GridImg(1,:)==c)&(GridImg(2,:)==r);
%         if(sum(Gi)>0)
%             VCFimg(r,c)=max(Conf(Gi));
%         end
%         disp([num2str(index),'\',num2str(Iw*Ih)])
%         index=index+1;
%     end
% end
%
% figure
% subplot(2,1,1)
% imshow(Img)
% daspect([1 1 1])
% title('Ref Img')
%
% subplot(2,2,3)
% imagesc(VCFimg_min)
% colorbar
% xlabel('pixels')
% ylabel('pixels')
% daspect([1 1 1])
% title('VCF min(Bh))')
%
% subplot(2,2,4)
% imagesc(VCFimg_mean)
% colorbar
% xlabel('pixels')
% ylabel('pixels')
% daspect([1 1 1])
% title('VCF mean(Bh))')
%
disp('Start saving')
% saveas(gcf,fullfile(SavDir,['VCF_minBh_',Hstr,hmode,'Fid',num2str(Fid),'.png']))
% saveas(gcf,fullfile(SavDir,['VCF_minBh_',Hstr,hmode,'Fid',num2str(Fid)]))
save(fullfile(SavDir,['VCF_Bh_',Hstr,hmode,'Fid',num2str(Fid),'_spat',num2str(spatio)]),'VCFimg_mean','VCFimg_max','VCFimg_min','VCFimg_meanN','step','Gridcart','Bh','Face3DSz')
disp('Finish saving')

%
% % vitualisation - XY at GT height
% [~,zindex]=min(abs(Z_g-gt3d(3)));
% VCFxy=reshape(Conf(Gridcart(3,:)==Z_g(zindex)),[length(Y_g) length(X_g)]);
% imagesc(X_g,Y_g,VCFxy)
% colorbar
% xlabel('X (m)')
% ylabel('Y (m)')
% hold on
% plot(camData.Cam_pos(1),camData.Cam_pos(2),'ko','LineWidth',4,'MarkerSize',5)
% plot(gt3d(1),gt3d(2),'ro','LineWidth',2,'MarkerSize',3)
% daspect([1 1 1])
% title('Vconf: GTz plane')
% saveas(gcf,fullfile(SavDir,['VCFGTz_',Hstr,'.png']))
% saveas(gcf,fullfile(SavDir,['VCFGTz_',Hstr]))
% save(fullfile(SavDir,['VCFGTz_',Hstr]),'VCFxy','Y_g','X_g')

disp('Finished')


end