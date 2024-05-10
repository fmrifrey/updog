function cfigopen(name)
% function cfigopen(name)
%
% Part of fmrifrey/mri-devtools software package by David Frey (2023)
%   git@github.com:fmrifrey/mri-devtools.git
%
% Description: Function that opens figure based on name
%
%
% Notes:
%   - if a figure with given name is already open, that figure will become
%       the current figure
%
% Dependencies:
%   - matlab default path
%       - can be restored by typing 'restoredefaultpath'
%
% Static input arguments:
%   - name:
%       - name of figure to open
%       - string describing figure name
%       - no default, argument is required
%

    % Check if figure with specified name is open
    if isempty(findobj('type','figure','name',name))
        % If not, open it
        figure('name',name);
    else
        % If so, make it the current figure
        figure(findobj('type','figure','name',name))
    end
    
end

