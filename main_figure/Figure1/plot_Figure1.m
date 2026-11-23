% Plot the spatial distributions of two precomputed mesoscale eddy diagnostics.
% The script reads Eddy_alpha.mat and Net_ratio.mat and displays both fields
% on a 1-degree grid using a Robinson projection from 80 deg S to 80 deg N.
% Panel (a) shows the structure index (alpha) of eddy-induced sea surface
% temperature anomalies (SSTAs) and outlines the AS, KE, STCC, GS, and ACC regions.
% Panel (b) shows the net heat-flux ratio index (epsilon_Q). For each eddy,
% this is the signed area integral of the heat-flux anomaly divided by the
% area integral of its absolute value, both taken within 1.5 eddy radii
% of the eddy center. Its magnitude measures the fraction of the heat-flux
% signal retained after spatial cancellation within the eddy.

clc
clear

load SourceDataFigure1.mat
%% Panel (a): SSTA structure index
lon1=0;lon2=360;
lat1=-90;lat2=90;
gap=1;

hf=figure('Name','1','NumberTitle','off','position',[100 100 1400 900])
h1=subplot(2,2,1)
set(gca,'position',[0.04,0.4,0.42,0.42])
[lat,lon]=meshgrid([lat1+1:gap:lat2],[lon1+1:gap:lon2]);
m_proj('Robinson','lon',[lon1,lon2],'lat',[lat1+10,lat2-10]);
m_pcolor(lon,lat,Eddy_alpha);

colormap(h1,flipud(MPL_RdYlBu));
% Add a horizontal colorbar.
hh1 = colorbar('horiz');
set(hh1, 'Position', [0.12, 0.78, 0.26, 0.02], ...
         'FontSize', 16, 'LineWidth', 2, 'FontWeight','bold', 'AxisLocation', 'out');

hh1.Title.String = '$\alpha \,\, \mathrm{distribution}$';

% Render the colorbar title using LaTeX.
hh1.Title.Interpreter = 'latex';

hh1.Title.FontSize = 20;
hh1.Title.FontWeight = 'normal';
hh1.Title.FontName = 'Arial';

caxis([0.1,0.7]);
set(hh1,'ytick',[0.1:0.2:0.7],'Fontweight','normal');
hold on;
m_grid('XaxisLocation','bottom','YaxisLocation','left','tickdir','on', ...
    'xtick',0:90:360,'ytick',-90:30:90, ...
    'fontsize',18,'FontWeight','normal','linestyle','none','linewidth',3);
m_coast('patch',[.5 .5 .5]);

m_text(65,55,'(a)','Fontsize',18);
lon_p=[50 76;135 190;125 200;285 340;0 360];
lat_p=[5 20; 30 45;12 28;30 55; -60 -33];
regionNames = {'AS','KE','STCC','GS','ACC'}
hold on
for ii=1:size(lon_p,1)
    m_plot([lon_p(ii,1),lon_p(ii,1),lon_p(ii,2),lon_p(ii,2),lon_p(ii,1)],...
        [lat_p(ii,1),lat_p(ii,2),lat_p(ii,2),lat_p(ii,1),lat_p(ii,1)],...
        'k','Linewidth',1.5);
    hold on
    if ii==2
        m_text(lon_p(ii,1)+(lon_p(ii,2)-lon_p(ii,1))*0.38,lat_p(ii,1)+(lat_p(ii,2)-lat_p(ii,1))*0.5,...
            regionNames{ii},'Fontsize',16);
    elseif ii==3
        m_text(lon_p(ii,1)+(lon_p(ii,2)-lon_p(ii,1))*0.2,lat_p(ii,1)+(lat_p(ii,2)-lat_p(ii,1))*0.45,...
            regionNames{ii},'Fontsize',16);
    elseif ii==4
        m_text(lon_p(ii,1)+(lon_p(ii,2)-lon_p(ii,1))*0.5,lat_p(ii,1)+(lat_p(ii,2)-lat_p(ii,1))*0.25,...
            regionNames{ii},'Fontsize',16);
    elseif ii==5
        m_text(lon_p(ii,1)+(lon_p(ii,2)-lon_p(ii,1))*0.65,lat_p(ii,1)+(lat_p(ii,2)-lat_p(ii,1))*0.65,...
            regionNames{ii},'Fontsize',16);
    else
        m_text(lon_p(ii,1)+(lon_p(ii,2)-lon_p(ii,1))*0.15,lat_p(ii,1)+(lat_p(ii,2)-lat_p(ii,1))*0.45,...
        regionNames{ii},'Fontsize',16);
    end
