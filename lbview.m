function im_lb = lbview(im, varargin)
% function im_lb = lbview(im, varargin)
%
% Part of fmrifrey/mri-devtools software package by David Frey (2023)
%   git@github.com:fmrifrey/mri-devtools.git
%
% Description: Function to display 3d images in lightbox view
%
%
% Static input arguments:
%   - im:
%       - image to display
%       - either a float/double 3D image array or name of a .nii file
%       - no default; required argument
%
% Variable input arguments (type 'help varargin' for usage info):
%   - 'frame':
%       - frame of timeseries image to display
%       - integer describing desired frame index
%       - only applicable if size of 4th dimension > 1
%       - default is 1
%   - 'slices':
%       - slices of image to show
%       - either an integer array describing desired slice indices or 'all'
%       - if 'all' is passed, all slices will be shown
%       - default is 'all'
%   - 'logscale'
%       - option to display image in logarithmic scale
%       - boolean integer (0 or 1) describing whether or not to use
%       - default is 0
%   - 'nrows':
%       - number of rows to display slices in
%       - integer describing number of rows
%       - if 'all' is passed, nrows will shape lightbox into a square
%       - default is 'all'
%   - 'orientation'
%       - slice dimension of brain
%       - either 'saggital','coronal', or 'axial'
%       - default is 'axial'
%   - 'zoomFactor'
%       - option to zoom into image along all dimensions
%       - float/double scalar value describing amount to zoom by
%       - default is 1
%   - 'resFactor'
%       - option to resample image along all dimensions
%       - float/double scale value describin amount to resample by
%       - default is 1
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
%   - im_lb
%       - lightbox concatenated image
%       - 2D array of slicewise images (size is dependent on input specs)
%       - no output will be returned unless specified (don't have to use ;
%           to avoid answer being printed to console) 
%       - if returned, lightbox image will not be shown
%

    % Define default arguments
    defaults = struct(...
        'frame',        1, ...
        'slices',       'all', ...
        'logscale',     0, ...
        'nrows',        'auto', ...
        'orientation',  'axial', ...
        'zoomFactor',   1, ...
        'resFactor',    1, ...
        'caxis',        'auto', ...
        'colormap',     gray(64), ...
        'colorbar',     1 ...
        );
    
    % Parse through variable inputs using matlab's built-in input parser
    args = vararginparser(defaults,varargin{:});
    
    % If im is a nii file name, read in from file
    if ischar(im)
        im = readnii(im);
    end
    
    % Warn user if image is complex
    if any(iscomplex(im(:)))
        warning('Complex images are not supported, using absolute value');
        im = abs(im);
    end
    
    % Permute based on orientation
    if strcmpi(args.orientation,'saggital')
        im = permute(im,[2 3 1 4]);
    elseif strcmpi(args.orientation,'coronal')
        im = permute(im,[1 3 2 4]);
    elseif ~strcmpi(args.orientation,'axial')
        error('Invalid orientation: %s', args.orientation);
    end
        
    % Apply log scale
    if args.logscale
        im = log(im - min(im(:)) + eps());
    end
    
    % Select single frame
    if size(im,4) > 1
        im = im(:,:,:,args.frame);
    end
    
    % If  there is a zoom/res factor, interpolate & extrapolate the image
    if any([args.resFactor;args.zoomFactor] ~= 1)
        im = regrid(im,'zoomfactor',args.zoomFactor,'resfactor',args.resFactor);
    end
    
    % Select slices
    if ~strcmp(args.slices,'all')
        im = im(:,:,args.slices);
    end
    
    % Determine number of rows and columns
    if strcmp(args.nrows, 'auto')
        args.nrows = floor(sqrt(size(im,3)));
    end
    ncols = ceil(size(im,3) / args.nrows);
    
    % Reshape image into concatenated slices
    im_lb = [];
    for rown = 1:args.nrows
        im_lb_row = [];
        for coln = 1:ncols
            slicen = (rown-1)*ncols + coln;
            if slicen <=  size(im,3)
                im_lb_row = [im_lb_row, im(:,:,slicen)'];
            else
                im_lb_row = [im_lb_row, ...
                    min(im(:))*ones(size(im,1),size(im,2))];
            end
        end
        im_lb = [im_lb; im_lb_row];
    end
    
    if nargout < 1
        % Display lightbox using imagesc
        imagesc(im_lb);
        set(gca,'Ydir','normal');
        grid off
        axis off
        if args.colorbar
            colorbar;
        end
        set(gca,'colormap',args.colormap);
        caxis(args.caxis);

        % Clear im_lb if not returned so it won't be printed to console
        clear im_lb
    end
    
end

