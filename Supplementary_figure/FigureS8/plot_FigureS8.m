% Reproduce the three panels of Figure S8 from SourceDataFigureS8.mat.
scriptDir = fileparts(mfilename('fullpath'));
sourceFile = fullfile(scriptDir,'SourceDataFigureS8.mat');
if ~isfile(sourceFile)
    error('Run prepare_FigureS8.m first to create %s.',sourceFile);
end
S = load(sourceFile);
fig = figure('Name','Figure S8','NumberTitle','off', ...
    'Units','pixels','Position',[100 100 1400 1000]);

% Panels (a) and (b). The horizontal coordinate varies down matrix rows,
% matching the original [Lat,Lon] = meshgrid(Y,X) and contourf(Lon,Lat,...).
[x,y] = ndgrid(S.Rnx,S.Rny);
maps = {S.FSLE_mono,S.FSLE_dio};
mapTitles = {'Monopole eddy','Dipole eddy'};
panelLetters = {'(a)','(b)'};
contourLevels = {-10:1:0,-6.5:1:0};
mapPos = [0.47 0.55 0.32 0.32; 0.72 0.55 0.32 0.32];
for k = 1:2
    ax = axes('Parent',fig,'Units','normalized','Position',mapPos(k,:));
    z = S.displayScale*maps{k};
    contourf(ax,x,y,z,1000,'LineStyle','none');
    colormap(ax,S.colorTable);
    shading(ax,'interp');
    caxis(ax,[-12 -3]);
    axis(ax,'equal');
    set(ax,'XLim',[-2 2],'YLim',[-2 2],'XTick',-4:4,'YTick',-4:4, ...
        'LineWidth',3,'FontSize',16);
    xlabel(ax,'R_n','FontSize',18);
    title(ax,mapTitles{k},'FontSize',20);
    if k==1
        ylabel(ax,'R_n','FontSize',18);
    else
        ax.YTickLabel = [];
        % Place one horizontal colorbar above the pair of maps.
        cb = colorbar(ax,'southoutside');
        set(cb,'Units','normalized','Position',[0.52 0.91 0.47 0.023], ...
            'FontSize',16,'LineWidth',2,'AxisLocation','out','Box','on','Ticks',-12:3:-3);
        set(cb.Label,'String','FSLE (10^{-2} d^{-1})','FontSize',18);
        ax.Position = mapPos(k,:);
    end
    % Overlay gray contours and label them in black at the original spacing.
    hold(ax,'on');
    [C,h] = contour(ax,x,y,z,contourLevels{k},'LineColor',[0.4 0.4 0.4],'LineWidth',1.2);
    clabel(C,h,'Color','k','FontSize',10,'FontWeight','bold','LabelSpacing',400);
    text(ax,-1.8,1.7,panelLetters{k},'Color','k','FontSize',20,'FontWeight','normal', ...
        'BackgroundColor','w','EdgeColor','none','Margin',2);
    hold(ax,'off');
end

% Panel (c). Show cyclone and anticyclone means side by side in each alpha bin.
ax = axes('Parent',fig,'Units','normalized','Position',[0.54 0.08 0.44 0.36]);
hold(ax,'on');
box(ax,'on');
height = S.deltaMean*S.displayScale;
halfWidth = S.deltaError*S.displayScale;
groups = (1:size(height,1)).';
b = bar(ax,groups,height,'grouped');
set(b(1),'FaceColor',[59 173 196]/255,'FaceAlpha',1,'EdgeColor','none');
set(b(2),'FaceColor',[236 86 74]/255,'FaceAlpha',1,'EdgeColor','none');
% Draw symmetric error bars at the original offsets.
offsets = [-0.15 0.15];
for g = 1:2
    errorbar(ax,groups+offsets(g),height(:,g),halfWidth(:,g),'k', ...
        'LineStyle','none','LineWidth',2);
end
set(ax,'FontSize',18,'LineWidth',3,'XTick',groups, ...
    'XTickLabel',{'0-0.2','0.2-0.4','0.4-0.6','0.6-0.8','0.8-1.0'}, ...
    'YLim',[3 12],'YTick',3:3:12);
xlabel(ax,'\alpha','FontSize',20);
ylabel(ax,'\DeltaFSLE (10^{-2} d^{-1})','FontSize',18);
lg = legend(ax,b,S.polarityLabels,'FontSize',18);
set(lg,'Box','off','Units','normalized','Position',[0.7 0.34 0.16 0.08]);
text(ax,0.8,11,'(c)','FontSize',20);
hold(ax,'off');
