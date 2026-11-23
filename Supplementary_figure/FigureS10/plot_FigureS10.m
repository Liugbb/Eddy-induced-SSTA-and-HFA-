% Plot Figure S10 from the source data. Run prepare_FigureS10 once first.
% The three windows follow the three original scripts. M_Map is needed for
% panels (a,b). Every panel uses the RGB values embedded in the MAT-file.
clc
clear
scriptDir = fileparts(mfilename('fullpath'));
S = load(fullfile(scriptDir,'SourceDataFigureS10.mat'));
drawMaps(S.map,S.colorScale);
drawComposites(S.composite,S.colorScale.composite);
drawRegionalBars(S.regional,S.colorScale.bars);

function drawMaps(map,colorScale)
fig = figure('Name','Figure S10 (a-b)','NumberTitle','off','Color','w', ...
    'Position',[100 100 1400 900]);
fields = {map.alpha,map.epsilonQ};
scales = {colorScale.mapAlpha,colorScale.mapRatio};
labels = {'(a)','(b)'};
[lat,lon] = meshgrid(map.lat,map.lon);
for k = 1:2
    left = 0.04 + (k-1)*0.50;
    pos = [left 0.4 0.42 0.42];
    ax = axes('Parent',fig,'Units','normalized','Position',pos);
    m_proj('Robinson','lon',[0 360],'lat',[-80 80]);
    m_pcolor(lon,lat,fields{k});
    hold(ax,'on');
    colormap(ax,scales{k}.rgb);
    caxis(ax,scales{k}.limits);
    m_grid('XaxisLocation','bottom','YaxisLocation','left','tickdir','in', ...
        'xtick',0:90:360,'ytick',-90:30:90,'fontsize',18, ...
        'FontWeight','normal','linestyle','none','linewidth',3);
    m_coast('patch',[0.5 0.5 0.5]);
    m_text(65,55,labels{k},'FontSize',20);

    % Anchor each horizontal colorbar above its own map.
    cb = colorbar(ax,'northoutside');
    cb.Units = 'normalized';
    cb.Position = [left+0.08 0.78 0.26 0.02];
    ax.Position = pos;
    set(cb,'Ticks',scales{k}.ticks,'AxisLocation','out','FontSize',16,'LineWidth',2);
    set(cb.Title,'String',scales{k}.title,'Interpreter','latex','FontSize',20, ...
        'FontWeight','normal','FontName','Arial');
end
end

function drawComposites(C,scale)
fig = figure('Name','Figure S10 (c-j)','NumberTitle','off','Color','w', ...
    'Position',[100 100 1400 900]);
titles = {'SSTA in monopole AE','SSTA in monopole CE','SSTA in dipole AE','SSTA in dipole CE', ...
          'HFA in monopole AE','HFA in monopole CE','HFA in dipole AE','HFA in dipole CE'};
letters = 'cdefghij';
left = [0.06 0.26 0.56 0.76];
% Preserve the panel-specific contour levels and label colors.
darkLevels  = {0:0.2:0.6, [], 0:0.05:0.2, 0:0.04:0.2, 0:4:16, [], 0:1:4, 0:0.8:4};
lightLevels = {[], -0.6:0.2:0, -0.2:0.05:-0.05, -0.3:0.04:-0.04, ...
               [], -16:4:-1, -4:0.4:-0.1, -4:1:-0.1};
for k = 1:8
    col = mod(k-1,4)+1;
    row = floor((k-1)/4);
    bottom = 0.65-row*0.37;
    pos = [left(col) bottom 0.18 0.28];
    ax = axes('Parent',fig,'Units','normalized','Position',pos);
    % The saved arrays are x-by-y. Contour plots with coordinate vectors
    % expect rows to correspond to y, hence the transpose here.
    field = C.(C.fields{k});
    field = field.';
    contourf(ax,C.x,C.y,field,1000,'LineStyle','none');
    hold(ax,'on');
    group = ceil(k/2);
    colormap(ax,scale.rgb);
    caxis(ax,scale.limits(group,:));
    axis(ax,'equal');
    set(ax,'XLim',[-2 2],'YLim',[-2 2],'XTick',-2:2,'YTick',-2:2, ...
        'LineWidth',2,'FontSize',16,'FontWeight','normal','Box','on');
    if mod(col,2)==1
        ylabel(ax,'R_{ny}','FontSize',16);
    else
        ax.YTickLabel = [];
    end
    if row==1, xlabel(ax,'R_{nx}','FontSize',16); end
    title(ax,titles{k},'FontSize',16,'FontWeight','normal');
    addContours(ax,C.x,C.y,field,darkLevels{k},0.4,'k');
    addContours(ax,C.x,C.y,field,lightLevels{k},0.9,'w');
    text(ax,-1.8,1.8,['(' letters(k) ')'],'FontSize',16,'Color','k', ...
        'BackgroundColor','w','EdgeColor','none','Margin',2);

    % The AE/CE pair for each pattern and variable shares one colorbar.
    if mod(col,2)==0
        cb = colorbar(ax,'eastoutside');
        cb.Units = 'normalized';
        cb.Position = [left(col)+0.19 bottom 0.01 0.28];
        ax.Position = pos;
        set(cb,'Ticks',scale.ticks{group},'AxisLocation','out','FontSize',16, ...
            'Box','on','LineWidth',2);
        set(cb.Title,'String',scale.units{group},'FontSize',16,'FontWeight','normal');
    end
