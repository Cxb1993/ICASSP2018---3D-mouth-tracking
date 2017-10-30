function AM=myAM(idealTDOA,CM,i)
% Input:
%   idealTDOA: ideal TDOA at each room grid for each Mic pair
%    i: audio frame index
%    CM: coherence measure
AM=zeros(size(idealTDOA));
index=(size(CM,1)+1)/2;

TDOA=CM(:,i); 
AM(1:end)=TDOA(idealTDOA(1:end)+index);  % this step is really time consuming


end
