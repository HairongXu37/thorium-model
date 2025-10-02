% th232_data_pipeline.m — build the 232Th dataset once
%
% What this does:
%   - Adds paths
%   - Sets input/output names
%   - If the output MAT file exists, it skips; otherwise it runs th232_pipeline
%   - Saves Th232dat to OutFile
%
% Toggle:
%   Overwrite = true to force a rebuild.

% Run the GEOTRACES 232Th pipeline once (with overwrite control).

addpath(genpath('../src'));
addpath(genpath('../utils'));

GridFile = '../utils/GRID.mat';
DataFile = '../GEOTRACES_IDP2021_Seawater_Discrete_Sample_Data_v1.nc';
OutFile  = 'Th232_bgrid.mat';
ErrFrac  = 0.05;    % relative error applied to 232Th
Overwrite = false;   % set true to force re-run

if ~Overwrite && exist(OutFile,'file')
    fprintf('[th232_data_pipeline] %s exists — skipping. Set Overwrite=true to re-run.\n', OutFile);
else
    Th232dat = th232_pipeline( ...
        'GridFile',GridFile, ...
        'DataFile',DataFile, ...
        'OutFile',OutFile, ...
        'ErrFrac',ErrFrac);
    fprintf('[th232_data_pipeline] Done. Saved -> %s\n', OutFile);
end
