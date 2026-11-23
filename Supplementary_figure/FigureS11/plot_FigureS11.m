clc
clear
% Recreate both Figure S11 windows from the saved data. Requires M_Map.
scriptDir = fileparts(mfilename('fullpath'));
S = load(fullfile(scriptDir,'SourceDataFigureS11.mat'), ...
    'lon','lat','panelLabels','titles','displaySlope','starMask','starOffsetDegrees','colorScale');
[lonGrid,latGrid] = ndgrid(S.lon,S.lat);

% Panels (a-f): two periods per row and one shared colorbar per variable.
fig = figure('Name','Figure S11 (a-f)','NumberTitle','off','Color','w', ...
    'Units','pixels','Position',[100 80 1100 950]);
left = [0.05 0.52];
bottom = [0.70 0.40 0.10];
for row = 1:3
    for col = 1:2
        k = 2*(row-1)+col;
        pos = [left(col) bottom(row) 0.38 0.30];
        ax = drawMap(fig,pos,S,k,1,lonGrid,latGrid);
    end
    drawScale(ax,pos,[0.92 bottom(row)+0.05 0.012 0.20],S.colorScale,k);
end

% Panels (g,h): keep the original two different color limits. Give each map
% its own scale, and use a shorter figure for this single row of panels.
fig = figure('Name','Figure S11 (g-h)','NumberTitle','off','Color','w', ...
    'Units','pixels','Position',[100 80 1200 360]);
for col = 1:2
    k = 6+col;
    pos = [0.035+0.5*(col-1) 0.10 0.365 0.79];
    ax = drawMap(fig,pos,S,k,2,lonGrid,latGrid);
    drawScale(ax,pos,[pos(1)+0.375 0.24 0.012 0.52],S.colorScale,k);
end

function ax = drawMap(fig,pos,S,k,paletteIndex,lon,lat)
ax = axes('Parent',fig,'Units','normalized','Position',pos);
m_proj('Robinson','lon',[0 360],'lat',[-80 80]);
m_pcolor(lon,lat,S.displaySlope(:,:,k));
hold(ax,'on');
colormap(ax,S.colorScale.rgb{paletteIndex});
caxis(ax,S.colorScale.limits(k,:));
m_grid('XaxisLocation','bottom','YaxisLocation','left','tickdir','in', ...
    'xtick',0:90:360,'ytick',-90:30:90,'fontsize',15, ...
    'FontWeight','bold','linestyle','none','linewidth',3);
% Mark significant cells at the half-grid offsets used in both source scripts.
mark = S.starMask(:,:,k);
if any(mark(:))
    m_plot(lon(mark)+S.starOffsetDegrees(1),lat(mark)+S.starOffsetDegrees(2), ...
        'k*','MarkerSize',2,'LineWidth',0.2);
end
m_coast('patch',[0.5 0.5 0.5]);
title(ax,S.titles{k},'Interpreter','latex','FontSize',18,'FontWeight','bold');
m_text(65,55,['(' S.panelLabels(k) ')'],'FontSize',18);
end

function drawScale(ax,mapPos,barPos,scale,k)
cb = colorbar(ax,'eastoutside');
cb.Units = 'normalized';
cb.Position = barPos;
ax.Position = mapPos;
set(cb,'Ticks',scale.ticks{k},'FontSize',14,'AxisLocation','out','LineWidth',2);
set(cb.Label,'String',scale.units{k},'Interpreter','latex','FontSize',14,'Rotation',90);
end
