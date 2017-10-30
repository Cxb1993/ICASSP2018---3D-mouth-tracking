% Description:
% check the 3D re-projection results of the MXNet based face detector
% Date: 18/09/2017
% Author: XQ


clear all
close all
clc

dbstop if error
restoredefaultpath

addpath(genpath(fullfile('..', '..',  '..','src')));
addpath(genpath(fullfile('..', '..',  '..',  '..','Data')));

RstDir=fullfile('..', '..', '..','..','Results','FaceBB_MXnet');
addpath(genpath(RstDir));



cam=5;
fv=15;
nfft=2^15;
fa=96000;
dataset='FBK';
load('C5.mat');
camData.dataset='FBK';
camData.Cam_pos=-camData.R'*camData.T;  % need to be removed AX

sf=768/600; % resize factor of the detector

Wo=0.2:0.01:0.4; % 3D bounding box length of face (Landmarker Detector)
% Wo=0.14;
% Wo=0.09:0.01:0.12;

% SEQ=6:21;
SEQ=[11,13,17,20];
% SEQ=17;
% SEQ=13;
AExyz=zeros(3,length(SEQ));

MAE=zeros(length(Wo),length(SEQ));
for sq=1:length(SEQ)
    seq=num2str(SEQ(sq),'%02d');
    seq_name=['seq',seq];
    
    filename=['facebb_FBKseq',seq,'.txt'];
    
    Rstname=fullfile(RstDir,'FBK',filename);
    if(~exist(Rstname,'file'))
        disp(['no face detection rst:',seq_name])
        continue
    end
    
    fileID = fopen(filename);
    C = textscan(fileID,'%s %d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','CollectOutput', true);
    fclose(fileID);
    
    picName=C{1};  % picture name
    detN=C{2};  % detection number
    faceDet=C{3}; % face detection bounding box
    faceBB=faceDet;
    StrNum=zeros(size(faceBB,1),1);
    for i=1:size(faceBB,1)  % re-order the detection results
        StrNum(i)=str2double(picName{i}(end-8:end-4));
    end
    [StrNum,Istr]=sort(StrNum);
    detN=detN(Istr);
    faceBB=faceBB(Istr,:);
    faceDet=faceDet(Istr,:);
    
    faceBB(:,3)=faceDet(:,3)-faceDet(:,1);
    faceBB(:,4)=faceDet(:,4)-faceDet(:,2);
    faceBB(:,8)=faceDet(:,8)-faceDet(:,6);
    faceBB(:,9)=faceDet(:,9)-faceDet(:,7);
    faceBB(:,13)=faceDet(:,13)-faceDet(:,11);
    faceBB(:,14)=faceDet(:,14)-faceDet(:,12);
    faceBB(:,[1:4,6:9,11:14])=sf*faceBB(:,[1:4,6:9,11:14]);
    
    
    
    [GTimg,GT3d,Afr,Vfr]=myAVsync_AV163(seq_name,cam, fv, nfft, fa,dataset);
    
    
    st=find(StrNum==Vfr(1));
    ed=find(StrNum==Vfr(2));
    mouth1=[faceBB(st:ed,1)+0.5*faceBB(st:ed,3),faceBB(st:ed,2)+0.75*faceBB(st:ed,4)];
    mouth2=[faceBB(st:ed,6)+0.5*faceBB(st:ed,8),faceBB(st:ed,7)+0.75*faceBB(st:ed,9)];
    mouth3=[faceBB(st:ed,11)+0.5*faceBB(st:ed,13),faceBB(st:ed,12)+0.75*faceBB(st:ed,14)];
    erimg1=sqrt(sum((mouth1-GTimg).^2,2));
    erimg2=sqrt(sum((mouth2-GTimg).^2,2));
    erimg3=sqrt(sum((mouth3-GTimg).^2,2));
    
    [~,index]=min([erimg1,erimg2,erimg3]');
    det=5*(index-1)+1;
    
    FaceBB=zeros(length(index),4);
    for id=1:length(index)
        FaceBB(id,:)=faceBB(id+st-1,det(id):det(id)+3);
    end
    
    
    for w=1:length(Wo)
        disp(['========== w-',num2str(w),'/',num2str(length(Wo)),'==========='])
        W=Wo(w);
        [mouth3D,mouthsph,Mouthimg] = myUpBody3D(FaceBB, W, camData,dataset);
        Vg=mouth3D(1,:)>0;
        
        AE=NaN*ones(1,length(Mouthimg));
        ErXYZ=NaN*ones(3,length(Mouthimg));
        
        
%                 s = get(0, 'ScreenSize');
%                 figure('Position', [0 0 s(3) s(4)]);
%                 for ii=1:length(mouth3D)
%                     if(Vg(ii))
%                         subplot(1,2,1)
%                         %             plot3(mouth3D(1,1:ii-1),mouth3D(2,1:ii-1),mouth3D(3,1:ii-1),'r.-')
%                         plot(mouth3D(1,Vg(1:ii-1)),mouth3D(2,Vg(1:ii-1)),'r.-')
%                         disp([num2str(mouth3D(1,ii)),'   ',num2str(mouth3D(2,ii))])
%                         hold on
%                         grid on
%                         %             plot3(GT3d(1:ii-1,1),GT3d(1:ii-1,2),GT3d(1:ii-1,3),'g.-')
%                         %             plot3(mouth3D(1,1:ii),mouth3D(2,1:ii),mouth3D(3,1:ii),'r*')
%                         %             plot3(GT3d(1:ii,1),GT3d(1:ii,2),GT3d(1:ii,3),'g*')
%                         %             plot3(camData.Cam_pos(1),camData.Cam_pos(2),camData.Cam_pos(3),'k*','MarkerSize',10)
%                         plot(GT3d(1:ii,1),GT3d(1:ii,2),'g-')
%                         plot(mouth3D(1,Vg(1:ii-1)),mouth3D(2,Vg(1:ii-1)),'r-')
%         
%                         plot(GT3d(ii,1),GT3d(ii,2),'g*')
%                         plot(mouth3D(1,ii),mouth3D(2,ii),'r*')
%                         plot(camData.Cam_pos(1),camData.Cam_pos(2),'k*','MarkerSize',10)
%         
%                         xlim([0 3])
%                         ylim([0 4])
%                         %             zlim([0 2])
%                         xlabel('X (m)')
%                         ylabel('Y (m)')
%                         %             zlabel('Z (m)')
%                         daspect([1 1 1])
%                         subplot(1,2,2)
%                         Y_k=imread(['C:\QMUL_PhD\AVPF_XQAX\Data\FBK_CHIL\',seq_name,'\cam5\',num2str(ii+Vfr(1)-1,'%06d'),'.jpg']);
%                         videoOut = insertObjectAnnotation(Y_k,'rectangle',FaceBB(ii,:), 'face');
%         
%                         imshow(videoOut)
%                         hold on
%                         plot(GTimg(ii,1),GTimg(ii,2),'g+')
%                         plot(Mouthimg(1,ii),Mouthimg(2,ii),'r+')
%                         daspect([1 1 1])
%         
%                         pause(0.0001)
%                         clf
%                     end
%                 end
        
        
        
        ErXYZ(:,Vg)=mouth3D(:,Vg)-GT3d(Vg,:)';
        AExyz(:,sq)=mean(abs(mouth3D(:,Vg)-GT3d(Vg,:)'),2);
        AE(Vg)=sqrt(sum((mouth3D(:,Vg)-GT3d(Vg,:)').^2));
        MAE(w,sq)=mean(AE(Vg));
        
%         s = get(0, 'ScreenSize');
%         figure('Position', [0 0 s(3) s(4)]);
%         subplot(2,2,1)
%         plot(ErXYZ(1,Vg),'B.-')
%         grid on
%         xlabel('frames')
%         ylabel('Er_{X} (m)')
%         title('X-axis: est-GT')
%         subplot(2,2,2)
%         plot(ErXYZ(2,Vg),'B.-')
%         grid on
%         xlabel('frames')
%         ylabel('Er_{Y} (m)')
%         title('Y-axis: est-GT')
%         subplot(2,2,3)
%         plot(ErXYZ(3,Vg),'B.-')
%         grid on
%         xlabel('frames')
%         ylabel('Er_{Z} (m)')
%         title('Z-axis: est-GT')
%         subplot(2,2,4)
%         plot(AE(Vg),'r.-')
%         grid on
%         xlabel('frames')
%         ylabel('Error (m)')
%         title([seq_name,'    MAE_{3d}=',num2str(mean(AE(Vg)))])
%         suptitle(['MXNet detector:  FaceWidth=',num2str(W)])
%         saveas(gcf,['C:\QMUL_PhD\AVPF_XQAX\Results\FaceBB_MXnet\FaceBB',seq_name,'.png'])
%         
    end
end

AExyz(:,sq+1)=mean(AExyz(:,1:sq),2);
MAE(:,sq+1)=mean(MAE(:,1:sq),2);
f1 = fopen(['C:\QMUL_PhD\AVPF_XQAX\Results\FaceBB_MXnet\ReprojFBB_3Der_SF_SEQ11_20_FBK_DiagonalSize',camData.dataset],'w');
fprintf(f1, '%.3f %.3f %.3f %.3f %.3f %.3f \n', [Wo',MAE]');
fclose(f1);

f1 = fopen(['C:\QMUL_PhD\AVPF_XQAX\Results\FaceBB_MXnet\ReprojFBB_AExyz_SEQ11_20_FBK_DiagonalSize',camData.dataset],'w');
fprintf(f1, '%.3f %.3f %.3f %.3f %.3f  \n',[[SEQ,0.5]', AExyz']);
fclose(f1);

% MAE(:,sq+1)=mean(MAE(:,1:sq),2);
% f1 = fopen(['C:\QMUL_PhD\AVPF_XQAX\Results\FaceBB_MXnet\ReprojFBB_3Der_SF_2'],'w');
% fprintf(f1, '%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f \n', [Wo',MAE]');
% fclose(f1);
