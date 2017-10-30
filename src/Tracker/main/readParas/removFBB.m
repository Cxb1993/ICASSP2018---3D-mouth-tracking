function [FBB,detN,mouthImg,mouth3D]=removFBB(FBB,detN,mouthImg,mouth3D,K)
% Description:
%   randomly remove K percentage of FBB
% Input:
%    FBB: face bounding box Fr by [u,v,w,h]*detN
%   mouthImg: [u,v]*detN by Fr
%   mouth3D: [x,y,z]*detN by Fr

% Output:
% Date: 25/10/2017
% Author: XQ

disp(['Start Remove  ',num2str(K),' FBB'])
if(K==0) % use original face detection rst
   return 
end

FrD=find(detN>0);  % detect frame index
Nrm=round(length(FrD)*K); % remove frame number

% FBB Fr for remove
Ri=randperm(length(FrD)); % non-repetitive random integers
Rv=Ri(1:Nrm);
Rf=FrD(Rv); % remove frame index

% remove FBB information
detN(Rf,:)=0;
FBB(Rf,:)=NaN;
mouthImg(:,Rf)=NaN;
mouth3D(:,Rf)=0;

disp(['Finish FBB Removing '])

end