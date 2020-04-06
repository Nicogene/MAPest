
% Copyright (C) 2018 Istituto Italiano di Tecnologia (IIT)
% All rights reserved.
%
% This software may be modified and distributed under the terms of the
% GNU Lesser General Public License v2.1 or any later version.

function [smooth, varargout] = SgolayFilterAndDifferentiation(polynOrder,window,a, varargin)
% SGOLAYFILTERANDDIFFERENTIATION computes the smmothing, first order and
% second order derivation of a signal using SgolayFilt choosing properly
% the polynomial order and the size of the moving window.
% It computes a diffCoeff matrix of (polynomialOrder-1) columns where:
% - ( ,1)                 --> coefficient for S-Golay as smoother;
% - ( ,2)                 --> coefficient for S-Golay as 1st differentiator;
% - ( ,3)                 --> coefficient for S-Golay as 2nd differentiator;
%     .
%     .
%     .
% - ( ,polynomialOrder-1) --> coefficient for S-Golay as
%                                (polynomialOrder) differentiator;


[~, diffCoeff] = SgolayWrapper(polynOrder, window);
halfWindow  = ((window+1)/2) - 1;
l = size(a, 2);
varargout = cell(2, 1);
if ~isempty(varargin)
    da = zeros(size(a));
    dda = zeros(size(a));
end


smooth = zeros(size(a));

for n = (window+1)/2 : l-(window+1)/2
    for j = 1 : size(a, 1)
        if ~isempty(varargin)
            % 1st differential
            da(j,n) = factorial(1) * dot(diffCoeff(:,2), a(j,n - halfWindow:n + halfWindow));
            % 2nd differential
            dda(j,n) = factorial(2) * dot(diffCoeff(:,3), a(j,n - halfWindow:n + halfWindow));
        end
        % smoother
        smooth(j,n) = factorial(0) * dot(diffCoeff(:,1), a(j,n - halfWindow:n + halfWindow));
    end
end

if ~isempty(varargin)
    samplingTime = varargin{1};
    varargout{1} = da ./ samplingTime;
    varargout{2} = dda ./ (samplingTime)^2;
end

end
