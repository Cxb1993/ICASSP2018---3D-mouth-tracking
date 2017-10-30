function [camData,seq_name,fmt,RoomRg,T,Face3DSz,ma,cam,fv,nfft,fa,AMvad,Upstd,gammaG,Q,c,Mic_pos,Mic_c,ImgSize]=readParas(seq,dataset,cam)
% Description:
% read parameters
% XQ
% Date: 18/10/2017


disp(['Start Read parameters:    ',dataset,' dataset'])


switch  dataset
    case 'FBK'
        % load camera data
        seq_name=['seq', num2str(seq,'%02d')];
        load('C5.mat');
        camData.dataset='FBK';
        camData.Cam_pos=-camData.R'*camData.T;  % need to be removed AX
        load('FBK_RoomRg');
        RoomRg(3,:)=[0.5 2];
        T=load('table.txt');
        %         Face3DSz = [0.14 0.18];
        ImgSize=[768 1024];
        
        ma=0;
        cam=5;
        fv=15;
        nfft=2^15;
        fa=96000;
        AMvad=0.03;
        
        fmt{1}=['cam' num2str(cam)];
        fmt{2}=[];
        fmt{3}='%06d';
        fmt{4}='.jpg';
        
    case 'AV16.3'
        
        switch seq
            case 11
                ses=9;
            otherwise
                ses=10;
        end
        
        seq_name=['seq', num2str(seq,'%02d'), '-1p-0100'];
        load(['session' num2str(ses,'%02d') '_shift.mat']);
        camData = readCameraData(cam,shift);
        camData.dataset='AV16.3';
        camData.RT=inv(camData.K)*camData.Pmat;
        T=zeros(4,3);
        load('RoomRg');
        %         Face3DSz = [0.16 0.2];
        %         Face3DSz = [0.14 0.18];
        
        ImgSize=[288 360];
        
        ma=1;
        fv=25;
        %         nfft=2^12;
        nfft=2^10;
        fa=16000;
        AMvad = 0.1;
        
        fmt{1}=['C' num2str(cam)];
        fmt{2}='img';
        fmt{3}='%04d';
        fmt{4}='.png';
        
end

gammaG = 0.8;
Q = [2, 2, 2];
c=342;
Upstd=0.3;

load(['MA',num2str(ma),'_pos']); % microphone position
Mic_pos=Mic_pos';
Mic_c=mean(Mic_pos);

% Face3DSz = [0.15 0.2];
Face3DSz = [0.14 0.18];
disp('Finish reading parameters....')

end