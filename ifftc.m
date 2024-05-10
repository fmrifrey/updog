function out = ifftc(in,dim)
% function out = ifftc(in,dim)
%
% Part of fmrifrey/mri-devtools software package by David Frey (2023)
%   git@github.com:fmrifrey/mri-devtools.git
%
% Description: Function to calculate Nd inverse fourier transform with
%   fft shifts and scaling accounted for
%
%
% Static input arguments:
%   - in:
%       - frequency data to perform ifft on
%       - float/double matrix containing data at uniformly spaced
%           frequencies
%       - no default, required argument
%   - dim:
%       - dimension(s) to perform ifft along
%       - integer array describing desired dimensions, or 'all' for all
%           dimensions
%       - default is 'all'
%
% Function output:
%   - out:
%       - inverse fourier transformed data
%       - float/double matrix containing data at uniformly spaced points
%

    % Set default dimensions
    if nargin<2 || isempty(dim) || strcmpi(dim,'all')
        dim = 1:ndims(in);
    elseif any(dim(:) > ndims(in)) || any(dim(:) < 1)
        error('dimensions are out of range');
    end
    
    % Define fourier transform with scaling and shifts
    ifftc1d = @(x,d) sqrt(size(x,d))*ifftshift(ifft(ifftshift(x,d),[],d),d);
    
    % Fourier transform along each requested dimension
    out = in;
    for n = dim
        out = ifftc1d(out,n);
    end
    
end