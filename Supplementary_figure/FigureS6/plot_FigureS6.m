% Reproduce Figure S6 from SourceDataFigureS6.mat. The map uses M_Map.
% The two numbered panels open in separate windows. Set the switch to true
% to also draw the unnumbered six-row figure from read_STAm_trend.m.
clc
clear
showStackedFigure = false;
scriptDir = fileparts(mfilename('fullpath'));
sourceFile = fullfile(scriptDir,'SourceDataFigureS6.mat');
if ~isfile(sourceFile)
    error('Run prepare_FigureS6.m first to create %s.',sourceFile);
end
D = load(sourceFile,'map','regional','stacked','regionNames');

% Panel (a). Plot the smoothed amplitude trend and stipple significant cells
% using the p values of the unsmoothed trends.
figMap = figure('Name','Figure S6 (a) - SSTA amplitude trend','NumberTitle','off', ...
    'Units','pixels','Position',[100 100 1400 900]);
mapAxes = axes('Parent',figMap,'Units','normalized','Position',[0.04 0.4 0.42 0.42]);
[lon,lat] = ndgrid(D.map.lonPlot,D.map.latPlot);
m_proj('Robinson','lon',[0 360],'lat',[-80 80]);
m_pcolor(lon,lat,100*D.map.smoothedSlopePerYear);
cmap = D.map.colorTable;
if isempty(cmap)
    % Standard NCL BlueDarkRed18 palette (RGB values on the 0-255 scale).
    cmap = [36 0 216; 24 28 247; 40 87 255; 61 135 255; 86 176 255; ...
            117 211 255; 153 234 255; 188 249 255; 234 255 255; ...
            255 255 234; 255 241 188; 255 214 153; 255 172 117; ...
            255 120 86; 255 61 61; 247 39 53; 216 21 47; 165 0 33]/255;
end
colormap(mapAxes,cmap);
caxis(mapAxes,[-1 1]);
cb = colorbar(mapAxes,'southoutside');
set(cb,'Units','normalized','Position',[0.12 0.78 0.26 0.02], ...
    'FontSize',16,'LineWidth',2,'FontWeight','normal','AxisLocation','out', ...
    'Ticks',-1:0.5:1);
set(cb.Title,'String','$A_T$ trend ($10^{-1}\,{}^{\circ}\mathrm{C}\,\mathrm{decade}^{-1}$)', ...
    'Interpreter','latex','FontSize',20,'FontWeight','normal', ...
    'Position',[130 45 0],'HorizontalAlignment','center');
set(mapAxes,'Position',[0.04 0.4 0.42 0.42]);
axes(mapAxes);
hold(mapAxes,'on');
sig = D.map.significant;
m_plot(lon(sig)+D.map.starOffset,lat(sig)+D.map.starOffset,'k*', ...
    'MarkerSize',2,'LineWidth',0.5);
m_coast('patch',[0.5 0.5 0.5]);
m_grid('XaxisLocation','bottom','YaxisLocation','left','tickdir','on', ...
    'xtick',0:90:360,'ytick',-90:30:90,'fontsize',16,'fontweight','normal', ...
    'linestyle','none','linewidth',2);
m_text(65,55,'(a)','FontSize',20);

% Panel (b). Place the six regional series in the original 3-by-2 layout.
drawRegions(D.regional,D.regionNames,false);
if showStackedFigure
    drawRegions(D.stacked,D.regionNames,true);
end

