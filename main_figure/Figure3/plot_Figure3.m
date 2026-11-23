% Draw four separate SHAP dependence plots and one figure with four global maps.
% Place XGBoost_SHAP_inputs.mat beside this script. Run in MATLAB with
% smooth (Curve Fitting Toolbox), ksdensity (Statistics and Machine Learning
% Toolbox), and M_Map on the path.

folder = fileparts(mfilename('fullpath'));
load(fullfile(folder,'SourceDataFigure3.mat'),'longitude','latitude', ...
     'predictorNames','predictors','shapValues','sstaAmp','absDeltaFSLE', ...
     'scatterColors','dampingColors','mapColors');

%% Four dependence plots, each with a LOESS curve and a top density panel
xLabels = {'$\nabla \overline{\mathrm{SST}}\ (10^{-5}\ ^\circ\mathrm{C}\,\mathrm{m}^{-1})$', ...
           '$U/c$', '$\lambda^*$', '$\mathrm{SR}_{\mathrm{L}}\ (10^{-6}\,\mathrm{s}^{-1})$'};
ampLabel = '$\mathrm{SSTA\ Amp}\ (^\circ\mathrm{C})$';
colorLabels = {ampLabel,'$\Delta \mathrm{FSLE}\ (\mathrm{d}^{-1})$',ampLabel,'$U/c$'};
colorValues = {sstaAmp,absDeltaFSLE,sstaAmp,predictors(:,2)};
palettes = {scatterColors,scatterColors,dampingColors,scatterColors};

xScale = [1e5 1 1 1e6];
xMax = [2.5 30 2 1.5];
span = [0.25 0.30 0.15 0.15];
cMax = [1.5 0.3 1.5 15];
cStep = [0.5 0.1 0.5 5];
barFont = [16 18 16 16];
barWidth = [1.5 2 2 1.5];
zeroWidth = [1.8 2 2 1.8];
bottom = [0.12 0.12 0.12 0.13];

for k = 1:4
    x = predictors(:,k)*xScale(k);
    y = shapValues(:,k);
    c = colorValues{k};
    keep = isfinite(x) & isfinite(y) & isfinite(c);
    x = x(keep); y = y(keep); c = c(keep);

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
    if ~isempty(xs) && (k < 4 || numel(unique(xs)) >= 3)
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
    axes(ax);
end

%% Four SHAP maps in the original layout, with a shared vertical colorbar
lon = 1:2:359;
lat = -89:2:89;
mapSHAP = nan(numel(lon),numel(lat),4);
for i = 1:numel(lon)
    % Both cell edges are included, as in the original analysis.
    inLon = longitude >= lon(i)-1 & longitude <= lon(i)+1;
    localLat = latitude(inLon);
    localSHAP = shapValues(inLon,:);
    for j = 1:numel(lat)
        z = localSHAP(localLat >= lat(j)-1 & localLat <= lat(j)+1,:);
        if isempty(z)
            continue
        end
        mapSHAP(i,j,1) = mean(z(:,1),'omitnan');
        mapSHAP(i,j,2) = mean(z(:,2),'omitnan');
        mapSHAP(i,j,4) = mean(z(:,4),'omitnan');
        % Trim the sorted damping values using the full number of samples.
        n = size(z,1);
        damp = sort(z(:,3));
        mapSHAP(i,j,3) = mean(damp(floor(n*0.05)+1:floor(n*0.95)),'omitnan');
    end
end
mapSHAP(:,41:50,:) = NaN;

[Lon,Lat] = ndgrid(lon,lat);
positions = [0.08 0.68 0.37 0.30; 0.52 0.68 0.37 0.30; ...
             0.08 0.36 0.37 0.30; 0.52 0.36 0.37 0.30];
figure('Name','1','NumberTitle','off','Position',[100 50 1400 950]);
for k = 1:4
    ax = subplot(3,2,k);
    ax.Position = positions(k,:);
    m_proj('Miller','lon',[0 360],'lat',[-70 70]);
    m_pcolor(Lon,Lat,mapSHAP(:,:,k));
    colormap(ax,mapColors);
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
    title(ax,['SHAP contribution: ' predictorNames{k}],'FontSize',20);
end
