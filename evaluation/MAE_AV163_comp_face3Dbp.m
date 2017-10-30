% Description: to evaluat the tracking error on FBK dataset
% Description:
% compare the audio-only PF tracking results
% Date: 17/08/2017
% Author: XQ
%

clear all
close all
clc

dbstop if error
restoredefaultpath
disp('Restore default paths')

addpath(genpath(fullfile('..','src')))
addpath(genpath(fullfile('..','..','Data')))

R=10;
dataset='AV16.3';
ImgSize=[360 288];


addpath(genpath(fullfile('..','res',dataset,'face3Dbp')));


SEQ=[8,11,12];
CAM=1:3;

FLAG=0;
AL=4;
VL=2;
HM{1}='hsvspatio';
% HM{1}='0';

Date=[];


Row=0;
for ver=1:length(VL)
    almode=AL(ver);
    vlmode=VL(ver);
    hmode=HM{ver};
    
    avgMAE_3D=zeros(length(SEQ)*length(CAM),length(FLAG));% three different audio likelihood
    avgMAE_2D=zeros(length(SEQ)*length(CAM),length(FLAG));% three different audio likelihood
    stdMAE_3D=zeros(length(SEQ)*length(CAM),length(FLAG));
    stdMAE_2D=zeros(length(SEQ)*length(CAM),length(FLAG));
    
    index=1;
    %     figure
    for f=1:length(FLAG)
        flag=FLAG(f);
        
        for sq=1:length(SEQ)
            seq=SEQ(sq);
            
            
            for c=1:length(CAM)
                cam=CAM(c);
                Row=Row+1;
                
                % disp(['seq!',num2str(seq),' al',num2str(almode),' vl',num2str(vlmode),' hmode',hmode])
                camData=readParas(seq,dataset,cam);
                seq_name=['seq',num2str(SEQ(sq),'%02d')];
                [PF,Version,dirRst,dirF]=SavFile_info(flag,vlmode,hmode,almode,dataset,R,0,1,1,seq,Date);

                
                for iter=1:R  % iteration
                    
                    fName = ['trackRes_S' num2str(seq,'%02d') 'C',num2str(cam),'MA1_FBK_face3Dbp_vlm',num2str(vlmode),'_almode',num2str(almode),'_iter',num2str(iter) '.dat'];
                    if(~exist(fullfile(Version,PF,fName),'file'))
                        disp(['No file! ',num2str(seq,'%02d'),PF,'  ',num2str(vlmode),' ',num2str(almode),' ',hmode,'  ',fName])
                        continue
                    end
                    Rst= dlmread(fullfile(Version,PF,fName));
                    
                    GT3d=Rst(:,2:4);
                    est3d=Rst(:,5:7);
                    GTimg=Rst(:,9:10)';
                    estimg=myproject( [est3d ones(size(est3d,1),1)]', camData);
                    estimg(3,:)=[];
                    %%% 3D Error
                    Er3d = sqrt(sum((Rst(:,2:4) - Rst(:,5:7)).^2,2));
                    MAE_3D(iter)=mean(Er3d);
                    
                    %%% Image Error
                    [Ioigt,~,Roi]=OutsideImg(GTimg,ImgSize); % check GT outside image
                    [Ioires,~,~]=OutsideImg(estimg,ImgSize); % audio tracking outside image
                    FoV=~isnan(GTimg(1,:));
                    
                    Ibi=~Ioigt&~Ioires&FoV;  % both GT and tracking results are on the image
                    Igtito=~Ioigt&Ioires&FoV;  % GT on image / tracking results not
                    
                    %                 disp(['GT&Res on image:                ',num2str(sum(Ibi))])
                    disp(['seq:',num2str(seq),'  cam:',num2str(cam),'  GT on image/Res outside image:  ',num2str(sum(Igtito))])
                    
                    Er2D = sqrt(sum((GTimg(:,Ibi) - estimg(:,Ibi)).^2));
                    Er2D(sum(Ibi)+1:sum(Igtito))=norm(ImgSize);
                    MAE_2D(iter)=mean(Er2D);
                    
                    
                end
                
                disp(['seq',num2str(SEQ(sq)),'   Roi=',num2str(Roi)])
                
                avgMAE_3D(Row,f)=mean(MAE_3D);
                avgMAE_2D(Row,f)=mean(MAE_2D);
                
                stdMAE_3D(Row,f)=std(MAE_3D);
                stdMAE_2D(Row,f)=std(MAE_2D);
                
            end
            
        end
        
    end
    
    
    avgMAE_3D(Row+1,:)=mean(avgMAE_3D);
    avgMAE_2D(Row+1,:)=mean(avgMAE_2D);
    stdMAE_3D(Row+1,:)=mean(stdMAE_3D);
    stdMAE_2D(Row+1,:)=mean(stdMAE_2D);
    
    
    
    flen=length(FLAG);
    
    switch flen
        case 1 % AV only results
            res3D=[avgMAE_3D(:,1) stdMAE_3D(:,1)];
            res2D = [avgMAE_2D(:,1) stdMAE_2D(:,1)];
            
            f1 = fopen(fullfile(dirRst(7:end),'..',['MAE3D_',PF,'comp',Version,'.dat']),'w');
            fprintf(f1, '$%.3f\\pm%.3f$\n', res3D');
            fclose(f1);
            
            f1 = fopen(fullfile(dirRst(7:end),'..',['MAEimg_',PF,'comp',Version,'.dat']),'w');
            fprintf(f1, '$%.2f\\pm%.2f$\n', res2D');
            fclose(f1);
            
        case 3   % AO,VO,AV
            
            res3D=[avgMAE_3D(:,1) stdMAE_3D(:,1) avgMAE_3D(:,2) stdMAE_3D(:,2) avgMAE_3D(:,3) stdMAE_3D(:,3)];
            res2D=[avgMAE_2D(:,1) stdMAE_2D(:,1) avgMAE_2D(:,2) stdMAE_2D(:,2) avgMAE_2D(:,3) stdMAE_2D(:,3)];
            
            f1 = fopen(fullfile(dirRst(7:end),'..',['MAE3D_aovoavcomp',Version,'.dat']),'w');
            fprintf(f1, '%.1f $%.2f\\pm%.2f$ $%.2f\\pm%.2f$ $%.2f\\pm%.2f$\n', res3D');
            fclose(f1);
            
            f1 = fopen(fullfile(dirRst(7:end),'..',['MAEimg_aovoavcomp',Version,'.dat']),'w');
            fprintf(f1, '$%.2f\\pm%.2f$ $%.2f\\pm%.2f$ $%.2f\\pm%.2f$\n', res2D');
            fclose(f1);
            
              
    end

end





