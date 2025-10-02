function x = wrap_longitudes_for_grid(x)
%WRAP_LONGITUDES_FOR_GRID Convert [0,360] longitudes to [-180,180] where needed.
%
% Syntax
%   x = wrap_longitudes_for_grid(x)
%
% Description
%   Converts longitude values > 180° into the interval [-180,180] by
%   subtracting 360. Useful when working with a grid that is shifted by
%   180° for dateline-friendly operations.
%
% Input
%   x   Scalar, vector, or array of longitudes (degrees), typically in [0,360]
%
% Output
%   x   Same size as input, with elements > 180 reduced by 360
%
% Notes
%   • This does a simple wrap for values in (180,360]; it does not apply a
%     general modular wrap for arbitrary ranges.
%   • Pair with REORDER_LON_BLOCKS and LOAD_GRID_AND_SHIFT when handling
%     cruises that cross the dateline.

x = x;
ix = x > 180;
x(ix) = x(ix) - 360;
end
