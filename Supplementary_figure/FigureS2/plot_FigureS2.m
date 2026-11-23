% Plot Figure S2 in three separate windows from SourceDataFigureS1.mat.
% The first two show SSTA, heat-flux anomalies, and surface geostrophic
% velocity anomalies for filters 8 and 12. The third maps trends in the
% SSTA structure index and net heat-flux ratio for both filters.
% Place this script beside the MAT-file. The third window uses M_Map.

folder = fileparts(mfilename('fullpath'));
dataFile = fullfile(folder,'SourceDataFigureS2.mat');
D = load(dataFile,'filterSizes','eddyNames','coord','SSTA','HFA','U','V', ...
    'trend','compositeRGB','trendRGB');

% Composite windows: (a)-(h) for filter 8 and (i)-(p) for filter 12.
% The first grid dimension is x, as in the original [Lat,Lon] = meshgrid(Y,X).
[x,y] = ndgrid(D.coord,D.coord);
left = [0.00 0.20 0.50 0.70];
bottom = [0.65 0.28];
colorMax = [0.6 0.6 0.1 0.1 12 12 4 4];
darkLevels = {0:0.2:0.6, [], 0:0.05:0.2, 0:0.05:0.2, ...
              0:4:12, [], 0:1:4, 0:0.4:4};
lightLevels = {[], -0.6:0.2:0, -0.2:0.05:-0.05, -0.3:0.05:-0.05, ...
               [], -12:4:-1, -4:0.4:-0.1, -4:1:-0.1};
arrowGray = [0.8 0.4 0.8 0.4];
vecScale = 2.0;
refSpeed = 0.20;   % m/s
figComposite = gobjects(1,2);

for f = 1:2
    figComposite(f) = figure('Name',sprintf('Figure S1 - filter %d',D.filterSizes(f)), ...
        'NumberTitle','off','Color','w','Position',[100 100 1400 900]);
    for p = 1:8
        col = mod(p-1,4)+1;
        row = ceil(p/4);
        pos = [left(col) bottom(row) 0.30 0.28];
        ax = axes('Parent',figComposite(f),'Units','normalized','Position',pos);
        if row == 1
            field = D.SSTA{f,col};
            fieldName = 'SSTA';
        else
            field = D.HFA{f,col};
            fieldName = 'HFA';
        end
        contourf(ax,x,y,field,1000,'LineStyle','none');
        if f == 1
            shading(ax,'interp');
            ticks = -4:4;
        else
            ticks = -2:2;
        end
        hold(ax,'on');
        colormap(ax,D.compositeRGB);
        caxis(ax,[-colorMax(p) colorMax(p)]);
        axis(ax,'equal');
        set(ax,'XLim',[-2 2],'YLim',[-2 2],'XTick',ticks,'YTick',ticks, ...
            'Box','on','LineWidth',2,'FontSize',16,'FontWeight','normal');
        title(ax,[fieldName ' in ' D.eddyNames{col}],'FontSize',16,'FontWeight','normal');
        if col == 1 || col == 3
            ylabel(ax,'R_{ny}','FontSize',16);
        else
            ax.YTickLabel = [];
        end
        if row == 1
            % One physical velocity scale for all panels, including dipole CE.
            quiver(ax,x,y,vecScale*D.U{col},vecScale*D.V{col},0, ...
                'Color',repmat(arrowGray(col),1,3),'LineWidth',1.2,'MaxHeadSize',1.4);
        else
            xlabel(ax,'R_{nx}','FontSize',16);
        end

        panelLabel = ['(' char('a'+8*(f-1)+p-1) ')'];
        label = text(ax,-1.8,1.8,panelLabel,'FontSize',16,'Color','k', ...
            'BackgroundColor','w','EdgeColor','none','Margin',2);
        if ~isempty(darkLevels{p})
            [c,h] = contour(ax,x,y,field,darkLevels{p},'Color',[0.4 0.4 0.4],'LineWidth',1.2);
            clabel(c,h,'Color','k','FontSize',10,'FontWeight','normal','LabelSpacing',400);
        end
        if ~isempty(lightLevels{p})
            [c,h] = contour(ax,x,y,field,lightLevels{p},'Color',[0.9 0.9 0.9],'LineWidth',1.2);
            clabel(c,h,'Color','w','FontSize',10,'FontWeight','normal','LabelSpacing',400);
        end
        if f == 2 || p == 8
            uistack(label,'top');
        end

        if col == 2 || col == 4
            cb = colorbar(ax,'eastoutside');
            cbLeft = left(col)+0.25;
            set(cb,'Units','normalized','Position',[cbLeft bottom(row) 0.01 0.28], ...
                'Ticks',linspace(-colorMax(p),colorMax(p),5),'FontSize',16,'Box','on','LineWidth',2);
            cb.Title.String = 'W/m^2';
            if row == 1
                cb.Title.String = '°C';
            end
            cb.Title.FontSize = 16;
            cb.Title.FontWeight = 'normal';
            if f == 1
                cb.AxisLocation = 'out';
                cb.Title.Position = [5 190 0];
            end
        end
        if row == 1 || f == 2
            ax.Position = pos;
            ax.Layer = 'top';
        end
        if p == 4
            % Reference arrow in the upper right of panels (d) and (l).
            w = 1.00;
            hBox = 0.70;
            xBox = ax.XLim(2)-w;
            yBox = ax.YLim(2)-hBox;
            xc = xBox+w/2;
            len = vecScale*refSpeed;
            rectangle('Parent',ax,'Position',[xBox yBox w hBox],'FaceColor','w','EdgeColor','none');
            quiver(ax,xc-len/2,yBox+0.72*hBox,len,0,0,'Color','k','LineWidth',1.2,'MaxHeadSize',1.4);
            text(ax,xc,yBox+0.28*hBox,sprintf('%.2f m/s',refSpeed), ...
                'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',10,'Interpreter','none');
        end
        hold(ax,'off');
    end
