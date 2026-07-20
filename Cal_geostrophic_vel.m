%==========================================================
% Batch compute geostrophic velocity from regular 0.1° CESM SSH files
% Interpolate SSH onto the AVISO grid, then compute geostrophic velocity
%
% Input file example:
%   /media/sust/.../CESM/linux/SSH_1993-02-01.nc
%
% Input variables:
%   lon(nlon), lat(nlat), SSH(nlon,nlat,time)
%
% Output file example:
%   geos_AVISOgrid_from_CESM_SSH_1993-02-01.nc
%
% Notes:
% 1. Source SSH is already on a regular 0.1° grid
% 2. Target grid uses the actual AVISO longitude/latitude
% 3. Ocean mask also uses AVISO
% 4. Output time is rebuilt from filename date:
%       if file is SSH_2023-04-01.nc
%       then time = datenum(2023,4,1) + (0:nt-1)
%==========================================================
clear; clc;
tic

%% ===================== USER SETTINGS =====================
inPath  = '/media/sust/5173010b-2665-404a-9e8d-a1754c2cc675/lgb/CESM/linux/';
outPath = '/media/sust/5173010b-2665-404a-9e8d-a1754c2cc675/lgb/CESM/Cal_geostrophic_vel/';

% % % inPath  = 'K:\CESM\linux\';
% % % outPath = 'K:\CESM\Cal_geostrophic_vel\';

dateMin = datetime(1993,1,1);
dateMax = datetime(2100,12,31);

% CESM variables
varName  = 'SSH';
lonVar   = 'lon';
latVar   = 'lat';
timeVar  = 'time';   % only used if you still want to inspect it, not used for output time

% AVISO file for target grid and ocean mask
avisoFile      = '/media/sust/5173010b-2665-404a-9e8d-a1754c2cc675/lgb/CESM/dt_global_allsat_phy_l4_19930101_20190101.nc';
% % % avisoFile      = 'V:\AVISO\1993\dt_global_allsat_phy_l4_19930101_20190101.nc';
avisoLonVar    = 'longitude';
avisoLatVar    = 'latitude';
avisoMaskVar   = 'ugosa';
avisoMask_isOcean1 = false;   % false means ocean where ugosa is finite

% Parameters
FILL_BIG  = 1e30;
ssh_in_cm = true;             % input SSH unit is centimeter
f_min     = 8e-6;             % avoid equatorial blow up
core_n    = 72;               % adjust according to memory

%% ===================== PREP FOLDER =====================
if ~exist(outPath, 'dir')
    mkdir(outPath);
end

%% ===================== FIND INPUT FILES =====================
dd = dir(fullfile(inPath, 'SSH_*.nc'));
if isempty(dd)
    error('No files found with pattern SSH_*.nc in: %s', inPath);
end

dates = NaT(numel(dd),1);
keep  = false(numel(dd),1);

for i = 1:numel(dd)
    tok = regexp(dd(i).name, '^SSH_(\d{4}-\d{2}-\d{2})\.nc$', 'tokens', 'once');
    if ~isempty(tok)
        dates(i) = datetime(tok{1}, 'InputFormat', 'yyyy-MM-dd');
        keep(i) = true;
    end
end

dd    = dd(keep);
dates = dates(keep);

keep2 = (dates >= dateMin) & (dates <= dateMax);
dd    = dd(keep2);
dates = dates(keep2);

if isempty(dd)
    error('No files in range %s to %s', datestr(dateMin,'yyyy-mm-dd'), datestr(dateMax,'yyyy-mm-dd'));
end

[dates, isrt] = sort(dates);
dd = dd(isrt);

fprintf('Use %d files. Date range: %s -> %s\n', ...
    numel(dd), datestr(dates(1),'yyyy-mm-dd'), datestr(dates(end),'yyyy-mm-dd'));

%% ===================== READ SOURCE GRID FROM FIRST FILE =====================
firstFile = fullfile(inPath, dd(1).name);
fprintf('Init source grid using: %s\n', firstFile);

