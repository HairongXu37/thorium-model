# GEOTRACES 232Th

## What is this?
A MATLAB pipeline that grids **GEOTRACES IDP2021** discrete seawater **232Th** data onto a model grid, builds per-cruise products, and saves a single output file.

## Main code
- **One-click runner (entry point):** `pipeline/run_th232_pipeline.m`

## Dataset
- Source: **GEOTRACES IDP2021** (seawater discrete samples, NetCDF)
- Variables used (IDP2021 names): `metavar1` (cruise), `metavar2` (station), `date_time`, `latitude`, `longitude`, `var2` (depth), `var213` (232Th)

## Units
- **232Th:** picomolar (**pM**)
- **Longitude/Latitude:** degrees (0–360 for lon in grid; stations wrapped as needed)
- **Depth:** units of `grid.zt` (typically meters)

## Output
- **File:** `Th232_bgrid.mat`
- **Struct:** `Th232dat`  
  - **Per cruise** (e.g., `GA02`, `GA03w`, `GA03e`, `GA10`, `GP16`, `GPc01w`, `GIPY05w`, `GIPY05e`, `GSc02`): `.mu/.var/.n` (3-D fields), `.Mc` (mask), `.xsec` (cross-section), `.x/.y` (track)  
  - **Global:** `glob.mu/.var/.n`, `glob.mu2` (longitude-reordered view)

## Data Visuals — GEOTRACES 232Th
- **Code:**:** `pipeline/plot_th232_xsecs.m`
- A single, multi-panel **(4×2)** figure with cross-sections for:
  **GA02, GA03w, GA03e, GA10, GP16, GPc01w, GIPY05e, GSc02**  
- Independent colorbars per panel (keeps each cruise’s dynamic range readable)
- Depth plotted downwards (negative), units in **pM** for 232Th
