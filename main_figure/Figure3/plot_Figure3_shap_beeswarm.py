"""Draw the four-predictor SHAP beeswarm from the MAT file beside this script."""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.cm import ScalarMappable
from matplotlib.colors import LinearSegmentedColormap, Normalize
from matplotlib.ticker import MultipleLocator
from scipy.io import loadmat

folder = Path(__file__).resolve().parent
data = loadmat(folder / "SourceDataFigure3_shap_beeswarm.mat", simplify_cells=True)
features = data["feature_values"]
shap_values = data["shap_values"]
names = data["feature_names"]
cmap = LinearSegmentedColormap.from_list("feature_value", data["palette_rgb"] / 255)

# Draw the most important row at the top. Each dot retains its signed SHAP value.
order = np.argsort(np.abs(shap_values).mean(axis=0))
rng = np.random.default_rng(42)
fig, ax = plt.subplots(figsize=(7.6, 3.23))
fig.subplots_adjust(left=0.164, right=0.861, bottom=0.177, top=0.949)
ax.axvline(0, color="#999999", linewidth=1.4, zorder=0)

for row, col in enumerate(order):
    sample = rng.permutation(len(shap_values))
    x = shap_values[sample, col]
    values = features[sample, col]

    # Stack nearby points in 100 SHAP intervals, alternating above and below the row.
    bins = np.rint(100 * (x - x.min()) / (np.ptp(x) + 1e-8)).astype(int)
    offset = np.zeros(len(x))
    for b in np.unique(bins):
        idx = np.flatnonzero(bins == b)
        rng.shuffle(idx)
        slot = np.arange(len(idx))
        offset[idx] = ((slot + 1) // 2) * np.where(slot % 2 == 1, 1, -1)
    offset *= 0.36 / (offset.max() + 1)

    # Scale colors within each predictor. Extreme values use the endpoint colors.
    low, high = np.percentile(values, [5, 95])
    ax.axhline(row, color="#d7d7d7", linestyle=(0, (1, 4)), linewidth=0.5, zorder=0)
    ax.scatter(x, row + offset, c=values, cmap=cmap, vmin=low, vmax=high,
               s=16, linewidths=0, zorder=2)

ax.set(ylim=(-1, len(order)), yticks=range(len(order)), yticklabels=names[order])
ax.set_xlabel("SHAP value (impact on model output)", fontsize=13.8)
ax.xaxis.set_major_locator(MultipleLocator(0.05))
ax.tick_params(axis="x", pad=3.8, labelsize=8.5, colors="#333333")
ax.tick_params(axis="y", length=0, pad=24.5, labelsize=8.5, colors="#333333")
ax.spines[["top", "right", "left"]].set_visible(False)

cax = fig.add_axes([0.903, 0.177, 0.0043, 0.772])
bar = fig.colorbar(ScalarMappable(norm=Normalize(0, 1), cmap=cmap), cax=cax)
bar.set_ticks([0, 1], labels=["Low", "High"])
bar.ax.tick_params(length=0, labelsize=11.7, pad=4)
bar.set_label("Feature value", fontsize=12.8, labelpad=0)
bar.outline.set_visible(False)

fig.savefig(folder / "shap_summary_beeswarm_without_lat.png", dpi=600, facecolor="white")
plt.show()
