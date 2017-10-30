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

%
Ih =768;  % Image height
Iw =1024; % Image width
ImgSize=[Iw Ih];
SEQ=[11,13,17,20];
e3d=0.4; % error in 3D (m)
eimg=50; % error on image plane (pixels)

K=[0.2,0.3,0.5,0.7,0.9];
% K=0.2:0.1:0.9;

% FLAG=[1,2,0];  % audio,video audiovisual
% AL=[2 2 3 1 1 0 4];
% VL=[1 1 1 1 1 1 1];
% HM{1}='0'; HM{2}='rgb'; HM{3}='rgb'; HM{4}='rgb';
% HM{5}='hsvspatio';HM{6}='hsvspatio';HM{7}='hsvspatio';

% FLAG=[1,2,0];
FLAG=0;
AL=4;
VL=2;
HM{1}='hsvspatio';
% HM{1}='0';
R=5;

if length(FLAG)>1 && length(K)>1
   disp('ERROR!! FLAG and K ---- only one could be a vector')
    pause
end


dataset='FBK';
Date='25';
% Date=[];
camData=readParas(11,dataset,5);
addpath(genpath(fullfile('..','res',dataset,'face3Dbp')));


for ver=1:length(VL)
    almode=AL(ver);
    vlmode=VL(ver);
    hmode=HM{ver};
    
    avgMAE_3D=zeros(length(SEQ),length(FLAG));% three different audio likelihood
    avgMAE_2D=zeros(length(SEQ),length(FLAG));% three different audio likelihood
    stdMAE_3D=zeros(length(SEQ),length(FLAG));
    stdMAE_2D=zeros(length(SEQ),length(FLAG));
    
    index=1;
    %     figure
    for f=1:length(FLAG)
        flag=FLAG(f);
        
        for k=1:length(K)
            if K==0
                K=0; % use original faceBB
                Kstr='';
                disp('Original face BB')
            else
                Kstr=['K',num2str(K(k))];
                disp(['Remove ',num2str(K(k)),' FBB'])
            end
            f=k;
            
            for sq=1:length(SEQ)
                seq=SEQ(sq);
                seq_name=['seq',num2str(SEQ(sq),'%02d')];
                [PF,Version,dirRst,dirF]=SavFile_info(flag,vlmode,hmode,almode,dataset,R,0,1,1,seq,Date);
                Para=load(fullfile(Version,['Paras_',PF,Kstr,'.mat']));
                Face3DSz=Para.Face3DSz;
                
                for iter=1:R  % iteration
                    fName = ['trackRes_S' num2str(seq,'%02d') 'C5MA0_FBK_face3Dbp_vlm',num2str(vlmode),'_almode',num2str(almode),Kstr,'_iter',num2str(iter) '.dat'];
                    if(~exist(fullfile(Version,PF,fName),'file'))
                        disp(['No file! ',num2str(seq),PF,'  ',num2str(vlmode),' ',num2str(almode),' ',hmode,'  ',fName])
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
                    tl3D(iter)=sum(Er3d<=e3d)/length(Er3d);
                    
                    %%% Image Error
                    [Ioigt,~,Roi]=OutsideImg(GTimg,ImgSize); % check GT outside image
                    [Ioires,~,~]=OutsideImg(estimg,ImgSize); % audio tracking outside image
                    FoV=~isnan(GTimg(1,:));
                    
                    Ibi=~Ioigt&~Ioires&FoV;  % both GT and tracking results are on the image
                    Igtito=~Ioigt&Ioires&FoV;  % GT on image / tracking results not
                    
                    %                 disp(['GT&Res on image:                ',num2str(sum(Ibi))])
                    disp(['seq:',num2str(seq),'GT on image/Res outside image:  ',num2str(sum(Igtito))])
                    
                    Er2D = sqrt(sum((GTimg(:,Ibi) - estimg(:,Ibi)).^2));
                    Er2D(sum(Ibi)+1:sum(Igtito))=norm(ImgSize);
                    MAE_2D(iter)=mean(Er2D);
                    tlimg(iter)=sum(Er2D<=eimg)/length(Er2D);
                    
                    % Track & Loss on image plane
                    tckr(iter)=myTrackLos_OverlapImg(GT3d',est3d',camData,Face3DSz,ImgSize);
                    
                    
                end
                
                %             disp(['seq',num2str(SEQ(sq)),'   Roi=',num2str(Roi)])
                
                
                avgMAE_3D(sq,f)=mean(MAE_3D);
                avgMAE_2D(sq,f)=mean(MAE_2D);
                
                stdMAE_3D(sq,f)=std(MAE_3D);
                stdMAE_2D(sq,f)=std(MAE_2D);
                
                TL3D(sq,f)=mean(tl3D);
                TLimg(sq,f)=mean(tlimg);
                TLovlap(sq,f)=mean(tckr);
                
                
            end
            
        end
    end
    
    avgMAE_3D(length(SEQ)+1,:)=mean(avgMAE_3D);
    avgMAE_2D(length(SEQ)+1,:)=mean(avgMAE_2D);
    stdMAE_3D(length(SEQ)+1,:)=mean(stdMAE_3D);
    stdMAE_2D(length(SEQ)+1,:)=mean(stdMAE_2D);
    
    TL3D(length(SEQ)+1,:)=mean(TL3D);
    TLimg(length(SEQ)+1,:)=mean(TLimg);
    TLovlap(length(SEQ)+1,:)=mean(TLovlap);
    
    flen=length(FLAG);
    
    switch flen
        case 1 % AV only results
            if K==0
                KS='';
            else
                KS='_FBBremov';
            end
            
            
            res3D=[SEQ,0]';
            res2D=[SEQ,0]';
            resStr='%.1f &';
            for k=1:length(K)
            res3D=[res3D avgMAE_3D(:,k) stdMAE_3D(:,k)];
            res2D=[res2D avgMAE_2D(:,k) stdMAE_2D(:,k)];
            resStr=[resStr,' $%.2f\\pm%.2f$ &' ];
            end
            resStr=[resStr,'\n'];
            
            
            f1 = fopen(fullfile(dirRst(7:end),'..',['MAE3D_',PF,'comp',Version,KS,'.dat']),'w');
            fprintf(f1, resStr, res3D');
            fclose(f1);
            
            f1 = fopen(fullfile(dirRst(7:end),'..',['MAEimg_',PF,'comp',Version,KS,'.dat']),'w');
            fprintf(f1, resStr, res2D');
            fclose(f1);
            
            if length(K)==1
            f1= fopen(fullfile(dirRst(7:end),'..',['TrackLoss_',PF,'comp',Version,KS,'.dat']),'w');
            fprintf(f1, '%s %s %s \n', [['TL3D   ']',['TLimg  ']',['TLovlap']']);
            fprintf(f1, '%.2f %.2f %.2f \n', [e3d;eimg;0]);
            fprintf(f1, '%.2f %.2f %.2f \n',[TL3D,TLimg,TLovlap]'*100);
            fclose(f1);
            end
            
        case 3 % AO,VO,AV comparison
            res3D=[[SEQ,0]' avgMAE_3D(:,1) stdMAE_3D(:,1) avgMAE_3D(:,2) stdMAE_3D(:,2) avgMAE_3D(:,3) stdMAE_3D(:,3)];
            res2D = [[SEQ,0]' avgMAE_2D(:,1) stdMAE_2D(:,1) avgMAE_2D(:,2) stdMAE_2D(:,2) avgMAE_2D(:,3) stdMAE_2D(:,3)];
            
            
            f1 = fopen(fullfile(dirRst(7:end),'..',['MAE3D_aovoavcomp',Version,'.dat']),'w');
            fprintf(f1, '%.1f $%.2f\\pm%.2f$ $%.2f\\pm%.2f$ $%.2f\\pm%.2f$\n', res3D');
            fclose(f1);
            
            f1 = fopen(fullfile(dirRst(7:end),'..',['MAEimg_aovoavcomp',Version,'.dat']),'w');
            fprintf(f1, '%.1f $%.2f\\pm%.2f$ $%.2f\\pm%.2f$ $%.2f\\pm%.2f$\n', res2D');
            fclose(f1);
            
    end
end




% figure of remove % of face detections

figure
hold on
grid on
% for sq=1:size(avgMAE_3D,1)
% errorbar(K*100,avgMAE_3D(sq,:),stdMAE_3D(sq,:),'-','LineWidth',1.5,'MarkerSize',7)
% end

errorbar(K*100,avgMAE_3D(1,:),stdMAE_3D(1,:),'rd--','LineWidth',1,'MarkerSize',8,'MarkerFaceColor','r')
errorbar(K*100,avgMAE_3D(2,:),stdMAE_3D(2,:),'bs--','LineWidth',1,'MarkerSize',8,'MarkerFaceColor','b')
errorbar(K*100,avgMAE_3D(3,:),stdMAE_3D(3,:),'go--','LineWidth',1,'MarkerSize',8,'MarkerFaceColor','g')
errorbar(K*100,avgMAE_3D(4,:),stdMAE_3D(4,:),'m*--','LineWidth',1,'MarkerSize',8,'MarkerFaceColor','m')

sq=size(avgMAE_3D,1); % average
% errorbar(K*100,avgMAE_3D(sq,:),stdMAE_3D(sq,:),'k-','LineWidth',2,'MarkerSize',8)
% lgd =legend('poses','behind','2-people','easy','Avg.','Location','northwest');

lgd =legend('poses','behind','2-people','easy','Location','northwest');
xlabel('% of face detection removal')
ylabel('MAE (m)')
set(gca,'fontsize', 13);
lgd.FontSize = 11;
ylim([0.1 0.73])
saveas(gcf,'D:\FBK_Trento\doc\ICASSP2018\figures\FBBremoval.png')
saveas(gcf,'D:\FBK_Trento\doc\ICASSP2018\figures\FBBremoval.fig')

