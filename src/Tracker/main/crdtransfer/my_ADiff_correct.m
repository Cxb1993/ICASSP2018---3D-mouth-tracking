function theta=my_ADiff_correct(theta,unit)
% Description:
%   the difference between 2 angles should be smaller than pi
%
% Input:
%  unit: either 'rad' or 'deg'

if(strcmp('rad',unit)) % in rad
    index=find(abs(theta)>pi);
    theta(index)=-sign(theta(index)).*(2*pi-abs(theta(index)));
else if(strcmp('deg',unit))
        index=find(abs(theta)>180);
        theta(index)=-sign(theta(index)).*(2*180-abs(theta(index)));
    else
        display('Error: please specify the angle unit')
    end
end

end