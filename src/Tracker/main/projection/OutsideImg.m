function [Ioi,p2d_oi,Roi]=OutsideImg(p2d,ImgSize)
% Description:
% check whether the points are outside the image
% Date: 17/08/2017
% Author; XQ
%   Input:
%   p2d: points on image plane 2 by N_points
%   ImgSize: image size [x,y]
%   Output:
%       Ioi: index of points outside image
%       p2d_oi: points positions outside the image
%       Roi: outside image rate

Ioi1=(0>=p2d(1,:))|(p2d(1,:)>ImgSize(1));
Ioi2=(0>=p2d(2,:))|(p2d(2,:)>ImgSize(2));

Ioi=Ioi1|Ioi2;
p2d_oi=p2d(:,Ioi);

Roi=sum(Ioi)/length(Ioi);


end