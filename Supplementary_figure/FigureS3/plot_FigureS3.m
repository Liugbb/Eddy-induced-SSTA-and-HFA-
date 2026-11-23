% Reproduce Figure S3 in two windows from SourceDataFigureS3.mat.
% Run prepare_FigureS3.m once before using this script.
scriptDir = fileparts(mfilename('fullpath'));
sourceFile = fullfile(scriptDir, 'SourceDataFigureS3.mat');
if ~isfile(sourceFile)
    error('Run prepare_FigureS3.m first to create %s.', sourceFile);
end
S = load(sourceFile);

% Panels (a)-(d). Keep the first matrix dimension along Rnx, as in the
% original [Lat,Lon] = meshgrid(Y,X) followed by contourf(Lon,Lat,...).
[Rnx, Rny] = ndgrid(S.Rnx, S.Rny);
maps = {S.HFA_mono_AE, S.HFA_mono_CE, S.HFA_dio_AE, S.HFA_dio_CE};
mapTitles = {'HFA in monopole AE', 'HFA in monopole CE', ...
             'HFA in dipole AE',   'HFA in dipole CE'};
panelLabels = {'(a)', '(b)', '(c)', '(d)'};
panelLeft = [0, 0.2, 0.5, 0.7];
colorLimits = [12, 12, 4, 4];
% The original contour intervals differ by eddy structure and polarity.
darkLevels  = {0:4:12, [],        0:1:4,       0:0.4:4};
lightLevels = {[],     -12:4:-1, -4:0.4:-0.1, -4:1:-0.1};

figMaps = figure('Name', 'Figure S3 (a-d)', 'NumberTitle', 'off', ...
    'Units', 'pixels', 'Position', [100 100 1400 900]);
for k = 1:numel(maps)
    pos = [panelLeft(k), 0.68, 0.3, 0.28];
    ax = axes('Parent', figMaps, 'Units', 'normalized', 'Position', pos);
    contourf(ax, Rnx, Rny, maps{k}, 1000, 'LineStyle', 'none');
    colormap(ax, S.CustomColormap);
    shading(ax, 'interp');
    caxis(ax, [-colorLimits(k), colorLimits(k)]);
    axis(ax, 'equal');
    set(ax, 'XLim', [-2 2], 'YLim', [-2 2], 'XTick', -4:4, ...
        'YTick', -4:4, 'LineWidth', 2, 'FontSize', 16, 'FontWeight', 'normal');
    xlabel(ax, 'R_{nx}', 'FontSize', 16, 'FontWeight', 'normal');
    title(ax, mapTitles{k}, 'FontSize', 16, 'FontWeight', 'normal');

    if k == 1 || k == 3
        ylabel(ax, 'R_{ny}', 'FontSize', 16, 'FontWeight', 'normal');
    else
        % Place one vertical colorbar to the right of each AE/CE pair.
        ax.YTickLabel = [];
        cb = colorbar(ax, 'eastoutside');
        set(cb, 'Units', 'normalized', 'Position', [panelLeft(k)+0.25, 0.68, 0.01, 0.28], ...
            'Ticks', linspace(-colorLimits(k), colorLimits(k), 5), ...
            'FontSize', 16, 'AxisLocation', 'out', 'Box', 'on', 'LineWidth', 2);
        set(cb.Title, 'String', 'W/m^2', 'FontSize', 16, ...
            'Position', [5 190 0], 'FontWeight', 'normal');
        ax.Position = pos;
    end

    % Draw and label the dark and light contour lines separately.
    hold(ax, 'on');
    if ~isempty(darkLevels{k})
        addContours(ax, Rnx, Rny, maps{k}, darkLevels{k}, [0.4 0.4 0.4], 'k');
    end
    if ~isempty(lightLevels{k})
        addContours(ax, Rnx, Rny, maps{k}, lightLevels{k}, [0.9 0.9 0.9], 'w');
    end
    % Place black panel letters on a white background with a small margin.
    text(ax, -1.8, 1.8, panelLabels{k}, 'Color', 'k', 'FontSize', 16, ...
        'FontWeight', 'normal', 'BackgroundColor', 'w', 'EdgeColor', 'none', 'Margin', 2);
    hold(ax, 'off');
end

