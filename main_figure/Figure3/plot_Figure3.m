% Run this script with SourceDataFigure3.mat beside it.
% Panel (a) shows prediction counts. Panels (c)-(f) show the four dependence
% plots, followed by a separate map figure. The Python script draws panel (b).
% Requires smooth (Curve Fitting Toolbox), ksdensity (Statistics and Machine
% Learning Toolbox), and M_Map for the maps.
folder = fileparts(mfilename('fullpath'));
sourceFile = fullfile(folder,'SourceDataFigure3.mat');
assert(isfile(sourceFile),'Place SourceDataFigure3.mat beside this script or run prepare_Figure3 first.');
fields = {'prediction','dampingPoints','predictors','shapValues','sstaAmp','absDeltaFSLE', ...
    'scatterColors','dampingColors','mapColors','lon','lat','mapSHAP','predictorNames'};
missing = setdiff(fields,who('-file',sourceFile));
assert(isempty(missing),'Missing fields in SourceDataFigure3.mat: %s. Run the updated prepare_Figure3.m.', ...
    strjoin(missing,', '));
D = load(sourceFile,fields{:});
prediction = D.prediction;
rows = prediction.plotRows;
counts = prediction.pointCount;
observed = prediction.observed;
predicted = prediction.predicted;

%% Observed vs predicted alpha (Without_lat)
predictionFig = figure('Name','alpha_pred_vs_true','NumberTitle','off', ...
    'Position',[100 100 1400 1000],'Color','w');
mainPos = [0.06 0.55 0.38 0.35];
ax = axes('Parent',predictionFig,'Position',mainPos);
hold(ax,'on'); box(ax,'on');
scatter(ax,observed(rows),predicted(rows),10,counts,'filled','MarkerEdgeColor','none');
colormap(ax,D.mapColors);
ax.ColorScale = 'log';
caxis(ax,[1 max(2,counts(end))]);
cb = colorbar(ax,'northoutside');
cb.Units = 'normalized';
cb.Position = [0.06 0.91 0.38 0.023];
ax.Position = mainPos;
cb.Ticks = 10.^(0:floor(log10(counts(end))));
cb.TickLabels = arrayfun(@(t) sprintf('10^{%d}',round(log10(t))),cb.Ticks,'UniformOutput',false);
cb.TickLabelInterpreter = 'tex';
set(cb,'AxisLocation','out','FontSize',16,'FontWeight','normal','LineWidth',2);
set(cb.Label,'String','Sample Count','FontSize',18,'FontWeight','normal');
plot(ax,[0 1.2],[0 1.2],'--','Color',[0.45 0.45 0.45],'LineWidth',2);
set(ax,'FontSize',16,'LineWidth',2,'Layer','top','XLim',[0 .8],'YLim',[0 .8], ...
    'XTick',0:.2:.8,'YTick',0:.2:.8);
xlabel(ax,'Observed α','Interpreter','none','FontSize',20);
ylabel(ax,'Predicted α','Interpreter','none','FontSize',20);
rText = sprintf('r (reported) = %.2f',prediction.rAnnotation);
if isfinite(prediction.pCalculated)
    if prediction.pCalculated<0.01
        rText = [rText ' (p<0.01)'];
    else
        rText = sprintf('%s (p=%.3g)',rText,prediction.pCalculated);
    end
end
text(ax,0.03,0.82,sprintf('%s\nRMSE = %.2f\nMAE = %.2f',rText,prediction.rmse,prediction.mae), ...
    'Units','normalized','FontName','Calibri','FontSize',18, ...
    'BackgroundColor','w','Margin',4,'Interpreter','none');
hold(ax,'off');
ax.YLabel.Units = 'normalized';
drawnow;
text(ax,ax.YLabel.Position(1),1.04,'(a)','Units','normalized','Clipping','off', ...
    'FontWeight','normal','FontSize',18,'HorizontalAlignment','center');

%% Four dependence plots, each with a LOESS curve and a top density panel
xLabels = {'$\nabla \overline{\mathrm{SST}}\ (10^{-5}\ ^\circ\mathrm{C}\,\mathrm{m}^{-1})$', ...
           '$U/c$', '$\lambda^*$', '$\mathrm{SR}_{\mathrm{L}}\ (10^{-6}\,\mathrm{s}^{-1})$'};
ampLabel = '$\mathrm{SSTA\ Amp}\ (^\circ\mathrm{C})$';
colorLabels = {ampLabel,'$\Delta \mathrm{FSLE}\ (\mathrm{d}^{-1})$',ampLabel,'$U/c$'};
colorValues = {D.sstaAmp,D.absDeltaFSLE,D.sstaAmp,D.predictors(:,2)};
palettes = {D.scatterColors,D.scatterColors,D.dampingColors,D.scatterColors};

xScale = [1e5 1 1 1e6];
xMax = [2.5 30 2 1.5];
span = [0.25 0.30 0.15 0.15];
cMax = [1.5 0.3 1.5 15];
cStep = [0.5 0.1 0.5 5];
barFont = [16 18 16 16];
barWidth = [1.5 2 2 1.5];
zeroWidth = [1.8 2 2 1.8];
bottom = [0.12 0.12 0.12 0.13];
panelLetters = {'(c)','(d)','(e)','(f)'};

