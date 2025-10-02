% plot_th232_xsecs_singlefigure.m
% PLOT_TH232_XSECS_SINGLEFIGURE — Multi-panel (4x2) cross-sections of GEOTRACES 232Th.
%
% Purpose
%   Display observed 232Th cross-sections for eight GEOTRACES cruises in
%   one figure, using outputs from the pipeline.
%
% What it shows (per panel)
%   • Filled contours of 232Th cross-section (pM) vs. latitude/longitude and depth
%   • Independent colorbars per panel with cruise-specific caxis ranges
%   • Axis limits roughly matched to each cruise’s sector
%
% Usage
%   %   1) Run the pipeline once to produce Th232_bgrid.mat
%   %   2) Then:
%   run('plot_th232_xsecs.m');
%
% Inputs (files expected on disk)
%   Th232_bgrid.mat        % produced by th232_pipeline, contains Th232dat
%   utils/GRID.mat         % provides grid struct with xt/yt/zt
%
% Assumptions / Units
%   • 232Th units: picomolar (pM)
%   • Depth units: same as grid.zt (typically meters)
%   • grid.xt in [0,360]; GA10 is displayed with a -180 shift (x2 = xt-180)
%
% Notes
%   • If you want a single shared colorbar, unify the caxis across panels and
%     create one colorbar outside the subplots (not done here to preserve
%     cruise-specific dynamic ranges).

%% Housekeeping & data load
close all;

% Load cross-section products from the saved pipeline output
S = load('Th232_bgrid.mat','Th232dat'); 
Th232dat = S.Th232dat;

% Load grid for coordinate vectors (xt, yt, zt)
G = load('utils/GRID.mat','grid'); 
grid = G.grid;

% Convenience: shifted-longitude axis for GA10 (zonal, wrapMode=shift180)
x2 = grid.xt - 180;

%% Figure layout
% One big figure (4 rows x 2 cols) for the eight cruises
f = figure('Color','w','Position',[100 50 900 900]); %#ok<NASGU>
nrows = 4; 
ncols = 2;
p = @(r,c) subplot(nrows,ncols,(r-1)*ncols + c);  % helper to index subplots

%% Row 1
% GA02 (meridional cross-section: latitude vs depth)
ax = p(1,1);
draw_panel(ax, grid.yt, 'Latitude', Th232dat.GA02.xsec, ...
    'GA02 Observed [Th232] (pM)', [0 0.5], grid);
xlim([-60 65]);    % broader lat range to show full section

% GA03w (zonal cross-section: longitude vs depth)
ax = p(1,2);
draw_panel(ax, grid.xt, 'Longitude', Th232dat.GA03w.xsec, ...
    'GA03w Observed [Th232] (pM)', [0 0.5], grid);
xlim([285 345]);   % western leg sector

%% Row 2
% GA03e (meridional)
ax = p(2,1);
draw_panel(ax, grid.yt, 'Latitude', Th232dat.GA03e.xsec, ...
    'GA03e Observed [Th232] (pM)', [0 0.5], grid);
xlim([16 37]);     % eastern leg latitude window

% GA10 (zonal) — use shifted longitude axis (prime meridian centered)
ax = p(2,2);
draw_panel(ax, x2, 'Longitude', Th232dat.GA10.xsec, ...
    'GA10 Observed [Th232] (pM)', [0 0.3], grid);
xlim([-55 -7]);    % South Atlantic sector (shifted longitudes)

%% Row 3
% GP16 (zonal)
ax = p(3,1);
draw_panel(ax, grid.xt, 'Longitude', Th232dat.GP16.xsec, ...
    'GP16 Observed [Th232] (pM)', [0 0.1], grid);
xlim([202 285]);   % tropical Pacific sector

% GPc01w (zonal)
ax = p(3,2);
draw_panel(ax, grid.xt, 'Longitude', Th232dat.GPc01w.xsec, ...
    'GPc01w Observed [Th232] (pM)', [0 0.3], grid);
xlim([152 178]);   % western Pacific window

%% Row 4
% GIPY05e (meridional)
ax = p(4,1);
draw_panel(ax, grid.yt, 'Latitude', Th232dat.GIPY05e.xsec, ...
    'GIPY05e Observed [Th232] (pM)', [0 0.5], grid);
xlim([-70 -40]);   % Southern Ocean sector

% GSc02 (meridional)
ax = p(4,2);
draw_panel(ax, grid.yt, 'Latitude', Th232dat.GSc02.xsec, ...
    'GSc02 Observed [Th232] (pM)', [0 0.3], grid);
xlim([-68 -53]);   % Scotia Sea window


function draw_panel(ax, xaxis, xlab, XSEC, titleStr, crange, grid)
% DRAW_PANEL  Render a single cross-section panel with its own colorbar.
%
% Inputs
%   ax       : target axes handle (from subplot)
%   xaxis    : coordinate vector for horizontal axis (grid.xt or grid.yt or shifted x)
%   xlab     : x-axis label string ('Longitude' or 'Latitude')
%   XSEC     : 2-D cross-section array (size: [nx|ny] x nz) matching xaxis & grid.zt
%   titleStr : panel title
%   crange   : 1x2 vector for color axis limits, e.g., [0 0.5]
%   grid     : grid struct with field zt (depth coordinates)
%
% Behavior
%   • Draws a filled contour (contourf) with 100 levels, no contour lines.
%   • Adds a per-panel colorbar and sets axis labels/limits/fonts.
%   • Depth axis is plotted as negative to increase downward.

    axes(ax); %#ok<LAXES>
    contourf(xaxis, -grid.zt, XSEC', 100, 'LineStyle','none');  % filled contours
    shading flat; 
    box on; 
    colorbar;                      % per-panel colorbar
    caxis(crange);                 % cruise-specific dynamic range
    ylim([-5400 0]);               % depth range; adjust if your grid differs
    ax.FontSize = 9;
    xlabel(xlab, 'FontSize',12);
    ylabel('Depth (m)', 'FontSize',12);
    title(titleStr, 'FontSize',12);
end
