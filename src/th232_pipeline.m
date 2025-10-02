function Th232dat = th232_pipeline(varargin)
%TH232_PIPELINE Build gridded, cruise-resolved GEOTRACES 232Th dataset.
%
% Syntax
%   Th232dat = th232_pipeline()
%   Th232dat = th232_pipeline('Name',Value,...)
%
% Description
%   Loads the model grid, reads GEOTRACES IDP2021 discrete seawater data,
%   grids 232Th (pM) with simple relative uncertainties, builds cruise
%   averaging masks and along-track cross-sections, performs a global
%   binning, and saves results to a MAT file. Returns the results struct.
%
% Name-Value Arguments
%   'GridFile'  Path to GRID.mat (expects variables: grid, M3d).
%               Default: 'utils/GRID.mat'
%
%   'DataFile'  GEOTRACES IDP2021 NetCDF with variables:
%               'metavar1' (cruise), 'metavar2' (station), 'date_time',
%               'latitude', 'longitude', 'var2' (depth), 'var213' (232Th, pM).
%               Default: 'GEOTRACES_IDP2021_Seawater_Discrete_Sample_Data_v1.nc'
%
%   'OutFile'   Output MAT filename. Default: 'Th232_bgrid.mat'
%
%   'ErrFrac'   Relative error applied to 232Th to form per-sample
%               uncertainties for binning (e.g., 0.05 = 5%). Default: 0.05
%
% Output
%   Th232dat    Struct with per-cruise fields:
%                 .mu/.var/.n   (ny×nx×nz) gridded statistics of 232Th
%                 .Mc           (ny×nx×nz) cruise averaging mask
%                 .xsec         along-track cross-section
%                 .x/.y         ordered cruise track (lon/lat)
%               and global fields:
%                 .glob.mu/.var/.n   all-data binning on the grid
%                 .glob.mu2          same as .glob.mu with longitudes
%                                    reordered for a 180° shift (dateline-friendly)
%
% Notes
%   • Cruises that cross the dateline are processed on a 180°-shifted view
%     of the grid; .glob.mu2 provides the reordered longitude view.
%   • If your MATLAB lacks 'nansum' or 'nanmean', include shims in utils/.
%   • Cruise selection rules are centralized in CRUISE_DEFINITIONS.m.
%
% Dependencies (on path)
%   src/load_grid_and_shift.m
%   src/load_geotraces_th232.m
%   src/cruise_definitions.m
%   src/process_cruise.m
%   src/reorder_lon_blocks.m
%   utils/bin3d.m, utils/make_cruise_mask.m, utils/make_xsec.m
%   utils/GRID.mat

% -------- Arguments & defaults
p = inputParser;
p.addParameter('GridFile','utils/GRID.mat',@(s)ischar(s)||isstring(s));
p.addParameter('DataFile','GEOTRACES_IDP2021_Seawater_Discrete_Sample_Data_v1.nc',@(s)ischar(s)||isstring(s));
p.addParameter('OutFile','Th232_bgrid.mat',@(s)ischar(s)||isstring(s));
p.addParameter('ErrFrac',0.05,@(x)isnumeric(x)&&isscalar(x)&&x>=0&&x<=1);
p.parse(varargin{:});
cfg = p.Results;

fprintf('[%s] Starting pipeline\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

% -------- Load grid & shifted grid
[grid, M3d, grid2, M3d2, Ihi, Ilo] = load_grid_and_shift(cfg.GridFile);
fprintf('  Loaded grid: nx=%d ny=%d nz=%d\n', size(grid.XT3d,2), size(grid.XT3d,1), size(grid.XT3d,3));

% -------- Load GEOTRACES 232Th + expand per-sample arrays
D = load_geotraces_th232(cfg.DataFile, cfg.ErrFrac);
fprintf('  Loaded GEOTRACES: %d stations, %d depth levels\n', numel(D.lon), size(D.depth,1));

% -------- Cruise definitions
defs = cruise_definitions();

% -------- Process each cruise
Th232dat = struct();
for k = 1:numel(defs)
    def = defs(k);
    fprintf('  Processing cruise %-6s ... ', def.name);
    S = process_cruise(def, D, grid, grid2, M3d, M3d2, Ihi, Ilo);
    Th232dat.(def.name) = S;
    fprintf('done. (has %d valid bins)\n', nansum(S.n(:) > 0));
end

% -------- Global binning (all cruises)
I = ~isnan(D.Th232);
Th232g     = D.Th232(I);
Th232gerr  = D.Th232err(I);
depthg     = D.depth(I);
LONg       = D.LON(I);
LATg       = D.LAT(I);

% Clip longitudes like your original
LONg(LONg>grid.xt(end)) = grid.xt(end);
LONg(LONg<grid.xt(1))   = grid.xt(end);

[mu,var,n] = bin3d(LONg,LATg,depthg,Th232g,Th232gerr,grid.XT3d,grid.YT3d,grid.ZT3d);
Th232dat.glob.mu  = mu;
Th232dat.glob.var = var;
Th232dat.glob.n   = n;
Th232dat.glob.mu2 = reorder_lon_blocks(mu,Ihi,Ilo); % dateline-friendly view

% -------- Save
save(cfg.OutFile,'Th232dat','-v7.3');
fprintf('[%s] Saved -> %s\n', datestr(now,'yyyy-mm-dd HH:MM:SS'), cfg.OutFile);
end
