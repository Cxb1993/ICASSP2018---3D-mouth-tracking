% Description: to evaluat the tracking error on FBK dataset
% Description:
% compare the audio-only PF tracking results
% Date: 08/10/2017
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
ImgSize=[1024 768];
SEQ=[11,13,17,20];


Subfolder='rstAL_GCF2_FBBvalid_final';
dataset='FBK';
Date='17';
camData=readParas(11,dataset,5);
addpath(genpath(fullfile('..','res',dataset,'face3Dbp',Subfolder)));


for flag=0:2


switch flag
    case 1
        % audio only
        Ver=cell(4,4);
        Ver{1,1}=2;  Ver{1,2}=3;    Ver{1,3}=0;          Ver{1,4}=1; %Ver{1,5}=4;  % al mode
        Ver{2,1}=1;  Ver{2,2}=1;    Ver{2,3}=1;          Ver{2,4}=1;   %Ver{2,5}=1;  % vl mode
        Ver{3,1}='0';Ver{3,2}='rgb';Ver{3,3}='hsvspatio';Ver{3,4}='hsvspatio';%Ver{3,5}='hsvspatio';
        Order=reshape(2:2*size(Ver,2)+1,[size(Ver,2),2])';
        Ver{4,1}=[1 Order(:)'];
        Ver{4,2}='%.1f  & $%.2f\\pm%.2f$  & $%.2f\\pm%.2f$  & $%.2f\\pm%.2f$  & $%.2f\\pm%.2f$\n';
        Ver{4,3}='%d  %d  %d  %d \n';
        Ver{4,4}='%s  %s  %s  %s \n';

    case 2
        % video only
        Ver=cell(4,4);
        Ver{1,1}=2;  Ver{1,2}=2;    Ver{1,3}=1;          Ver{1,4}=1;  % al mode
        Ver{2,1}=1;  Ver{2,2}=1;    Ver{2,3}=1;          Ver{2,4}=1; % vl mode
        Ver{3,1}='0';Ver{3,2}='rgb';Ver{3,3}='hsvspatio';Ver{3,4}='rgb';
        Order=reshape(2:2*size(Ver,2)+1,[size(Ver,2),2])';
        Ver{4,1}=[1 Order(:)'];  % order
        Ver{4,2}='%.1f & $%.2f\\pm%.2f$  & $%.2f\\pm%.2f$ & $%.2f\\pm%.2f$ & $%.2f\\pm%.2f$\n';
        Ver{4,3}='%d  %d  %d   %d  \n';
        Ver{4,4}='%s  %s  %s   %s  \n';

    case 0
        % AV
        Ver=cell(4,7);
        Ver{1,1}=2;  Ver{1,2}=3;    Ver{1,3}=2;    Ver{1,4}=1;     Ver{1,5}=0;          Ver{1,6}=1;          Ver{1,7}=4;            % al mode
        Ver{2,1}=1;  Ver{2,2}=1;    Ver{2,3}=1;    Ver{2,4}=1;     Ver{2,5}=1;          Ver{2,6}=1;          Ver{2,7}=1;            % vl mode
        Ver{3,1}='0';Ver{3,2}='rgb';Ver{3,3}='rgb';Ver{3,4}='rgb'; Ver{3,5}='hsvspatio';Ver{3,6}='hsvspatio';Ver{3,7}='hsvspatio';  
        Order=reshape(2:2*size(Ver,2)+1,[size(Ver,2),2])';
        Ver{4,1}=[1 Order(:)'];  % order
        Ver{4,2}='%.1f& $%.2f\\pm%.2f$& $%.2f\\pm%.2f$ & $%.2f\\pm%.2f$ & $%.2f\\pm%.2f$ & $%.2f\\pm%.2f$ & $%.2f\\pm%.2f$ & $%.2f\\pm%.2f$ \n';
        Ver{4,3}='%d  %d  %d  %d  %d  %d %d \n';
        Ver{4,4}='%s  %s  %s  %s  %s  %s %s  \n';

end


avgMAE_3D=zeros(length(SEQ),size(Ver,1));% three different audio likelihood
avgMAE_2D=zeros(length(SEQ),size(Ver,1));% three different audio likelihood
stdMAE_3D=zeros(length(SEQ),size(Ver,1));
stdMAE_2D=zeros(length(SEQ),size(Ver,1));


for ver=1:size(Ver,2)
    almode=Ver{1,ver};
    vlmode=Ver{2,ver};
    hmode=Ver{3,ver};
%     flag=Ver{4,1};
    
    index=1;
    
    for sq=1:length(SEQ)
        seq=SEQ(sq);
        %             disp(['seq!',num2str(seq),' al',num2str(almode),' vl',num2str(vlmode),' hmode',hmode])
        
        seq_name=['seq',num2str(SEQ(sq),'%02d')];
        [PF,Version,dirRst,dirF]=SavFile_info(flag,vlmode,hmode,almode,dataset,R,0,1,1,seq,Date);

        
        MAE_2D=zeros(1,R);
        MAE_3D=zeros(1,R);
        for iter=1:R  % iteration
            Er2D=0;
            
            fName = ['trackRes_S' num2str(seq,'%02d') 'C5MA0_FBK_face3Dbp_vlm',num2str(vlmode),'_almode',num2str(almode),'_iter',num2str(iter) '.dat'];
            if(~exist(fullfile(Version,PF,fName),'file'))
                disp(['No file! ',num2str(seq),PF,'  ',num2str(almode),' ',num2str(vlmode),' ',hmode,'  ',fName])
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
            %                 disp(['GT on image/Res outside image:  ',num2str(sum(Igtito))])
            
            Er2D = sqrt(sum((GTimg(:,Ibi) - estimg(:,Ibi)).^2));
            Er2D(sum(Ibi)+1:sum(Igtito))=norm(ImgSize);
            MAE_2D(iter)=mean(Er2D);
            
            
        end
        
        %             disp(['seq',num2str(SEQ(sq)),'   Roi=',num2str(Roi)])

        avgMAE_3D(sq,ver)=mean(MAE_3D);
        avgMAE_2D(sq,ver)=mean(MAE_2D);
        
        stdMAE_3D(sq,ver)=std(MAE_3D);
        stdMAE_2D(sq,ver)=std(MAE_2D);
        
        
    end
    
    
end

avgMAE_3D(length(SEQ)+1,:)=mean(avgMAE_3D);
avgMAE_2D(length(SEQ)+1,:)=mean(avgMAE_2D);
stdMAE_3D(length(SEQ)+1,:)=mean(stdMAE_3D);
stdMAE_2D(length(SEQ)+1,:)=mean(stdMAE_2D);

res3D=[[SEQ,0]' avgMAE_3D stdMAE_3D];
res2D=[[SEQ,0]' avgMAE_2D stdMAE_2D];

res3D=res3D(:,Ver{4,1});
res2D=res2D(:,Ver{4,1});

f1 = fopen(fullfile('..','res',dataset,'face3Dbp',Subfolder,['MAE3D_',PF,'comp.dat']),'w');
fprintf(f1, '%s', 'almode   ');
fprintf(f1, Ver{4,3}, Ver{1,:});
fprintf(f1, '%s', 'vlmode   ');
fprintf(f1, Ver{4,3}, Ver{2,:});
fprintf(f1, '%s', 'hmode   ');
fprintf(f1, Ver{4,4}, Ver{3,:});
fprintf(f1, Ver{4,2}, res3D');
fclose(f1);

f1 = fopen(fullfile('..','res',dataset,'face3Dbp',Subfolder,['MAEimg_',PF,'comp.dat']),'w');
fprintf(f1, '%s', 'almode   ');
fprintf(f1, Ver{4,3}, Ver{1,:});
fprintf(f1, '%s', 'vlmode   ');
fprintf(f1, Ver{4,3}, Ver{2,:});
fprintf(f1, '%s', 'hmode   ');
fprintf(f1, Ver{4,4}, Ver{3,:});

fprintf(f1, Ver{4,2}, res2D');
fclose(f1);

end



