function [vad,VAD]=FBK_VADextraction(seq_name,ma,Results,Afr)
% Description:
% extract the manually annotated voice activity detection results
% Date: 14/08/2017
% Author: XQ
% Input:
%       seq: seq index
%       ma: microphone array index   0: circular microphone array
%                                   1: distributed microphone array on the
%                                   wall (to be added)
% Output:
%   VAD: 
%       0: no sound
%       1: speech
%       2: hand clap
%       3: other background noise

addpath(genpath(fullfile('..','..','Datasets','FBK_CHIL')));
AVsync=dlmread('FBK_AVsync_content.txt');

if(nargin<3)
load(fullfile(seq_name,['GCFSSL_MA',num2str(ma),'_nfft32768']))
end

rst_t=Results.SSLcart(1,:)-Results.SSLcart(1,1);
rst_t=AVsync(AVsync(:,1)==str2double(seq_name(4:end)),5)+rst_t;  % audio time 

% read VAD results
VADgt=dlmread([seq_name,'_MA0_c1.lbl']); % vad ground truth
VADt=VADgt(:,1);  % vad  timetable
VAD=repmat(rst_t,length(VADt),1)-repmat(VADt,1,length(rst_t));
VADslot=sum(VAD>0); % check timetable

VAD=VADgt(VADslot(Afr(1):Afr(2)),2);  % VAD results
vad=VAD==1;  % only speech


if(sum(VADslot>length(VADt)))  % 
    disp('VAD error! SSL time exceed VAD ground truth! ')
end

end