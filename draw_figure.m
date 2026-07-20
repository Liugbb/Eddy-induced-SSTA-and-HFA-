clc
clear
file1 = "I:\Eddy_SSTA_structure\Normalized_distance\XGBoost_shap_old\XGBoost_SHAP_new\Normalized\Without_lat\xgb_shap_values_without_lat_data.csv";
file2 = "I:\Eddy_SSTA_structure\Normalized_distance\XGBoost_shap_old\XGBoost_SHAP_new\Normalized\Without_lat\xgb_pred_without_lat_data.csv"
% Read the specified data range
SHAP_Data = readmatrix(file1, "Range", "A2:R137432");   % [row1 col1 row2 col2]
Pos= readmatrix(file1, "Range", "A2:B137432");  
%%%%%%%===================================================================
%%% 1. lon; 2. lat; 3. time; 4. move velocity; 5. Max velocity; 6.
%%% mean_velocity; 7. U/c; 8. Strain rate; 9. Normalized stirring term
%%% 10. SST gradient; 11. Normalized damping rate; 12. damping rate;
%%% 13. alpha; 14. index; 15. U/c SHAP; 16. Strain rate SHAP; 
%%% 17. SST gradient SHAP; 18. damping rate SHAP; 19: Latitude SHAP
%%%%%%%%==================================================================
load('I:\Eddy_SSTA_structure\Normalized_distance\extract_varaition\Eddy_data_all.mat')
% % % % colNames = ["Longitude","Latitude","Time","Move velocity","Max_rotation_velocity",...
% % % %      "Mean_rotation_velocity","U/c","Strain_rate","Normalized_Stirring_term",...
% % % %      "SST_gradient","Normalized_damping_rate","damping_rate","Structural_index(alpha)",...
% % % %      "SSTA_amplitude","DFSLE"];   % 1×M


A = SHAP_Data(:,1:3);
B = Eddy_data_all(:,1:3);
[tf, loc] = ismember(A, B, 'rows');   % Perform row-wise matching in a single operation
SHAP_Data(:,20:21) = NaN;              % Initialize with NaN
SHAP_Data(tf,20:21) = Eddy_data_all(loc(tf), [14:15]);


%% SST gradient
SST_gra = [];
SST_gra(:,1) = SHAP_Data(:,10);   % background SST gradient
SST_gra(:,2) = SHAP_Data(:,17);   % SHAP value
SST_gra(:,3) = SHAP_Data(:,20);   % SSTA amplitude (for color)

% ---- remove NaN
zz = isnan(SST_gra(:,1)) | isnan(SST_gra(:,2)) | isnan(SST_gra(:,3));
SST_gra(zz,:) = [];

% ---- assign x/y/c
x = SST_gra(:,1) * 1e5;   % ∇SST (10^-5 °C m^-1)
y = SST_gra(:,2);         % SHAP value
c = SST_gra(:,3);         % SSTA amplitude

% ---- remove inf
idx = isfinite(x) & isfinite(y) & isfinite(c);
x = x(idx); y = y(idx); c = c(idx);

% =========================================================
%  Main plot: scatter + LOESS
% =========================================================
figure('Color','w','Position',[100 100 720 480]);

ax_main = axes;
set(ax_main,'Position',[0.12,0.12,0.73,0.65]);
hold(ax_main,'on'); box(ax_main,'on');

% scatter
scatter(ax_main, x, y, 18, c, 'filled', ...
    'MarkerFaceAlpha',0.85, 'MarkerEdgeAlpha',0.85);

% colormap + colorbar
load('D:\software\R2020b\toolbox\colorbar_ncl\MPL_RdYlBu.txt');
colormap(ax_main, flipud(MPL_RdYlBu));

cb = colorbar(ax_main);
cb.Position = [0.88 0.12 0.02 0.65];
cb.Label.Interpreter = 'latex';
cb.Label.String = '$\mathrm{SSTA\ Amp}\ (^\circ\mathrm{C})$';
cb.FontSize = 14;
cb.LineWidth = 1.5;
caxis(ax_main, [0 1.5]);
set(cb,'YTick',0:0.5:1.5);

% y=0 reference line
yline(ax_main, 0, '--k', 'LineWidth', 1.8);

% LOESS trend line
[xs, I] = sort(x);
ys = y(I);
ys_fit = smooth(xs, ys, 0.25, 'loess');
plot(ax_main, xs, ys_fit, 'k-', 'LineWidth', 2.5);

