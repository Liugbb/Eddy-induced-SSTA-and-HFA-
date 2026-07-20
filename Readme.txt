Code Description
This repository contains four main components: Observational_data, iHESP, Eddy_track, and XGBoost&SHAP.
1. Observational_data
The Observational_data folder contains scripts used to extract eddy-centred sea surface temperature anomaly (SSTA) and turbulent heat-flux anomaly (HFA) patches from satellite observations, calculate the SSTA structural index (\alpha) and the net HFA ratio, and estimate the air–sea thermal damping rate.
read_eddy_HFA_SSTA
Extracts eddy-centred SSTA and sensible and latent heat-flux anomaly patches from satellite observations using the identified eddy trajectories and properties.
read_HFA_alpha_quantify
Calculates the SSTA structural index (\alpha) and quantifies the eddy-core HFA properties, including the net and absolute HFA contributions.
read_air_sea_damping
Estimates the air–sea thermal damping rate from the spatial relationship between eddy-induced SSTA and HFA and calculates the corresponding normalized damping rate.
2. iHESP
The iHESP folder contains scripts used to process the iHESP model output and extract eddy-centred variables.
data_transfer
Extracts the required variables from the original iHESP model output and interpolates or converts them onto a standard spatial grid.
cal_geostrophic_data
Calculates the surface geostrophic velocity from sea surface height (SSH).
SSTA_HFA_eddy
Uses the identified eddy trajectories and properties to extract the SSTA and HFA patches associated with each eddy.
3. Eddy_track
The Eddy_track code applies the mesoscale eddy identification and tracking algorithm provided by Dong et al. (2022) to the processed SSH and geostrophic velocity fields. It provides the trajectories and properties of individual eddies required for the subsequent extraction of eddy-centred SSTA and HFA fields.
The overall iHESP processing workflow is:
raw iHESP output → standard gridded data → geostrophic velocity calculation → eddy identification and tracking → extraction of eddy-centred SSTA and HFA patches
4. XGBoost&SHAP
The XGBoost&SHAP folder contains scripts used to analyse and visualize the outputs from the XGBoost model and the SHAP attribution analysis.
read_XGBoost&SHAP_result
Uses the model-output data to generate figures showing the XGBoost predictions and SHAP analysis results.
read_SHAP_different_factor
Generates scatter plots illustrating the relationships between individual predictor variables and their corresponding SHAP values.
read_SHAP_global_distribution
Generates global spatial maps of the SHAP values associated with the different predictor variables.