end
end

function addContours(ax,x,y,field,levels,gray,labelColor)
if isempty(levels), return; end
[contours,h] = contour(ax,x,y,field,levels,'Color',[gray gray gray],'LineWidth',1.2);
if ~isempty(contours)
    clabel(contours,h,'Color',labelColor,'FontSize',10,'FontWeight','normal','LabelSpacing',400);
end
end

function drawRegionalBars(R,colors)
fig = figure('Name','Figure S10 (k)','NumberTitle','off','Color','w', ...
    'Position',[100 100 1400 400]);
n = numel(R.names);
left = 0.08; width = 0.88;
bottom = [0.62 0.25];
ylimits = [-0.2 1; -1 0.2];
polarityLabels = {'Anticyclone','Cyclone'};
% Preserve the original nominal legend intervals. The actual overlapping
% calculation windows, centered on those intervals, are in R.alphaBounds.
legendText = {'0~0.25','0.25~0.5','0.5~0.75','0.75~1'};
offset = [-0.272 -0.09 0.09 0.272];
for p = 1:2
    ax = axes('Parent',fig,'Units','normalized','Position',[left bottom(p) width 0.32]);
    means = R.mean(:,:,p);
    err = R.ci95(:,:,p);
    bars = bar(ax,1:n,means,'grouped');
    hold(ax,'on');
    for k = 1:numel(bars)
        set(bars(k),'FaceColor',colors(k,:),'EdgeColor','none');
        centers = (1:n) + offset(k);
        if isprop(bars(k),'XEndPoints'), centers = bars(k).XEndPoints; end
        errorbar(ax,centers(:),means(:,k),err(:,k),'k','LineStyle','none', ...
            'LineWidth',1.3,'HandleVisibility','off');
    end
    set(ax,'XLim',[0.5 n+0.5],'YLim',ylimits(p,:),'XTick',1:n,'XTickLabel',[], ...
        'FontSize',15,'LineWidth',2,'TickDir','out','Box','off', ...
        'XAxisLocation','origin','YAxisLocation','left');
    if p==1
        text(ax,0.02,0.90,'(k)','Units','normalized','FontSize',18);
        y = 0.90;
    else
        y = 0.20;
        legend(ax,bars,legendText,'Location','south','NumColumns',4, ...
            'Box','off','FontSize',13);
    end
    text(ax,0.99,y,polarityLabels{p},'Units','normalized','HorizontalAlignment','right', ...
        'FontSize',18);
end
% Add the five region names below the CE bars with the same group centers.
labelsAx = axes('Parent',fig,'Units','normalized','Position',[left 0.18 width 0.08], ...
    'Color','none','Box','off','XLim',[0.5 n+0.5],'YLim',[-1 1], ...
    'XAxisLocation','origin','XTick',1:n,'XTickLabel',R.names,'YTick',[], ...
    'YColor','none','LineWidth',2,'FontSize',15);
labelsAx.TickLength = [0 0];
annotation(fig,'textbox',[0.01 0.62 0.06 0.10],'String','$\varepsilon_Q$', ...
    'Interpreter','latex','FitBoxToText','on','EdgeColor','none','FontSize',28);
annotation(fig,'textbox',[0.31 0.225 0.055 0.10],'String','$\alpha$:', ...
    'Interpreter','latex','FitBoxToText','on','EdgeColor','none','FontSize',18);
end
