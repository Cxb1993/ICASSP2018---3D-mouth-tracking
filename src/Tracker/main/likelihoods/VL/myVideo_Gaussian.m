function wv=myVideo_Gaussian(Xcart,mouth,Upstd,crd,Cam_c)
% from multiple mouth detections
% Date: 28/09/2017
% Author: XQ
% Input:
%   detN: detection number
%   i: frame index
%   X: 3 by N ptls in Cart coord
% crd: 'cart'/'sph'
% Cam_c: camera center position

N=size(Xcart,2);

if(nargin<5)
    crd='cart';
end

if(strcmp(crd,'sph')) % if likelihood compute in Spherical coordiantes
    X=myParticle_cart2sph(Xcart,Cam_c);
    mouth=myParticle_cart2sph(mouth,Cam_c);
    Ver=X-mouth*ones(1,N);  % error square
    wv=exp(-(Ver.^2)/2./(Upstd.^2*ones(1,N)));
    wv=prod(wv);
else
    X=Xcart;
    Ver=sqrt(sum((X- mouth*ones(1,N)).^2));
    wv=exp(-(Ver.^2)/(2*Upstd^2));
end


end