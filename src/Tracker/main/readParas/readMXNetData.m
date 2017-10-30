function [FBB,detN,Conf,mouthImg,mouth3D]=readMXNetData(seq,Vfr,camData,W,cam,comp)
% Date: 22/09/2017
% Author: XQ
% Output:
% FBB: face detection bounding box
% Conf: confidence value
% W: face width

if(nargin<6)
    comp=1;  % default compute mouth in3D
end

disp('read MXNet data')

RstDir=fullfile('..', '..', '..','..','Results','FaceBB_MXnet',camData.dataset);
addpath(genpath(RstDir));


seq_name=['seq', num2str(seq,'%02d')];

dataset=camData.dataset;

switch dataset
    case 'FBK'
        disp([dataset,':   read FBB results'])
        sf=768/600; % resize factor of the detector
        filename=['facebb_FBKseq',num2str(seq,'%02d'),'.txt'];
        Rstname=fullfile(RstDir,filename);
        if(~exist(Rstname,'file'))
            disp(['no face detection rst:',seq_name])
        end
        % read detection data
        fileID = fopen(filename);
        C = textscan(fileID,'%s %d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','CollectOutput', true);
        fclose(fileID);
        
        picName=C{1};  % picture name
        detN=C{2};  % detection number
        faceBB=C{3}; % face detection bounding box
        StrNum=zeros(size(faceBB,1),1);
        for i=1:size(faceBB,1)  % re-order the detection results
            StrNum(i)=str2double(picName{i}(end-8:end-4));
        end
        [StrNum,Istr]=sort(StrNum);
        detN=detN(Istr);
        faceBB=faceBB(Istr,:);
        
        % change width and height
        faceBB(:,3)=faceBB(:,3)-faceBB(:,1);
        faceBB(:,4)=faceBB(:,4)-faceBB(:,2);
        
        faceBB(:,8)=faceBB(:,8)-faceBB(:,6);
        faceBB(:,9)=faceBB(:,9)-faceBB(:,7);
        
        faceBB(:,13)=faceBB(:,13)-faceBB(:,11);
        faceBB(:,14)=faceBB(:,14)-faceBB(:,12);
        
        % synchronisation
        st=find(StrNum==Vfr(1));
        ed=find(StrNum==Vfr(2));
        
        FBB=faceBB(st:ed,[1:4,6:9,11:14])*sf;
        Conf=faceBB(st:ed,[5,10,15]);
        detN=double(detN(st:ed));
        
        disp('estimate mouth on image plane')
        
        
        mouthImg=zeros(6,size(FBB,1));
        for d=1:3  % multiple detection number
            id=(d-1)*4;
            mouthImg((d-1)*2+1:(d-1)*2+2,:)=[FBB(:,id+1)'+0.5*FBB(:,id+3)';FBB(:,id+2)'+0.75*FBB(:,id+4)'];
        end
        if(comp) % compute mouth in 3D
            disp('compute mouth in 3D')
            
            mouth3D=zeros(9,size(FBB,1));
            mouth3D(1:3,:)= myUpBody3D(FBB(:,1:4), W, camData,dataset);
            mouth3D(4:6,:)= myUpBody3D(FBB(:,5:8), W, camData,dataset);
            mouth3D(7:9,:)= myUpBody3D(FBB(:,9:12), W, camData,dataset);
   
            disp([dataset,':   Finish reading MXNet data...'])
        else
            mouth3D=[];
        end
    case 'AV16.3'
        sf=1; % resize factor of the detector

        disp([dataset,':   read FBB results'])
                filename=['facebb_AV16.3seq',num2str(seq,'%02d'),'_C',num2str(cam),'.txt'];
        Rstname=fullfile(RstDir,filename);
        if(~exist(Rstname,'file'))
            disp(['no face detection rst:',seq_name])
        end
        
        fileID = fopen(filename);
        C = textscan(fileID,'%s %d %f %f %f %f %f','CollectOutput', true);
        fclose(fileID);
       
        FBB=C{3}(:,1:4)*sf;
        FBB(:,3)=FBB(:,3)-FBB(:,1);
        FBB(:,4)=FBB(:,4)-FBB(:,2);
        
        FBB=FBB(Vfr(1):Vfr(2),:);
        
        Conf=C{3}(Vfr(1):Vfr(2),5);
        detN=C{2}(Vfr(1):Vfr(2),:);
        mouthImg=[FBB(:,1)'+0.5*FBB(:,3)';FBB(:,2)'+0.75*FBB(:,4)'];
        mouth3D(1:3,:)= myUpBody3D(FBB(:,1:4), W, camData,dataset);

    otherwise
        disp('Error in the dataset name')
        
end

end