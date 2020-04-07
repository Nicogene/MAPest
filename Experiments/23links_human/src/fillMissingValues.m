
% Copyright (C) 2019 Istituto Italiano di Tecnologia (IIT)
% All rights reserved.
%
% This software may be modified and distributed under the terms of the
% GNU Lesser General Public License v2.1 or any later version.

function [data] = fillMissingValues( vectorIndx, missingVectorIdx, data )

sortedVectorIndx = sort(vertcat(vectorIndx,missingVectorIdx'));
    for r_shoeIdx = 1 : length(vectorIndx)
        for missingIdx = 1 : length(missingVectorIdx)
            if sortedVectorIndx(r_shoeIdx) == missingVectorIdx(missingIdx)
                tempForce = data(:,r_shoeIdx-1);
                data = (insertrows(data',tempForce',r_shoeIdx-1))';
            end
        end
    end
end

