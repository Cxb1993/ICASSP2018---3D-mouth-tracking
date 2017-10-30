function Vfr=myFrameRangeToCompare(seq_name,cam)
% Description:
%   calculate the framerange to make comparison with
% Date: 09/04/2017
% Author: Xinyuan



if strcmp(seq_name, 'seq08-1p-0100')
    
    if(cam==1)
        Vfr(1)     = 35;       % Initial frame for seq08-1p-0100 cam1
        Vfr(2)     = 500;      % Last frame for seq08-1p-0100 cam1
    else if (cam==2)
            Vfr(1)     = 25;       % Initial frame for seq08-1p-0100 cam2
            Vfr(2)     = 495;      % Last frame for seq08-1p-0100 cam2
        else if(cam==3)    
                Vfr(1)     = 25;       % Initial frame for seq08-1p-0100 cam3
                Vfr(2)     = 515;      % Last frame for seq08-1p-0100 cam3
            end
        end
    end
    
    
else if strcmp(seq_name, 'seq11-1p-0100') 
        if(cam==1)
            Vfr(1)     = 20;       % Initial frame for seq11-1p-0100 cam1
            Vfr(2)     = 549;      % Last frame for seq11-1p-0100 cam1
        else if (cam==2)
                Vfr(1)     = 11;       % Initial frame for seq11-1p-0100 cam2
                Vfr(2)     = 544;      % Last frame for seq11-1p-0100 cam2
            else if(cam==3)
                    
                    Vfr(1)     = 49;       % Initial frame for seq11-1p-0100 cam3
                    Vfr(2)     = 578;      % Last frame for seq11-1p-0100 cam3
                end
            end
        end
        
        
    else if strcmp(seq_name, 'seq12-1p-0100')
            if(cam==1)
                Vfr(1)     = 90;       % Initial frame for seq12-1p-0100 cam1
                Vfr(2)     = 1160;     % Last frame for seq12-1p-0100 cam1
            else if (cam==2)
                    Vfr(1)     = 123;      % Initial frame for seq12-1p-0100 cam2
                    Vfr(2)     = 1190;     % Last frame for seq12-1p-0100 cam2
                else if(cam==3)
                        Vfr(1)     = 80;       % Initial frame for seq12-1p-0100 cam3
                        Vfr(2)     = 1155;     % Last frame for seq12-1p-0100 cam3
                    end
                end
            end
        end
    end
end
end
