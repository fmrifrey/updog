classdef overlayview
% classdef overlayview()
%
% Part of fmrifrey/mri-devtools software package by David Frey (2023)
%   git@github.com:fmrifrey/mri-devtools.git
%
% Description: Displays overlaid 3D images
%
%
% Methods:
%
%   function obj = overlayview()
%
%       Description: Constructor function for overlayview class
%
%       Function Output:
%           - obj:
%               - returned output overlayview object
%
%   function [obj,n] = addlayer(obj,im,varargin)
%
%       Description: Function to add a layer to the overlayview class
%
%       Static input arguments:
%           - im:
%               - image to display
%               - a float/double 3D image array or name of a .nii file
%               - only first frame will be used if there is more than 1
%               - no default; required argument
%
%       Variable input arguments:
%           - 'caxis':
%               - color limits for image
%               - 2-element double vector containing color limits
%               - default is min/max of layer image (opaque)
%           - 'cloc':
%               - colorbar location
%               - string describing location (see colorbar for more info)
%               - if left empty, no colorbar will be used for layer
%               - default is empty
%           - 'cmap':
%               - colormap
%               - Nx3 array describing color spectrum
%               - default is gray(128)
%           - 'mask':
%               - layer mask
%               - binary mask of image size
%               - default is empty (no mask)
%           - 'name':
%               - name of layer
%               - string describing name of layer
%               - will be used for colorbar label
%               - default is layer number
%
%       Function output:
%           - obj:
%               - returned output overlayview object with edits
%           - n:
%               - layer index that was just added
%               - if not returned, function will print the layer number
%
%   function obj = swaplayers(obj,n1,n2)
%       
%       Description: Function to swap layers within the overlayview object
%       
%       Static input arguments:
%           - n1:
%               - first layer to swap
%               - integer describing layer index
%               - no default
%           - n2:
%               - second layer to swap
%               - integer describing layer index
%               - no default
%       
%       Function output:
%           - obj:
%               - returned output overlayview object with edits
%
%   function obj = editlayer(obj,n,varargin)
%       
%       Description: Function to edit a layer within the overlayview object
%       
%       Static input arguments:
%           - n:
%               - layer to edit
%               - integer describing layer index
%               - no default
%       
%       Variable input arguments:
%           - Can change all layer properties (same arguments as in
%               addlayer())
%           - 'im':
%               - image to display
%               - a float/double 3D image array or name of a .nii file
%               - only first frame will be used if there is more than 1
%               - no default; required argument
%
%       Function output:
%           - obj:
%               - returned output overlayview object with edits
%
%   function show(obj,varargin)
%  
%       Description: Function to show the total overlaid images
%
%       Variable input arguments:
%           - 'layers':
%               - layers to show
%               - integers (or an array) describing layer indicies to show
%               - default is all layers
%           - 'viewtype':
%               - type of 3D view to use
%               - can be 'lbview' or 'orthoview'
%               - default is 'lbview'
%           - 'viewargs':
%               - structure containing arguments for view function
%               - see orthoview and lbview for more info
%

    properties
        ims % Cell array of image structures to overlay
    end
    
    methods
        function obj = overlayview()
            % Initialize ims array
            obj.ims = {};
        end

        function [obj,n] = addlayer(obj,im,varargin)

            % Get layer index
            n = length(obj.ims) + 1;

            % If im is a nii file name, read in from file
            if ischar(im)
                im = readnii(im);
            end

            % Force im to be 1st frame
            im = im(:,:,:,1);

            % Initialize structure and set parameters
            obj.ims{n} = struct('im', [], ...
                'caxis', [], ...
                'cloc', [], ...
                'cmap', [], ...
                'mask', [], ...
                'name', []);

            % Edit the layer with some defaults
            obj = obj.editlayer(n, ...
                'im', im, ...
                'caxis', [min(abs(im(:))), max(abs(im(:)))], ...
                'cmap', gray(128), ...
                'cloc', 'eastoutside', ...
                'name', sprintf('layer %d', n), ...
                varargin{:});

            % Return layer index
            if nargout < 2
                fprintf("%s image added to overlay layer %d\n", ...
                    obj.ims{n}.name, n);
            end

        end

        function obj = swaplayers(obj,n1,n2)

            % Swap the indicies of the ims array
            tmp = obj.ims{n1};
            obj.ims{n1} = obj.ims{n2};
            obj.ims{n2} = tmp;
        
        end

        function obj = editlayer(obj,n,varargin)

            % Set defaults and parse through variable inputs
            defaults = obj.ims{n};
            args = vararginparser(defaults, varargin{:});
            
            % Set parameters
            obj.ims{n}.im = args.im; % Image array
            obj.ims{n}.caxis = args.caxis; % Colorbar limits
            obj.ims{n}.cloc = args.cloc; % Colorbar location
            obj.ims{n}.cmap = args.cmap; % Colormap
            obj.ims{n}.mask = args.mask; % Layer mask
            obj.ims{n}.name = args.name; % Layer name

        end

        function show(obj,varargin)

            % Set defaults and parse through variable inputs
            defaults = struct('layers', 1:length(obj.ims), ...
                'viewtype', 'lbview', ...
                'viewargs', []);
            args = vararginparser(defaults, varargin{:});

            % Initialize overlaid image
            im_all = zeros(size(obj.ims{1}.im));
            cmap_all = [];

            for n = 1:length(args.layers)

                % Get layer
                imn = obj.ims{args.layers(n)};

                % Normalize layer image
                im_layer = (imn.im - imn.caxis(1)) / diff(imn.caxis);

                % Apply mask
                im_layer(imn.mask < 1) = 0;

                % Clip image bounds
                im_layer(im_layer(:) >= 1) = 1 - eps;
                im_layer(im_layer(:) <= 0) = 0;

                % Mask the underlay and add the layer
                im_all(im_layer(:) > 0) = n - 1;
                im_all = im_all + im_layer;

                % Append the colormap
                cmap_all = [cmap_all;
                    interp1(linspace(0,1,size(imn.cmap,1)), ...
                    imn.cmap, ...
                    linspace(0,1,128))];

            end

            % Set viewargs
            if isempty(args.viewargs)
                args.viewargs = cell(0);
            end

            % Display the image
            if strcmpi(args.viewtype,'lbview')
                lbview(im_all,args.viewargs{:},'colormap',cmap_all);
            elseif strcmpi(args.viewtype,'orthoview')
                orthoview(im_all,args.viewargs{:},'colormap',cmap_all);
            else
                error('invalid view type')
            end

            % Make colorbars
            for n = 1:length(args.layers)
                imn = obj.ims{args.layers(n)};
                if ~isempty(imn.cloc)
                    c = colorbar;
                    c.Location = imn.cloc;
                    c.Limits = [n-1 n];
                    c.TickLabels = linspace(imn.caxis(1),imn.caxis(2), ...
                        length(c.Ticks));
                    c.Label.String = imn.name;
                end
            end
            clim([0 n]);

        end

    end
end