% axes formatting
xlim(ax_main, [0 2.5]);
ylim(ax_main, [-0.10 0.15]);
set(ax_main,'FontSize',16,'LineWidth',2);

xlabel(ax_main, ...
    '$\nabla\overline{SST}\ (10^{-5}\,^\circ\mathrm{C}\,\mathrm{m}^{-1})$', ...
    'Interpreter','latex', ...
    'FontSize',18);
ylabel(ax_main, '$\mathrm{SHAP\ value}$', 'Interpreter','latex','FontSize',18);

% =========================================================
%  Top panel: PDF (ksdensity) as grey shading
% =========================================================
% =========================================================
%  Top panel: PDF band of x (U/c) using ksdensity
% =========================================================
pos = ax_main.Position;
h_top = 0.10;
gap   = 0.05;

ax_top = axes('Position',[pos(1), pos(2)+pos(4)+gap, pos(3), h_top]);
hold(ax_top,'on'); box(ax_top,'off');

x_use = x(isfinite(x));
xgrid = linspace(min(x_use), max(x_use), 300);

% Recommended bandwidth: adapt automatically to the data scale (robust; no manual tuning required)
bw = 1.06 * std(x_use) * numel(x_use)^(-1/5);
if ~isfinite(bw) || bw<=0
    bw = 0.1 * range(x_use); % Fallback
end

[pdfx, xgrid] = ksdensity(x_use, xgrid, 'Bandwidth', bw);

% Grey PDF shading
fill(ax_top, ...
    [xgrid fliplr(xgrid)], ...
    [pdfx zeros(size(pdfx))], ...
    [0.7 0.7 0.7], ...
    'EdgeColor','none', 'FaceAlpha', 1);

% Optional: add an outline for better visibility
% plot(ax_top, xgrid, pdfx, 'k', 'LineWidth', 1.2);

% Align with the main plot
xlim(ax_top, xlim(ax_main));
set(ax_top,'XTick',[]);
ax_top.Color = 'none';
set(ax_top,'LineWidth',1.8,'FontSize',15);

% Optional: verify that the integral equals 1
% disp(trapz(xgrid, pdfx))

axes(ax_main);


%%%%% =========================
%  Output (optional)
% =========================
% exportgraphics(gcf,'SHAP_SSTgrad_density.png','Resolution',600);

%% U/c
SST_gra = [];
SST_gra(:,1) = SHAP_Data(:,7);          % U/c  (x)
SST_gra(:,2) = SHAP_Data(:,15);         % SHAP value (y)
SST_gra(:,3) = abs(SHAP_Data(:,21));    % |ΔFSLE| (color)

% ---- remove NaN (all three columns)
zz = isnan(SST_gra(:,1)) | isnan(SST_gra(:,2)) | isnan(SST_gra(:,3));
SST_gra(zz,:) = [];

x = SST_gra(:,1);
y = SST_gra(:,2);
c = SST_gra(:,3);

% ---- remove inf
idx = isfinite(x) & isfinite(y) & isfinite(c);
x = x(idx); y = y(idx); c = c(idx);

% =========================================================
%  Main plot: scatter + LOESS
% =========================================================
figure('Color','w','Position',[100 100 720 480]);

ax_main = axes;
set(ax_main,'Position',[0.12,0.12,0.73,0.65]);
hold(ax_main,'on'); box(ax_main,'on');

scatter(ax_main, x, y, 18, c, 'filled', ...
    'MarkerFaceAlpha',0.85, 'MarkerEdgeAlpha',0.85);

% colormap + colorbar
load('D:\software\R2020b\toolbox\colorbar_ncl\MPL_RdYlBu.txt');
colormap(ax_main, flipud(MPL_RdYlBu));

cb = colorbar(ax_main);
cb.Position = [0.88 0.12 0.02 0.65];
cb.Label.Interpreter = 'latex';
cb.Label.String = '$\Delta \mathrm{FSLE}\ (\mathrm{d}^{-1})$';
cb.FontSize = 16;
cb.LineWidth = 2;

caxis(ax_main, [0 0.3]);
set(cb,'YTick',0:0.1:0.3);

% y=0 reference line
yline(ax_main, 0, '--k', 'LineWidth', 2);