end
%% Panel (b): Net heat-flux ratio index

lon1=0;lon2=360;
lat1=-90;lat2=90;
gap=1;
h2=subplot(2,2,2)
set(gca,'position',[0.54,0.4,0.42,0.42])
[lat,lon]=meshgrid([lat1+gap:gap:lat2],[lon1+gap:gap:lon2]);
m_proj('Robinson','lon',[lon1,lon2],'lat',[lat1+10,lat2-10]);
m_pcolor(lon,lat,Net_ratio);

colormap(h2,(cmp_b2r));
% Add a horizontal colorbar.
hh2 = colorbar('horiz' );
set(hh2, 'Position', [0.62, 0.78, 0.26, 0.02], ...
         'FontSize', 16, 'LineWidth', 2, 'FontWeight','normal', 'AxisLocation', 'out');

% Set the title above the colorbar.
% Use LaTeX math mode and \varepsilon for the index symbol.
hh2.Title.String = '$\varepsilon_Q \, \, \mathrm{distribution}$';

% Render the colorbar title using LaTeX.
hh2.Title.Interpreter = 'latex';

hh2.Title.FontSize = 20;
hh2.Title.FontWeight = 'normal';
hh2.Title.FontName = 'Arial';

hh2.Title.Position = [140, 45.0, 0];  % The y coordinate sets the title height above the colorbar.
hh2.Title.HorizontalAlignment = 'center';
caxis([0,0.5]);
set(hh2,'ytick',[0:0.125:0.5]);
hold on;
% % set(get(hh2,'Title'),'string','(m^2/s^{-2})','FontSize',18,'position',[308,-2]);
m_grid('XaxisLocation','bottom','YaxisLocation','left','tickdir','on','xtick',[0:90:360],...
    'ytick',[-90:30:90],'fontsize',18,'linestyle','none','linewidth',3);  % Set the line width of the map frame.
m_coast('patch',[.5 .5 .5]);
% % % text(50,80,'EKE distribution','Fontsize',20);
m_text(65,55,'(b)','Fontsize',18);


%%
% Plot eddy-centered composites of sea surface temperature anomalies (SSTAs)
% and turbulent heat-flux anomalies (HFAs) in figure panels (c)-(j).
% The composites are grouped by eddy polarity and monopole or dipole SSTA pattern.
% Columns show monopole anticyclones (AE), monopole cyclones (CE), dipole
% AEs, and dipole CEs. Panels (c)-(f) show SSTA in degrees Celsius with
% surface geostrophic velocity anomaly vectors on one common scale. Panel (f)
% includes the 0.20 m/s reference arrow. Panels (g)-(j) show
% HFA in W/m^2. Both coordinates are offsets from the eddy center divided
% by the eddy radius. Each matrix is indexed as (x/R, y/R).
% To recreate the figure, place Figure_b1_plot_data.mat beside this
% script and run it. The MAT-file includes the original figure colormap.

%% Load the published plot data
dataFile = fullfile(fileparts(mfilename('fullpath')), 'SourceDataFigure1.mat');
if ~isfile(dataFile)
    error('Place Figure_b1_plot_data.mat in the same folder as this script.');
end
D = load(dataFile);
[xGrid, yGrid] = ndgrid(D.xOverR, D.yOverR);

%% Configure the eight panels
groupTitles = {'monopole AE', 'monopole CE', 'dipole AE', 'dipole CE'};
quantities = {'SSTA', 'HFA'};
panelLabels = {'(c)', '(d)', '(e)', '(f)'; ...
               '(g)', '(h)', '(i)', '(j)'};
