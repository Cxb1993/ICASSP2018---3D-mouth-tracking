function CPimg=myConvexPolygon(p3d,step,GridImg,camData)
% Description:
% for each 3D point, compute the projected pixels on image plane
% Date: 17/09/2017
% Author: XQ
% disp('start my ConvexPolygon')

NbMtx=[-1 -1 -1 -1 1 1 1 1; -1 -1 1 1 -1 -1 1 1; -1 1 -1 1 -1 1 -1 1];  % neiboring 8 points matrix
Nb8p=p3d*ones(1,8)-step*NbMtx; % 8 neiboring points
Nb8pImg=myproject([Nb8p;ones(1,8)], camData); % top-left corner point
Nb8pImg(3,:)=[];
% disp('Finish myproject...')

% disp('Polygon on image plane')
Nbmid=mean(Nb8pImg,2);
[~,Iisd]=sort(abs(sum((Nb8pImg-Nbmid*ones(1,8)).^2))); % grid points inside the 6-polygen
NbImg=Nb8pImg(:,Iisd(3:end));  % 6 points on image plane that define the 6 polygen
th=cart2pol(NbImg(1,:)-Nbmid(1),NbImg(2,:)-Nbmid(2));
[~,Ith]=sort(th);
NbImg=NbImg(:,Ith);

% disp('compute inpolygon')
[in,on] = inpolygon(GridImg(1,:),GridImg(2,:),NbImg(1,:),NbImg(2,:));
CPimg=GridImg(:,in|on);

% disp('End my ConvexPolygon')
end