% LOESS trend line (sort x)
[xs, I] = sort(x);
ys = y(I);
ys_fit = smooth(xs, ys, 0.30, 'loess');
plot(ax_main, xs, ys_fit, 'k-', 'LineWidth', 2.5);

% axes formatting
xlim(ax_main, [0 30]);
% Uncomment the next line to use a fixed y-axis range
% ylim(ax_main, [-0.15 0.15]);

set(ax_main,'LineWidth',2,'FontSize',16);
xlabel(ax_main, '$U/c$', 'Interpreter','latex','FontSize',18);
ylabel(ax_main, '$\mathrm{SHAP\ value}$', 'Interpreter','latex','FontSize',18);

% =========================================================
%  Top panel: PDF band of x (U/c) using ksdensity
% =========================================================
pos = ax_main.Position;
h_top = 0.10;
gap   = 0.05;

ax_top = axes('Position',[pos(1), pos(2)+pos(4)+gap, pos(3), h_top]);
hold(ax_top,'on'); box(ax_top,'off');

x_use = x(isfinite(x));
xgrid = linspace(min(x_use), max(x_use), 300);

% Recommended bandwidth: adapt automatically to the data scale (robust; no manual tuning required)
bw = 1.06 * std(x_use) * numel(x_use)^(-1/5);
if ~isfinite(bw) || bw<=0
    bw = 0.1 * range(x_use); % Fallback
end

[pdfx, xgrid] = ksdensity(x_use, xgrid, 'Bandwidth', bw);

% Grey PDF shading
fill(ax_top, ...
    [xgrid fliplr(xgrid)], ...
    [pdfx zeros(size(pdfx))], ...
    [0.7 0.7 0.7], ...
    'EdgeColor','none', 'FaceAlpha', 1);

% Optional: add an outline for better visibility
% plot(ax_top, xgrid, pdfx, 'k', 'LineWidth', 1.2);

% Align with the main plot
xlim(ax_top, xlim(ax_main));
set(ax_top,'XTick',[]);
ax_top.Color = 'none';
set(ax_top,'LineWidth',1.8,'FontSize',15);

% Optional: verify that the integral equals 1
% disp(trapz(xgrid, pdfx))

axes(ax_main);

%% Damping rate
% =========================================================
%  lambda* vs SHAP (colored by SSTA Amp) + LOESS + Top PDF panel
%  x: lambda*   (SHAP_Data(:,11))
%  y: SHAP value (SHAP_Data(:,18))
%  c: SSTA Amp   (SHAP_Data(:,20))
% =========================================================

SST_gra = [];
SST_gra(:,1) = SHAP_Data(:,11);   % lambda* (x)
SST_gra(:,2) = SHAP_Data(:,18);   % SHAP value (y)
SST_gra(:,3) = SHAP_Data(:,7);   % U/c

% ---- remove NaN (all three columns)
zz = isnan(SST_gra(:,1)) | isnan(SST_gra(:,2)) | isnan(SST_gra(:,3));
SST_gra(zz,:) = [];

x = SST_gra(:,1);
y = SST_gra(:,2);
c = SST_gra(:,3);

% ---- remove inf
idx = isfinite(x) & isfinite(y) & isfinite(c);
x = x(idx); y = y(idx); c = c(idx);

% =========================================================
%  Main plot: scatter + LOESS
% =========================================================
figure('Color','w','Position',[100 100 720 480]);

ax_main = axes;
set(ax_main,'Position',[0.12,0.12,0.73,0.65]);
hold(ax_main,'on'); box(ax_main,'on');

scatter(ax_main, x, y, 18, c, 'filled', ...
    'MarkerFaceAlpha',0.85, 'MarkerEdgeAlpha',0.85);

% colormap + colorbar
load('D:\software\R2020b\toolbox\colorbar_ncl\MPL_RdYlBu.txt');
colormap(ax_main, flipud(MPL_RdYlBu));

cb = colorbar(ax_main);
cb.Position = [0.88 0.12 0.02 0.65];
cb.Label.Interpreter = 'latex';
% % % cb.Label.String = '$\mathrm{SSTA\ Amp}\ (^\circ\mathrm{C})$';
cb.Label.String = '$U/c$';
cb.FontSize = 16;
cb.LineWidth = 2;

% % caxis(ax_main, [0 1.5]);
% % set(cb,'YTick',0:0.5:1.5);
caxis(ax_main, [0 15]);
set(cb,'YTick',0:5:15);