rowUnits = {[char(176) 'C'], 'W/m^2'};

% Monopole and dipole pairs have different color limits in each row.
colorLimits = [0.6, 0.6, 0.1, 0.1; ...
               16,  16,  4,   4];
left = [0.00, 0.20, 0.50, 0.70];
bottom = [0.65, 0.28];

% Each cell lists the labeled contour levels for one panel. Empty cells
% indicate that this contour style is unused in that panel.
darkLevels = {0:0.2:0.6, [], 0:0.05:0.2, 0:0.05:0.2; ...
              0:4:16,    [], 0:1:4,       0:0.4:4};
lightLevels = {[], -0.6:0.2:0, -0.2:0.05:-0.05, -0.3:0.05:-0.05; ...
               [], -16:4:-1,   -4:0.4:-0.1,     -4:1:-0.1};
contourColors = [0.4 0.4 0.4; 0.9 0.9 0.9];
contourTextColors = {'k', 'w'};
arrowGray = [0.8, 0.4, 0.8, 0.4];

% One m/s corresponds to two normalized coordinate units on every SSTA panel.
vecScale = 2.0;
refSpeed = 0.20;  % m/s

%% Draw the composites
fig = figure('Name', 'Eddy composites', 'NumberTitle', 'off', ...
             'Color', 'w', 'Units', 'pixels', 'Position', [100 100 1400 900]);
colormap(fig, D.CustomColormap);
velocityAxes = gobjects(1,4);

for row = 1:2
    for col = 1:4
        panelPosition = [left(col), bottom(row), 0.30, 0.28];
        ax = axes('Parent', fig, 'Units', 'normalized', 'Position', panelPosition);
        fieldName = [quantities{row} '_' D.groupKeys{col}];
        fieldValues = D.(fieldName);

        contourf(ax, xGrid, yGrid, fieldValues, 1000, 'LineStyle', 'none');
        hold(ax, 'on');
        axis(ax, 'equal');
        xlim(ax, [-2 2]);
        ylim(ax, [-2 2]);
        limit = colorLimits(row, col);
        caxis(ax, [-limit limit]);
        set(ax, 'FontSize', 16, 'FontWeight', 'normal', 'LineWidth', 2, ...
                'Box', 'on', 'XTick', -2:2, 'YTick', -2:2);

        % Overlay the velocity anomaly from the same eddy group as the SSTA.
        % Apply the common velocity scale and turn off automatic rescaling.
        if row == 1
            velocityAxes(col) = ax;
            key = D.groupKeys{col};
            u = D.(['UA_' key]);
            v = D.(['VA_' key]);
            quiver(ax, xGrid, yGrid, vecScale*u, vecScale*v, 0, ...
                   'Color', repmat(arrowGray(col), 1, 3), ...
                   'LineWidth', 1.2, 'MaxHeadSize', 1.4);
        else
            xlabel(ax, 'R_{nx}', 'FontSize', 16, 'FontWeight', 'normal');
        end

        % Apply the dark and light contours for this panel separately.
        levelSets = {darkLevels{row,col}, lightLevels{row,col}};
        for style = 1:2
            levels = levelSets{style};
            if ~isempty(levels)
                [C, h] = contour(ax, xGrid, yGrid, fieldValues, levels, ...
                    'LineColor', contourColors(style,:), 'LineWidth', 1.2);
                clabel(C, h, 'Color', contourTextColors{style}, 'FontSize', 10, ...
                    'FontWeight', 'normal', 'LabelSpacing', 400);
            end
        end

        % The right-hand panel of each pair carries its shared colorbar.
        if col == 2 || col == 4
            ax.YTickLabel = [];
            cb = colorbar(ax, 'eastoutside');
            cb.Units = 'normalized';
            cb.Position = [left(col) + 0.25, bottom(row), 0.01, 0.28];
            cb.Ticks = linspace(-limit, limit, 5);
            cb.FontSize = 16;
            cb.LineWidth = 2;
            cb.Box = 'on';
            cb.Title.String = rowUnits{row};
            cb.Title.FontSize = 16;
            cb.Title.FontWeight = 'normal';
            cb.Title.Position = [5,190,0];
            ax.Position = panelPosition;
        else
            ylabel(ax, 'R_{ny}', 'FontSize', 16, 'FontWeight', 'normal');
        end

        title(ax, [quantities{row} ' in ' groupTitles{col}], ...
              'FontSize', 16, 'FontWeight', 'normal');
        text(ax, -1.8, 1.8, panelLabels{row,col}, 'Color', 'k', ...
             'FontSize', 16, 'FontWeight', 'normal', 'BackgroundColor', 'w', ...
             'EdgeColor', 'none', 'Margin', 2);
        hold(ax, 'off');
    end
