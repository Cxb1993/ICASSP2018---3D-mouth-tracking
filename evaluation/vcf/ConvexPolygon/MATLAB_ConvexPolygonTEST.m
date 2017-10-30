% Description:
%   test the convex polygon code in MATALB
% Date: 17/09/2017
% Author: XQ


clear all
close all
clc

dbstop if error


addpath(genpath(fullfile('..', '..',  '..','Data')));
addpath(genpath(fullfile('..', '..','src')));

% read camera data
load(['C5.mat']);
camData.dataset='FBK';
camData.Cam_pos=-camData.R'*camData.T;  % need to be removed AX


load('RefAX')
gt3d=Ref.gt3d';

% create grid
step=0.05;
X_g=0:step:2.5;
Y_g=0:step:3.73;
Z_g=0:step:4;
GN=length(X_g)*length(Y_g)*length(Z_g); % # grid point
Gridcart=zeros(3,GN);
Gi=1;
for x=1:length(X_g)
    for y=1:length(Y_g)
        for z=1:length(Z_g)
            Gridcart(1,Gi)=X_g(x);
            Gridcart(2,Gi)=Y_g(y);
            Gridcart(3,Gi)=Z_g(z);
            Gi=Gi+1;
        end
    end
end
GridImg=myproject([Gridcart;ones(1,GN)], camData); % top-left corner point


NbMtx=[-1 -1 -1 -1 1 1 1 1; -1 -1 1 1 -1 -1 1 1; -1 1 -1 1 -1 1 -1 1];  % neiboring 8 points matrix
Nb8p=gt3d*ones(1,8)-step*NbMtx; % 8 neiboring points
Nb8pImg=myproject([Nb8p;ones(1,8)], camData); % top-left corner point


Img=imread(Ref.Img); % ref img
figure
imshow(Img)
hold on
plot(Ref.gtimg(1),Ref.gtimg(2),'r*')
plot(Nb8pImg(1,:),Nb8pImg(2,:),'g*')
legend('gt','8 convex polygon')
[in,on] = inpolygon(GridImg(1,:),GridImg(2,:),Nb8pImg(1,:),Nb8pImg(2,:));
plot(GridImg(1,in),GridImg(2,in),'m+')
plot(GridImg(1,~in),GridImg(2,~in),'b+')


figure
imshow(Img)
hold on
for i=1:8
    plot(Nb8pImg(1,i),Nb8pImg(2,i),'g*')
    pause
end



%% MATLAB example file
%Define the x and y coordinates of polygon vertices to create a pentagon.
L = linspace(0,2.*pi,6);
xv = cos(L)';
yv = sin(L)';

% Define x and y coordinates of 250 random query points. Initialize the random-number generator to make the output of randn repeatable.
rng default
xq = randn(250,1);
yq = randn(250,1);


% Determine whether each point lies inside or on the edge of the polygon area. Also determine whether any of the points lie on the edge of the polygon area.
[in,on] = inpolygon(xq,yq,xv,yv);

% Determine the number of points lying inside or on the edge of the polygon area.
numel(xq(in))

% Determine the number of points lying on the edge of the polygon area.
numel(xq(on))

% Determine the number of points lying outside the polygon area (not inside or on the edge).
numel(xq(~in))

figure

plot(xv,yv) % polygon
axis equal

hold on
plot(xq(in),yq(in),'r+') % points inside
plot(xq(~in),yq(~in),'bo') % points outside
hold off