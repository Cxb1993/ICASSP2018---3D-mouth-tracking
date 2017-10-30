

clear all
close all
clc

dbstop if error
restoredefaultpath

% SEQ=[8,11,12];
% SEQ=[11,13,17,20];
SEQ=8;

AL=6;
% FLAG=0:2;  % 0 av; 1 audio only; 2 video only
FLAG=0;
MP='all';
R=1;
N=100;
p=0;
vlmode=2; % multivariate Gaussian
hmode='hsvspatio';
% hmode='0';
savfig=2;
% dataset='FBK';
dataset='AV16.3';
savRst=1;



MAEavg=zeros(length(SEQ),length(FLAG));
MAEstd=zeros(length(SEQ),length(FLAG));

for cam=2
    for al=1:length(AL)
        almode=AL(al);
        row=1;
        for sq=1:length(SEQ)
            seq=SEQ(sq);
            for f=1:length(FLAG)
                for K=0
                flag=FLAG(f);
                [MAEavg(row,f),MAEstd(row,f),Version,dirRst] =myTracker3D_icassp2018(seq,MP,almode,vlmode,hmode,R,N,flag,p,savfig,savRst,dataset,cam,K);
                row=row+1;
                end
            end
        end
    end
end

MAEavg
MAEstd

% % save results
% res=[MAEavg(:,1),MAEstd(:,1),MAEavg(:,2),MAEstd(:,2)];
% % Comment/Uncomment this
% fName = ['trackRes_S' num2str(seq,'%02d'),'_vl',num2str(vlmode),'_al',num2str(almode), '_FBK_face3Dbp','.dat'];
% f1 = fopen(fullfile(dirRst,fName),'w');
% fprintf(f1, '$%.2f\\pm%.2f$ $%.2f\\pm%.2f$ \n', res');
% fclose(f1);
% disp('Saved!');
%

