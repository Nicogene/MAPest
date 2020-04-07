
% Copyright (C) 2017 Istituto Italiano di Tecnologia (IIT)
% All rights reserved.
%
% This software may be modified and distributed under the terms of the
% GNU Lesser General Public License v2.1 or any later version.

function [sensPosWRTlink] = printSensorPosition(suit)
%PRINTSENSORPOSITION prints a structure with the estimated position of the
% sensors w.r.t. the attached link frame.

sensPosWRTlink = struct;
    for i = 1 : size(suit.sensors,1)
        sensPosWRTlink(i).attachedLink = suit.sensors{i, 1}.attachedLink;
        sensPosWRTlink(i).pos_x = suit.sensors{i, 1}.position(1);
        sensPosWRTlink(i).pos_y = suit.sensors{i, 1}.position(2);
        sensPosWRTlink(i).pos_z = suit.sensors{i, 1}.position(3);
    end

end
