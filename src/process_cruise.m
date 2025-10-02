function S = process_cruise(def, D, grid, grid2, M3d, M3d2, Ihi, Ilo)
%PROCESS_CRUISE Selection, binning, mask, and cross-section for one cruise.
%
% Syntax
%   S = process_cruise(def, D, grid, grid2, M3d, M3d2, Ihi, Ilo)
%
% Description
%   Applies the cruise-specific selection defined in DEF to the expanded
%   GEOTRACES dataset D, bins 232Th onto the model grid, constructs a
%   cruise-averaging mask, and generates an along-track cross-section.
%   Handles cruises that cross the dateline by optionally using a 180°-
%   shifted grid and longitude reordering.
%
% Inputs
%   def    Struct describing the cruise (from CRUISE_DEFINITIONS), fields:
%            .name           (string)  cruise label (e.g., "GA02")
%            .orientation    (string)  'zonal' | 'merid' (mask/xsec axis)
%            .wrapMode       (string)  'none' | 'shift180' (dateline handling)
%            .splitOutputs   (logical) split track into x_1/x_2, y_1/y_2
%            .clipLonToGrid  (logical) clip LON to grid bounds before binning
%            .selector       (func)    @(cruise,lat,lon,date)->logical index
%
%   D      Data struct from LOAD_GEOTRACES_TH232, expected fields:
%            .LON, .LAT, .DATE (levels×stations expanded arrays)
%            .lon, .lat, .date (per-station vectors)
%            .depth (levels×stations), .Th232, .Th232err (levels×stations)
%
%   grid   Base grid struct (xt in [0,360]) with XT3d/YT3d/ZT3d; M3d mask
%   grid2  Shifted grid struct (xt-180 view) for dateline-friendly ops
%   M3d    Ocean mask aligned with grid   (ny×nx×nz)
%   M3d2   Ocean mask aligned with grid2  (ny×nx×nz)
%   Ihi    Column indices where grid.xt > 180 (for reordering)
%   Ilo    Column indices where grid.xt <= 180 (for reordering)
%
% Output
%   S      Struct with:
%            .mu/.var/.n   (ny×nx×nz)  binned 232Th statistics
%            .x,.y         ordered cruise track (lon/lat)
%            .Mc           (ny×nx×nz)  cruise-averaging mask
%            .xsec         along-track cross-section (2-D)
%          Optional (if def.splitOutputs = true):
%            .x_1,.x_2,.y_1,.y_2  track split around 180°E
%
% Notes
%   • Orientation: 'zonal' orders the track by longitude; 'merid' by latitude.
%   • wrapMode='shift180' reorders μ via REORDER_LON_BLOCKS and wraps the
%     station longitudes with WRAP_LONGITUDES_FOR_GRID before mask creation.
%   • If def.clipLonToGrid is true, longitudes are clipped to grid.xt bounds
%     prior to binning (mirrors original special-case handling).

% ---- Index stations/samples for this cruise
Ic = find(def.selector(D.cruise, D.lat, D.lon, D.date));
LONc   = D.LON(:,Ic);
LATc   = D.LAT(:,Ic);
depthc = D.depth(:,Ic);
Th232c = D.Th232(:,Ic);
Th232e = D.Th232err(:,Ic);

% Optional clipping (mirrors your special case)
if def.clipLonToGrid
    LONc(LONc>grid.xt(end)) = grid.xt(end);
    LONc(LONc<grid.xt(1))   = grid.xt(end);
end

% ---- Bin valid samples
Ivalid = ~isnan(Th232c);
[mu,var,n] = bin3d(LONc(Ivalid),LATc(Ivalid),depthc(Ivalid),Th232c(Ivalid),Th232e(Ivalid), ...
                   grid.XT3d, grid.YT3d, grid.ZT3d);

% ---- Store binned fields
S.mu  = mu;
S.var = var;
S.n   = n;

% ---- Ordered cruise track (x,y) for plotting/averaging
switch def.orientation
    case "zonal"  % order by longitude
        [xcruise,Is] = sort(D.lon(Ic)); 
        ycruise      = D.lat(Ic(Is));
    case "merid"  % order by latitude
        [ycruise,Is] = sort(D.lat(Ic)); 
        xcruise      = D.lon(Ic(Is));
    otherwise
        error('Unknown orientation: %s', def.orientation);
end
S.x = xcruise;
S.y = ycruise;

% Optional split (like your GA10/GIPY05e helpers)
if def.splitOutputs
    I_1 = find(xcruise<180);
    I_2 = find(xcruise>180);
    S.x_1 = xcruise(I_1); S.x_2 = xcruise(I_2);
    S.y_1 = ycruise(I_1); S.y_2 = ycruise(I_2);
end

% ---- Choose grid/view & possibly reorder mu for dateline
switch def.wrapMode
    case "none"
        gridUsed = grid; M3dUsed = M3d; muUsed = mu;
        xyForMaskX = xcruise;
    case "shift180"
        gridUsed = grid2; M3dUsed = M3d2;
        muUsed   = reorder_lon_blocks(mu, Ihi, Ilo);
        % shift station longitudes into [-180,180] for mask construction
        xyForMaskX        = wrap_longitudes_for_grid(xcruise);
    otherwise
        error('Unknown wrapMode: %s', def.wrapMode);
end

% ---- Averaging mask along cruise path
S.Mc = make_cruise_mask(xyForMaskX, ycruise, gridUsed, M3dUsed, 1, char(def.orientation));

% ---- Cross-section (masked-out cells set to NaN)
xsec = make_xsec(muUsed, gridUsed, M3dUsed, char(def.orientation));

switch def.orientation
    case "zonal"
        Ox = mean(S.Mc .* M3dUsed, 1, 'omitnan');  % average across latitude
    case "merid"
        Ox = mean(S.Mc .* M3dUsed, 2, 'omitnan');  % average across longitude
end
xsec(Ox==0) = NaN;
S.xsec = xsec;
end
