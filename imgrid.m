function varargout = imgrid(fov,dim,type)
% function varargout = imgrid(fov,dim)
%
% Part of fmrifrey/mri-devtools software package by David Frey (2023)
%   git@github.com:fmrifrey/mri-devtools.git
%
% Description: Function to quickly create Nd cartesian grids based on field
%   of view and dimension
%
%
% Static input arguments:
%   - fov:
%       - field of view (maximum coordinate value x 2) along each dimension
%       - vector of same number of elements as dimensions in cartesian grid
%       - must be same size as dim
%       - no default
%   - dim:
%       - grid size along each dimension
%       - vector of same number of elements as dimensions in cartesian grid
%       - must be same size as fov
%       - no default
%   - type:
%       - type of grids to output
%       - 'meshgrid' or 'ndgrid'
%       - see meshgrid() for explanation of difference
%       - default is 'ndgrid'
%
% Variable function output (type 'help varargout' for usage info):
%   - Grid arrays
%       - example: [X,Y,Z] = imgrid([100 100 100], [100 100 100])
%           will produce X, Y, and Z grids for ranging from -50 to 50 in
%           100 steps along each dimension
%

    % Set default for type
    if nargin < 3 || isempty(type)
        type = 'ndgrid';
    end

    % Check that fov and dim are same size
    if numel(dim) == 1 && numel(fov) > 1
        dim = dim*ones(size(fov));
    elseif numel(fov) == 1 && numel(dim) > 1
        fov = fov*ones(size(dim));
    elseif numel(fov) ~= numel(dim)
        error('fov and dim must be same size');
    end

    % Check that number of grid dimensions in output is equal to number of
    % input dimensions
    if nargout ~= numel(fov) && numel(fov) == 1
        fov = fov*ones(nargout,1);
        dim = dim*ones(nargout,1);
    elseif nargout ~= numel(fov)
        error('number of arguments out must be equal to number of dimenstions in fov/dim');
    end

    % Make cartesian coord. vectors
    x = cell(1,nargout);
    for i = 1:nargout
        x{i} = linspace(-fov(i)/2,fov(i)/2,dim(i));
    end
    
    % Make grid arrays
    varargout = cell(nargout,1);
    if ~ischar(type)
        error('type must be a character vector');
    elseif strcmpi(type,'ndgrid')
        [varargout{:}] = ndgrid(x{:});
    elseif strcmpi(type,'meshgrid')
        [varargout{:}] = meshgrid(x{:});
    else
        error("type must be either 'ndgrid' or 'meshgrid'");
    end

end

