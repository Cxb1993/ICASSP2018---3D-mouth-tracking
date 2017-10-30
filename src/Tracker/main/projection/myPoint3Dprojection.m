function [mouth3D] = myPoint3Dprojection(mouth2D, C)
%% 
% UpBody: [x y w h]
% W: upper body width in reality
% C: camera parameters:
%   - K: calibration matrix
%   - kc: distortion coefficients
%   - alpha_c: 
%   - T: camera pose (translation + orientation)
%   - Align_mat: alignment matrix for AV16.3
%   - shift: image offset for Av16.3

% Scale factor from the 
% Remove shift
mouth2D( 1, : ) = mouth2D( 1, : ) - C.shift(1);
mouth2D( 2, : ) = mouth2D( 2, : ) - C.shift(2);

% Remove radial distortion
mouth2Dun = undoradial( [mouth2D;ones(1,size(mouth2D,2))], C.K, [C.kc 0]); 

X = [mouth2Dun(1:2,:); ones(1,size(mouth2D,2))];

% Get 3D point in camera coordinate system
iX = inv(C.K) * X;

if size(C.T,1) == 3
  T = [C.T; 0 0 0 1];
else
  T = C.T;
end

% Get mouth position in 3D in homogeneous coordinates
mouth3Dh = 	C.Align * (inv(T) * [iX; ones(1,size(mouth2D,2))]);

mouth3D = mouth3Dh(1:3,:);

end
