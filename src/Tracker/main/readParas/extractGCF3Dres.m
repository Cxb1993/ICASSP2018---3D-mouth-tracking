function Results=extractGCF3Dres(seq_name,ma,gammaG,Q,dataset)
% Description:
% extract the GCF 3D sound source localisation results and save them
% Date: 13/07/2017
% Author: XQ
% Input:
%   gammaG: adaptive standard deviation parameters
%   Q: quantile vector in individual spherical coordinates
disp('extract GCF 3Dres')

switch dataset
    case 'AV16.3'
        load(fullfile(seq_name,['GCFSSL_MA',num2str(ma),'_all_whole'])) 
    case 'FBK'
%         3D GCF in the overall room space
%         load(fullfile(seq_name,['GCFSSL_MA',num2str(ma),'_nfft32768'])) %
%         3D GCF with smaller Z height
         load(fullfile(seq_name,['GCFSSL_MA',num2str(ma),'_nfft32768_Z2']))% 3D GCF SSL

end

ind=find(Results.GammaG==gammaG);
Results.gammaG=Results.GammaG(ind);
Results.SSLcartStd=Results.SSLcartStd{ind};
Results.SSLsphStd=Results.SSLsphStd{ind};

Quant=Results.Quant;

if(Q(1)<2)
    Q1=find(Quant==Q(1));
    Results.SSLsph(2,:)=Results.SSLsphQuant.Th(Q1,:);
    Results.SSLcart(2,:)=Results.SSLcartQuant.X(Q1,:);
end

if(Q(2)<2)
    Q2=find(Quant==Q(2));
    Results.SSLsph(3,:)=Results.SSLsphQuant.Phi(Q2,:);
    Results.SSLcart(3,:)=Results.SSLcartQuant.Y(Q2,:);
end

if(Q(3)<2)
    Q3=find(Quant==Q(3));
    Results.SSLsph(4,:)=Results.SSLsphQuant.R(Q3,:);
    Results.SSLcart(4,:)=Results.SSLcartQuant.Z(Q3,:);
end

disp('finish extract GCF 3Dres')

end


