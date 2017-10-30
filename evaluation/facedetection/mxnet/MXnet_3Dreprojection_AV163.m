% Description:
%   check the reprojected 3D points from face detection
% Date: 28/0
% Author:XQ

clear all
close all
clc

dbstop if error

addpath(genpath(fullfile('..', '..',  '..','..','Data','AV163')));
addpath(genpath(fullfile('..', '..', '..','src')));


dataset='AV16.3';
cam=1;

SEQ=[8,11,12];
Wo=0.2:0.01:0.4; % 3D bounding box length of face (Landmarker Detector)



for sq=1:length(SEQ)
    
    seq=SEQ(sq);
    
    disp(['========== sq-',num2str(sq),'/',num2str(length(SEQ)),'==========='])
    [camData,seq_name,fmt,RoomRg,T,Face3DSz,ma,cam,fv,nfft,fa,AMvad,Upstd,gammaG,Q,c,Mic_pos,Mic_c,ImgSize]=readParas(seq,dataset,cam);
    [GTimg,GT3d,Afr, Vfr]=myAVsync_AV163(seq_name,cam, fv, nfft, fa,dataset);

    for w=1:length(Wo)
        disp(['========== w-',num2str(w),'/',num2str(length(Wo)),'==========='])
        W=Wo(w);
        
        [FBB,detN,~,mouthImg,mouth3D]=readMXNetData(SEQ(sq),Vfr,camData,W,cam);
        %         [mouth3D,mouthsph,Mouthimg] = myUpBody3D(FaceBB, W, camData,dataset);
        Vg=logical(detN);
        
        VFr=Vfr(1):length(GT3d)+Vfr(1)-1;
        % error computation
        AE=NaN*ones(1,length(GT3d));
        ErXYZ=NaN*ones(3,length(GT3d));
        
        
        ErXYZ(:,Vg)=mouth3D(:,Vg)-GT3d(Vg,:)';
        AE(Vg)=sqrt(sum((mouth3D(:,Vg)-GT3d(Vg,:)').^2));
        MAE(w,sq)=mean(AE(Vg));
    
    end
    
end
MAE(:,sq+1)=mean(MAE(:,1:sq),2);


f1 = fopen(['C:\QMUL_PhD\AVPF_XQAX\Results\FaceBB_MXnet\ReprojFBB_3Der_SF_Face_DiagonalSize',camData.dataset],'w');
% fprintf(f1, '%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f \n', [Wo',MAE]');
fprintf(f1, '%.3f %.3f %.3f %.3f %.3f \n', [Wo',MAE]');

fclose(f1);
