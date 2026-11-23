%% EKE model
% Use Run Section to draw this model alone, or Run to draw both figures.
scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end
S = load(fullfile(scriptDir,'SourceDataFigureS12.mat'),'EKE','axisLimits','colorMap');
model = S.EKE;
fig = figure('Name',['Figure S12 - ' model.name],'NumberTitle','off', ...
    'Units','pixels','Position',[100 100 1400 1000],'Color','w');
mapPos = [0.06 0.55 0.38 0.35];
ax = axes('Parent',fig,'Units','normalized','Position',mapPos);
hold(ax,'on');
box(ax,'on');

% Each point takes the count of its 0.01-by-0.01 bin. Draw dense bins last.
idx = double(model.plotRows);
scatter(ax,model.observed(idx),model.predicted(idx),10,double(model.pointCounts), ...
    'filled','MarkerEdgeColor','none');
colormap(ax,S.colorMap);
set(ax,'ColorScale','log');
caxis(ax,model.colorLimits);

% Show powers of ten on the horizontal count scale above this panel.
cb = colorbar(ax,'northoutside');
cb.Units = 'normalized';
cb.Position = [0.06 0.91 0.38 0.023];
ax.Position = mapPos;
cb.AxisLocation = 'out';
cb.Ticks = model.colorTicks;
cb.TickLabels = cellstr(compose('10^{%d}',round(log10(model.colorTicks(:)))));
cb.TickLabelInterpreter = 'tex';
set(cb,'FontSize',16,'FontWeight','bold','LineWidth',2);
set(cb.Label,'String','Sample Count','FontSize',18,'FontWeight','bold');

plot(ax,[0 1.2],[0 1.2],'--','Color',[0.45 0.45 0.45],'LineWidth',2);
set(ax,'XLim',S.axisLimits,'YLim',S.axisLimits,'XTick',0:0.2:0.8,'YTick',0:0.2:0.8, ...
    'FontSize',16,'LineWidth',2,'Layer','top');
xlabel(ax,'Observed \alpha','FontSize',20);
ylabel(ax,'Predicted \alpha','FontSize',20);

% Report significance from this model's Pearson test.
rText = sprintf('r = %.2f',model.r);
if isfinite(model.pValue)
    if model.pValue<0.01
        rText = [rText ' (p<0.01)'];
    else
        rText = sprintf('%s (p=%.3g)',rText,model.pValue);
    end
end
txt = sprintf('%s\nRMSE = %.2f\nMAE = %.2f',rText,model.rmse,model.mae);
text(ax,0.03,0.82,txt,'Units','normalized','FontName','Calibri', ...
    'FontSize',18,'BackgroundColor','w','Margin',4);
hold(ax,'off');

%% Latitude model
% Use Run Section to draw this model alone, or Run to draw both figures.
scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end
S = load(fullfile(scriptDir,'SourceDataFigureS12.mat'),'Latitude','axisLimits','colorMap');
model = S.Latitude;
fig = figure('Name',['Figure S12 - ' model.name],'NumberTitle','off', ...
    'Units','pixels','Position',[100 100 1400 1000],'Color','w');
mapPos = [0.06 0.55 0.38 0.35];
ax = axes('Parent',fig,'Units','normalized','Position',mapPos);
hold(ax,'on');
box(ax,'on');

% Each point takes the count of its 0.01-by-0.01 bin. Draw dense bins last.
idx = double(model.plotRows);
scatter(ax,model.observed(idx),model.predicted(idx),10,double(model.pointCounts), ...
    'filled','MarkerEdgeColor','none');
colormap(ax,S.colorMap);
set(ax,'ColorScale','log');
caxis(ax,model.colorLimits);

% Show powers of ten on the horizontal count scale above this panel.
cb = colorbar(ax,'northoutside');
cb.Units = 'normalized';
cb.Position = [0.06 0.91 0.38 0.023];
ax.Position = mapPos;
cb.AxisLocation = 'out';
cb.Ticks = model.colorTicks;
cb.TickLabels = cellstr(compose('10^{%d}',round(log10(model.colorTicks(:)))));
cb.TickLabelInterpreter = 'tex';
set(cb,'FontSize',16,'FontWeight','bold','LineWidth',2);
set(cb.Label,'String','Sample Count','FontSize',18,'FontWeight','bold');

plot(ax,[0 1.2],[0 1.2],'--','Color',[0.45 0.45 0.45],'LineWidth',2);
set(ax,'XLim',S.axisLimits,'YLim',S.axisLimits,'XTick',0:0.2:0.8,'YTick',0:0.2:0.8, ...
    'FontSize',16,'LineWidth',2,'Layer','top');
xlabel(ax,'Observed \alpha','FontSize',20);
ylabel(ax,'Predicted \alpha','FontSize',20);

% Report significance from this model's Pearson test.
rText = sprintf('r = %.2f',model.r);
if isfinite(model.pValue)
    if model.pValue<0.01
        rText = [rText ' (p<0.01)'];
    else
        rText = sprintf('%s (p=%.3g)',rText,model.pValue);
    end
end
txt = sprintf('%s\nRMSE = %.2f\nMAE = %.2f',rText,model.rmse,model.mae);
text(ax,0.03,0.82,txt,'Units','normalized','FontName','Calibri', ...
    'FontSize',18,'BackgroundColor','w','Margin',4);
hold(ax,'off');
