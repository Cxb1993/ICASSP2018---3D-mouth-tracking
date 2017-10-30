function [mouth3D,mouthsph,mouth2D,mouth3DS1] = myUpBody3D(UpBody, W, C,dataset,S1)
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
%   S1: scaling factor =1
if(nargin<5)
    S1=0; % set scaling factor to 1
end

Vg=UpBody(:,3)>0;
N=size(UpBody,1);  % number of detection
BL3d=zeros(3,N);
BR3d=zeros(3,N);
mouth3D=zeros(3,N);
mouthsph=zeros(3,N);
s=zeros(1,N);

if(sum(Vg)) % if there is detection
    % estimate scaling factor
    BLimg=[UpBody(:,1),UpBody(:,2)+UpBody(:,4)]'; % bottom left corner point of the detection bounding box
    BRimg=[UpBody(:,1)+UpBody(:,3),UpBody(:,2)+UpBody(:,4)]'; % bottom right corner point of the detection bounding box
%     TLimg=[UpBody(:,1),UpBody(:,2)]'; % top left

    % mouth2D = [(UpBody(:,1) + UpBody(:,3)/2) (UpBody(:,2) + UpBody(:,4)/2)]';
    mouth2D = [(UpBody(:,1) + UpBody(:,3)/2) (UpBody(:,2) + UpBody(:,4)*3/4)]';
    
    switch dataset
        case 'AV16.3'
            
            BL3d=myPoint3Dprojection(BLimg, C);  % projection of the bottom left corner point
            BR3d=myPoint3Dprojection(BRimg, C);  % projection of the bottom right corner point
%             TL3d=myPoint3Dprojection(TLimg, C);

            s = W./sqrt(sum((BL3d-BR3d).^2)); % width 
%             s = W./sqrt(sum((TL3d-BR3d).^2)); % diagonal size

            % Mouth image position from the boudning box; 2x1;
            
            % Remove shift
            mouth2D( 1, : ) = mouth2D( 1, : ) - C.shift(1);
            mouth2D( 2, : ) = mouth2D( 2, : ) - C.shift(2);
            
            % Remove radial distortion
            mouth2Dun = undoradial( [mouth2D;ones(1,N)], C.K, [C.kc 0]);
            X = ones(3,1)*s .* [mouth2Dun(1:2,:); ones(1,N)];
            % Get 3D point in camera coordinate system
            iX = inv(C.K) * X;
            if size(C.T,1) == 3
                T = [C.T; 0 0 0 1];
            else
                T = C.T;
            end
            % Get mouth position in 3D in homogeneous coordinates
            mouth3Dh = 	C.Align * (inv(T) * [iX; ones(1,N)]);
            mouth3D = mouth3Dh(1:3,:);
            % change to Spherical coordinates where camera is the origin
            mouthsph=myParticle_cart2sph(mouth3D,C.Cam_pos);
            
        case 'FBK'  % missing distortion code
            
            BL3d(:,Vg) = myBackProjection(BLimg(:,Vg), ones(1,sum(Vg)), C);
            BR3d(:,Vg) = myBackProjection(BRimg(:,Vg), ones(1,sum(Vg)), C);
%             TL3d(:,Vg) = myBackProjection(TLimg(:,Vg), ones(1,sum(Vg)), C);

            s(:,Vg) = W./sqrt(sum((BL3d(:,Vg)-BR3d(:,Vg)).^2));
%             s(:,Vg) = W./sqrt(sum((TL3d(:,Vg)-BR3d(:,Vg)).^2));

                        
            mouth3D(:,Vg)= myBackProjection(mouth2D(1:2,Vg), s(:,Vg), C);
            mouthsph(:,Vg)=myParticle_cart2sph(mouth3D(:,Vg),C.Cam_pos);
            if(S1)
                mouth3DS1=zeros(3,N);
                mouth3DS1(:,Vg)= myBackProjection(mouth2D(1:2,Vg),ones(1,sum(Vg)), C);
            end
            
    end
end

end
