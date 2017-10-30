function camData=readCameraData(cam,shift)

[K,kc,alpha_c] = readradfile(['cam' num2str(cam) '.rad']);
load(['P',num2str(cam)]);
load(['cam',num2str(cam),'pos']);
align_mat = dlmread('align010203.mat');

camData.Align = align_mat;
camData.Pmat = P;
camData.K = K;
camData.kc = kc;
camData.alpha_c =  alpha_c;
camData.shift = [shift.cam( cam ).delta_x shift.cam( cam ).delta_y]';
camData.Cam_pos = Cam_pos;
camData.T=inv(K)*P;
camData.dataset='AV16.3';
end