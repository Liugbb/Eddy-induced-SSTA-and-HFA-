% Plot Figure S1 from SourceDataFigureS1.mat. The four windows show net
% heat-flux contributions, gross heat-flux contributions, eddy snapshot
% fractions, and annual snapshot counts, grouped by region and alpha bin.

scriptFolder = fileparts(mfilename('fullpath'));
data = load(fullfile(scriptFolder, 'SourceDataFigureS1.mat'));
alphaLabels = {'0–0.25','0.25–0.5','0.5–0.75','0.75–1'};
heatLabels = {'0~0.25','0.25~0.5','0.5~0.75','0.75~1'};
nBins = numel(data.alphaEdges) - 1;
upperPosition = [0.08 0.62 0.88 0.32];
lowerPosition = [0.08 0.25 0.88 0.32];

% Windows 1 and 2: regional net and gross heat-flux contributions (TW).
nHeatRegions = numel(data.heatRegionNames);
for window = 1:2
    if window == 1
        windowName = 'Net heat-flux contribution';
        values = data.netHFA_TW;
        axisLabel = '$\int_{A_e} Q^\prime\,\mathrm{d}A$ (TW)';
        limits = [-10 40; -40 10];
        ticks = {0:20:40, -40:20:0};
    else
        windowName = 'Gross heat-flux contribution';
        values = data.grossHFA_TW;
        values(:,:,2) = -values(:,:,2);  % Display gross cyclone contributions below zero.
        axisLabel = '$\int_{A_e} |Q^\prime|\,\mathrm{d}A$ (TW)';
        limits = [-10 100; -100 10];
        ticks = {0:25:100, -100:25:0};
    end
    fig = figure('Name',windowName,'NumberTitle','off','Color','w', ...
        'Position',[100 100 1400 400]);
    positions = [upperPosition; lowerPosition];
    for p = 1:2
        ax = axes('Parent',fig,'Position',positions(p,:));
        bars = bar(ax,values(:,:,p),'grouped','EdgeColor','none');
        for bin = 1:nBins
            bars(bin).FaceColor = data.barColors(bin,:);
        end
        set(ax,'XLim',[0.5 nHeatRegions+0.5],'XTick',1:nHeatRegions, ...
            'XTickLabel',[],'XAxisLocation','origin','YLim',limits(p,:), ...
            'YTick',ticks{p},'FontSize',15,'LineWidth',2,'TickDir','out','Box','off');
    end
    legend(ax,bars,heatLabels,'Location','south','NumColumns',4,'FontSize',13,'Box','off');
    axes('Parent',fig,'Position',[0.08 0.18 0.88 0.08], ...
        'XLim',[0.5 nHeatRegions+0.5],'YLim',[-1 1],'XAxisLocation','origin', ...
        'XTick',1:nHeatRegions,'XTickLabel',data.heatRegionNames,'YTick',[], ...
        'YColor','none','Box','off','FontSize',15,'LineWidth',2);
    annotation(fig,'textbox',[0.04 0.35 0.25 0.08],'String',axisLabel, ...
        'Interpreter','latex','FitBoxToText','on','EdgeColor','none', ...
        'BackgroundColor','none','FontSize',20,'Rotation',90);
    annotation(fig,'textarrow',[0.22 0.22],[0.9 0.9],'String','Anticyclone', ...
        'HeadStyle','none','LineStyle','none','FontSize',18);
    annotation(fig,'textarrow',[0.2 0.2],[0.32 0.32],'String','Cyclone', ...
        'HeadStyle','none','LineStyle','none','FontSize',18);
    annotation(fig,'textarrow',[0.36 0.36],[0.3 0.3],'String','$\alpha$:', ...
        'Interpreter','latex','HeadStyle','none','LineStyle','none','FontSize',18);
end


% Window 3: log10 of the annual number of snapshots in each alpha bin.
% Rows are already in region order, including AS and the global domain.
counts = data.annualCount;
counts(counts <= 0) = NaN;
logCount = log10(counts);
zmax = 2 * ceil(max(logCount(:),[],'omitnan') / 2);
if ~isfinite(zmax) || zmax <= 0
    zmax = 2;
end
maxRegion = numel(regions);
fig = figure('Name','Eddy number','NumberTitle','off','Color','w', ...
    'Position',[100 100 1400 420]);
positions = [upperPosition; lowerPosition];
for p = 1:2
    ax = axes('Parent',fig,'Position',positions(p,:));
    if p == 1
        values = logCount(:,:,1);
        limits = [0 zmax];
        ticks = 0:2:zmax;
    else
        values = -logCount(:,:,2);
        limits = [-zmax 0];
        ticks = -fliplr(0:2:zmax);
    end
    bars = bar(ax,values,'grouped','EdgeColor','none');
    for bin = 1:nBins
        bars(bin).FaceColor = data.barColors(bin,:);
    end
    set(ax,'XLim',[0.5 maxRegion+0.5],'XTick',regions,'XTickLabel',[], ...
        'XAxisLocation','origin','YLim',limits,'YTick',ticks,'YTickLabel',string(abs(ticks)), ...
        'FontSize',15,'LineWidth',2,'TickDir','out','Box','off');
    if p == 1
        text(ax,0.88,0.82*zmax,'Anticyclone','FontSize',18);
    else
        text(ax,0.95,-0.82*zmax,'Cyclone','FontSize',18);
    end
end
legend(ax,bars,alphaLabels,'Orientation','horizontal','Location','south', ...
    'Box','off','FontSize',13);
axes('Parent',fig,'Position',[0.08 0.16 0.88 0.08], ...
    'XLim',[0.5 maxRegion+0.5],'YLim',[-1 1],'XAxisLocation','origin', ...
    'XTick',regions,'XTickLabel',data.regionNames,'YTick',[], ...
    'YColor','none','Box','off','FontSize',15,'LineWidth',2);
annotation(fig,'textbox',[0.04 0.1 0.30 0.06],'String','Eddy number (log_{10})', ...
    'EdgeColor','none','BackgroundColor','none','FontSize',18,'Rotation',90, ...
    'HorizontalAlignment','center','VerticalAlignment','middle');
annotation(fig,'textarrow',[0.36 0.36],[0.3 0.3],'String','$\alpha$:', ...
    'Interpreter','latex','HeadStyle','none','LineStyle','none','FontSize',18);
