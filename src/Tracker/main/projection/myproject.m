%
% p3d: 4xN points in 3D (homogenoeus coordinates) -> [X, Y, Z, 1]'
%
% C: camera data structure
%   - f: nominal focal length
%   - m: pixels/mm (m_x, m_y)
%   - pp: principal point, (p_x,p_y)
%   - K: camera calibration matrix
%   - RT: roto-translation from world to camera coordinates
%   - kc: distortion parameters (Tsai model), [k1,k2,k3,p1,p1]

function p2d = myproject(p3d, C)

mode = C.dataset;

switch mode
  case 'AV16.3'
    p2d = projectionAV163(p3d, C);
  case 'FBK'
    p2d = projectionCHIL(p3d, C);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROJECTIONCHIL()
%
%
% Author: Francesco Tobia, FBK-TeV
%   Date:
%
% Author: Alessio Xompero, QMUL/FBK-TeV
%   Date: 2017/08/01
%
function p2d = projectionCHIL(p3d, C)

f = C.f;
mu = C.m(1);
mv = C.m(2);
cx = C.pp(1);
cy = C.pp(2);

K = C.K;
RT = C.RT;
kc = C.kc;

N = size(p3d,2);

% 2. projection
P = K * RT; % Projection matrix, P = K [R|T]

p2d = zeros(3, N);
for n=1:N
  v = P * p3d(:,n);
  
  v = v / v(3);
  
  % 3. distortion (Tsai)
  fx = f * mu;
  fy = f * mv;
  
  dx = (v(1) - cx) / fx;
  dy = (v(2) - cy) / fy;
  dx2 = dx * dx;
  dy2 = dy * dy;
  dxdy = dx * dy;
  r2 = dx2 + dy2;
  
  x = dx * (1 + r2 * (kc(1) +r2 * (kc(2) + r2 * kc(3))));
  y = dy * (1 + r2 * (kc(1) +r2 * (kc(2) + r2 * kc(3))));
  
  x = x + 2 * kc(4) * dxdy + kc(5) * (r2 + 2*dx2);
  y = y + 2 * kc(5) * dxdy + kc(4) * (r2 + 2*dy2);
  
  d = [cx cy]' + [fx *x, fy*y]';
  
  % 4. output
%   disp(['(x,y) = ' num2str(d(1)) ',' num2str(d(2))]);
  
  p2d(:,n) = [d(1) d(2) 1];
end
end
