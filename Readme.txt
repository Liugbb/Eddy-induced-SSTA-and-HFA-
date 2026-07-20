This repository contains three main components: iHESP, Eddy_track, and XGBoost&SHAP.
1. iHESP
The iHESP folder contains the scripts used to process the iHESP model output and extract eddy-centred variables. The main scripts and their functions are described below.
data_transfer
Extracts the required variables from the original iHESP model output and interpolates or converts them onto a standard spatial grid.
cal_geostrophic_data
Calculates the surface geostrophic velocity from sea surface height (SSH).
SSTA_HFA_eddy
Uses the identified eddy trajectories and properties to extract the sea surface temperature anomaly (SSTA) and turbulent heat-flux anomaly (HFA) patches associated with each eddy.
2. Eddy_track
The Eddy_track code applies the mesoscale eddy identification and tracking algorithm provided by Dong et al. (2022) to the processed SSH and geostrophic velocity fields. It provides the trajectories and properties of individual eddies required for the subsequent extraction of eddy-centred SSTA and HFA fields.
The overall processing workflow is:
raw iHESP output → standard gridded data → geostrophic velocity calculation → eddy identification and tracking → extraction of eddy-centred SSTA and HFA patches
3. XGBoost&SHAP
The XGBoost&SHAP folder contains scripts used to analyse and visualize the outputs from the XGBoost model and the SHAP attribution analysis.
draw_shap_varies
Uses the model-output data to generate figures showing the XGBoost predictions and SHAP analysis results.
draw_figure
Generates scatter plots illustrating the relationships between individual predictor variables and their corresponding SHAP values.