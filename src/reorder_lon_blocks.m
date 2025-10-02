function A2 = reorder_lon_blocks(A, Ihi, Ilo)
%REORDER_LON_BLOCKS Reorder (ny×nx×nz) field into a 180°-shifted lon order.
%
% Syntax
%   A2 = reorder_lon_blocks(A, Ihi, Ilo)
%
% Description
%   Reorders the longitude (x) columns of a 3-D field to match a grid that
%   has been shifted by −180°. Columns are concatenated as [Ihi, Ilo], where
%   Ihi indexes longitudes > 180 and Ilo indexes longitudes ≤ 180 in the
%   original grid. This pairs with GRID2 built by LOAD_GRID_AND_SHIFT.
%
% Inputs
%   A    ny×nx×nz numeric array (field on the original grid)
%   Ihi  Column indices where grid.xt > 180
%   Ilo  Column indices where grid.xt ≤ 180
%
% Output
%   A2   ny×nx×nz array with longitude columns reordered as [A(:,Ihi,:), A(:,Ilo,:)]
%
% Notes
%   • Preserves y (latitude) and z (depth) ordering; only x (longitude) is reordered.
%   • Requires that [Ihi, Ilo] is a permutation of 1:nx.
%   • Does not modify coordinate vectors; only reorders the data array.
%   • Use WRAP_LONGITUDES_FOR_GRID to wrap station longitudes when building masks.

% A2(y, :, z) = [A(y, Ihi, z), A(y, Ilo, z)]
A2 = cat(2, A(:,Ihi,:), A(:,Ilo,:));
end