function drawRegions(S,names,stackedLayout)
    colors = [0.00 0.45 0.74; 0.85 0.33 0.10; 0.47 0.67 0.19; ...
              0.93 0.69 0.13; 0.49 0.18 0.56; 0.20 0.20 0.20];
    limits = [0.18 0.41; 0.40 0.82; 0.10 0.32; 0.32 0.68; 0.30 0.45; 0.28 0.34];
    if stackedLayout
        fig = figure('Name','Figure S6 - Untrimmed regional trends','NumberTitle','off', ...
            'Units','pixels','Position',[100 100 700 1000]);
    else
        fig = figure('Name','Figure S6 (b) - Regional trends','NumberTitle','off', ...
            'Color','w','Units','pixels','Position',[50 50 1650 900]);
    end
    tickYears = (1993:5:2018).';
    tickDate = datenum(tickYears,ones(size(tickYears)),ones(size(tickYears)));
    ax = gobjects(numel(names),1);
    for r = 1:numel(names)
        if stackedLayout
            h = (0.975-0.08-5*0.02)/6;
            pos = [0.10,0.975-r*h-(r-1)*0.02,0.80,h];
            rightSide = mod(r,2)==1;
            showYears = r==numel(names);
        else
            row = ceil(r/2);
            col = mod(r-1,2);
            pos = [0.065+col*0.47,0.95-row*0.245-(row-1)*0.045,0.4,0.245];
            rightSide = row==2;
            showYears = row==3;
        end
        ax(r) = axes('Parent',fig,'Units','normalized','Position',pos);
        a = ax(r); color = colors(r,:);
        hold(a,'on');
        hasFit = isfinite(S.fitDate(1,r));
        if hasFit && ~stackedLayout
            % Draw the 95% confidence band for the fitted mean behind the lines.
            tf = S.fitDate(:,r);
            fill(a,[tf; flipud(tf)],[S.fitLower95(:,r); flipud(S.fitUpper95(:,r))], ...
                color,'EdgeColor','none','FaceAlpha',0.15);
        end
        % Pale line: quarterly observations. Colored line: four-quarter mean.
        plot(a,S.date,S.mean(:,r),'-','Color',0.25*color+0.75,'LineWidth',1);
        plot(a,S.date,S.movingMean(:,r),'-','Color',color,'LineWidth',1.5);
        if hasFit
            plot(a,S.fitDate(:,r),S.fitMean(:,r),'-','Color',color,'LineWidth',2);
            label = trendLabel(S.slopePerDecade(r),S.slopeCI95HalfWidth(r),S.pValue(r),stackedLayout);
            if stackedLayout
                text(a,0.05,1,label,'Units','normalized','FontSize',14, ...
                    'FontWeight','bold','Color',color,'Interpreter','latex');
            else
                text(a,0.04,0.96,label,'Units','normalized','FontSize',13, ...
                    'VerticalAlignment','top','Color',color,'Interpreter','latex');
            end
        else
            missingLabel = 'Insufficient data';
            if stackedLayout, missingLabel = names{r}; end
            text(a,0.05,0.78,missingLabel,'Units','normalized','FontSize',12,'Color',color);
        end
        side = 'left';
        if rightSide, side = 'right'; end
        set(a,'FontSize',13,'LineWidth',1.6,'Box','off','TickDir','out', ...
            'YAxisLocation',side,'YColor','k','XLim',[datenum(1993,1,1) datenum(2019,1,1)], ...
            'XTick',tickDate);
        if ~stackedLayout
            ylim(a,limits(r,:));
        elseif r==3
            set(a,'YTick',-0.1:0.2:0.3001);
        end
        if showYears
            set(a,'XTickLabel',cellstr(num2str(tickYears)),'XColor','k');
            xlabel(a,'Year','FontSize',14);
        else
            set(a,'XTickLabel',[],'XColor','none');
        end
        ylabel(a,names{r},'FontSize',14,'FontWeight','normal','Color','k');
    end
    if ~stackedLayout
        annotation(fig,'textbox',[0.01 0.94 0.05 0.05],'String','(b)', ...
            'FontSize',20,'EdgeColor','none','HorizontalAlignment','left', ...
            'VerticalAlignment','top','FitBoxToText','on');
    end
    linkaxes(ax,'x');
end

function label = trendLabel(slope,halfWidth,p,stackedLayout)
% Report the decadal slope and its 95% CI half-width at a common exponent.
    if slope==0
        slopeText = '0.00';
    else
        e = floor(log10(abs(slope)));
        m = round(slope/10^e,2);
        if abs(m)>=10
            m = m/10; e = e+1;
        end
        slopeText = sprintf('%.2f\\pm%.2f\\times 10^{%d}',m,round(halfWidth/10^e,2),e);
    end
    if ~isfinite(p)
        pText = '=\mathrm{NaN}';
    elseif p<0.01 && stackedLayout
        pText = '=0.00';
    elseif p<0.01
        pText = '<0.01';
    else
        pText = sprintf('=%.2f',p);
    end
    label = ['$\mathrm{slope}=',slopeText,'\,\mathrm{/decade},\ \mathrm{p}',pText,'$'];
end
