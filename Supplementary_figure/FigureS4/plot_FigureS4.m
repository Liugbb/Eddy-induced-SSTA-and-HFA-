% Plot Figure S4 from the percentages saved by prepare_FigureS4.m.
scriptDir = fileparts(mfilename('fullpath'));
sourceFile = fullfile(scriptDir, 'SourceDataFigureS4.mat');
if ~isfile(sourceFile)
    error('Run prepare_FigureS4.m first to create %s.', sourceFile);
end
S = load(sourceFile, 'center', 'binPercent', 'sampleCount', 'groupNames', 'periodYears');

% As in the original comparison, show curves only when both periods contain
% observations for that eddy group. All panels use the same vertical scale.
percent = S.binPercent;
percent(:,any(S.sampleCount == 0, 2),:) = NaN;
finitePercent = percent(isfinite(percent));
yMax = 10;
if ~isempty(finitePercent)
    yMax = max(10, 2 * ceil(max(finitePercent) / 2));
end
% Keep the original panel-letter height where it fits inside the axes.
labelY = min(11.3, 0.95*yMax);

fig = figure('Name', 'Figure S4', 'NumberTitle', 'off', ...
    'Color', 'w', 'Units', 'pixels', 'Position', [100 200 1450 480]);
% Axes positions are fractions of the figure [left bottom width height].
pos = [0.07  0.18 0.27 0.68; ...
       0.385 0.18 0.27 0.68; ...
       0.70  0.18 0.27 0.68];
panelLabels = {'(a)', '(b)', '(c)'};
periodLabels = {sprintf('%d-%d', S.periodYears(1,:)), ...
                sprintf('%d-%d', S.periodYears(2,:))};

for g = 1:numel(S.groupNames)
    ax = axes('Parent', fig, 'Units', 'normalized', 'Position', pos(g,:));
    % Use circles for the early period and squares for the late period.
    plot(ax, S.center, percent(:,g,1), '-o', 'LineWidth', 2.2, 'MarkerSize', 5);
    hold(ax, 'on');
    plot(ax, S.center, percent(:,g,2), '-s', 'LineWidth', 2.2, 'MarkerSize', 5);
    xlabel(ax, '\alpha', 'FontSize', 22, 'FontName', 'Arial', 'Interpreter', 'tex');
    if g == 1
        ylabel(ax, 'Percentage (%)', 'FontSize', 22, 'FontName', 'Arial');
    end
    title(ax, S.groupNames{g}, 'FontSize', 20, 'FontWeight', 'normal', 'FontName', 'Arial');
    legend(ax, periodLabels, 'Location', 'northeast', 'FontSize', 16, 'Box', 'off');
    set(ax, 'FontSize', 18, 'FontName', 'Arial', 'LineWidth', 1.2, ...
        'TickDir', 'out', 'XLim', [0 1], 'YLim', [0 yMax], 'XTick', 0:0.2:1);
    text(ax, 0.05, labelY, panelLabels{g}, 'FontSize', 18);
    box(ax, 'on');
    grid(ax, 'on');
end
