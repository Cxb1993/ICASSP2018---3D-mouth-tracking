% face detection prediction & recall curve
% Date: 28/08/2017
% Author: XQ

clear all
close all
clc

dbstop if error

addpath(genpath(fullfile('..', '..',  '..','Data','FBK_CHIL')));

nfft=2^15;
fv=15;
fa=96000;
dataset='FBK';
% SEQ=6:21;
SEQ=[11,13,17,20];
cam=5;
W=0.15; % 3D bounding box length of face (Landmarker Detector)
Gmax=0.05;

% s = get(0, 'ScreenSize');
% figure('Position', [0 0 s(3) s(4)]);



er=30; % error within 10 pixels => correct detection
R=zeros(length(SEQ),1);
P=zeros(length(SEQ),1);
DR=zeros(length(SEQ),1);% detection rate

for sq=1:length(SEQ)
    TP=0;  % true positive
    FN=0; % false negative
    FP=0; % false positive
    dr=0;  % detection rate
    
    seq_name=['seq',num2str(SEQ(sq),'%02d')];
    
    [GTimg,GT3d,Afr,Vfr,FoV]=myAVsync_AV163(seq_name,cam, fv, nfft, fa,dataset);
    
    mouthDet=load([seq_name,'_cam',num2str(cam),'_detections.txt']);
    mouthImg=mouthDet(Vfr(1):Vfr(2),8:9);
    detN=mouthImg(:,2)>0;
    [DR(sq),P(sq),R(sq)]=myPRcurve_mouth(GTimg,mouthImg,detN,FoV,er);
    disp([seq_name,'  P=',num2str(P(sq)),'  R=',num2str(R(sq))])
    %     pause
    
end

PR=[SEQ',DR,P,R];
PR(length(SEQ)+1,:)=sum(PR)/length(SEQ);
PR
fName='PR_FaceDetection.dat';
disp('Saved!');
f1 = fopen(fullfile('C:\QMUL_PhD\AVPF_XQAX\Results\FaceDetection_Evaluation',fName),'w');
fprintf(f1, '%02d %.3f %.3f %.3f\n', PR');
fclose(f1);
