% face detection prediction & recall curve
% Date: 18/09/2017
% Author: XQ

clear all
close all
clc

dbstop if error
restoredefaultpath

dataset='FBK';

addpath ..
addpath(genpath(fullfile('..', '..',  '..','src')));
addpath(genpath(fullfile('..', '..',  '..',  '..','Data')));

RstDir=fullfile('..', '..', '..','..','Results','FaceBB_MXnet',dataset);

addpath(genpath(RstDir));

cam=5;
fv=15;
nfft=2^15;
fa=96000;


load('C5.mat');
camData.dataset='FBK';
camData.Cam_pos=-camData.R'*camData.T;  % need to be removed AX

sf=768/600; % resize factor of the detector
er=30; % error within 10 pixels => correct detection


% SEQ=6:21;
SEQ=[11,13,17,20];

R=zeros(length(SEQ),1); % recall
P=zeros(length(SEQ),1); % precision
DR=zeros(length(SEQ),1);% frame with detection /#Frames
DR2=zeros(length(SEQ),1);% TP/#Frames
Nseq=0;

for sq=1:length(SEQ)
    seq=num2str(SEQ(sq),'%02d');
    seq_name=['seq',seq];
    [GTimg,GT3d,Afr,Vfr,FoV]=myAVsync_AV163(seq_name,cam, fv, nfft, fa,dataset);
    [FBB,detN,Conf,mouthImg,mouth3D]=readMXNetData(seq,Vfr,camData,[],5,0);
    
    [DR(sq),P(sq),R(sq),~,~,~,DR2(sq)]=myPRcurve_mouth(GTimg,mouthImg',detN,FoV,er);
    disp([seq_name,' DR=',num2str(DR(sq)),'  P=',num2str(P(sq)),'  R=',num2str(R(sq))])
    
end



PR=[SEQ',DR,P,R,DR2];
PR(length(SEQ)+1,:)=sum(PR)/length(SEQ);
PR

fName='PR_MXnet_FaceDetection.dat';
f1 = fopen(fullfile(RstDir,fName),'w');
fprintf(f1, '%02d %.4f %.4f %.4f %.4f\n', PR');
fclose(f1);
disp('Saved!');


