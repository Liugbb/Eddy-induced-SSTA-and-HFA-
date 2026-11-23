% Reproduce the two Figure S5 regional trend figures from saved source data.
% Run prepare_FigureS5.m once before running this script.
clc
clear
scriptDir = fileparts(mfilename('fullpath'));
sourceFile = fullfile(scriptDir, 'SourceDataFigureS5.mat');
if ~isfile(sourceFile)
    error('Run prepare_FigureS5.m first to create %s.', sourceFile);
end
D = load(sourceFile, 'regionNames', 'HFA', 'Alpha');

% Y-axis limits follow the original figures, in AS, KE, STCC, GS, ACC order.
hfaLimits = [-0.05 0.25; 0.05 0.35; -0.05 0.2501; 0 0.3; 0.05 0.35];
alphaLimits = [0.20 0.35; 0.25 0.40; 0.20 0.35; 0.25 0.40; 0.25 0.40];
drawTrendFigure(D.HFA, D.regionNames, hfaLimits, 'Figure S5 - HFA regional trend');
alphaAxes = drawTrendFigure(D.Alpha, D.regionNames, alphaLimits, 'Figure S5 - Alpha regional trend');
linkaxes(alphaAxes, 'x');

function ax = drawTrendFigure(S, regionNames, yLimits, windowName)
    colors = [0.00 0.45 0.74; 0.85 0.33 0.10; 0.47 0.67 0.19; ...
              0.93 0.69 0.13; 0.49 0.18 0.56];
    fig = figure('Name', windowName, 'NumberTitle', 'off', ...
        'Units', 'pixels', 'Position', [100 100 700 1000]);

    % Preserve the original six-slot layout and the five occupied rows.
    top = 0.975;
    bottom = 0.08;
    gap = 0.02;
    nSlots = 6;
    height = (top - bottom - gap*(nSlots-1)) / nSlots;
    tickYears = (1993:5:2018).';
    tickDates = datenum(tickYears, ones(size(tickYears)), ones(size(tickYears)));
    xRange = [S.monthDate(1), datenum(2019,1,1)];
    ax = gobjects(numel(regionNames),1);

    for r = 1:numel(regionNames)
        y0 = top - r*height - (r-1)*gap;
        ax(r) = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.10 y0 0.78 height]);
        a = ax(r);
        hold(a, 'on');
        color = colors(r,:);
        hasFit = isfinite(S.fitDate(1,r));

        % Draw the mean-response confidence band underneath all three curves.
        if hasFit
            x = S.fitDate(:,r);
            fill(a, [x; flipud(x)], [S.fitLower95(:,r); flipud(S.fitUpper95(:,r))], ...
                color, 'EdgeColor', 'none', 'FaceAlpha', 0.18);
        end
        % Use a pale version of the regional color for the raw monthly means.
        plot(a, S.monthDate, S.monthMean(:,r), '-', ...
            'Color', 0.75*[1 1 1] + 0.25*color, 'LineWidth', 1.0);
        plot(a, S.monthDate, S.rollingMean(:,r), '-', 'Color', color, 'LineWidth', 1.5);
        if hasFit
            plot(a, x, S.fitMean(:,r), '-', 'Color', color, 'LineWidth', 2);
            label = fitLabel(S.slopePerDecade(r), S.slopeCI95HalfWidth(r), S.pValue(r));
            text(a, 0.05, 1, label, 'Units', 'normalized', 'FontSize', 14, ...
                'Color', color, 'FontWeight', 'bold', 'Interpreter', 'latex');
        else
            text(a, 0.05, 0.78, regionNames{r}, 'Units', 'normalized', ...
                'FontSize', 12, 'Color', color, 'FontWeight', 'bold');
        end

        % Alternate the side of the y-axis. Show years on the bottom plotted row.
        ySide = 'left';
        if mod(r,2) == 0
            ySide = 'right';
        end
        set(a, 'FontSize', 13, 'LineWidth', 1.6, 'Box', 'off', 'TickDir', 'out', ...
            'YAxisLocation', ySide, 'YColor', 'k', 'XLim', xRange, 'YLim', yLimits(r,:));
        if r < numel(regionNames)
            set(a, 'XTick', [], 'XColor', 'none');
        else
            set(a, 'XColor', 'k', 'XTick', tickDates, 'XTickLabel', cellstr(num2str(tickYears)));
            xlabel(a, 'Year', 'FontSize', 14);
        end
        ylabel(a, regionNames{r}, 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');
    end
end

function label = fitLabel(slope, halfWidth, pValue)
% Express the slope and its 95% CI half-width with a common power of ten.
    if ~isfinite(slope)
        slopeText = 'NaN';
    elseif slope == 0
        slopeText = '0.00';
    else
        exponent = floor(log10(abs(slope)));
        mantissa = round(slope / 10^exponent, 2);
        if abs(mantissa) >= 10
            mantissa = mantissa / 10;
            exponent = exponent + 1;
        end
        slopeText = sprintf('%.2f\\pm%.2f\\times 10^{%d}', ...
            mantissa, round(halfWidth / 10^exponent, 2), exponent);
    end
    if ~isfinite(pValue)
        pText = '=\mathrm{NaN}';
    elseif pValue < 0.01
        pText = '<0.01';
    else
        pText = sprintf('=%.2f', pValue);
    end
    label = ['$\mathrm{slope}=', slopeText, '\,\mathrm{/decade},\ \mathrm{p}', pText, '$'];
end