end

% Restore equal plot-box sizes after positioning all shared colorbars.
for col = 1:4
    ax = velocityAxes(col);
    ax.Position = [left(col), bottom(1), 0.30, 0.28];
    ax.Layer = 'top';
    axis(ax, 'equal');
    xlim(ax, [-2 2]);
    ylim(ax, [-2 2]);
end

% Draw the velocity key in the upper-right corner of panel (f). Its length
% uses the same conversion as the composite vectors.
ax = velocityAxes(4);
hold(ax, 'on');
boxWidth = 1.00;
boxHeight = 0.70;
boxX = ax.XLim(2) - boxWidth;
boxY = ax.YLim(2) - boxHeight;
centerX = boxX + boxWidth/2;
refLength = vecScale * refSpeed;

rectangle('Parent', ax, 'Position', [boxX boxY boxWidth boxHeight], ...
          'FaceColor', 'w', 'EdgeColor', 'none');
quiver(ax, centerX-refLength/2, boxY+0.72*boxHeight, refLength, 0, 0, ...
       'Color', 'k', 'LineWidth', 1.2, 'MaxHeadSize', 1.4);
text(ax, centerX, boxY+0.28*boxHeight, sprintf('%.2f m/s', refSpeed), ...
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
     'FontSize', 10, 'FontWeight', 'normal', 'Color', 'k', 'Interpreter', 'none');
hold(ax, 'off');

%%
%% Regional net heat-flux ratios by eddy polarity and SSTA structure (panel k)
% Plot the mean signed net heat-flux ratio (epsilon_Q) in five ocean regions.
% Bars are grouped by region and colored by four bins of the eddy-induced
% sea surface temperature anomaly (SSTA) structure index (alpha).
% The upper and lower panels show anticyclonic and cyclonic eddies, respectively.
% Error bars extend by the stored uncertainty on either side of each mean.

load SourceDataFigure1.mat
hf=figure('Name','1','NumberTitle','off','position',[100 100 1400 400]);
regionNames = {'AS','KE','STCC','GS','ACC'};
means_AE = HFA_AE(:, [2 4 6 8 10 ])';   % AE means by region (rows) and alpha bin (columns).
ci_AE    = HFA_AE(:, [3 5 7 9 11 ])';   % AE error-bar half-widths by region (rows) and alpha bin (columns).
means_CE = HFA_CE(:, [2 4 6 8 10 ])';   % CE means by region (rows) and alpha bin (columns).
ci_CE    = HFA_CE(:, [3 5 7 9 11 ])';   % CE error-bar half-widths by region (rows) and alpha bin (columns).

hf1=subplot(5,1,1)
set(gca,'position',[0.08,0.62,0.88,0.32])
% Plot the regional means for anticyclonic eddies.
b1 = bar(means_AE, 'grouped');
set(b1(1), 'FaceColor', [25/255 86/255 150/255], 'FaceAlpha', 1, 'EdgeColor', 'none'); % Dark blue for the 0-0.25 alpha bin.
set(b1(2), 'FaceColor', [59/255,173/255,196/255], 'FaceAlpha', 1, 'EdgeColor', 'none'); % Turquoise for the 0.25-0.5 alpha bin.
set(b1(3), 'FaceColor', [236/255,141/255,57/255],  'FaceAlpha', 1, 'EdgeColor', 'none'); % Orange for the 0.5-0.75 alpha bin.
set(b1(4), 'FaceColor', [236/255,86/255,74/255],'FaceAlpha', 1, 'EdgeColor', 'none'); % Coral red for the 0.75-1 alpha bin.

