function [DR,P,R,TP,FP,FN,DR2]=myPRcurve_mouth(GTimg,Est,detN,FoV,er)
% Description:
% prediction and recall curve
% Date: 28/08/2017
% Author; XQ
% Input:
%   GT: frames by 2
%   Est: frames by ...
%   detN: detect number
%   FoV: object inside FoV index
%   er: accepted Error in pixel

Fr=length(GTimg);

DR=0;
TP=0;
FP=0;
TN=0;
FN=0;


for fr=1:Fr
     
    
    if(FoV(fr))   % object inside FoV
        
        if(~detN(fr)) % No detection
            FN=FN+1;
        else % have detection results
            mouth=reshape(Est(fr,:),[2,length(Est(fr,:))/2]);
            gt=GTimg(fr,:)';
            
            DR=DR+1;
            Er=sqrt(sum((mouth(:,1:detN(fr))-repmat(gt,[1 detN(fr)])).^2));
            TP=TP+sum(Er<=er);
            FP=FP+sum(Er>er);
            
            if(sum(Er>er)==detN(fr)) % all detections are incorrect
               FN=FN+1; 
            end
        end
        
    else  % object outside FoV
        if(detN(fr))
            FP=FP+1;
        end
    end
    
    
end

    P=TP/(TP+FP);
    R=TP/(TP+FN);
    DR=DR/Fr;
    DR2=TP/Fr;


end