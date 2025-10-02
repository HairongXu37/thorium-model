function y = nansum(x, dim)
%NANSUM Compatibility shim: sum ignoring NaNs (no toolboxes required).
%
% Description
%   Computes the sum of X along dimension DIM while treating NaNs as zeros,
%   matching the behavior of the legacy Statistics Toolbox function NANSUM.
%
% Inputs
%   x    Array of numeric values (any size). NaNs are ignored in the sum.
%   dim  Dimension to operate along. If omitted, uses the first
%        non-singleton dimension of X (or 1 if X is scalar).
%
% Output
%   y    Sum of X along DIM with NaNs treated as zeros.
%
% Notes
%   • Promotes to double internally to mirror SUM’s promotion behavior.
%   • Equivalent to: sum(x, dim, 'omitnan') in newer MATLAB versions, except
%     that 'omitnan' skips NaNs rather than zero-filling; results are the same.
%
% Behavior: treats NaNs as zeros (matches original nansum semantics).

if nargin < 2
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

x = double(x);           % follow SUM promotion rules
x(isnan(x)) = 0;         % ignore NaNs by zeroing them
y = sum(x, dim);
end
