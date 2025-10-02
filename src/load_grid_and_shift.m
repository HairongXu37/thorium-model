function [grid, M3d, grid2, M3d2, Ihi, Ilo] = load_grid_and_shift(gridFile)
%LOAD_GRID_AND_SHIFT Load base grid and prepare a 180°-shifted view.
%
% Syntax
%   [grid, M3d, grid2, M3d2, Ihi, Ilo] = load_grid_and_shift(gridFile)
%
% Description
%   Loads the model grid and ocean mask from a MAT file, and constructs a
%   dateline-friendly view by shifting longitudes by -180° and reordering
%   columns. Returns both the original grid/mask and the shifted versions,
%   along with column indices that split longitudes into xt>180 and xt<=180.
%
% Input
%   gridFile  Path to GRID.mat (expects variables: grid, M3d)
%
% Outputs
%   grid   Struct with original coordinates; requires fields:
%            .xt (1×nx) longitudes in [0,360]
%            .XT3d, .YT3d, .ZT3d (ny×nx×nz)  % used elsewhere in the pipeline
%   M3d    (ny×nx×nz) ocean mask aligned with grid
%   grid2  Same as grid but with xt shifted by -180 ([-180,180] view)
%   M3d2   M3d columns reordered to match grid2
%   Ihi    Column indices where grid.xt > 180
%   Ilo    Column indices where grid.xt <= 180
%
% Notes
%   • This function does not modify any data values—only coordinates/order.
%   • The (Ihi, Ilo) indices are used by REORDER_LON_BLOCKS to reorder 3-D
%     fields consistently with the shifted longitude view.

S = load(gridFile);          % expects 'grid' and 'M3d'
grid = S.grid;
M3d  = S.M3d;

% Indices for reordering longitudes (0-360) to a -180..180 view
Ihi = find(grid.xt > 180);
Ilo = find(grid.xt <= 180);

% Shifted grid (x -> x-180)
grid2      = grid;
grid2.xt   = grid.xt - 180;
M3d2       = cat(2, M3d(:,Ihi,:), M3d(:,Ilo,:));
end

