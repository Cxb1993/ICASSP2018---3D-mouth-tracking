
function [GTimg,GT3d,Afr, Vfr,Vg]=myAVsync_AV163(seq_name, cam, fv, nfft, fa,dataset,camData)
% Description:
%   synchronise the audio and video sequences, and ground truth
% Input:
%   seq_name: 'seq08/11/12'
%   cam: camera index
%   fv: video framerate (e.g. 25 fps)
%   nfft:
%   fa: Audio sampling frequency (e.g. 16 kHz)
% Output:
%   GTimg: ground truth on image plane
%   GT3d: ground truth in 3D
%   Vfr: [start frame, end frame]
%   Afr: [start frame, end frame]
%   Vg: FoV ground truth
%
%        Author: Xinyuan Qian
%        Author: Alessio Xompero
%   Create Date: 2017/04/09
% Modified Date: 2017/07/22
%
%
if(nargin<6)
    dataset='AV16.3';
    disp('Default dataset: AV16.3')
end

switch dataset
    case 'AV16.3'
         disp('AV16.3 dataset')
        af1_timestamp = 10;
        af1_time = af1_timestamp + (nfft/fa/2);
        
        % Read all timecodes and convert the first in seconds (h:m:s.fr, fr is the frame rate)
        %         fileID = fopen(fullfile('Datasets',seq_name,[seq_name,'_timings_cam',num2str(cam)]), 'r');
        fileID = fopen(fullfile(seq_name,[seq_name,'_timings_cam',num2str(cam)]), 'r');
        timecodes = textscan(fileID,'%s %.2f %d');
        fclose(fileID);
        
        timecode1 = timecodes{1,1}{1};
        
        vf1_time = timecode_to_sec(timecode1);
        
        %%% OLD CODE TO REMOVE and replaced with the previous one where we used the
        %%% AV16.3 authors function for timecode conversions
        % timecodes = load(fullfile('Datasets',seq_name,[seq_name,'_timings_cam',num2str(cam)]));
        % timecode1 = timecodes(1,2);
        %
        % vf1_time = floor(timecode1) + (timecode1-floor(timecode1))*4
        
        % global video framerate
        Vfr = myFrameRangeToCompare(seq_name, cam);
        Afr=round(Vfr+(vf1_time-af1_time)*fv);  % audio-visual synchronisation
        
        % load ground-truth data and synchronise
        gt=load(fullfile(seq_name,[seq_name,'-cam',num2str(cam),'-person1-interpolated-reprojected.mouthgt']));
        GTimg=gt(Vfr(1):Vfr(2),4:5);
        
        gt3d=load(fullfile(seq_name,[seq_name,'-person1-interpolated.3dmouthgt']));
        [~,gt3dst_index]=min(abs(gt3d(:,1)-(Vfr(1)-1)/fv-vf1_time));
        GT3d=gt3d(gt3dst_index:gt3dst_index+Afr(2)-Afr(1),3:5);
        
        
    case 'FBK'
        disp('FBK dataset')
        Afr=zeros(1,2);
        Vfr=zeros(1,2);
        
        AVsync=dlmread('FBK_AVsync_content.txt');
        row=find(AVsync(:,1)==str2double(seq_name(4:end)));
        Vfr(1)=AVsync(row,2);
        Vfr(2)=AVsync(row,3);
        
        Afr(1)=1;
        Afr(2)=Vfr(2)-Vfr(1)+1;
        
        % truncate the middle part for tracking
        st_diff=AVsync(row,8)-Vfr(1);
        ed_diff=AVsync(row,9)-Vfr(2);
        
        Afr(1)=Afr(1)+st_diff;
        Afr(2)=Afr(2)+ed_diff;
        Vfr(1)=Vfr(1)+st_diff;
        Vfr(2)=Vfr(2)+ed_diff;
        
        
        % load ground-truth data and synchronise
        gt3d=load(fullfile(seq_name,'annotation',[seq_name,'.3dmouthgt']));
        GT3d=gt3d(Vfr(1):Vfr(end),3:5);
        
        % --- Image plane ground truth ------------
        if(nargin<7)
            load(['C' num2str(cam) '.mat']);
            camData.dataset='FBK';
            camData.Cam_pos=-camData.R'*camData.T;  % need to be removed AX
            disp('FBK dataset: reading camera parameters')
        end
        GTimg= myproject( [GT3d';ones(1,size(GT3d,1))], camData);
        GTimg(3,:)=[];
 
        
        Vg=dlmread(fullfile(seq_name,'annotation','fov.txt')); % FoV GT
        st=find(Vg(:,1)==Vfr(1));
        ed=find(Vg(:,1)==Vfr(2));
        Vg=Vg(st:ed,2); % object inside FoV
        GTimg(:,~Vg)=NaN;
        GTimg=GTimg';
        Vg=logical(Vg);
        
end

disp('Finish AV sync')

end

% Vfr = myFrameRangeToCompare(seq_name,cam)
%   Calculate the framerange to make comparison with
%
% Date: 09/04/2017
% Author: Xinyuan
function Vfr=myFrameRangeToCompare(seq_name,cam)

if strcmp(seq_name, 'seq08-1p-0100')
    
    if(cam==1)
        Vfr(1)     = 35;       % Initial frame for seq08-1p-0100 cam1
        Vfr(2)     = 500;      % Last frame for seq08-1p-0100 cam1
    else if (cam==2)
            Vfr(1)     = 25;       % Initial frame for seq08-1p-0100 cam2
            Vfr(2)     = 495;      % Last frame for seq08-1p-0100 cam2
        else if(cam==3)
                Vfr(1)     = 25;       % Initial frame for seq08-1p-0100 cam3
                Vfr(2)     = 515;      % Last frame for seq08-1p-0100 cam3
            end
        end
    end
    
    
else if strcmp(seq_name, 'seq11-1p-0100')
        if(cam==1)
            Vfr(1)     = 20;       % Initial frame for seq11-1p-0100 cam1
            Vfr(2)     = 549;      % Last frame for seq11-1p-0100 cam1
        else if (cam==2)
                Vfr(1)     = 11;       % Initial frame for seq11-1p-0100 cam2
                Vfr(2)     = 544;      % Last frame for seq11-1p-0100 cam2
            else if(cam==3)
                    
                    Vfr(1)     = 49;       % Initial frame for seq11-1p-0100 cam3
                    Vfr(2)     = 578;      % Last frame for seq11-1p-0100 cam3
                end
            end
        end
        
        
    else if strcmp(seq_name, 'seq12-1p-0100')
            if(cam==1)
                Vfr(1)     = 90;       % Initial frame for seq12-1p-0100 cam1
                Vfr(2)     = 1160;     % Last frame for seq12-1p-0100 cam1
            else if (cam==2)
                    Vfr(1)     = 123;      % Initial frame for seq12-1p-0100 cam2
                    Vfr(2)     = 1190;     % Last frame for seq12-1p-0100 cam2
                else if(cam==3)
                        Vfr(1)     = 80;       % Initial frame for seq12-1p-0100 cam3
                        Vfr(2)     = 1155;     % Last frame for seq12-1p-0100 cam3
                    end
                end
            end
        end
    end
end
end
