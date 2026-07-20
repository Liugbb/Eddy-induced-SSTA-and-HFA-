# -*- coding: utf-8 -*-
"""
Created on Tue Jan  6 17:18:01 2026

@author: bing2
"""


import pandas as pd
import numpy as np
import shap
import matplotlib.pyplot as plt

# ========= 1) paths & column ranges =========
file = r"I:\Eddy_SSTA_structure\Normalized_distance\XGBoost_SHAP_new\Normalized\Without_lat\xgb_shap_values_without_lat_data.csv"

# Excel-style columns to 0-based indices:
# A=0, B=1, ..., G=6, H=7, J=9, K=10, O=14, P=15, Q=16, R=17
feat_idx = [6, 7, 9, 10]          # G,H,J,K
shap_idx = [14, 15, 16, 17]       # O,P,Q,R

feature_names = ["U/c", "Strain rate", "SST gradient", "damping rate",'Latitude']

# ========= 2) read only needed columns =========
# Read without dtype guessing issues; handle huge file robustly
df = pd.read_csv(file, header=0)  # if your csv has no header, set header=None

X = df.iloc[:, feat_idx].to_numpy(dtype=float)
S = df.iloc[:, shap_idx].to_numpy(dtype=float)

# Basic cleaning: remove rows with NaN/Inf in either X or S
mask = np.isfinite(X).all(axis=1) & np.isfinite(S).all(axis=1)
X = X[mask]
S = S[mask]
# 对纬度取绝对值（南北半球一致）
X[:, -1] = np.abs(X[:, -1])
# ========= 3) build SHAP Explanation (recommended by SHAP docs) =========
# SHAP expects shape (n_samples, n_features)
exp = shap.Explanation(
    values=S,
    data=X,
    feature_names=feature_names
)

# ========= 4) plot: official beeswarm =========
plt.figure(figsize=(7.6, 4.6), dpi=150)

# Create the beeswarm plot and capture the mappable object for the colorbar
shap_plot = shap.plots.beeswarm(exp, max_display=len(feature_names), show=False)

# Get the mappable object for the colorbar
mappable = shap_plot.collections[0]  # The scatter plot collection

# Customize label size and colorbar width
plt.xticks(fontsize=8)  # Change x-axis font size
plt.yticks(fontsize=8)  # Change y-axis font size

# # Adjust colorbar's width and font size
# cb = plt.colorbar(mappable)  # Pass the mappable object to colorbar
# cb.ax.tick_params(labelsize=12)  # Set colorbar tick labels' font size
# cb.ax.set_aspect(20)  # Control the width of the colorbar (larger means thinner)

# # Set the label font size for colorbar
# cb.set_label('Feature value', fontsize=14)

plt.savefig("shap_summary_beeswarm.png", dpi=600, bbox_inches="tight")
plt.tight_layout()
plt.show()


# ========= 5) Plot: Bar chart for mean SHAP values =========
# Calculate mean absolute SHAP values for each feature
# Using shap.summary_plot() directly to plot the bar chart
plt.figure(figsize=(10, 5), dpi=150)

# Create the summary plot with plot_type="bar" to display mean(|SHAP value|)
shap.summary_plot(S, X, plot_type="bar", feature_names=feature_names)


# plt.xticks(fontsize=8)  # Change x-axis font size
plt.savefig("shap_summary_bar_chart.png", dpi=600, bbox_inches="tight")
# Show the plot
plt.tight_layout()
plt.show()

