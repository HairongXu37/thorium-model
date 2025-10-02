function D = load_geotraces_th232(ncFile, errFrac)
%LOAD_GEOTRACES_TH232 Read GEOTRACES IDP2021 discrete 232Th dataset.
%
% Syntax
%   D = load_geotraces_th232(ncFile, errFrac)
%
% Description
%   Reads required variables from a GEOTRACES IDP2021 NetCDF file and
%   returns a struct with both per-station vectors and depth-expanded
%   arrays. 232Th uncertainties are computed as a fixed fraction
%   (errFrac) of the reported concentrations.
%
% Inputs
%   ncFile   Path to the GEOTRACES IDP2021 NetCDF file.
%   errFrac  Relative error applied to 232Th (e.g., 0.05 for 5%).
%
% Output
%   D        Struct with fields:
%              % Per-station vectors (length = number of stations)
%              .cruise  (cellstr)   Cruise IDs from 'metavar1'
%              .stn     (cellstr)   Station IDs from 'metavar2'
%              .date    (vector)    Station times from 'date_time'
%              .lat     (vector)    Latitudes from 'latitude'
%              .lon     (vector)    Longitudes from 'longitude'
%
%              % Depth × station arrays (levels × stations)
%              .depth   (L×S)       Depth from 'var2'
%              .Th232   (L×S)       232Th (pM) from 'var213'
%              .Th232err(L×S)       = errFrac .* Th232
%
%              % Expanded per-sample metadata matching depth arrays
%              .LAT     (L×S)       Repeated latitudes per depth
%              .LON     (L×S)       Repeated longitudes per depth
%              .DATE    (L×S)       Repeated times per depth
%
% Notes
%   • Expected NetCDF variable names (IDP2021):
%       'metavar1' (cruise), 'metavar2' (station), 'date_time',
%       'latitude', 'longitude', 'var2' (depth), 'var213' (232Th, pM).
%   • Dimensions: depth arrays are (levels × stations). The expanded
%     LAT/LON/DATE match those dimensions for per-sample operations.

cruise = ncread(ncFile,'metavar1');
stn    = ncread(ncFile,'metavar2');
date   = ncread(ncFile,'date_time');
lat    = ncread(ncFile,'latitude');
lon    = ncread(ncFile,'longitude');
depth  = ncread(ncFile,'var2');
Th232  = ncread(ncFile,'var213'); % pM

Th232err = Th232 .* errFrac;

% Make text into cell arrays
cruise = cellstr(cruise');
stn    = cellstr(stn');

% Expand lat/lon/date along depth dimension
nsample = size(depth,1);
LAT  = repmat(lat',[nsample,1]);
LON  = repmat(lon',[nsample,1]);
DATE = repmat(date',[nsample,1]);

D = struct('cruise',{cruise}, 'stn',{stn}, 'date',date, ...
           'lat',lat, 'lon',lon, 'depth',depth, ...
           'Th232',Th232, 'Th232err',Th232err, ...
           'LAT',LAT, 'LON',LON, 'DATE',DATE);
end
