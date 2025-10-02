function [Vxsec] = make_xsec(Vmat,grid,M3d,orient)
%MAKE_XSEC Build an along-track cross-section from a 3-D gridded field.
%
% Syntax
%   Vxsec = make_xsec(Vmat, grid, M3d, orient)
%
% Description
%   Generates a 2-D cross-section from a 3-D field Vmat by averaging across
%   the transverse dimension and linearly interpolating to fill gaps along
%   depth and along the track. Values < 0 are treated as missing (set NaN).
%
%   • orient = 'zonal' :
%       - Averages across latitude (dimension 1) → initial slice is X×Z
%       - Interpolates each vertical profile vs grid.zt
%       - Then interpolates along longitude vs grid.xt
%
%   • orient = 'merid' :
%       - Averages across longitude (dimension 2) → initial slice is Y×Z
%       - Interpolates each vertical profile vs grid.zt
%       - Then interpolates along latitude vs grid.yt
%
% Inputs
%   Vmat    ny×nx×nz numeric array (e.g., binned field .mu)
%   grid    Struct with coordinate vectors used for interpolation:
%             .xt (1×nx) longitudes, .yt (1×ny) latitudes, .zt (1×nz) depths
%   M3d     ny×nx×nz ocean mask (used only for sizing)
%   orient  'zonal' or 'merid' (defines which dimension is averaged first)
%
% Output
%   Vxsec   2-D cross-section:
%             • 'zonal'  → size nx×nz (longitude × depth)
%             • 'merid'  → size ny×nz (latitude  × depth)
%
% Notes
%   • Values < 0 in Vmat are set to NaN before processing.
%   • Initial average uses NANMEAN (ignores NaNs); ensure you have a shim if
%     NANMEAN isn’t available in your MATLAB.
%   • Vertical interpolation is performed where at least 3 valid points
%     exist in a column; same rule for along-track interpolation.
%   • No extrapolation: if fewer than 3 points are valid, the column/row is
%     left as-is (may remain partially NaN).

Vmat(Vmat<0) = NaN;
[ny nx nz] = size(M3d);

switch orient
    case 'zonal'

        % define initial xsec
        Vxsec = squeeze(nanmean(Vmat,1));
        
        % interpolate the profiles
        for i = 1:nx;
            Iprof = find(~isnan(Vxsec(i,:)));
            if length(Iprof)>2;
                Vprof = interp1(grid.zt(Iprof),Vxsec(i,Iprof),grid.zt);
                Vxsec(i,:) = Vprof;
            end
        end
        
        % interpolate over longitude
        for i = 1:nz
            Ilon = find(~isnan(Vxsec(:,i)));
            if length(Ilon)>2;
                Vlon = interp1(grid.xt(Ilon),Vxsec(Ilon,i),grid.xt);
                Vxsec(:,i) = Vlon;
            end
        end
        
    case 'merid'

        % define initial xsec
        Vxsec = squeeze(nanmean(Vmat,2));
        
        % interpolate the profiles
        for i = 1:ny;
            Iprof = find(~isnan(Vxsec(i,:)));
            if length(Iprof)>2;
                Vprof = interp1(grid.zt(Iprof),Vxsec(i,Iprof),grid.zt);
                Vxsec(i,:) = Vprof;
            end
        end
        
        % interpolate over longitude
        for i = 1:nz
            Ilat = find(~isnan(Vxsec(:,i))); 
            if length(Ilat)>2;
                Vlon = interp1(grid.yt(Ilat),Vxsec(Ilat,i),grid.yt);
                Vxsec(:,i) = Vlon;
            end
        end
end
