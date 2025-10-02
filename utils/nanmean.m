function y = nanmean(x, dim)
%NANMEAN Compatibility shim: mean ignoring NaNs (no toolboxes required).
%
% Description
%   Computes the arithmetic mean of X along dimension DIM while ignoring
%   NaN values, mimicking the behavior of the legacy Statistics Toolbox
%   function NANMEAN. 
%
% Inputs
%   x    Array of numeric values (any size). NaNs are ignored in the mean.
%   dim  Dimension to operate along. If omitted, uses the first
%        non-singleton dimension of X (or 1 if X is scalar).
%
% Output
%   y    Mean of X along DIM with NaNs ignored. If all elements along DIM
%        are NaN, the result is NaN for that slice.
%
% Notes
%   • Promotes to double internally to match MEAN’s promotion behavior.
%   • Equivalent to: mean(x, dim, 'omitnan') in newer MATLAB versions.
%   • This shim treats NaNs as missing values; it does not weight samples.

if nargin < 2
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

% Work in double (matches mean's promotion behavior)
x = double(x);

mask = ~isnan(x);
n = sum(mask, dim);

x(~mask) = 0;         % zero-out NaNs so sums ignore them
s = sum(x, dim);

y = s ./ n;
y(n == 0) = NaN;      % if all NaNs along dim, return NaN (not Inf)
end
