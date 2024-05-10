function out = fftc(in,dim)
% function out = fftc(in,dim)
%
% Part of fmrifrey/mri-devtools software package by David Frey (2023)
%   git@github.com:fmrifrey/mri-devtools.git
%
% Description: Function to calculate Nd fourier transform with
%   fft shifts and scaling accounted for
%
%
% Static input arguments:
%   - in:
%       - data to perform fft on
%       - float/double matrix containing data at uniformly spaced points
%       - no default, required argument
%   - dim:
%       - dimension(s) to perform fft along
%       - integer array describing desired dimensions, or 'all' for all
%           dimensions
%       - default is 'all'
%
% Function output:
%   - out:
%       - fourier transformed data
%       - float/double matrix containing data at uniformly spaced
%           frequencies
%

    % Set default dimensions
    if nargin<2 || isempty(dim)
        dim = 1:ndims(in);
    elseif any(dim(:) > ndims(in)) || any(dim(:) < 1)
        error('dimensions out of range');
    end
    
    % Define fourier transform with scaling and shifts
    fftc1d = @(x,d) 1/sqrt(size(x,d))*fftshift(fft(fftshift(x,d),[],d),d);
    
    % Fourier transform along each requested dimension
    out = in;
    for n = dim
        out = fftc1d(out,n);
    end
    
end