% Center the symmetric error bars on the four bars in each region.
hold on;
for i = 1:size(means_AE, 1)
    errorbar(i - 0.272, means_AE(i, 1), ci_AE(i, 1), ci_AE(i, 1), 'k', 'LineStyle', 'none','Linewidth',1.3);
    errorbar(i - 0.09, means_AE(i, 2), ci_AE(i, 2),  ci_AE(i, 2),'k', 'LineStyle', 'none','Linewidth',1.3);
    errorbar(i + 0.09, means_AE(i, 3), ci_AE(i, 3),  ci_AE(i, 3),'k', 'LineStyle', 'none','Linewidth',1.3);
    errorbar(i + 0.272, means_AE(i, 4), ci_AE(i, 4),  ci_AE(i, 4),'k', 'LineStyle', 'none','Linewidth',1.3);
end

% Format the axes.
set(gca,'Fontsize',15,'Linewidth',2);
set(gca, 'XTick', 1:6, 'XTickLabel',[]);
% % % l1=legend(b1,{'0~0.25','0.25~0.5','0.5~0.75','0.75~1'}, 'FontSize', 13);
% % % set(l1,'Location','northout','NumColumns',4,'Box','off');
hold off;
set(gca,'TickDir','out');     % Point the tick marks outward.
set(gca,'box','off');
set(gca,'YAxisLocation','left');             % Place the y-axis on the left.
ylim([-0.2 1])
ax = gca;
% Place the x-axis and its ticks at y = 0.
ax.XAxisLocation = 'origin';
% Keep the y-axis on the left.
ax.YAxisLocation = 'left';


% Use a separate axis for the region names shared by both panels.
hf3=subplot(5,1,5);
set(gca,'position',[0.08,0.18,0.88,0.08])
ax3 = gca;
cla(ax3);                    % Clear the axes before adding zero-height bars for label alignment.
hold(ax3,'off');
% Zero-height bars reproduce the group positions for the shared labels.
means=zeros(size(means_CE));
b3 = bar(means, 'grouped');
set(b3(1), 'FaceColor', [25/255 86/255  150/255], 'FaceAlpha', 1, 'EdgeColor', 'none'); % Dark blue for the 0-0.25 alpha bin.
set(b3(2), 'FaceColor', [59/255,173/255,196/255], 'FaceAlpha', 1, 'EdgeColor', 'none'); % Turquoise for the 0.25-0.5 alpha bin.
set(b3(3), 'FaceColor', [236/255,141/255,57/255], 'FaceAlpha', 1, 'EdgeColor', 'none'); % Orange for the 0.5-0.75 alpha bin.
set(b3(4), 'FaceColor', [236/255,86/255,74/255], 'FaceAlpha', 1, 'EdgeColor', 'none'); % Coral red for the 0.75-1 alpha bin.

% Set the vertical limits of the axis used for region labels.
ylim(ax3, [-1 1]);

% Use the region names as the x-axis tick labels.
set(ax3, 'XTick', 1:6, ...
         'XTickLabel', regionNames, ...
         'FontSize', 15, ...
         'LineWidth', 2,...
         'Fontweight','normal');

% Hide the y-axis and its ticks.
set(ax3, 'YTick', [], 'YColor', 'none');
% Remove the top and right borders.
 set(ax3, 'Box', 'off');
 ax3.XAxisLocation = 'origin';