for k = 1:4
    if k == 3
        x = D.dampingPoints(:,1);
        y = D.dampingPoints(:,2);
        c = D.dampingPoints(:,3);
    else
        x = D.predictors(:,k)*xScale(k);
        y = D.shapValues(:,k);
        c = colorValues{k};
    end
    x = x(:); y = y(:); c = c(:);
    keep = isfinite(x) & isfinite(y) & isfinite(c);
    x = x(keep); y = y(keep); c = c(keep);
    assert(~isempty(x),'No finite x, SHAP and colour triples for panel %s.',panelLetters{k});

    figure('Color','w','Position',[100 100 720 480]);
    mainPos = [0.12 bottom(k) 0.73 0.65];
    ax = axes('Position',mainPos);
    hold(ax,'on'); box(ax,'on');
    scatter(ax,x,y,18,c,'filled','MarkerFaceAlpha',0.85,'MarkerEdgeAlpha',0.85);
    colormap(ax,palettes{k});
    caxis(ax,[0 cMax(k)]);
    cb = colorbar(ax);
    set(cb,'Position',[0.88 0.12 0.02 0.65],'Ticks',0:cStep(k):cMax(k), ...
        'FontSize',barFont(k),'LineWidth',barWidth(k));
    set(cb.Label,'String',colorLabels{k},'Interpreter','latex');
    if k == 4
        ax.Position = mainPos;
    end
    yline(ax,0,'--k','LineWidth',zeroWidth(k));
    [xs,order] = sort(x);
    if numel(unique(xs)) >= 3
        fitY = smooth(xs,y(order),span(k),'loess');
        plot(ax,xs,fitY,'k-','LineWidth',2.5);
    end
    xlim(ax,[0 xMax(k)]);
    if k == 1
        ylim(ax,[-0.10 0.15]);
    end
    set(ax,'FontSize',16,'LineWidth',2);
    xlabel(ax,xLabels{k},'Interpreter','latex','FontSize',18);
    ylabel(ax,'$\mathrm{SHAP\ value}$','Interpreter','latex','FontSize',18);

    % Use the same finite samples for the density and the scatter plot.
    pos = ax.Position;
    top = axes('Position',[pos(1) pos(2)+pos(4)+0.05 pos(3) 0.10]);
    bw = 1.06*std(x)*numel(x)^(-1/5);
    if k < 4 && ~isempty(x) && (~isfinite(bw) || bw <= 0)
        bw = 0.1*range(x);
    end
    if isfinite(bw) && bw > 0
        xGrid = linspace(min(x),max(x),300);
        density = ksdensity(x,xGrid,'Bandwidth',bw);
        fill(top,[xGrid fliplr(xGrid)],[density zeros(size(density))], ...
             [0.7 0.7 0.7],'EdgeColor','none');
    end
    xlim(top,[0 xMax(k)]);
    set(top,'XTick',[],'Color','none','Box','off','LineWidth',1.8,'FontSize',15);
    ax.YLabel.Units = 'normalized';
    drawnow;
    text(top,ax.YLabel.Position(1),1.02,panelLetters{k},'Units','normalized', ...
        'HorizontalAlignment','center','FontWeight','normal','FontSize',16,'Clipping','off');
    axes(ax);
end

%% Four SHAP maps in the original layout, with a shared vertical colorbar
[Lon,Lat] = ndgrid(D.lon,D.lat);
positions = [0.08 0.68 0.37 0.30; 0.52 0.68 0.37 0.30; ...
             0.08 0.36 0.37 0.30; 0.52 0.36 0.37 0.30];
figure('Name','1','NumberTitle','off','Position',[100 50 1400 950]);
for k = 1:4
    ax = subplot(3,2,k);
    ax.Position = positions(k,:);
    m_proj('Miller','lon',[0 360],'lat',[-70 70]);
    m_pcolor(Lon,Lat,D.mapSHAP(:,:,k));
    colormap(ax,D.mapColors);
    caxis(ax,[-0.06 0.06]);
    if k == 2
        cb = colorbar(ax,'eastoutside');
        set(cb,'Position',[0.93 0.35 0.015 0.60],'Ticks',-0.06:0.03:0.06, ...
            'FontSize',18,'AxisLocation','out','LineWidth',2);
    end
    grid(ax,'on');
    tickOptions = {};
    if k <= 2
        tickOptions = {'xticklabel',[]};
    end
    m_grid('XaxisLocation','bottom','YaxisLocation','left','tickdir','on','box','on', ...
           'xtick',0:60:360,'ytick',-90:30:90,'fontsize',18,'linestyle',':', ...
           'linewidth',3,tickOptions{:});
    m_coast('patch',[.5 .5 .5]);
    title(ax,['SHAP contribution: ' D.predictorNames{k}],'FontSize',20);
end
