function [MAEavg,MAEstd,Version,dirRst,dirF]=myTracker3D_icassp2018(seq,MP,almode,vlmode,hmode,R,N,flag,p,savfig,savRst,dataset,cam,K)

% Description
% 3D object tracking with audio visual
% video: back project face to 3D using prior knowledge of the width
% audio: GCF compuation on video estimated speaker height
% Input:
%   N: number of particles
%   flag:
%   0: audio-visual
%   1: audio-only
%   2: video-only
%   K: randomly remove % of face detection results K=[0,1]
% almode:
%  audio likelihood mode:
% 0: AL = 3D GCF value at particles
% 1: AL = 2D GCF value at particles projected on XY plane with given height (take exponential)
% 2: 3D localisation resutls
% 3: 2D localisation results at specified Zp plane
% 4: when face det-> 3D, no det->2D
% 6: ICASSP (3D GCF) in spherical coordiantes
% vlmode
% 0: use the detection selected by Ground truth ( when there are multiple
% detection  => choose the cloest one to the GT on image plane)

% if(flag==1) % audio only-  we don't  have visual information to use , apply 3D GCF computation
%     almode=0;
% end


disp(['vl',num2str(vlmode),' al',num2str(almode),'  flag',num2str(flag),' sq',num2str(seq),hmode])
class(vlmode)
class(almode)
class(flag)
class(seq)
class(hmode)

disp('switch dataset start')
switch dataset
    case 'FBK'
        addpath(genpath(fullfile('..', '..',  '..',  '..','Data','FBK_CHIL')));
    case 'AV16.3'
        addpath(genpath(fullfile('..', '..', '..',  '..', 'Data','AV163')));
    otherwise
        disp('error in dataset name')
end
disp('switch dataset finish')

addpath(genpath(fullfile('..', '..',  '..','src')));
addpath(genpath(fullfile('..', '..',  '..','evaluation','VisualFeatures','spatiogram')));
addpath(genpath(fullfile('..', '..', '..','..','Results','FaceBB_MXnet')));
fbb3Dbp=1;

[camData,seq_name,fmt,RoomRg,T,Face3DSz,ma,cam,fv,nfft,fa,AMvad,Upstd,gammaG,Q,c,Mic_pos,Mic_c,ImgSize]=readParas(seq,dataset,cam);
Wdiag=0.14;

% prediction matrix
Pmtx=eye(3);

if(vlmode==2) % Video likelihood in Sph coordinates
    Upstd=[2;2;0.4];
end

if(nargin<=13)
    K=0; % use original faceBB
    Kstr='';
    disp('Original face BB')
else
    Kstr=['K',num2str(K)];
    disp(['Remove ',num2str(K),' FBB'])
end


[PF,Version,dirRst,dirF]=SavFile_info(flag,vlmode,hmode,almode,dataset,R,savfig,savRst,fbb3Dbp,seq,[]);
Prestd=[1;1;0.5]/fv;  % standard deviation in prediction

if(flag==1&&almode==1) % audio only and 2D GCF
    Prestd(3)=0;  % standard deviation in prediction
    disp('Only do 2D GCF tracking')
end

Mic_pair=my_Mic_pair(MP);


%  audio-visual synchronisation
disp('AV-sync...')
[GTimg, GT3d, Afr, Vfr] = myAVsync_AV163(seq_name, cam, fv, nfft, fa,dataset);
Results = extractGCF3Dres(seq_name, ma, gammaG, Q,dataset);
SSL=Results.SSLcart(2:4,Afr(1):Afr(2));
SSL(4,:)=Results.AM_max(Afr(1):Afr(2))>=AMvad;
CM=Results.CM;
X_g=Results.par.X_g;
Y_g=Results.par.Y_g;
if(strcmp(dataset,'FBK'))
    vadgt=FBK_VADextraction(seq_name,ma,Results,Afr);  % VAD ground truth
else
    vadgt=zeros(length(GT3d),1);
end

clear Results
disp('Finish AV sync')

if(p||savfig)
    s = get(0, 'ScreenSize');
    PrtImg = figure('Position', [0 0 s(3) s(4)]);
end

if(savfig||savRst)
    save(fullfile(dirRst,'..',['Paras_',PF,Kstr,'.mat']),'almode','vlmode','hmode','dataset','AMvad','Prestd','Upstd','Face3DSz','Pmtx','Wdiag','K')
end

%% PF framework
i0=1; %starting point
MAE=zeros(1,R);
MAEstd=zeros(1,R);
Fr=length(GT3d);

