function Xw=myPtl_killRoomRg(X,Mic_c,RoomRg,mode)
% Description:
%   kill the partiles outside the room range
% Date: 14/07/2017
% Author: XQ
% Input:
%   X: 3 by N particles
%   crd: 'sph' or 'cart'
%   RoomRg: room range [X;Y;Z]
% Output:
%   Xw: binary index whether the particles are INSIDE the room or not
% 
% if(strcmp(crd,'sph'))
%     Xcart=myParticle_sph2cart(X,Mic_c);
% else
%     if(~strcmp(crd,'cart'))
%         disp('specify particle coordinates')
%     end
% end

% particles inside room range
% x1=(Xcart(1,:)>=RoomRg(1,1))&(Xcart(1,:)<=RoomRg(1,2));
% x2=(Xcart(2,:)>=RoomRg(2,1))&(Xcart(2,:)<=RoomRg(2,2));
% x3=(Xcart(3,:)>=RoomRg(3,1))&(Xcart(3,:)<=RoomRg(3,2));

% Xw=x1.*x2.*x3;
% display(['Particles inside room:',num2str(sum(Xw))])
X=X(1:3,:); % only consider position


if(nargin<4)
   mode='sph' ;
end

if(strcmp(mode,'sph'))
X = myParticle_sph2cart(X, Mic_c);
end

Xw = prod((X >= repmat(RoomRg(:,1),1,length(X))) & (X <= repmat(RoomRg(:,2),1,length(X))));
end
