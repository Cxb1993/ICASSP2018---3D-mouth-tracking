% MYBACKPROJECTION back-projects an image point into the 3D world using the
% scale factor prior.
%
% Parameters:
%   - p2d: image point
%   - s: scale factor:
%   - C: intrinsic and extrinsic camera parameters
%
% Output:
%   - p3d: back-projected 3D point
%
% Author: Alessio Xompero
%   Date: 2017/08/22
%
function p3d = myBackProjection(p2d, s, C)

% Get camera paramters from camData to use in the MATLAB built-in function 
% undistorPoints 
field1 = 'IntrinsicMatrix';     value1 = C.K';
field5 = 'RadialDistortion';    value5 = C.kc(1:3);
field6 = 'TangentialDistortion';value6 = C.kc(4:5);
cameraParams = cameraParameters(field1,value1,field5,value5,field6,value6);

% Undistort point
up2d = undistortPoints(p2d',cameraParams);

% Back-project scaled image point to camera coordinates
Xcam = inv(C.K) *( repmat(s,3,1).* [up2d';ones(1,size(up2d,1))]);

% Trasnform 3D point from camera to world coordinates
p3d = inv([C.RT;0,0,0,1]) * [Xcam;ones(1,size(Xcam,2))];
p3d(4,:) = [];
end