for iter=1:R
    
    if(vlmode==0)&& (strcmp(dataset,'FBK')) % video results selected by GT
        load([seq_name,'_AVSSL_fixZ_',MP])
        fd=mouth3D(1,:)>0;  % face detection
        mouthImg=myproject([mouth3D;ones(1,length(fd))], camData);
        mouthImg(3,:)=[];
        detN=[];
    else
        switch dataset
            case 'FBK'
                [FBB,detN,~,mouthImg,mouth3D]=readMXNetData(seq,Vfr,camData,Wdiag,cam,flag~=1);
                [FBB,detN,mouthImg,mouth3D]=removFBB(FBB,detN,mouthImg,mouth3D,K);
                fd=detN>0;
                mouthiIsize=size(mouthImg,1);
                Zp=1.5;
            case 'AV16.3'
                [FBB,detN,~,mouthImg,mouth3D]=readMXNetData(seq,Vfr,camData,Wdiag,cam,flag~=1);
                [FBB,detN,mouthImg,mouth3D]=removFBB(FBB,detN,mouthImg,mouth3D,K);
                fd=detN>0;
                mouthiIsize=size(mouthImg,1);
                Zp=0.8;
                
        end
    end
    
    % initialisation
    disp('Initilisation.....')
    X=GT3d(i0,:)'*ones(1,N)+randn(3,N).*(Prestd*ones(1,N));  % particles in Cartesian coordiantes
    Xest=zeros(3,length(GT3d)); % our estimation
    Xest_Img=zeros(2,length(GT3d));
    SSLc=zeros(3,length(GT3d));
    er=zeros(1,length(GT3d));
    mae=zeros(1,length(GT3d));
    vad=false(size(vadgt));
    FoV=zeros(1,Fr);
    RefImg=[];
    Hr=[];
    
    for i=i0:Fr
 
        disp(['===',Kstr,'===',seq_name,'  cam',num2str(cam),'  ',num2str(i),'/',num2str(length(GT3d)),...
            '  flag',num2str(flag),'  almode',num2str(almode),...
            '  vlmode',num2str(vlmode),'  hmode ',hmode])
        
        if(flag~=1) % use video
            [mouthImg(:,i),mouth3D(:,i),FBB(i,:),detN(i),fd(i)]=myFBBvalidation(Xest_Img,mouthImg,i,i0,detN,mouth3D,FBB,fd);
        end
        
        % video likelihood
        [wv,Zp,fdstr,Vmap,Hr,RefImg]=myVL(X,detN(i),mouth3D,fd,i,Zp,vlmode,hmode,X_g,Y_g,Upstd,FBB,seq_name,Vfr,Hr,Xest,Face3DSz,camData,RefImg,FoV(i),flag,Xest_Img,mouthImg,fmt);
        
        % audio likelhood
        [wa,~,~,Amap,vad(i),SSLc(:,i),Za]=myAL(X,CM,Mic_pair,Mic_pos,c,fa,i,Afr,Zp,almode,p||savfig,X_g,Y_g,AMvad,flag,SSL,Upstd,detN(i));
        
        wa(wa<0)=0;
        wa=wa.^2;
        % update
        w=wa.*wv;
        w(w<0)=0;
        w=w./sum(w);
        
        if(isnan(sum(w)))||(~sum(w))
            w=1/N*ones(1,N);
            disp('particle weights not valid: set to equal weights......')
        end
        
        
        Xest(:,i)=X(1:3,:)*w';     % est 3D
        ImgEst=myproject([Xest(:,i);1], camData);
        Xest_Img(:,i)=ImgEst(1:2); % est Img
        
        er(i)=norm(Xest(:,i)-GT3d(i,:)');
        mae(i)=mean(er(i0:i));
        
        %% display the results
        if p || (savfig==1) || (savfig==2&&i==Fr)
            
            Y_k = imread(fullfile(seq_name,fmt{1}, [fmt{2} num2str(i+Vfr(1)-1,fmt{3}) fmt{4}]));
            
            % image plane
            subplot(2,2,1)
            if(vlmode~=0)
                fbb=reshape(FBB(i,~isnan(FBB(i,:))),[4,sum(~isnan(FBB(i,:)))/4])';  % face bounding box for current frame
                Y_k=insertObjectAnnotation(Y_k,'rectangle',fbb,'face');
            end
            imshow(Y_k)
            hold on
            if(flag~=2)&&(fd(i))
                plot(mouthImg(1:2:mouthiIsize,i),mouthImg(2:2:mouthiIsize,i),'y+','LineWidth',2,'MarkerSize',5)
            end
            plot(Xest_Img(1,i),Xest_Img(2,i),'r+','LineWidth',2,'MarkerSize',10)
            plot(GTimg(i,1),GTimg(i,2),'g+','LineWidth',2,'MarkerSize',5)
            if(vadgt(i))
                title([seq_name,'   ',num2str(i),'/',num2str(length(GT3d)),'  vad=',num2str(vad(i)),' ',fdstr],'Color','m')
            else
                title([seq_name,'   ',num2str(i),'/',num2str(length(GT3d)),'  vad=',num2str(vad(i)),' ',fdstr])
            end
            
            % Audio map
            subplot(3,6,13)
            imagesc(X_g,Y_g,Amap)
            hold on
            plot(Mic_pos(:,1),Mic_pos(:,2),'bo-')  % microphone position
            plot(camData.Cam_pos(1),camData.Cam_pos(2),'b*','MarkerSize',15)  % microphone position
            
            plot(GT3d(i,1),GT3d(i,2),'g*','LineWidth',2,'MarkerSize',5)
            plot(T(:,1),T(:,2),'-k');
            set(gca,'Xdir','reverse')
            daspect([1 1 1])
            title({['A map H=',num2str(Za),' m']})
            ylabel('Y (m)')
            
            % Video map
            subplot(3,6,14)
            if(isempty(Vmap))
                imshow(RefImg)
                title('Ref face image for Hist compute')
            else
                imagesc(X_g,Y_g,Vmap)
                hold on
                plot(Mic_pos(:,1),Mic_pos(:,2),'bo-')  % microphone position
                plot(camData.Cam_pos(1),camData.Cam_pos(2),'b*','MarkerSize',15)  % microphone position
                plot(T(:,1),T(:,2),'-k');
                plot(GT3d(i,1),GT3d(i,2),'g*','LineWidth',2,'MarkerSize',5)
                set(gca,'Xdir','reverse')
                daspect([1 1 1])
                title(['V map ',fdstr])
            end
            
            % 3D
            subplot(3,6,15)  % overall tracking results on XY plane
            if(~isempty(Vmap))
                AVmap=Amap.*Vmap;
            else
                AVmap=Amap;
            end
            imagesc(X_g,Y_g,AVmap)
            hold on
            plot(X(1,:),X(2,:),'k.')
            %             plot(mouth3D(1,i),mouth3D(2,i),'Y*','LineWidth',2,'MarkerSize',5)
            plot(GT3d(1:i,1),GT3d(1:i,2),'g-')
            plot(GT3d(i,1),GT3d(i,2),'g*','LineWidth',2,'MarkerSize',5)
            plot(Mic_pos(:,1),Mic_pos(:,2),'bo-')  % microphone position
            plot(T(:,1),T(:,2),'-k');
            plot(Xest(1,1:i),Xest(2,1:i),'r-')
            plot(Xest(1,i),Xest(2,i),'r+','LineWidth',2,'MarkerSize',10)
            title(['3D error=',num2str(er(i),'%.2f')])
            xlim(RoomRg(1,:))
            ylim(RoomRg(2,:))
            grid on
            xlabel('X (m)')
            set(gca,'Ydir','reverse','Xdir','reverse')
            daspect([1 1 1])
            
            % plot error in individual XYZ plane
            subplot(4,2,2)  % x
            hold on
            grid on
            plot(1:i,Xest(1,1:i),'r.-')
            plot(1:i,GT3d(1:i,1),'g.-')
            %             xlabel('frames')
            ylabel('X position')
            title(['X error (t)=',num2str(Xest(1,i)-GT3d(i,1),'%.02f')])
            ylim(RoomRg(1,:))
            xlim([1 length(GT3d)])
            
            subplot(4,2,4)  % y
            hold on
            grid on
            plot(1:i,Xest(2,1:i),'r.-')
            plot(1:i,GT3d(1:i,2),'g.-')
            %             xlabel('frames')
            ylabel('Y position')
            title(['Y error (t)=',num2str(Xest(2,i)-GT3d(i,2),'%.02f')])
            ylim(RoomRg(2,:))
            xlim([1 length(GT3d)])
            
            subplot(4,2,6)  % z
            hold on
            grid on
            plot(1:i,Xest(3,1:i),'r.-')
            plot(1:i,GT3d(1:i,3),'g.-')
            %             xlabel('frames')
            ylabel('Z position')
            title(['Z error (t)=',num2str(Xest(3,i)-GT3d(i,3),'%.02f')])
            ylim([0 2.5])
            xlim([1 length(GT3d)])
            
            
            subplot(4,2,8)  % overall error
            hold on
            grid on
            plot(1:i,er(1:i),'b.-')
            plot(1:i,mae(1:i),'k.-')
            %             plot(find(vad(1:i)==1),zeros(1,sum(vad(1:i))),'m.-')
            %             plot(find(aFoV(1:i)==1),2*ones(1,sum(aFoV(1:i))),'b.-')
            legend('error','MAE')
            xlabel('frames')
            ylabel('overall error')
            title(['er3D (t)=',num2str(mean(er(i)),'%.02f'),'  (MAE3D=',num2str(mean(er(i0:i)),'%.02f'),' std=',num2str(std(er(i0:i)),'%.02f'),')'])
            ylim([0 2])
            xlim([1 length(GT3d)])
            
            % particle weights
            subplot(6,6,19)
            plot(1:N,wa,'m.-')
            xlim([1 N])
            grid on
            title(['\omega_{a}: max=',num2str(max(wa),'%.3f')])
            
            subplot(6,6,20)
            plot(1:N,wv,'y.-')
            xlim([1 N])
            grid on
            title(['\omega_{v}: max=',num2str(max(wv),'%.3f')])
            
            subplot(6,6,21)
            plot(1:N,w,'r.-')
            xlim([1 N])
            grid on
            title(['\omega: max=',num2str(max(w),'%.3f')])
            
            
            if (savfig==1&&iter==R) || (savfig==2&&i==Fr)
                saveas(gcf,fullfile(dirF,[seq_name,'_ma',num2str(ma),'_cam',num2str(cam),'_',PF,'_al',num2str(almode),'_vl',num2str(vlmode),'_fr',num2str(i,'%04d'),Kstr,'_R',num2str(iter),'.png']))
            else
                pause(0.0001)
            end
            figure(PrtImg)
            clf
            
        end
        
        %%
        
        % resampling
        Xw=myPtl_killRoomRg(X,Mic_c,RoomRg,'cart');
        w(logical(~Xw))=0;  % kill the particles outside the room
        C = cumsum(w);   % calculate cumulative sum of elements
        T = rand(1, N); % generate 1 by N uniformly distributed random numbers between (0,1)
        [~, I] = histc(T, C); % histogram count
        X = X(:, I + 1);
        w=w(I+1);
        
        %  perdiction
        FoV(i+1)=myFoV_sel(Xest,i,Mic_c,Xest_Img,ImgSize,camData);
        Pstd=Prestd;

        [~,idx]=sort(w,'descend');
        Nsp=N*0.9;
        X(:,idx(1:Nsp))=Pmtx*X(:,idx(1:Nsp))+Pstd*ones(1,Nsp).*randn(3,Nsp);
        X(:,idx(Nsp+1:end))=Pmtx*X(:,idx(Nsp+1:end))+3*Pstd*ones(1,N-Nsp).*randn(3,N-Nsp);  % 10% particles with heigher speed

        
        disp(['Flag',num2str(flag),'  R',num2str(iter),'  AL=',num2str(wa(1)),'    VL=',num2str(wv(1)),'(',fdstr,')    AVL=',num2str(w(1)),'     mae=',num2str(er(i),'%.3f'),'  MAE3d=',num2str(mean(er(i0:i)),'%.3f')])
        
    end
    MAE(iter)=mean(er(i0:end));
    MAEstd(iter)=std(er(i0:end));
    disp([seq_name,'-iter',num2str(iter),'  flag=',num2str(flag),'  almode=',num2str(almode),'  MAE3d error=',num2str(MAE(iter),'%.3f'),'  MAEstd=',num2str(MAEstd(iter),'%.3f')])
    
    if(savRst)
        % saving results
        res = [(Vfr(1):Vfr(2))', GT3d, Xest', vad,GTimg,vadgt,FoV(1:Fr)'];
        fName = ['trackRes_S' num2str(seq,'%02d') 'C' num2str(cam) 'MA' num2str(ma) '_FBK_face3Dbp_vlm',num2str(vlmode),'_almode',num2str(almode),Kstr,'_iter',num2str(iter) '.dat'];
        f1 = fopen(fullfile(dirRst,fName),'w');
        fprintf(f1, '%d %.3f %.3f %.3f %.3f %.3f %.3f %d %.3f %.3f %d %d\n', res');
        fclose(f1);
        disp('Saved!');
    end
end

% pause
MAEavg=mean(MAE);
MAEstd=mean(MAEstd);
disp([seq_name,'   Finish all iterations!  MAE=',num2str(MAE)])
disp([seq_name,'  flag=',num2str(flag),'  almode=',num2str(almode),'   Average er=',num2str(MAEavg),'   std=',num2str(MAEstd)])
close all
end