% Figure S9. The map positions, limits and SHAP profiles follow Figure4.m.
% Run beside SourceDataFigureS9.mat. Requires M_Map and spcrv (Curve Fitting Toolbox).
scriptDir = fileparts(mfilename('fullpath'));
S = load(fullfile(scriptDir,'SourceDataFigureS9.mat'),'ln','lt','Uc','SSTG','Damp','Strain', ...
    'SHAP_Uc','SHAP_SSTG','SHAP_Damp','SHAP_Strain','cmap');
hf = figure('Name','Figure S9','NumberTitle','off','Units','pixels', ...
    'Position',[100 100 1400 950],'Color','w');
climSHAP = [-0.06 0.06];
[lat,lon] = meshgrid(S.lt,S.ln);

% Assign a separate map and profile axis to each panel in reading order.
mapPositions = [0.05 0.62 0.36 0.30; 0.55 0.62 0.36 0.30; ...
                0.05 0.22 0.36 0.30; 0.55 0.22 0.36 0.30];
sidePositions = [0.41 0.62 0.08 0.30; 0.91 0.62 0.08 0.30; ...
                 0.41 0.22 0.08 0.30; 0.91 0.22 0.08 0.30];
mapAxes = gobjects(1,4);
sideAxes = gobjects(1,4);
for k = 1:4
    mapAxes(k) = axes('Parent',hf,'Units','normalized','Position',mapPositions(k,:));
    sideAxes(k) = axes('Parent',hf,'Units','normalized','Position',sidePositions(k,:));
end
fields = {S.SSTG,S.Uc,S.Damp,S.Strain};
profiles = {S.SHAP_SSTG,S.SHAP_Uc,S.SHAP_Damp,S.SHAP_Strain};
labels = {'(a)','(b)','(c)','(d)'};
titles = {'$\mathrm{SHAP\ contribution:\ \nabla\overline{SST}}$', ...
          '$\mathrm{SHAP\ contribution:}\ U/c$', ...
          '$\mathrm{SHAP\ contribution:}\ \lambda^{*}$', ...
          '$\mathrm{SHAP\ contribution:\ SR_{L}}$'};
colormap(hf,S.cmap);
for k = 1:4
    ax = mapAxes(k);
    axes(ax); % M_Map uses the current axes.
    m_proj('Miller','lon',[0 360],'lat',[-80 80]);
    m_pcolor(lon,lat,fields{k});
    hold(ax,'on');
    colormap(ax,S.cmap);
    caxis(ax,climSHAP);
    grid(ax,'on');
    m_grid('XaxisLocation','bottom','YaxisLocation','left','tickdir','in','box','on', ...
        'xtick',0:60:300,'ytick',-80:40:80,'fontsize',16,'linestyle',':','linewidth',2);
    m_coast('patch',[0.5 0.5 0.5]);
    title(ax,titles{k},'Interpreter','latex','FontSize',20);
    m_text(50,60,labels{k},'FontSize',20);
end

% Keep the hidden host above the bar so its outer side faces the page bottom.
scaleAx = axes('Parent',hf,'Units','normalized','Position',[0.06 0.18 0.88 0.03], ...
    'Visible','off','CLim',climSHAP);
colormap(scaleAx,S.cmap);
cb = colorbar(scaleAx,'southoutside');
set(cb,'Units','normalized','Position',[0.06 0.14 0.88 0.02], ...
    'Ticks',-0.06:0.02:0.06,'TickLabels',{'-0.06','-0.04','-0.02','0','0.02','0.04','0.06'}, ...
    'Visible','on','Box','on','TickDirection','in','FontSize',16,'LineWidth',2);
cb.AxisLocation = 'out'; % Below the bar. Use 'in' for labels above the bar.
set(cb.Label,'String','SHAP values','FontSize',20,'Interpreter','latex');

% Draw the original order-3 spline profiles from the saved latitude, mean
% and 1.96*SE columns. Both hemispheres use the original linear latitude axis.
for k = 1:4
    side = sideAxes(k);
    P = profiles{k};
    control = P([1 1:end end],:).';
    meanCurve = spcrv(control([1 2],:),3);
    bandCurve = spcrv(control([1 3],:),3);
    keep = ~isnan(meanCurve(2,:));
    meanCurve = meanCurve(:,keep);
    bandCurve = bandCurve(:,keep);
    firstNorth = find(meanCurve(1,:)>0,1);
    if isempty(firstNorth), firstNorth = size(meanCurve,2)+1; end
    hemispheres = {1:firstNorth-1,firstNorth:size(meanCurve,2)};
    hold(side,'on');
    for h = 1:2
        ii = hemispheres{h};
        if isempty(ii), continue; end
        yy = meanCurve(1,ii); mu = meanCurve(2,ii); hw = bandCurve(2,ii);
        plot(side,mu,yy,'r','LineWidth',2);
        fill(side,[mu+hw fliplr(mu-hw)],[yy fliplr(yy)],[0.01 0.01 0.01], ...
            'FaceAlpha',0.2,'EdgeAlpha',1,'EdgeColor','none');
    end
    plot(side,[0 0],[-100 100],'k--','LineWidth',2);
    set(side,'XLim',[-0.04 0.04],'YLim',[-80 80],'XTick',[-0.03 0 0.03], ...
        'XTickLabel',[],'YTick',[],'Box','on','LineWidth',2,'FontSize',16);
end
drawnow;
