function [out,bitpix] = niidatatype(in)
% function [out,bitpix] = niidatatype(in)
%
% Part of fmrifrey/mri-devtools software package by David Frey (2023)
%   git@github.com:fmrifrey/mri-devtools.git
%
% Description: Function to convert between string formatted precision and
%   nii data type integer
%
%
% Static input arguments:
%   - in:
%       - either an integer value describing data type or string formatted
%           precision
%       - no default, argument is required
%
% Function outputs:
%   - datatype:
%       - if in is a string: integer value describing data type
%       - if in is an integer: string formatted precision
%   - bitpix:
%       - number of bits/voxel for specified data type
%
% Example:
%   'uint8' = niidatatype(2)
%   4 = niidatatype('int16')
%

    % Nifti datatypes table
    niitypes = { ...
        'binary'        1       1;
        'uint8'         2       8;
        'int16'         4       16;
        'int32'         8       32;
        'float32'       16      32;
        'complex64'     32      64;
        'float64'       64      64;
        'rgb24'         128     24;
        'int8'          256     8;
        'uint16'        512     16;
        'uint32'        768     32;
        'int64'         1024    64;
        'uint64'        1280    64;
        'float128'      1536    128;
        'complex128'	1792    128;
        'complex256'	2048    256;
        'rgba32'        2304    32;
        };
    
    % Find type in table
    [row,col] = find(strcmpi(string(niitypes(:,1:2)),string(in)));
    if isempty(row) || isempty(col)
        error('Invalid type: %s', in);
    end
    
    % Output its corresponding value
    out = niitypes{row,mod(col,2)+1};
    bitpix = niitypes{row,3};

end

