function [wa,AM,AMmax,Amap,vad,sslc,Za]=myAL(X,CM,Mic_pair,Mic_pos,c,fa,i,Afr,Zp,almode,p,X_g,Y_g,AMvad,flag,SSL,Upstd,detN)
% Description:
% compute audio likelihood
% vad: voice activity detection results
% detN:
%   video detection number

Mic_c=mean(Mic_pos);
X=X(1:3,:); % only use position

N=size(X,2);
afr=i+Afr(1)-1;
Za=[];

wa=ones(1,N);
AM=0;
AMmax=0;

if(flag==2) % only use video information
    Amap=ones(length(Y_g),length(X_g));
    vad=false;
    sslc=NaN*ones(3,1);
    return
end

if(almode==4) % when det-> 3D, no det->2D
    if(detN)
        almode=0;
    else
        almode=1;
    end
end

if(almode==5)
    if(detN)
        almode=0;
    else
        almode=3;
    end
end

if(almode==6)  % ICASSP (3D GCF) in spherical coordiantes
    almode=2;
    crd='sph';
else
    crd='cart';
end

switch almode
    case 0 % 3D GCF
        disp('Audio Likelihood: 3D GCF! ')
        AM=myAL_GCF(X,CM,afr,Mic_pair,Mic_pos,c,fa);
        vad=max(AM(:))>=AMvad;
        if(vad)
            wa=AM;
            sslc=SSL(1:3,i);
        end
    case 1 % GCF at given Z plane
        disp(['Audio Likelihood: GCF at estimated XY plane   Zp=',num2str(Zp),' m'])
        Xz=X; % particles projected on XY plane
        [~,z]=min(abs(ones(length(Zp),1)*X(3,:)-Zp'*ones(1,N)),[],1);
        Xz(3,:)=Zp(z);
        AM=myAL_GCF(Xz,CM,afr,Mic_pair,Mic_pos,c,fa);
        vad=max(AM(:))>=AMvad;
        
        if(vad)
            wa=AM;
            [~,z]=min(abs(Zp-mean(X(3,:))));
            GridZ=CreateGrid_GTZ(Zp(z),X_g,Y_g);  % create audio grid
            am=myAL_GCF(GridZ,CM,afr,Mic_pair,Mic_pos,c,fa);
            sslc=mean(GridZ(:,am==max(am)),2);
        end
        
    case 2 % 3D localisation resutls
        vad=SSL(4,i);
        if(vad)
            disp('3D GCF localisation rst!')
            sslc=SSL(1:3,i);
            if(strcmp(crd,'sph'))  % ICASSP audio likelihood
                Xsph=myParticle_cart2sph(X,Mic_c);
                sslsph=myParticle_cart2sph(sslc,Mic_c);
                Ver=Xsph-sslsph*ones(1,N);  % error square
                wa=prod(exp(-(Ver.^2)/2./(Upstd.^2*ones(1,N))));
            else
                Ver=sqrt(sum((X- sslc*ones(1,N)).^2));
                wa=exp(-(Ver.^2)/(2*Upstd^2));
            end
            
            AM=wa;
        else
            AM=0;
        end
    case 3 % 2D localisation results
        disp('2D GCF localisation rst!')
        am=zeros(length(Zp),length(X_g)*length(Y_g));
        for z=1:length(Zp)
            GridZ=CreateGrid_GTZ(Zp(z),X_g,Y_g);  % create audio grid
            am(z,:)=myAL_GCF(GridZ,CM,afr,Mic_pair,Mic_pos,c,fa);
        end
        [~,z]=max(max(am,[],2));
        AM=am(z,:);
        vad=max(AM(:))>=AMvad;
        
        if(vad)
            sslc=mean(GridZ(:,AM==max(AM)),2);
            Ver=sqrt(sum((X- sslc*ones(1,N)).^2));
            wa=exp(-(Ver.^2)/(2*Upstd^2));
        end
          
end
AMmax=max(AM(:));

% VAD
if(~vad)
    sslc=NaN*ones(3,1);
    wa=ones(1,N);
end

%% Display
if(p&&vad)
    if(length(Zp)>1)
        [~,z]=min(abs(Zp-mean(X(3,:))));
        Za=Zp(z);
    else
        Za=Zp;
    end
    GridZ=CreateGrid_GTZ(Za,X_g,Y_g);  % create audio grid
    
    switch almode
        case {2,3}  % 2D/ 3D GCF localisation
            if(strcmp(crd,'sph'))
                GridZsph=myParticle_cart2sph(GridZ,Mic_c);
                Ver=GridZsph-sslsph*ones(1,length(GridZsph));  % error square
                am=prod(exp(-(Ver.^2)/2./(Upstd.^2*ones(1,length(GridZsph)))));
            else
                Ver=sqrt(sum((GridZ- sslc*ones(1,length(GridZ))).^2));
                am=exp(-(Ver.^2)/(2*Upstd^2));
            end
            
        otherwise
            am=myAL_GCF(GridZ,CM,afr,Mic_pair,Mic_pos,c,fa);
    end
    Amap=reshape(am,[length(Y_g) length(X_g)]);
    
else
    Amap=ones(length(Y_g),length(X_g));
end


end