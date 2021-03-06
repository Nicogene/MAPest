
% Copyright (C) 2017 Istituto Italiano di Tecnologia (IIT)
% All rights reserved.
%
% This software may be modified and distributed under the terms of the
% GNU Lesser General Public License v2.1 or any later version.

function [q, dq, d2q, time] = readStateExt(n, filename)
% READSTATEEXT reads data from robot acqisizion. 
%
% Inputs 
% - n       : is the number of degrees of freedom of the part of the robot;
% - filename: is the name of the file containing the data from stateEXT:o 
%             port.

format = '%d %f ';
fid    = fopen(filename);

for j = 1 : 10
   format = [format, '('];
   for i = 1 : n
      if j < 9
         format = [format, '%f '];
      else
         format = [format, '%d '];
      end
   end
   format = [format, ') [ok] '];
end
C    = textscan(fid, format);
time = C{1, 2};
q    = cell2mat(C(1, 3    :3+  n-1)); % n columns of "q" value
dq   = cell2mat(C(1, 3+  n:3+2*n-1)); % n columns of "dq" value
d2q  = cell2mat(C(1, 3+2*n:3+3*n-1)); % n columns of "d2q" value

[tu,iu] = unique(time);
time    = tu';
q       = q(iu, :)';
dq      = dq(iu, :)';
d2q     = d2q(iu, :)';

if fclose(fid) == -1
   error('[ERROR] there was a problem in closing the file')
end
end
