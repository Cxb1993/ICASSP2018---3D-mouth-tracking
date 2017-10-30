% 
% Based on isInFrustrum function within ORB-SLAM2
%
%   - Xw: 3D point in world coordinates
%
% Author: Alessio Xompero
%   Date: 2017/09/02
function s = isInFrustum(Xw, C, viewingCosLimit, Iw, Ih)

s = true;

if size(Xw,1) == 3
  Xw = [Xw; 1];
end

% Convert the 3D points from world to camera coordinates
Xc = C.RT * Xw;

% Check positive depth
if(Xc(3) < 0)
%   disp('Not positive depth')
  s = false;
  return;
end

% Project in image and check it is not outside
Ximg = myproject( Xw, C ); % project mouth position

if(Ximg(1)<0 || Ximg(1)>Iw)
%   disp('Mouth outside FoV')
  s = false;
  return;
end

if(Ximg(2)<0 || Ximg(2)>Ih)
  disp('Mouth outside FoV')
  s = false;
  return;
end

% Check distance is in the scale invariance region of the MapPoint
PO = Xw(1:3) - C.Cam_pos;
dist = norm(PO);

% Check viewing angle
Pn = PO/dist;

viewCos = dot(PO,Pn)/dist;

if(viewCos<viewingCosLimit)
  disp('Not good viewCos')
  viewCos
  s = false;
  return;
end

end
