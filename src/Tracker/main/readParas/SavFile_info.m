function[PF,Version,dirRst,dirF]=SavFile_info(flag,vlmode,hmode,aemode,dataset,R,savfig,savRst,fbb3Dbp,seq,Date)
% Description:
% saving file information
% Date: 04/09/2017
% Author:XQ
% Input:
% fbb3Dbp: flag of fbb3Dbp

disp('sav fig info')

if ~savRst && ~savfig
    PF=[];
    Version=[];
    dirRst=[];
    dirF=[];
    return
end

switch flag
    case 1
        PF= 'APF';
    case 2
        PF= 'VPF';
    otherwise
        PF= 'AVPF';
end


formatOut = 'yy.mm.dd';
DTstr=datestr(now,formatOut);
if(nargin<7||(fbb3Dbp~=1))
    Version=['20',DTstr,'_R',num2str(R),'_',dataset,'_vl',num2str(vlmode),'_',hmode,'_ae',num2str(aemode)];
    if(~isempty(Date))
        Version(9:10)=Date;
    end
    dirA=fullfile('..','res', dataset,Version,'APF');
    dirV=fullfile('..','res', dataset,Version,'VPF');
    dirAV=fullfile('..','res', dataset,Version,'AVPF');
    
else %use the 3D face back projection
    Version=['20',DTstr,'_3DfaceBP_R',num2str(R),'_',dataset,'_vl',num2str(vlmode),'_',hmode,'_ae',num2str(aemode)];
    if(~isempty(Date))
        Version(9:10)=Date;
    end
    dirA=fullfile('..','..','..','res', dataset,'face3Dbp',Version,'APF');
    dirV=fullfile('..','..','..','res', dataset,'face3Dbp',Version,'VPF');
    dirAV=fullfile('..','..','..','res', dataset,'face3Dbp',Version,'AVPF');
end

if(flag==1)
    dirRst=dirA;
    if(~exist(dirA,'dir'))
        mkdir(dirA)
    end
end

if(flag==2)
    dirRst=dirV;
    if(~exist(dirV,'dir'))
        mkdir(dirV)
    end
end

if(flag==0)
    dirRst=dirAV;
    if(~exist(dirAV,'dir'))
        mkdir(dirAV)
    end
end

if(savfig)  % saving figures
    if(nargin<7||(fbb3Dbp~=1))
        dirF=fullfile('..','res', dataset,Version,'figures',['seq',num2str(sq,'%02d')]);
    else
        dirF=fullfile('..','..','..','res', dataset,'face3Dbp',Version,'figures',['seq',num2str(seq,'%02d')]);
    end
    
    if(~exist(dirF,'dir'))
        mkdir(dirF);
    end
    clear dir
else
    dirF=[];
end


end