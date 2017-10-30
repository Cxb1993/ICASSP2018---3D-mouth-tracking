% Description:
%   check the reprojected 3D points from face detection
% Date: 28/0
% Author:XQ

clear all
close all
clc

dbstop if error

addpath(genpath(fullfile('..', '..',  '..','Data','FBK_CHIL')));
addpath(genpath(fullfile('..', '..','src')));

load('C5.mat');
camData.dataset='FBK';
camData.Cam_pos=-camData.R'*camData.T;  % need to be removed AX
load('FBK_RoomRg');


nfft=2^15;
fv=15;
fa=96000;
dataset='FBK';
% SEQ=6:21;
SEQ=[11,13,17,20];
cam=5;
% Wo=0.13:0.01:0.25; % 3D bounding box length of face (Landmarker Detector)
Wo=0.17;
Gmax=0.05;

s = get(0, 'ScreenSize');
figure('Position', [0 0 s(3) s(4)]);


for sq=1:length(SEQ)
    disp(['========== sq-',num2str(sq),'/',num2str(length(SEQ)),'==========='])
    
    seq_name=['seq',num2str(SEQ(sq),'%02d')];
    %     seq_name=['seq17'];
    
    Results=extractGCF3Dres(seq_name,0,0.8,[2 2 2],dataset);
    [GTimg,GT3d,Afr, Vfr]=myAVsync_AV163(seq_name,cam, fv, nfft, fa,dataset);
    [~,FaceBB,vad,Vg,SSLsph,SSLcart,~,AMmax,Nmax]=myAVDatasync_AV163_2(seq_name,cam,Vfr,Afr,Results,Gmax);
    Fr=find(Vg==1);
    
    for w=1:length(Wo)
        disp(['========== w-',num2str(w),'/',num2str(length(Wo)),'==========='])
        W=Wo(w);
        [mouth3D,mouthsph,Mouthimg,mouth3DS1] = myUpBody3D(FaceBB, W, camData,dataset,1);
        
%         figure
%         
%         for f=1:length(Fr)%:length(Fr)
%             fr=Fr(f);
% %             plot3(mouth3D(1,Fr(1:f-1)),mouth3D(2,Fr(1:f-1)),mouth3D(3,Fr(1:f-1)),'r.-')
%             grid on
%             hold on
% %             plot3(mouth3DS1(1,Fr(1:f-1)),mouth3DS1(2,Fr(1:f-1)),mouth3DS1(3,Fr(1:f-1)),'b.-')
% %             plot3(GT3d(Fr(1:f-1),1),GT3d(Fr(1:f-1),2),GT3d(Fr(1:f-1),3),'k.-')
%             
%             plot3(mouth3D(1,fr),mouth3D(2,fr),mouth3D(3,fr),'r*')
%             plot3(mouth3DS1(1,fr),mouth3DS1(2,fr),mouth3DS1(3,fr),'b*')
%             plot3(GT3d(fr,1),GT3d(fr,2),GT3d(fr,3),'k*')
%             
%             plot3(camData.Cam_pos(1),camData.Cam_pos(2),camData.Cam_pos(3),'ko')
%             legend('BP-3D','BP-3D(s=1)','GT','CamPos')
%             title([seq_name,'  fr-',num2str(fr)])
%             
%             xlim(RoomRg(1,:))
%             ylim(RoomRg(2,:))
%             zlim(RoomRg(3,:))
%             xlabel('X')
%             ylabel('Y')
%             set(gca, 'CameraPosition', [41.6320   15.6356   18.2631]);
%             daspect([1 1 1])
%             
%             
%             pause(0.001)
%             clf
%             
%         end
%         disp('Key-in to continue...')
%         pause
        
        
        
        %         VFr=Vfr(1):length(AMmax)+Vfr(1)-1;
        %         % error computation
        %         AE=NaN*ones(1,length(AMmax));
        %         ErXYZ=NaN*ones(3,length(AMmax));
        %
        %
                AExyz(:,sq)=mean(abs(mouth3D(:,Vg)-GT3d(Vg,:)'),2);    
                AE(Vg)=sqrt(sum((mouth3D(:,Vg)-GT3d(Vg,:)').^2));
                MAE(w,sq)=mean(AE(Vg));
        %
    end
    
end
MAE(:,sq+1)=mean(MAE(:,1:sq),2);

f1 = fopen(['C:\QMUL_PhD\AVPF_XQAX\Results\FaceDetection_Evaluation\ReprojFBB_3Der_SF_SEQ11_20'],'w');
fprintf(f1, '%.3f %.3f %.3f %.3f %.3f %.3f \n', [Wo',MAE]');
fclose(f1);

AExyz(:,sq+1)=mean(AExyz(:,1:sq),2);

f1 = fopen(['C:\QMUL_PhD\AVPF_XQAX\Results\FaceBB_MXnet\ReprojFBB_AExyz_SEQ11_20'],'w');
fprintf(f1, '%.3f %.3f %.3f %.3f %.3f  \n',[[SEQ,0.5]', AExyz']);
fclose(f1);


% f1 = fopen(['C:\QMUL_PhD\AVPF_XQAX\Results\FaceDetection_Evaluation\ReprojFBB_3Der_SF'],'w');
% fprintf(f1, '%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f \n', [Wo',MAE]');
% fclose(f1);
