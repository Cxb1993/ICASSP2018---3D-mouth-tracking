function GridZ=CreateGrid_GTZ(gtZ,X_g,Y_g)
% create grid at speaker height
% Date: 01/09/2017
% Author: XQ

GridZ=gtZ*ones(3,length(X_g)*length(Y_g));

index=1;
for x=1:length(X_g)
    for y=1:length(Y_g)
        GridZ(1,index)=X_g(x);
        GridZ(2,index)=Y_g(y);
        index=index+1;
    end
end

end