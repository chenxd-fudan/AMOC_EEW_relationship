# Code files

This directory contains MATLAB plotting scripts and shell preprocessing scripts.

## MATLAB plotting scripts

| Script | Purpose |
|---|---|
| `PlotPattern_cmip6_dSST_dAMOC_regressedSST.m` | CMIP6 projected SST pattern, AMOC-regressed SST pattern, and AMOC weakening pattern. |
| `PlotScatter_cmip6_AMOC_PMOC_EEW_OVT.m` | CMIP6 scatter plots among AMOC, PMOC, EEW, T500, and ocean transport indices. |
| `PlotScatter&Pattern_hosing_AMOC_EEW.m` | Hosing AMOC–EEW scatter plot and hosing SST response pattern. |
| `PlotSector_cmip6_PT.m` | CMIP6 longitude-depth and latitude-depth Pacific temperature sector plots. |
| `PlotSector_hosing_PT.m` | Hosing longitude-depth and latitude-depth Pacific temperature sector plots. |
| `PlotSector_hosing_PT_real.m` | Alternative or final hosing Pacific temperature sector plot. |
| `PlotPattern_cmip6_MLB.m` | CMIP6 mixed-layer heat-budget and ocean-advection maps. |
| `PlotPattern_cmip6_OVT.m` | CMIP6 deep ocean volume transport maps. |
| `PlotPattern_hosing_OVT.m` | Hosing deep ocean volume transport maps. |
| `PlotPattern_hosing_OVT_real.m` | Alternative or final hosing ocean volume transport maps. |

## Preprocessing scripts

| Script | Purpose |
|---|---|
| `calc_cmip6_hist_ssps_1x1.sh` | Preprocess CMIP6 historical and SSP outputs to 1°×1° fields. |
| `calc_cmip6_picontrol.sh` | Preprocess CMIP6 piControl outputs. |
| `calc_NAHosMIP.sh` | Preprocess NAHosMIP hosing and piControl outputs. |
| `grid_1.0x1.0` | CDO target grid file used for regridding. |

## MATLAB path

Run the plotting scripts from the repository root, or add the helper functions to the MATLAB path:

```matlab
addpath(genpath('./code'));
addpath('./');
```

If a script uses

```matlab
dir = '';
```

set it to

```matlab
dir = './data/';
```

before running from the repository root.