lon0 = double(ncread(firstFile, lonVar));
lat0 = double(ncread(firstFile, latVar));

lon0 = lon0(:);
lat0 = lat0(:);

lon0 = mod(lon0, 360);
lon0(lon0 >= 360) = lon0(lon0 >= 360) - 360;

[lon0, ixLon0] = sort(lon0);

if lat0(2) < lat0(1)
    lat0 = flipud(lat0);
    lat_flip_src = true;
else
    lat_flip_src = false;
end

nLon0 = numel(lon0);
nLat0 = numel(lat0);

fprintf('Source grid size: nlon = %d, nlat = %d\n', nLon0, nLat0);

%% ===================== READ AVISO TARGET GRID =====================
fprintf('Reading AVISO target grid: %s\n', avisoFile);

lon25 = double(ncread(avisoFile, avisoLonVar));
lat25 = double(ncread(avisoFile, avisoLatVar));

lon25 = lon25(:);
lat25 = lat25(:);

lon25 = mod(lon25, 360);
lon25(lon25 >= 360) = lon25(lon25 >= 360) - 360;

[lon25, ixLon25] = sort(lon25);

if lat25(2) < lat25(1)
    lat25 = flipud(lat25);
    lat_flip_aviso = true;
else
    lat_flip_aviso = false;
end

nLon25 = numel(lon25);
nLat25 = numel(lat25);

[Lon25G, Lat25G] = meshgrid(lon25, lat25);   % (lat,lon)

fprintf('AVISO grid size: nlon = %d, nlat = %d\n', nLon25, nLat25);

%% ===================== BUILD OCEAN MASK ON AVISO GRID =====================
uA = double(ncread(avisoFile, avisoMaskVar));
uA = squeeze(uA);
if ndims(uA) > 2
    uA = uA(:,:,1);
end

mA = int8(isnan(uA));  % NaN=land if using ugosa rule

% Ensure mask shape is (lat,lon)
szA = size(mA);
if szA(1) == numel(lon25) && szA(2) == numel(lat25)
    mA = mA';
end

if lat_flip_aviso
    mA = flipud(mA);
end

mA = mA(:, ixLon25);

if avisoMask_isOcean1
    oceanmask25_latlon = (mA == 1);
else
    oceanmask25_latlon = (mA == 0);
end

fprintf('AVISO land fraction: %.4f\n', mean(~oceanmask25_latlon(:)));

%% ===================== GEOSTROPHY CONSTANTS ON AVISO GRID =====================
g     = 9.80665;
Omega = 7.292115e-5;
Re    = 6371000;

dlon25 = median(diff(lon25));
dlat25 = median(diff(lat25));

