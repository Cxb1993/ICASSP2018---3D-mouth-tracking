function AM=myAL_GCF(Gridcart,CM,afr,Mic_pair,Mic_pos,c,fa)
% Description:
% compute the GCF value for each particle
% Date: 20/09/2017
% Author: XQ


% compute ideal TDOA
idealTDOA=cell(8);  %  for each mirophone pair
for m=1:size(Mic_pair,1)
    a=Mic_pair(m,1);
    b=Mic_pair(m,2);
    idealTDOA{a,b}=MyIdealTDOA_Cart_3D(Gridcart,Mic_pos(a,:),Mic_pos(b,:),c,fa);
end

% compute GCF
AM=0;
for m=1:size(Mic_pair,1) % for each mic pair
    a=Mic_pair(m,1);
    b=Mic_pair(m,2);
    AMm=myAM(idealTDOA{a,b},CM{a,b},afr);  % afr=fr+Afr(1)-1
    AM=AM+AMm;
end
AM=AM/m;


end