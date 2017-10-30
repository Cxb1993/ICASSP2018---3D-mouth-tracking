function Xcart=myParticle_sph2cart(Xsph,OriginCart)
% Description:
% transfer the particles from Spherical coordinates to Cartesian
% coordinates
% Input:
%   Xsph: 3 by N matrix each row corresponds to a Sph coordinate componenets
%   OriginCart: Cartesian position of Spherical coordinates origin point
% Output:
%   Xcart: particle position in Cartesian coordinates
% Attention:
% unit of Spherical coordinates are in (deg,deg,m)


Xcart=zeros(3,size(Xsph,2));

[Xcart(1,:),Xcart(2,:),Xcart(3,:)]=sph2cart(Xsph(1,:)/180*pi,Xsph(2,:)/180*pi,Xsph(3,:));
Xcart(1,:)=Xcart(1,:)+OriginCart(1);
Xcart(2,:)=Xcart(2,:)+OriginCart(2);
Xcart(3,:)=Xcart(3,:)+OriginCart(3);


end