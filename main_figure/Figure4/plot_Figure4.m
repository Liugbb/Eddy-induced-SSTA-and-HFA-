% Plot Figure 5 from the archived data and save Figure5.pdf in this folder.
% Panels (a)-(c) map trends in the background SST gradient, eddy
% nonlinearity (U/c), and normalized air-sea thermal damping (lambda*).
% Panels (d)-(l) show their 1993-2018 quarterly means in the Kuroshio
% Extension (KE), Gulf Stream (GS), and Antarctic Circumpolar Current (ACC).
% Each regional panel includes a four-quarter running mean (black), a
% fitted trend (red), and the time mean (dashed). The legend p-values
% reproduce the labels in the source figure.
%
% Place Figure5_plot_data.mat beside this script and run it in MATLAB.

folder = fileparts(mfilename('fullpath'));
data = load(fullfile(folder,'SourceDataFigure4.mat'),'maps','regions','dates','series','style');
style = data.style;
dt = datetime(data.dates,'ConvertFrom','datenum');

% Stack the original map row above the time series. All panels retain
% their original sizes relative to the common source canvas width.
mapHeight = style.mapCanvas(4);
seriesHeight = style.seriesCanvas(4);
mapBase = min(style.mapPosition(:,2))*mapHeight;
height = seriesHeight+mapHeight-mapBase;
fig = figure('Name','Figure 5','NumberTitle','off','Color','w','Units','pixels', ...
             'Position',[style.seriesCanvas(1:3) height]);

%% Global trend maps and their horizontal colorbars
for k = 1:3
    m = data.maps(k);
    pos = stackedPosition(m.position,mapHeight,seriesHeight-mapBase,height);
    ax = axes('Parent',fig,'Units','normalized','Position',pos);
    set(ax,'Visible','off','NextPlot','add','XLim',m.limits(1:2),'YLim',m.limits(3:4), ...
        'ZLim',m.limits(5:6),'View',m.view,'DataAspectRatio',m.aspect,'SortMethod',m.sortMethod);
    % The layers retain the projected stars, coastline, ticks, and labels.
    for j = 1:numel(m.layers)
        item = m.layers{j};
        switch item.kind
            case 'field'
                surface(ax,m.x,m.y,m.z,m.trend,'FaceColor',m.faceColor,'EdgeColor',m.edgeColor, ...
                    'CDataMapping',m.cDataMapping);
            case 'patch'
                patch('Parent',ax,item.args{:});
            case 'line'
                line('Parent',ax,item.args{:});
            case 'text'
                text('Parent',ax,item.args{:});
        end
    end
    colormap(ax,style.rgb);
    caxis(ax,style.mapLimits(k,:));
    cb = colorbar(ax,'southoutside');
    cb.Units = 'normalized';
    cb.Position = stackedPosition(style.barPosition(k,:),mapHeight,seriesHeight-mapBase,height);
    set(cb,'Ticks',style.mapTicks{k},'FontSize',16,'AxisLocation','out','LineWidth',2);
    set(cb.Label,'String',style.mapLabel{k},'Interpreter','latex','FontSize',18,'Rotation',0);
    ax.Position = pos;
end

%% Regional quarterly series
for r = 1:3
    for v = 1:3
        s = data.series(r,v);
        pos = [style.seriesLeft(v) style.seriesBottom(r) style.seriesSize];
        ax = axes('Parent',fig,'Units','normalized', ...
                  'Position',stackedPosition(pos,seriesHeight,0,height));
        hRaw = plot(ax,dt,s.raw,'-','LineWidth',1);
        hold(ax,'on');
        box(ax,'on');
        plot(ax,dt,s.smooth,'-','Color',style.rawColor,'LineWidth',2);
        hFit = plot(ax,dt,s.fit,'-','Color',style.fitColor,'LineWidth',2);
        hMean = plot(ax,dt,repmat(s.mean,size(dt)),'--','LineWidth',2);
        % Preserve both the source transparency settings and its RGB
        % fallback on MATLAB releases that accept only three color values.
        try
            hRaw.Color = [style.rawColor style.rawAlpha];
        catch
            hRaw.Color = 0.75*style.rawColor+0.25*[1 1 1];
        end
        try
            hMean.Color = [style.rawColor style.meanAlpha];
        catch
            hMean.Color = 0.5*style.rawColor+0.25*[1 1 1];
        end
        set(ax,'FontSize',16,'LineWidth',1.4,'XLim',[min(dt) max(dt)], ...
            'XTick',datetime(style.yearTicks,1,1),'XTickLabel',cellstr(num2str(style.yearTicks(:))), ...
            'YLim',s.yLim,'YTick',s.yTicks,'YTickLabel',s.yTickLabel);
        ylabel(ax,style.seriesLabel{v},'Interpreter','latex','FontSize',18);
        xlabel(ax,'Year','Interpreter','latex','FontSize',18);
        lgd = legend(hFit,{style.legendText{r,v}},'Location',style.legendLocation{r,v}, ...
            'Box','off','FontSize',18);
        set(lgd,'Interpreter','latex');
        text(ax,-0.16,1.06,['(' s.panel ')'],'Units','normalized','Clipping','off', ...
            'FontSize',18,'Color','k','Interpreter','none', ...
            'HorizontalAlignment','left','VerticalAlignment','bottom');
        text(ax,0.98,1.06,data.regions.name{r},'Units','normalized','Clipping','off', ...
            'FontSize',16,'FontWeight','bold','Color','k', ...
            'HorizontalAlignment','right','VerticalAlignment','bottom');
    end
end

%% Export the complete figure on one page
pdfFile = fullfile(folder,'Figure4.pdf');
drawnow;
if exist('exportgraphics','file')
    exportgraphics(fig,pdfFile,'ContentType','vector');
else
    page = [style.seriesCanvas(3) height]/get(groot,'ScreenPixelsPerInch');
    set(fig,'PaperUnits','inches','PaperSize',page,'PaperPosition',[0 0 page]);
    print(fig,pdfFile,'-dpdf','-painters');
end
fprintf('Saved %s\n',pdfFile);

function pos = stackedPosition(pos,sourceHeight,verticalOffset,combinedHeight)
pos(2) = (pos(2)*sourceHeight+verticalOffset)/combinedHeight;
pos(4) = pos(4)*sourceHeight/combinedHeight;
end