end

% Trend window: rows are filters 8 and 12. Columns are alpha and epsilon_Q.
figTrend = figure('Name','Figure S1 - trends','NumberTitle','off', ...
    'Color','w','Position',[100 100 1400 900]);
[lon,lat] = ndgrid(D.trend.lon,D.trend.lat);
mapLeft = [0.04 0.54];
mapBottom = [0.5 0.12];
barLeft = [0.12 0.62];
mapMax = [5 6];
titles = {'$\alpha (10^{-2} \,\, \mathrm{decade}^{-1})$', ...
          '$\varepsilon_Q (10^{-2} \,\, \mathrm{decade}^{-1})$'};
% Older versions of m_usercoast read the coastline by filename. Using the
% script folder also supports paths containing spaces and avoids name clashes.
previousFolder = pwd;
cd(folder);
try
    for f = 1:2
        for v = 1:2
            pos = [mapLeft(v) mapBottom(f) 0.42 0.42];
            ax = axes('Parent',figTrend,'Units','normalized','Position',pos);
            m_proj('Robinson','lon',[0 360],'lat',[-80 80]);
            m_pcolor(lon,lat,D.trend.values{f,v});
            hold(ax,'on');
            colormap(ax,D.trendRGB);
            caxis(ax,[-mapMax(v) mapMax(v)]);
            mask = D.trend.significant{f,v};
            if any(mask(:))
                m_plot(lon(mask)+D.trend.markerOffset,lat(mask)+D.trend.markerOffset, ...
                    'k*','MarkerSize',2,'LineWidth',0.5);
            end
            m_usercoast('SourceDataFigureS2.mat','patch',[0.5 0.5 0.5]);
            m_grid('XaxisLocation','bottom','YaxisLocation','left','tickdir','on', ...
                'xtick',0:90:360,'ytick',-90:30:90,'fontsize',16, ...
                'fontweight','normal','linestyle','none','linewidth',3);
            m_text(65,55,['(' char('q'+2*(f-1)+v-1) ')'],'FontSize',20);
            if f == 1
                % The two rows use the same color scale in each column.
                cb = colorbar(ax,'southoutside');
                set(cb,'Units','normalized','Position',[barLeft(v) 0.88 0.26 0.02], ...
                    'Ticks',linspace(-mapMax(v),mapMax(v),5),'FontSize',16, ...
                    'LineWidth',2,'FontWeight','normal','AxisLocation','out');
                set(cb.Title,'String',titles{v},'Interpreter','latex','FontSize',20, ...
                    'FontName','Arial','FontWeight','normal','Position',[130 45 0], ...
                    'HorizontalAlignment','center');
                ax.Position = pos;
            end
            hold(ax,'off');
        end
    end
catch problem
    cd(previousFolder);
    rethrow(problem);
end
cd(previousFolder);

% Optional: export each window as its own PDF.
% exportgraphics(figComposite(1),fullfile(folder,'FigureS1_filter8.pdf'),'ContentType','vector');
% exportgraphics(figComposite(2),fullfile(folder,'FigureS1_filter12.pdf'),'ContentType','vector');
% exportgraphics(figTrend,fullfile(folder,'FigureS1_trends.pdf'),'ContentType','vector');