% Panel (e). Plot anticyclones above cyclones in a separate figure.
figBars = figure('Name', 'Figure S3 (e)', 'NumberTitle', 'off', ...
    'Units', 'pixels', 'Position', [100 100 1400 400]);
barColors = [25 86 150; 59 173 196; 236 141 57; 236 86 74] / 255;
regionTicks = 1:numel(S.regionNames);
axAE = axes('Parent', figBars, 'Units', 'normalized', 'Position', [0.08 0.62 0.88 0.32]);
drawBars(axAE, S.HFA_AE, barColors, regionTicks, [-0.2 1]);
axCE = axes('Parent', figBars, 'Units', 'normalized', 'Position', [0.08 0.25 0.88 0.32]);
barsCE = drawBars(axCE, S.HFA_CE, barColors, regionTicks, [-1 0.2]);
legend(axCE, barsCE, {'0~0.25', '0.25~0.5', '0.5~0.75', '0.75~1'}, ...
    'Location', 'south', 'NumColumns', 4, 'Box', 'off', 'FontSize', 13);

% Use a separate x-axis for the five region names. Align it with the bars,
% hide its y-axis and remove the top and right borders.
regionAxis = axes('Parent', figBars, 'Units', 'normalized', ...
    'Position', [0.08 0.18 0.88 0.08], 'Color', 'none');
set(regionAxis, 'XLim', xlim(axCE), 'YLim', [-1 1], 'XTick', regionTicks, ...
    'XTickLabel', S.regionNames, 'XAxisLocation', 'origin', 'YTick', [], ...
    'YColor', 'none', 'Box', 'off', 'FontSize', 15, 'LineWidth', 2, 'FontWeight', 'normal');

% Position the parameter, polarity and panel labels in figure coordinates.
annotation(figBars, 'textbox', [0.01 0.62 0.25 0.08], 'String', '$\varepsilon_Q$', ...
    'Interpreter', 'latex', 'FitBoxToText', 'on', 'EdgeColor', 'none', ...
    'BackgroundColor', 'none', 'FontSize', 28, 'FontWeight', 'normal');
addFigureLabel(figBars, 0.95, 0.90, 'Anticyclone', 'none');
addFigureLabel(figBars, 0.95, 0.32, 'Cyclone', 'none');
addFigureLabel(figBars, 0.12, 0.90, '(e)', 'none');
addFigureLabel(figBars, 0.36, 0.30, '$\alpha$:', 'latex');

function addContours(ax, x, y, field, levels, lineColor, textColor)
    [C, h] = contour(ax, x, y, field, levels, 'LineColor', lineColor, 'LineWidth', 1.2);
    clabel(C, h, 'Color', textColor, 'FontSize', 10, ...
        'FontWeight', 'normal', 'LabelSpacing', 400);
end

function bars = drawBars(ax, stats, colors, regionTicks, yLimits)
    % Rows are regions and columns are the four alpha groups.
    means = stats(:,2:2:end).';
    ci = stats(:,3:2:end).';
    bars = bar(ax, regionTicks, means, 'grouped');
    hold(ax, 'on');
    % Add symmetric 95% confidence intervals at the original bar offsets.
    offsets = [-0.272, -0.09, 0.09, 0.272];
    for k = 1:numel(bars)
        set(bars(k), 'FaceColor', colors(k,:), 'FaceAlpha', 1, 'EdgeColor', 'none');
        errorbar(ax, regionTicks(:) + offsets(k), means(:,k), ci(:,k), 'k', ...
            'LineStyle', 'none', 'LineWidth', 1.3);
    end
    % Place the x-axis at zero, keep the y-axis on the left and point ticks outward.
    set(ax, 'FontSize', 15, 'LineWidth', 2, 'XTick', regionTicks, 'XTickLabel', [], ...
        'TickDir', 'out', 'Box', 'off', 'XAxisLocation', 'origin', ...
        'YAxisLocation', 'left', 'YLim', yLimits);
    hold(ax, 'off');
end

function addFigureLabel(fig, x, y, label, interpreter)
    annotation(fig, 'textarrow', [x x], [y y], 'String', label, ...
        'Interpreter', interpreter, 'HeadStyle', 'none', 'LineStyle', 'none', ...
        'FontSize', 18, 'FontWeight', 'normal');
end