% y=0 reference line
yline(ax_main, 0, '--k', 'LineWidth', 2);

% LOESS trend line (sort x)
[xs, I] = sort(x);
ys = y(I);
ys_fit = smooth(xs, ys, 0.15, 'loess');
plot(ax_main, xs, ys_fit, 'k-', 'LineWidth', 2.5);

% axes formatting
xlim(ax_main, [0 2]);
% Uncomment the next line to use a fixed y-axis range
% ylim(ax_main, [-0.15 0.15]);

set(ax_main,'LineWidth',2,'FontSize',16);
xlabel(ax_main, '$\lambda^*$', 'Interpreter','latex','FontSize',18);
ylabel(ax_main, '$\mathrm{SHAP\ value}$', 'Interpreter','latex','FontSize',18);

% =========================================================
%  Top panel: PDF band of x (U/c) using ksdensity
% =========================================================
pos = ax_main.Position;
h_top = 0.10;
gap   = 0.05;

ax_top = axes('Position',[pos(1), pos(2)+pos(4)+gap, pos(3), h_top]);
hold(ax_top,'on'); box(ax_top,'off');

x_use = x(isfinite(x));
xgrid = linspace(min(x_use), max(x_use), 300);

% Recommended bandwidth: adapt automatically to the data scale (robust; no manual tuning required)
bw = 1.06 * std(x_use) * numel(x_use)^(-1/5);
if ~isfinite(bw) || bw<=0
    bw = 0.1 * range(x_use); % Fallback
end

[pdfx, xgrid] = ksdensity(x_use, xgrid, 'Bandwidth', bw);

% Grey PDF shading
fill(ax_top, ...
    [xgrid fliplr(xgrid)], ...
    [pdfx zeros(size(pdfx))], ...
    [0.7 0.7 0.7], ...
    'EdgeColor','none', 'FaceAlpha', 1);

% Optional: add an outline for better visibility
% plot(ax_top, xgrid, pdfx, 'k', 'LineWidth', 1.2);

% Align with the main plot
xlim(ax_top, xlim(ax_main));
set(ax_top,'XTick',[]);
ax_top.Color = 'none';
set(ax_top,'LineWidth',1.8,'FontSize',15);

% Optional: verify that the integral equals 1
% disp(trapz(xgrid, pdfx))
axes(ax_main);

%% Strain rate
SST_gra=[];
SST_gra(:,1)=SHAP_Data(:,8);
SST_gra(:,2)=SHAP_Data(:,16);
SST_gra(:,3)=SHAP_Data(:,7);
%  plot(SST_gra(:,1),SST_gra(:,2),'k.');
%%%% Plot a color-coded scatter plot 
zz=find(isnan(SST_gra(:,3)));
SST_gra(zz,:)=[];
x=SST_gra(:,1)*10^6;y=SST_gra(:,2);c=SST_gra(:,3);
% x: VMAX, y: SHAP, c: AMO
idx = isfinite(x) & isfinite(y) & isfinite(c);

figure('Color','w','Position',[100 100 720 420]);
set(gca,'position',[0.12,0.12,0.73,0.75])
scatter(x(idx), y(idx), 18, c(idx), 'filled', ...
    'MarkerFaceAlpha', 0.85, 'MarkerEdgeAlpha', 0.85);
load('D:\software\R2020b\toolbox\colorbar_ncl\MPL_RdYlBu.txt');
colormap(flipud(MPL_RdYlBu));
cb = colorbar;
cb.Position = [0.88 0.12 0.02 0.70];     % [left bottom width height]

cb.Label.Interpreter = 'latex';
cb.Label.String = '$U/c$';

caxis([0 20]);   % Set the color range from 0 to 20
set(cb,'ytick',[0:5:20]);
set(cb, 'Fontsize',16,'Linewidth',2);
hold on;
yline(0, '--k', 'LineWidth',2);
set(gca,'linewidth',2,'Fontsize',16);
% LOESS trend line
xs = x(idx); ys = y(idx);
[xs, I] = sort(xs); ys = ys(I);
ys_fit = smooth(xs, ys, 0.15, 'loess');
plot(xs, ys_fit, 'k-', 'LineWidth', 2);

hold off;
xlim([0 2]);
xlabel('$\mathrm{Strain\ rate}\ (10^{-6}\ \mathrm{s}^{-1})$', ...
       'Interpreter','latex','FontSize',16);
