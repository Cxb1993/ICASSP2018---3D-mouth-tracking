% Description:
% display the Audio-only, Video-only and Audiovisual trajectories
% Date:: 18/10/2017
% Author: XQ


clear all
close all
clc


dbstop if error
restoredefaultpath
disp('Restore default paths')

addpath(genpath(fullfile('..','..','src')))
addpath(genpath(fullfile('..','..','..','Data')))
addpath(genpath(fullfile('..','..','res','FBK','face3Dbp')));

% SEQ=[11,13,17,20];
SEQ=13;
% fig4='MAEt'; % MAE until current frame t
fig4='ERt'; % error at frame t

load('MA0_pos'); % mic pos
Mic_pos=Mic_pos';
load('C5.mat'); % camera pos
camData.dataset='FBK';
camData.Cam_pos=-camData.R'*camData.T;
T=load('table.txt'); % table
load('FBK_RoomRg'); % room range


% parameters
fbb3Dbp=1;
savfig=0;
savRst=1;
vlmode=2;
hmode='hsvspatio';
dataset='FBK';
R=10;
Date='25';

figure('Position', [200 200 300 400]);

for seq=13
    
    clear Rst
    
    for av=1:3 % initialise zero trajectory
        res3D{av}=0;
        MAE3D{av}=0;
    end
    
    for iter=1:R  % iteration
        
        % smoothed trajectory
        for flag=0:2
            switch flag
                case 0 % av
                    almode=4;
                case 1 % a
                    almode=1;
                case 2 % v
                    almode=4;
            end
            
            [PF,Version,dirRst,dirF]=SavFile_info(flag,vlmode,hmode,almode,dataset,R,savfig,savRst,fbb3Dbp,seq,Date);
            
            % read files
            fName = ['trackRes_S' num2str(seq,'%02d') 'C5MA0_FBK_face3Dbp_vlm',num2str(vlmode),'_almode',num2str(almode),'_iter',num2str(iter) '.dat'];
            if(~exist(fullfile(Version,PF,fName),'file'))
                disp(['No file! ',num2str(seq),PF,'  ',num2str(almode),' ',num2str(vlmode),' ',hmode,'  ',fName])
                continue
            end
            Rst= dlmread(fullfile(Version,PF,fName));
            GT3d=Rst(:,2:4);
            
            res3D{flag+1}=res3D{flag+1}+Rst(:,5:7)';
            if(iter==R)
                res3D{flag+1}=res3D{flag+1}/R;
                disp(['Taking average of ',num2str(R),' iterations'])
            end
        end
    end
    
    for av=1:3
        er{av}=zeros(1,length(GT3d));
        for fr=1:length(GT3d) % MAE over time
            er{av}(fr)=norm(GT3d(fr,:)-res3D{av}(:,fr)');
            MAE3D{av}(fr)=mean(er{av}(1:fr));
        end
    end
    
    % display
    subplot(2,2,1)
    hold on
    plot(1:length(GT3d),res3D{1}(1,:),'r','LineWidth',1.5)  % AVtracking results
    plot(1:length(GT3d),GT3d(:,1),'g','LineWidth',1.5)  % GT
    grid on
    ylabel('X pos (m)','fontsize', 11)
    ylim(RoomRg(1,:))
    xlim([1 length(GT3d)])
    %     title(['seq',num2str(seq),'  XYZ pos & MAE_{1:t} in 3D'])
    
    subplot(2,2,2)
    hold on
    plot(1:length(GT3d),res3D{1}(2,:),'r','LineWidth',1.5)  % AVtracking results
    plot(1:length(GT3d),GT3d(:,2),'g','LineWidth',1.5)  % GT
    grid on
    ylabel('Y pos (m)','fontsize', 11)
    ylim(RoomRg(2,:))
    xlim([1 length(GT3d)])
    
    subplot(2,2,3)
    hold on
    plot(1:length(GT3d),res3D{1}(3,:),'r','LineWidth',1.5)  % AVtracking results
    plot(1:length(GT3d),GT3d(:,3),'g','LineWidth',1.5)  % GT
    grid on
    ylabel('Z pos (m)','fontsize', 11)
    legend('AV','reference')
    ylim([0.5 2.5])
    xlim([1 length(GT3d)])
    xlabel('Frames')
    
    subplot(2,2,4)
    hold on
    grid on
    
    switch fig4
        case 'MAEt'
            plot(1:length(GT3d),MAE3D{2},'b','LineWidth',1.5)  %A
            plot(1:length(GT3d),MAE3D{3},'k','LineWidth',1.5)  %V
            plot(1:length(GT3d),MAE3D{1},'r','LineWidth',1.5)  %av
            legend({'AO','VO','AV'},'location','best')
            ylabel('MAE 3D','fontsize', 11)
            xlabel('Frames','fontsize', 11)
            ylim([0 1.7])
            %     ylim([0 max([MAE3D{1},MAE3D{2},MAE3D{3}])])
        case 'ERt'
            
            plot(er{2},'b','LineWidth',1)
            plot(er{3},'k','LineWidth',1)
            plot(er{1},'r','LineWidth',1)
%             legend({'AO','VO','AV'},'location','best','FontSize', 6)
            legend({'AO','VO','AV'},'location','best')

            ylabel('AE 3D (m)','fontsize', 11)
            xlabel('Frames','fontsize', 11)
            ylim([0 3.4])
            
    end
    xlim([1 length(GT3d)])
    
    %     set(gca,'fontsize', 11);
    saveas(gcf,['D:\FBK_Trento\doc\ICASSP2018\figures\FBK_seq',num2str(seq),'_XYZpos',fig4,'.png'])
    
    pause(0.1)
    clf
    
    
end