hf2=subplot(5,1,3)
set(gca,'position',[0.08,0.25,0.88,0.32])
% Plot the regional means for cyclonic eddies.
b2 = bar(means_CE, 'grouped');
set(b2(1), 'FaceColor', [25/255 86/255 150/255], 'FaceAlpha', 1, 'EdgeColor', 'none'); % Dark blue for the 0-0.25 alpha bin.
set(b2(2), 'FaceColor', [59/255,173/255,196/255], 'FaceAlpha', 1, 'EdgeColor', 'none'); % Turquoise for the 0.25-0.5 alpha bin.
set(b2(3), 'FaceColor', [236/255,141/255,57/255],  'FaceAlpha', 1, 'EdgeColor', 'none'); % Orange for the 0.5-0.75 alpha bin.
set(b2(4), 'FaceColor', [236/255,86/255,74/255],'FaceAlpha', 1, 'EdgeColor', 'none'); % Coral red for the 0.75-1 alpha bin.

% Center the symmetric error bars on the four bars in each region.
hold on;
for i = 1:size(means_CE, 1)
    errorbar(i - 0.272, means_CE(i, 1), ci_CE(i, 1), ci_CE(i, 1), 'k', 'LineStyle', 'none','Linewidth',1.3);
    errorbar(i - 0.09, means_CE(i, 2), ci_CE(i, 2),  ci_CE(i, 2),'k', 'LineStyle', 'none','Linewidth',1.3);
    errorbar(i + 0.09, means_CE(i, 3), ci_CE(i, 3),  ci_CE(i, 3),'k', 'LineStyle', 'none','Linewidth',1.3);
    errorbar(i + 0.272, means_CE(i, 4), ci_CE(i, 4),  ci_CE(i, 4),'k', 'LineStyle', 'none','Linewidth',1.3);
end

% Format the axes.
set(gca,'Fontsize',15,'Linewidth',2);
set(gca, 'XTick', 1:6, 'XTickLabel',[]);
l2=legend(b2,{'0~0.25','0.25~0.5','0.5~0.75','0.75~1'}, 'FontSize', 13);
set(l2,'Location','south','NumColumns',4,'Box','off');
hold off;
set(gca,'TickDir','out');     % Point the tick marks outward.
set(gca,'box','off');
set(gca,'YAxisLocation','left');             % Place the y-axis on the left.
ylim([-1 0.2])
ax = gca;
% Place the x-axis and its ticks at y = 0.
ax.XAxisLocation = 'origin';
% Keep the y-axis on the left.
ax.YAxisLocation = 'left';

% % eqn = '$\frac{\left|\overline{Q^\prime}\right|}{\overline{\left|Q^\prime\right|}}$';
eqn = '$\varepsilon_Q$';
hh = annotation(gcf,'textbox', [0.01 0.62 0.25 0.08], ...  % Normalized textbox position [x y width height].
    'String', eqn, ...
    'Interpreter','latex', ...
    'FitBoxToText','on', ...
    'EdgeColor','none', ...
    'BackgroundColor','none', ...
    'FontSize',28, ...
    'FontWeight','normal');
% % hh.TextRotation = 90;   % Rotate the label by 90 degrees.

% Label the eddy polarities, panel letter, and alpha legend.
hh1 = annotation(gcf,'textarrow',[0.95 0.95],[0.9 0.9], ...
    'String','Anticyclone', ...
    'HeadStyle','none', ...
    'LineStyle','none', ...
    'FontSize',18,...
    'Fontweight','normal');

hh2 = annotation(gcf,'textarrow',[0.95 0.95],[0.32 0.32], ...
    'String','Cyclone', ...
    'HeadStyle','none', ...
    'LineStyle','none', ...
    'FontSize',18,...
    'Fontweight','normal');

hh3 = annotation(gcf,'textarrow',[0.12 0.12],[0.9 0.9], ...
    'String','(k)', ...
    'HeadStyle','none', ...
    'LineStyle','none', ...
    'FontSize',18,...
    'Fontweight','normal');

hh4 = annotation(gcf,'textarrow',[0.36 0.36],[0.3 0.3], ...
    'String', '$\alpha$:', ...
    'Interpreter','latex', ...
    'HeadStyle','none', ...
    'LineStyle','none', ...
    'FontSize',18,...
    'Fontweight','normal');
