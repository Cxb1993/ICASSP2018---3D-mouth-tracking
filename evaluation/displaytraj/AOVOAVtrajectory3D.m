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

SEQ=[11,13,17,20];


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

almode=4;
vlmode=2;
hmode='hsvspatio';
dataset='FBK';
R=9;
Date=[];


figure

for seq=[11 13 17 20]
    
    clear Rst
    
    for av=1:3 % initialise zero trajectory
        res3D{av}=0;
        res2D{av}=0;
    end
    
    for iter=1:R  % iteration
        
        
        % smoothed trajectory
        for flag=0
            
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
    
    hold on
    plot3(res3D{1}(1,:),res3D{1}(2,:),res3D{1}(3,:),'r-','LineWidth',1.5)  % av
    plot3(GT3d(:,1),GT3d(:,2),GT3d(:,3),'g-','LineWidth',1)  % GT 3d
    %     plot3(res3D{2}(1,:),res3D{2}(2,:),res3D{2}(3,:),'m-')  % a
    %     plot3(res3D{3}(1,:),res3D{3}(2,:),res3D{3}(3,:),'y-')  % v
    plotCamera('Location', camData.Cam_pos, 'Orientation', camData.R, 'Size',0.15,'Color','b')
    plot3(Mic_pos(:,1),Mic_pos(:,2),Mic_pos(:,3),'bo-','LineWidth',1)  % microphone position
    plot3(T(:,1),T(:,2),T(:,3),'-k','LineWidth',1);
    
    
    grid on
    xlim([RoomRg(1,1) RoomRg(1,2)])
    ylim([RoomRg(2,1) RoomRg(2,2)])
    zlim([0 2.5])
    daspect([1 1 1])
    xlabel('X (m)')
    ylabel('Y (m)')
    zlabel('Z (m)')
    view([1 2.5 1.3])
    
    %     set(gca,'Xdir','reverse')
    %     set(gca,'Ydir','reverse')
    title(['seq',num2str(seq),'  AVtrack vs. refGT'])
    set(gca,'fontsize', 13);
    
    %     legend('AVtrack','refGT','Mics','Cam','Table','Location','best','fontsize', 13)
    saveas(gcf,['D:\FBK_Trento\doc\ICASSP2018\figures\FBK_seq',num2str(seq),'_AVtrack.png'])
    
    pause(0.1)
    clf
    
    
end
