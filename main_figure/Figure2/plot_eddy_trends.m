% Recreate the eight panels showing trends in eddy-induced sea surface
% temperature anomaly (SSTA) structure and the net air-sea heat-flux ratio.
% Panels (a)-(f) map the structure index alpha (left) and the net heat-flux
% ratio epsilon_Q (right) for anticyclonic, cyclonic, and all mesoscale
% eddies. Black stars show the stored p < 0.10 masks. The CE ratio trend
% is sign-reversed for comparison with AEs. Panels (g) and (h) show the
% global monthly means, 12-month running means, linear trends, and 95%
% confidence bands for the fitted means.
% Each map records the source of its significance mask in its pSource field.
% Place eddy_trends_plot_data.mat beside this script and run it in MATLAB.

dataFile = fullfile(fileparts(mfilename('fullpath')),'SourceDataFigure2.mat');
D = load(dataFile,'maps','mapGeometry','series','style');
g = D.mapGeometry;
style = D.style;
fig = figure('Name','Eddy structure and net heat-flux ratio trends', ...
    'NumberTitle','off','Color','w','Units','pixels','Position',[60 50 1230 1060]);
left = [0.070 0.565];
rowBottom = [0.716 0.502 0.288];
width = 0.383;

%% Spatial trends in units of 10^-2 per decade
for r = 1:3
    for c = 1:2
        m = D.maps(r,c);
        pos = [left(c),rowBottom(r),width,0.181];
        ax = axes('Parent',fig,'Units','normalized','Position',pos);
        hold(ax,'on');
        set(ax,'Visible','off','XLim',g.xLim,'YLim',g.yLim,'ZLim',g.zLim,'View',g.view, ...
            'DataAspectRatio',g.aspect,'SortMethod',g.sortMethod);
        drawMapLayers(ax,g.below);

        z = m.values;
        z(~g.visibleCells) = NaN;
        surface(ax,g.x,g.y,zeros(size(z)),z,'FaceColor','flat', ...
            'EdgeColor','none','CDataMapping','scaled');
        line(ax,m.starXY(:,1),m.starXY(:,2),'LineStyle','none','Marker','*', ...
            'Color','k','MarkerSize',2,'LineWidth',0.5);
        drawMapLayers(ax,g.above);
        text(ax,g.labelX,g.labelY,m.label,'FontSize',17,'Color','k');
        colormap(ax,style.rgb);
        caxis(ax,style.mapLimits(c,:));

        if r == 1
            cb = colorbar(ax,'northoutside');
            cb.Units = 'normalized';
            cb.Position = [left(c)+0.05,0.91,width-0.10,0.014];
            cb.Ticks = style.mapTicks{c};
            cb.FontSize = 13;
            cb.LineWidth = 1.5;
            cb.Title.Interpreter = 'latex';
            cb.Title.String = ['$' style.symbol{c} '\ (10^{-2}\,\mathrm{decade}^{-1})$'];
            cb.Title.FontSize = 17;
            cb.Title.FontWeight = 'normal';
            ax.Position = pos;
        end
    end
end

%% Global monthly series, running means, and linear fits
for c = 1:2
    s = D.series(c);
    color = style.seriesColors(c,:);
    monthlyColor = 0.75*[1 1 1] + 0.25*color;
    ax = axes('Parent',fig,'Units','normalized', ...
        'Position',[left(c)+0.01,0.064,width-0.01,0.166]);
    hold(ax,'on');
    if ~isempty(s.fitTime)
        fill(ax,[s.fitTime;flipud(s.fitTime)], ...
            [s.fitCI(:,1);flipud(s.fitCI(:,2))],color, ...
            'EdgeColor','none','FaceAlpha',0.18);
    end
    plot(ax,s.time,s.monthly,'-','Color',monthlyColor,'LineWidth',1.5);
    plot(ax,s.time,s.runningMean,'-','Color',color,'LineWidth',2);
    if ~isempty(s.fitTime)
        plot(ax,s.fitTime,s.fitMean,'-','Color',color,'LineWidth',3);
        text(ax,0.035,0.90,s.annotation,'Units','normalized','Interpreter','latex', ...
            'Color',color,'FontSize',13,'VerticalAlignment','middle');
    end
    set(ax,'Box','off','TickDir','out','FontSize',13,'LineWidth',1.6, ...
        'XLim',style.timeLimits,'XTick',style.yearTicks,'XTickLabel',cellstr(datestr(style.yearTicks,'yyyy')), ...
        'YLim',style.seriesLimits(c,:),'YTick',style.seriesLimits(c,1):0.05:style.seriesLimits(c,2));
    xlabel(ax,'Year','FontSize',15);
    ylabel(ax,['$' style.symbol{c} '$'],'Interpreter','latex','FontSize',19,'Rotation',0);
    text(ax,0.99,0.98,s.label,'Units','normalized','FontSize',15, ...
        'HorizontalAlignment','right','VerticalAlignment','top');
end

function drawMapLayers(ax,layers)
% Rebuild the saved coastline polygons, map boundary, ticks, and labels.
for k = 1:numel(layers)
    item = layers{k};
    switch item.kind
        case 'patch'
            patch('Parent',ax,item.args{:});
        case 'line'
            line('Parent',ax,item.args{:});
        case 'text'
            text('Parent',ax,item.args{:});
    end
end
end
