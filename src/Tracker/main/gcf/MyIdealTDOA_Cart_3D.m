function [idealTDOA,idealTDOA_org]=MyIdealTDOA_Cart_3D(Grid_cart,M1,M2,c,fa)
% Description:
%   estimate the idealTDOA between ONE Mic Pair
% Input: 
%   Mic_c: microphone center
% Date: 18/11/2016
% Author: Xinyuan Qian

% ideal TDOA
d1=sqrt(sum((Grid_cart-M1(:)*ones(1,size(Grid_cart,2))).^2,1)); % distance to Mic1
d2=sqrt(sum((Grid_cart-M2(:)*ones(1,size(Grid_cart,2))).^2,1));

idealTDOA_org=(d1-d2)/c*fa;
idealTDOA=round(idealTDOA_org);

end