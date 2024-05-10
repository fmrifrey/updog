function im_ortho = orthoview(im,varargin)
% function im_ortho = orthoview(im, varargin)
%
% Part of fmrifrey/mri-devtools software package by David Frey (2023)
%   git@github.com:fmrifrey/mri-devtools.git
%
% Description: Function to display 3d images in orthogonal cut view
%
%
% Static input arguments:
%   - im:
%       - image to display
%       - either a float/double 3D image array or name of a .nii file
%       - no default; required argument
%
% Variable input arguments (type 'help varargin' for usage info):
%   - 'fov':
%       - field of view of image
%       - 1x3 double/float array describing image fov (or at least
%           dimensional ratio, units don't matter as much here)
%       - if reading im from nii file, fov will automatically be read
%       - if empty and not reading im from file, fov will be assumed from
%           dimensions, which may be inaccurate
%       - default is empty
%   - 'frame':
%       - frame of timeseries image to display
%       - integer describing desired frame index
%       - only applicable if size of 4th dimension > 1
%       - default is 1
%   - 'orientation'
%       - option to display cuts horizontally or vertically
%       - string, either 'horizontal', or 'vertical'
%       - default is 'horizontal'
%   - 'zoomFactor'
%       - option to zoom into image along all dimensions
%       - float/double scalar value describing amount to zoom by
%       - default is 1
%   - 'resFactor'
%       - option to resample image along all dimensions
%       - float/double scale value describin amount to resample by
%       - default is 1
%   - 'offset':
%       - cut offset for each dimension
%       - 1x3 integer array describing offset from isocenter in each
%           dimension
%       - default is [0,0,0]
%   - 'logscale'
%       - option to display image in logarithmic scale
%       - boolean integer (0 or 1) describing whether or not to use
%       - default is 0
%   - 'caxis':
%       - color scale axis bounds
%       - float/double 1x2 array decribing minimum and maximum intensity of
%           color scale
%       - if 'auto' is passed, caxis will use min and max values of image
%       - default is 'auto'
%   - 'colormap:
%       - color map
%       - Nx3 color map array
%       - default is gray(64)
%   - 'colorbar':
%       - option to include a colorbar
%       - boolean integer (0 or 1) describing whether or not to use
%       - default is 1
%
% Function output:
%   - im_ortho
%       - orthogonal concatenated image
%       - 2D array of slicewise images (size is dependent on input specs)
%       - no output will be returned unless specified (don't have to use ;
%           to avoid answer being printed to console) 
%       - if returned, ortho image will not be shown
%

    % Define default arguments
    defaults = struct(...
        'fov',          [], ...
        'frame',        1, ...
        'orientation',  'horizontal', ...
        'zoomFactor',   1, ...
        'resFactor',    1, ...
        'offset',       [0,0,0], ...
        'logscale',     0, ...
        'caxis',        'auto', ...
        'colormap',     gray(64), ...
        'colorbar',     1 ...
        );
    
    % Parse through variable inputs using matlab's built-in input parser
    args = vararginparser(defaults,varargin{:});
    
    % If im is a nii file name, read in from nii file
    if ischar(im)
        [im,h] = readnii(im);
        args.fov = h.dim(2:4).*h.pixdim(2:4);
    elseif isempty(args.fov)
        args.fov = size(im);
    end
    
    % Warn user if image is complex
    if any(iscomplex(im(:)))
        warning('Complex images are not supported, using absolute value');
        im = abs(im);
    end
    
    % Apply log scale
    if args.logscale
        im = log(im - min(im(:)) + eps());
    end
    
    % Select single frame
    if size(im,4) > 1
        im = im(:,:,:,args.frame);
    end
    
    % Fix field of view and resolution
    args.resFactor = args.resFactor(:)'.* max(size(im)) ./ size(im);
    args.zoomFactor = args.zoomFactor(:)' .* size(im)/max(size(im));
    im = regrid(im, 'resFactor', args.resFactor, 'zoomFactor', args.zoomFactor);

    % Get cuts
    im_Sag = im(mod(round(size(im,1)/2)+args.offset(1),size(im,1)), :, :);
    im_Cor = im(:, mod(round(size(im,2)/2)+args.offset(2),size(im,2)), :);
    im_Ax = im(:, :, mod(round(size(im,3)/2)+args.offset(3),size(im,3)));
    
    % Concatenate cuts
    if strcmpi(args.orientation,'horizontal')
        im_ortho = [squeeze(im_Sag)', squeeze(im_Cor)', squeeze(im_Ax)'];
    elseif strcmpi(args.orientation,'vertical')
        im_ortho = [squeeze(im_Sag)'; squeeze(im_Cor)'; squeeze(im_Ax)'];
    else
        error('invalid orientation: %s', args.orientation);
    end
    
    if nargout < 1
        % Display orthoviews using imagesc
        imagesc(im_ortho);
        set(gca,'Ydir','normal');
        grid off
        axis off
        if args.colorbar
            colorbar;
        end
        set(gca,'colormap',args.colormap);
        caxis(args.caxis);

        % Clear im_ortho if not returned so it won't be printed to console
        clear im_ortho
        axis image
    end
    
end
