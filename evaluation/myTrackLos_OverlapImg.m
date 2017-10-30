function TckR=myTrackLos_OverlapImg(GT3d,est3d,camData,Face3DSz,ImgSize)
% Track and loss ratio
% Input:
%   GT3d: 3 by Fr GT data
%   est3d: 3 by Fr estimate
% Output:
% TckR=tracked frames / total number of frames

Fw = Face3DSz(1);
Fh = Face3DSz(2);

%
Iw = ImgSize(1); % Image width
Ih = ImgSize(2); % Image height

[GTbb,GTval]= myVirtualBoxCreation(GT3d, camData, Fw, Fh, Iw, Ih, 0);
[estbb,estval]= myVirtualBoxCreation(est3d, camData, Fw, Fh, Iw, Ih, 0);

OV = bboxOverlapRatio(GTbb(:,logical(GTval))',estbb(:,logical(estval))');
ovlap=diag(OV);

TckR=sum(ovlap>0)/length(ovlap);

end