ylabel('$\mathrm{SHAP\ value}$','Interpreter','latex','FontSize',16);
% % grid on;
% % box on;

%% Strain rate vs U/c
SST_gra=[];
SST_gra(:,1)=SHAP_Data(:,8);
SST_gra(:,2)=SHAP_Data(:,16);
SST_gra(:,3)=SHAP_Data(:,7);

%  plot(SST_gra(:,1),SST_gra(:,2),'k.');
%%%% Plot a color-coded scatter plot 
% ---- remove NaN (all three columns)
zz = isnan(SST_gra(:,1)) | isnan(SST_gra(:,2)) | isnan(SST_gra(:,3));
SST_gra(zz,:) = [];

x = SST_gra(:,1)*10^6;
y = SST_gra(:,2);
c = SST_gra(:,3);

% ---- remove inf
idx = isfinite(x) & isfinite(y) & isfinite(c);
x = x(idx); y = y(idx); c = c(idx);

% =========================================================
%  Main plot: scatter + LOESS
% =========================================================
figure('Color','w','Position',[100 100 720 480]);

ax_main = axes;
set(ax_main,'Position',[0.12,0.13,0.73,0.65]);
hold(ax_main,'on'); box(ax_main,'on');

scatter(ax_main, x, y, 18, c, 'filled', ...
    'MarkerFaceAlpha',0.85, 'MarkerEdgeAlpha',0.85);

% colormap + colorbar
load('D:\software\R2020b\toolbox\colorbar_ncl\MPL_RdYlBu.txt');
colormap(ax_main, flipud(MPL_RdYlBu));

cb = colorbar(ax_main);
cb.Position = [0.88 0.13 0.02 0.65];
cb.Label.Interpreter = 'latex';
cb.Label.String = '$U/c$';
cb.FontSize = 16;
cb.LineWidth = 2;

caxis(ax_main, [0 15]);
set(cb,'YTick',0:5:15);

% y=0 reference line
yline(ax_main, 0, '--k', 'LineWidth', 2);

% LOESS trend line (sort x)
[xs, I] = sort(x);
ys = y(I);
ys_fit = smooth(xs, ys, 0.30, 'loess');
plot(ax_main, xs, ys_fit, 'k-', 'LineWidth', 2.5);

% axes formatting
xlim(ax_main, [0 1.5]);
% Uncomment the next line to use a fixed y-axis range
% ylim(ax_main, [-0.15 0.15]);

set(ax_main,'LineWidth',2,'FontSize',16);
xlabel(ax_main, '$SR_L \ (10^{-6}\  s^{-1})$', 'Interpreter','latex','FontSize',18);
ylabel(ax_main, '$\mathrm{SHAP\ value}$', 'Interpreter','latex','FontSize',18);

% =========================================================
%  Top panel: PDF band of x (U/c) using ksdensity
% =========================================================
pos = ax_main.Position;
h_top = 0.10;
gap   = 0.05;

ax_top = axes('Position',[pos(1), pos(2)+pos(4)+gap, pos(3), h_top]);
hold(ax_top,'on'); box(ax_top,'off');

x_use = x(isfinite(x));
xgrid = linspace(min(x_use), max(x_use), 300);

% Recommended bandwidth: adapt automatically to the data scale (robust; no manual tuning required)
bw = 1.06 * std(x_use) * numel(x_use)^(-1/5);
if ~isfinite(bw) || bw<=0
    bw = 0.1 * range(x_use); % Fallback
end

[pdfx, xgrid] = ksdensity(x_use, xgrid, 'Bandwidth', bw);

% Grey PDF shading
fill(ax_top, ...
    [xgrid fliplr(xgrid)], ...
    [pdfx zeros(size(pdfx))], ...
    [0.7 0.7 0.7], ...
    'EdgeColor','none', 'FaceAlpha', 1);

% Optional: add an outline for better visibility
% plot(ax_top, xgrid, pdfx, 'k', 'LineWidth', 1.2);

% Align with the main plot
xlim(ax_top, xlim(ax_main));
set(ax_top,'XTick',[]);
ax_top.Color = 'none';
set(ax_top,'LineWidth',1.8,'FontSize',15);

% Optional: verify that the integral equals 1
% disp(trapz(xgrid, pdfx))

axes(ax_main);