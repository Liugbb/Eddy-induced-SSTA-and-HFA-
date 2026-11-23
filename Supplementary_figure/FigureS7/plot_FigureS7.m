% Reproduce both panels of Figure S7 and display the mean-comparison tables.
% Place this script and SourceDataFigureS7.mat in the same folder.
scriptDir = fileparts(mfilename('fullpath'));
D = load(fullfile(scriptDir,'SourceDataFigureS7.mat'));

fig = figure('Name','Figure S7 - Observed and predicted alpha','NumberTitle','off', ...
    'Units','pixels','Position',[100 100 1300 700]);
left = [0.07 0.55];
panelLabels = {'(a)','(b)'};
labelX = [-0.10 -0.05];

for k = 1:size(D.panelPeriods,1)
    pos = [left(k) 0.18 0.38 0.63];
    ax = axes('Parent',fig,'Units','normalized','Position',pos);
    hold(ax,'on');
    box(ax,'on');
    % Draw densely populated bins last so that their colors remain visible.
    rows = D.plotRows{k};
    counts = double(D.pointCounts{k});
    scatter(ax,D.observedAlpha(rows),D.predictedAlpha(rows),10,counts, ...
        'filled','MarkerEdgeColor','none');
    colormap(ax,flipud(D.colorTable));
    set(ax,'ColorScale','log');
    maxCount = max([1;counts(:)]);
    caxis(ax,[1 max(2,maxCount)]);

    % Give each panel its own logarithmic color scale above the axes.
    cb = colorbar(ax);
    cb.Orientation = 'horizontal';
    set(cb,'Units','normalized','Position',[left(k) 0.84 0.38 0.03], ...
        'FontSize',16,'FontWeight','bold','LineWidth',2);
    set(cb.Label,'String','Sample Count','FontSize',18,'FontWeight','bold');
    powers = 0:floor(log10(maxCount));
    cb.Ticks = 10.^powers;
    cb.TickLabels = arrayfun(@(p) sprintf('10^{%d}',p),powers,'UniformOutput',false);
    ax.Position = pos;

    % Add the 1:1 reference line. Use the original display limits in both panels.
    plot(ax,[0 1.2],[0 1.2],'--','Color',[0.45 0.45 0.45],'LineWidth',2);
    set(ax,'XLim',[0 0.8],'YLim',[0 0.8],'XTick',0:0.2:0.8,'YTick',0:0.2:0.8, ...
        'FontSize',16,'LineWidth',2,'Layer','top');
    xlabel(ax,'Observed \alpha','FontSize',20);
    ylabel(ax,'Predicted \alpha','FontSize',20);

    % Use the same paired observations for Pearson r, its p value, RMSE and MAE.
    if D.pValue(k)<0.01
        pText = '({\itp}<0.01)';
    else
        pText = sprintf('({\\itp}=%.2f)',D.pValue(k));
    end
    label = sprintf('{\\itr} = %.2f %s\nRMSE = %.2f\nMAE = %.2f\n', ...
        D.pearsonR(k),pText,D.rmse(k),D.mae(k));
    text(ax,0.03*0.8,0.82*0.8,label,'FontName','Calibri','FontSize',18, ...
        'BackgroundColor','w','Margin',4,'Interpreter','tex');
    text(ax,labelX(k),1.2,panelLabels{k},'Units','normalized','FontSize',20, ...
        'FontWeight','normal','VerticalAlignment','bottom','HorizontalAlignment','left');
    hold(ax,'off');
end

% Display the observed and predicted means, differences and percentage changes.
periodLabels = [compose("%d-%d",D.summaryPeriods(:,1),D.summaryPeriods(:,2)); "Late - Early"];
ResultTable = table(periodLabels,[D.summaryMeans(:,1); D.meanChange(1)], ...
    [D.summaryMeans(:,2); D.meanChange(2)],[D.summaryN; NaN], ...
    'VariableNames',{'Period','Observed_alpha','Predicted_alpha','N'});
ChangeTable = table(D.meanChange(1),D.meanChange(2),D.changePercent(1),D.changePercent(2), ...
    'VariableNames',{'Observed_change','Predicted_change','Observed_change_percent','Predicted_change_percent'});
disp(ResultTable);
disp(ChangeTable);
