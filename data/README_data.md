# Processed data files

The files in this directory are processed intermediate data used to reproduce the figures and analyses. They are derived from publicly available CMIP6 and NAHosMIP model outputs.

## File inventory

| File | Description | Used by |
|---|---|---|
| `moc_at_cmip6_hist_sst245.mat` | Atlantic meridional overturning circulation fields for CMIP6 historical and SSP245 periods. | CMIP6 AMOC index, scatter plots, SST/regression maps, sector plots |
| `moc_ip_cmip6_hist_sst245.mat` | Indo-Pacific meridional overturning circulation fields for CMIP6 historical and SSP245 periods. | PMOC analyses and PMOC contour overlays |
| `sst_global_cmip6_hist_sst245.mat` | CMIP6 historical and SSP245 sea-surface temperature fields. | EEW index and SST pattern plots |
| `Q_cmip6_hist_sst245.mat` | Surface heat-flux terms used for mixed-layer heat-budget maps. | Heat-budget pattern scripts |
| `ADV_cmip6_hist_sst245.mat` | Processed ocean advection terms used for mixed-layer heat-budget maps. | Ocean-advection pattern scripts |
| `tau_cmip6_hist_sst245.mat` | Surface wind-stress fields used for wind-stress vector overlays. | Wind-stress vector overlays |
| `To_eq_cmip6_hist_sst245_histWo.mat` | Equatorial Indo-Pacific temperature and vertical-velocity processed data. | Longitude-depth sector plots |
| `To_IP_cmip6_hist_sst245.mat` | Indo-Pacific zonal-mean ocean temperature processed data. | Latitude-depth sector plots |
| `IVT1500to3000_cmip6_hist_sst245.mat` | CMIP6 1500–3000 m volume transport derived from `uo` and `vo`. | Deep transport maps |
| `OHVx_1500mto3000m_global_cmip6_hist_sst245.mat` | 1500–3000 m zonal volume transport integrated over selected sectors. | Transport scatter plots |
| `OHVy_1500mto3000m_global_cmip6_hist_sst245.mat` | 1500–3000 m meridional volume transport integrated over selected sectors. | Transport scatter plots |
| `amoc_hos_piCtl.mat` | AMOC indices for hosing and piControl experiments. | Hosing AMOC–EEW scatter plot |
| `eew_hos_piCtl.mat` | EEW indices for hosing and piControl experiments. | Hosing AMOC–EEW scatter plot |
| `pmoc_hos_piCtl.mat` | PMOC fields for hosing and piControl experiments. | Hosing PMOC and sector plots |
| `To_eq_hos_piCtlWo.mat` | Equatorial hosing temperature and vertical-velocity processed data. | Hosing longitude-depth sector plots |
| `To_IP_hos_piCtl.mat` | Indo-Pacific zonal-mean hosing temperature processed data. | Hosing latitude-depth sector plots |
| `IVT1500to3000_hosing.mat` | Hosing 1500–3000 m volume transport response derived from `uo` and `vo`. | Hosing deep transport maps |
| `sst_hosing_response_TropicalMeanRomoved.mat` | Tropical-mean-removed SST response in hosing experiments. | Hosing SST response maps |
| `tos_hosing_response_TropicalMeanRomoved.mat` | Tropical-mean-removed `tos` response in hosing experiments. | Hosing `tos` response maps |

## Recommended checks before upload

Before pushing to GitHub, check the size of each file:

```bash
find data -type f -size +90M -print
```

Files larger than 100 MB should be tracked with Git LFS or deposited in a data repository and linked from the README.
