function Xsph=myParticle_cart2sph(Xcart,OriginSph_Cart)
% Description:
% transfer the particles from Cartesian coordinates to Spherical coordinates
% Input:
%   Xcart: particle position in Cartesian coordinates
%   OriginSph_Cart: Cartesian position of Spherical coordinates origin point
% Output:
%   Xsph: 3 by N matrix each row corresponds to a Sph coordinate componenets
%
% Attention:
% unit of Spherical coordinates are in (deg,deg,m)

Xsph=zeros(size(Xcart));

[Xsph(1,:),Xsph(2,:),Xsph(3,:)]=cart2sph(Xcart(1,:)-OriginSph_Cart(1),Xcart(2,:)-OriginSph_Cart(2),Xcart(3,:)-OriginSph_Cart(3));
Xsph(1,:)=Xsph(1,:)/pi*180;
Xsph(2,:)=Xsph(2,:)/pi*180;

end