latr25  = lat25(:) * pi/180;
f_lat25 = 2 * Omega * sin(latr25);
F25     = repmat(f_lat25', [nLon25, 1]);   % (lon,lat)

dlon25_rad = dlon25 * pi/180;
dlat25_rad = dlat25 * pi/180;

dx25    = Re * cos(latr25') * dlon25_rad;  % 1 x nLat25
dx25_2D = repmat(dx25, [nLon25, 1]);       % nLon25 x nLat25
dy25    = Re * dlat25_rad;

d_dx25 = @(A) (circshift(A,[-1,0]) - circshift(A,[1,0])) ./ ...
              (circshift(dx25_2D,[-1,0]) + circshift(dx25_2D,[1,0]));

d_dy25 = @(A) (circshift(A,[0,-1]) - circshift(A,[0,1])) ./ (2 * dy25);

%% ===================== PARPOOL =====================
p = gcp('nocreate');
if isempty(p)
    parpool('local', core_n);
end

%% ===================== MAIN LOOP =====================
for k = 1:numel(dd)
    inFile = fullfile(inPath, dd(k).name);
    dfile  = dates(k);

    outFile = fullfile(outPath, ['geos_AVISOgrid_from_CESM_SSH_' datestr(dfile,'yyyy-mm-dd') '.nc']);
    if exist(outFile, 'file')
        fprintf('[SKIP OUT EXISTS] %s\n', outFile);
        continue
    end

    fprintf('(%d/%d) %s\n', k, numel(dd), dd(k).name);

    % --------- get nt from SSH variable shape, not from wrong time values ---------
    infoSSH = ncinfo(inFile, varName);
    szSSH   = infoSSH.Size;

    if numel(szSSH) < 3
        error('Variable %s in %s does not have 3 dimensions.', varName, inFile);
    end

    nt = szSSH(3);

    % --------- rebuild time directly from filename date ---------
    time_start = datenum(year(dfile), month(dfile), day(dfile));
    t_out = time_start + (0:nt-1)';

    fprintf('    nt = %d, rebuilt time start = %s\n', nt, datestr(t_out(1), 'yyyy-mm-dd'));

    UG = nan(nLon25, nLat25, nt, 'single');
    VG = nan(nLon25, nLat25, nt, 'single');

    parfor it = 1:nt
        %% ---------- read SSH on source 0.1° grid ----------
        SSH0 = double(ncread(inFile, varName, [1,1,it], [Inf,Inf,1]));   % (nlon,nlat)

        if lat_flip_src
            SSH0 = SSH0(:, end:-1:1);
        end
        SSH0 = SSH0(ixLon0, :);

        SSH0(abs(SSH0) > FILL_BIG) = NaN;

        if ssh_in_cm
            SSH0 = SSH0 / 100.0;   % cm -> m
        end

        % Convert to (lat,lon) for griddedInterpolant
        SSH0_latlon = SSH0';

        %% ---------- periodic extension in longitude ----------
        lon_ext = [lon0(end) - 360; lon0; lon0(1) + 360];
        SSH_ext = [SSH0_latlon(:,end), SSH0_latlon, SSH0_latlon(:,1)];

        %% ---------- interpolate source SSH onto AVISO grid ----------
        Fssh_lin = griddedInterpolant({lat0, lon_ext}, SSH_ext, 'linear', 'none');
        SSH25_latlon = Fssh_lin(Lat25G, Lon25G);   % (lat,lon)

        % Use nearest to fill ocean holes only
        hole = isnan(SSH25_latlon) & oceanmask25_latlon;
        if any(hole(:))
            Fssh_nn = griddedInterpolant({lat0, lon_ext}, SSH_ext, 'nearest', 'nearest');
            SSH25_nn = Fssh_nn(Lat25G, Lon25G);
            SSH25_latlon(hole) = SSH25_nn(hole);
        end

        % Apply AVISO ocean mask
        SSH25_latlon(~oceanmask25_latlon) = NaN;

        %% ---------- compute geostrophic velocity on AVISO grid ----------
        eta = SSH25_latlon';   % convert to (lon,lat)

        deta_dx = d_dx25(eta);
        deta_dy = d_dy25(eta);

        deta_dy(:,1)   = NaN;
        deta_dy(:,end) = NaN;

        validF = isfinite(F25) & (abs(F25) >= f_min);

        valid_dx = isfinite(eta) & ...
                   isfinite(circshift(eta,[-1,0])) & ...
                   isfinite(circshift(eta,[1,0])) & ...
                   validF;

        valid_dy = isfinite(eta) & ...
                   isfinite(circshift(eta,[0,-1])) & ...
                   isfinite(circshift(eta,[0,1])) & ...
                   validF;

        valid_dy(:,1)   = false;
        valid_dy(:,end) = false;

        U  = nan(nLon25, nLat25);
        Vv = nan(nLon25, nLat25);

        U(valid_dy)  = -(g ./ F25(valid_dy)) .* deta_dy(valid_dy);
        Vv(valid_dx) =  (g ./ F25(valid_dx)) .* deta_dx(valid_dx);

        U(~oceanmask25_latlon')  = NaN;
        Vv(~oceanmask25_latlon') = NaN;

        UG(:,:,it) = single(U);
        VG(:,:,it) = single(Vv);
    end

    %% ===================== WRITE OUTPUT NETCDF =====================
    if exist(outFile, 'file')
        delete(outFile);
    end

    nccreate(outFile, 'lon', ...
        'Dimensions', {'lon', nLon25}, ...
        'Datatype', 'single');

    nccreate(outFile, 'lat', ...
        'Dimensions', {'lat', nLat25}, ...
        'Datatype', 'single');

    nccreate(outFile, 'time', ...
        'Dimensions', {'time', nt}, ...
        'Datatype', 'double');

    ncwrite(outFile, 'lon', single(lon25(:)));
    ncwrite(outFile, 'lat', single(lat25(:)));
    ncwrite(outFile, 'time', t_out(:));

    nccreate(outFile, 'ug', ...
        'Dimensions', {'lon', nLon25, 'lat', nLat25, 'time', nt}, ...
        'Datatype', 'single', ...
        'FillValue', single(nan));

    nccreate(outFile, 'vg', ...
        'Dimensions', {'lon', nLon25, 'lat', nLat25, 'time', nt}, ...
        'Datatype', 'single', ...
        'FillValue', single(nan));

    nccreate(outFile, 'oceanmask', ...
        'Dimensions', {'lon', nLon25, 'lat', nLat25}, ...
        'Datatype', 'int8');

    ncwrite(outFile, 'ug', UG);
    ncwrite(outFile, 'vg', VG);
    ncwrite(outFile, 'oceanmask', int8(oceanmask25_latlon'));   % write as (lon,lat)

    %% ---------- attributes ----------
    ncwriteatt(outFile, '/', 'title', 'Geostrophic velocity computed from CESM SSH interpolated onto AVISO grid');
    ncwriteatt(outFile, '/', 'source_file', inFile);
    ncwriteatt(outFile, '/', 'target_grid_file', avisoFile);
    ncwriteatt(outFile, '/', 'grid_note', 'Target longitude and latitude are taken directly from AVISO');
    ncwriteatt(outFile, '/', 'mask_note', 'Ocean mask is derived from AVISO ugosa NaN mask');
    ncwriteatt(outFile, '/', 'time_note', 'output time is rebuilt from filename date: datenum(file_date) + (0:nt-1)');
    ncwriteatt(outFile, '/', 'ssh_units_input', 'centimeter');
    ncwriteatt(outFile, '/', 'ug_units', 'm s-1');
    ncwriteatt(outFile, '/', 'vg_units', 'm s-1');

    ncwriteatt(outFile, 'lon', 'long_name', 'longitude');
    ncwriteatt(outFile, 'lon', 'units', 'degrees_east');

    ncwriteatt(outFile, 'lat', 'long_name', 'latitude');
    ncwriteatt(outFile, 'lat', 'units', 'degrees_north');

    ncwriteatt(outFile, 'time', 'long_name', 'rebuilt MATLAB datenum time');
    ncwriteatt(outFile, 'time', 'units', 'MATLAB datenum');
    ncwriteatt(outFile, 'time', 'note', 'time starts from the file date in filename');

    ncwriteatt(outFile, 'ug', 'long_name', 'zonal geostrophic velocity');
    ncwriteatt(outFile, 'vg', 'long_name', 'meridional geostrophic velocity');

    fprintf('[OK] %s\n', outFile);
end

toc

p = gcp('nocreate');
if ~isempty(p)
    delete(p);
end

%% ===================== QUICK CHECK =====================
% % % % testFile = fullfile(outPath, 'geos_AVISOgrid_from_CESM_SSH_1993-02-01.nc');
% % % % ncdisp(testFile)
% % % % 
% % % % ug = ncread(testFile, 'ug');
% % % % vg = ncread(testFile, 'vg');
% % % % ug1 = squeeze(ug(:,:,4));
% % % % vg1 = squeeze(vg(:,:,4));
% % % % 
% % % % EKE = 0.5 * (ug1.^2 + vg1.^2);
% % % % 
% % % % figure;
% % % % pcolor(EKE');
% % % % shading flat;
% % % % colorbar;
% % % % caxis([-0.5 0.5]);
% % % % title('EKE on AVISO grid');
% % % % 
% % % % time = ncread(testFile, 'time');
% % % % aa=datevec(time)