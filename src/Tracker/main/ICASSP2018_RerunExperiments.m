% Description:
% Final run of the experiments for ICASSP 2018
% Date: 24/10/2017
% Author: XQ


clear all
close all
clc

dbstop if error
restoredefaultpath

savRst=1;
savfig=2;

MP='all';
R=10;
N=100;
p=0;

%%  FBK dataset
dataset='FBK';
SEQ=[11,13,17,20];

% AV,VO
FLAG=[0,2];  % AV, VO
almode=4;
vlmode=2; % multivariate Gaussian
hmode='hsvspatio';
for sq=1:length(SEQ)
    seq=SEQ(sq);
    for f=1:length(FLAG)
        flag=FLAG(f);
        myTracker3D_faceRP_3DGCF(seq,MP,almode,vlmode,hmode,R,N,flag,p,savfig,savRst,dataset,5);
    end
end

% AO
FLAG=1;
almode=1;
vlmode=2; % multivariate Gaussian
hmode='hsvspatio';
for sq=1:length(SEQ)
    seq=SEQ(sq);
    for f=1:length(FLAG)
        flag=FLAG(f);
        myTracker3D_faceRP_3DGCF(seq,MP,almode,vlmode,hmode,R,N,flag,p,savfig,savRst,dataset,5);
    end
end

% ICASSP approach (AV)
FLAG=0;
almode=6;
vlmode=2; % multivariate Gaussian
hmode='0';
for sq=1:length(SEQ)
    seq=SEQ(sq);
    for f=1:length(FLAG)
        flag=FLAG(f);
        myTracker3D_faceRP_3DGCF(seq,MP,almode,vlmode,hmode,R,N,flag,p,savfig,savRst,dataset,5);
    end
end


%% AV16.3
dataset='AV16.3';
SEQ=[8,11,12];

FLAG=0;  % AV
almode=4;
vlmode=2; % multivariate Gaussian
hmode='hsvspatio';
for cam=1:3
    for sq=1:length(SEQ)
        seq=SEQ(sq);
        for f=1:length(FLAG)
            flag=FLAG(f);
            myTracker3D_faceRP_3DGCF(seq,MP,almode,vlmode,hmode,R,N,flag,p,savfig,savRst,dataset,cam);
        end
    end
end

% ICASSP
FLAG=0;
almode=6;
vlmode=2; % multivariate Gaussian
hmode='0';
for cam=1:3
    for sq=1:length(SEQ)
        seq=SEQ(sq);
        for f=1:length(FLAG)
            flag=FLAG(f);
            myTracker3D_faceRP_3DGCF(seq,MP,almode,vlmode,hmode,R,N,flag,p,savfig,savRst,dataset,cam);
        end
    end
end
    
    
