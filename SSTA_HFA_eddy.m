clc
clear
%%%%%%%%%==========================================================================
%%%%% Eddy_data:1. ID; 2.track number; 3. time (from 1993/01/01)
%%%%%           4. lon; 5. lat; 6. radius (m); 7. polarity (1/cyclone;-1/anticyclone)
%%%%%%%%===========================================================================
load ('/media/sust/5173010b-2665-404a-9e8d-a1754c2cc675/lgb/CESM/Eddy_tracking_data/Eddy_data_SHO.mat')
Eddy_data=Eddy_data4;
clearvars Eddy_data4
Eddy_data(:,3)=datenum(1993,1,1)+Eddy_data(:,3);
% % % % zz=find(Eddy_data(:,5)<0);
% % % % Eddy_data(zz,7)=-Eddy_data(zz,7);
time=datevec(Eddy_data(:,3));

%% ==== Parameter =================================================
extent_deg = 2;              % ±2°
dx = 0.25;                   % interval，SST is 0.25
x = -extent_deg:dx:extent_deg;
y = -extent_deg:dx:extent_deg;
[YY,XX] = meshgrid(y,x);    
Ngrid = numel(x);
RR=sqrt(XX.^2+YY.^2);
%%%% Select region=======================================
%%%%%Eddy track dataset
time1=datenum(1993,1,1);
time2=datenum(2018,12,31);
zz=find(Eddy_data(:,3)>=time1&Eddy_data(:,3)<=time2);
Eddy_da=Eddy_data(zz,:);
ln1=0;ln2=360;
lt1=-65;lt2=-5;
zz=find(Eddy_da(:,4)>=ln1&Eddy_da(:,4)<=ln2&...
    Eddy_da(:,5)>=lt1&Eddy_da(:,5)<=lt2);
Eddy_track=Eddy_da(zz,:);
Eddy_track=sortrows(Eddy_track,3);
Eddy_track(:,8)=1:size(Eddy_track,1);
rank=[];
rank(1,1)=Eddy_track(1,3);
rank(1,2)=1;mm=1;
for i=1:size(Eddy_track,1)-1
    if Eddy_track(i+1,3)~=Eddy_track(i,3)
        rank(mm,3)=i;
        rank(mm+1,1)=Eddy_track(i+1,3);
        rank(mm+1,2)=i+1;
        mm=mm+1;
    end
end
rank(end,3)=size(Eddy_track,1);
%%%% select correct date file====================
SST_file_in = '/media/sust/5173010b-2665-404a-9e8d-a1754c2cc675/lgb/CESM/linux/';
LHF_file_in = '/media/sust/5173010b-2665-404a-9e8d-a1754c2cc675/lgb/CESM/linux/heat_flux/';
%%%% ===================== SST search =====================
file_SST = dir(fullfile(SST_file_in, 'SST*'));
ftime_SST      = [];
file_index_SST = [];
time_index_SST = [];

for k = 1:length(file_SST)
    fpath = fullfile(SST_file_in, file_SST(k).name);
    tvec = double(ncread(fpath, 'time'));
    tvec = round(tvec(:));   % match by day
    ftime_SST      = [ftime_SST; tvec];
    file_index_SST = [file_index_SST; repmat(k, numel(tvec), 1)];
    time_index_SST = [time_index_SST; (1:numel(tvec))'];
end

% delete repeat files
[ftime_SST, ia] = unique(ftime_SST, 'stable');
file_index_SST  = file_index_SST(ia);
time_index_SST  = time_index_SST(ia)

%%%% ===================== LHF time search =====================
file_LHF = dir(fullfile(LHF_file_in, 'LHF*'));
ftime_LHF      = [];
file_index_LHF = [];
time_index_LHF = [];

for k = 1:length(file_LHF)
    fpath = fullfile(LHF_file_in, file_LHF(k).name);
    tvec = double(ncread(fpath, 'time'));
    tvec = round(tvec(:));   
    ftime_LHF      = [ftime_LHF; tvec];
    file_index_LHF = [file_index_LHF; repmat(k, numel(tvec), 1)];
    time_index_LHF = [time_index_LHF; (1:numel(tvec))'];
end

[ftime_LHF, ia] = unique(ftime_LHF, 'stable');
file_index_LHF  = file_index_LHF(ia);
time_index_LHF  = time_index_LHF(ia);
%%%% ===================== SENH_F search =====================
file_SENH = dir(fullfile(LHF_file_in, 'SENH_F*'));
ftime_SENH      = [];
file_index_SENH = [];
time_index_SENH = [];
for k = 1:length(file_SENH)
    fpath = fullfile(LHF_file_in, file_SENH(k).name);
    tvec = double(ncread(fpath, 'time'));
    tvec = round(tvec(:));  

    ftime_SENH      = [ftime_SENH; tvec];
    file_index_SENH = [file_index_SENH; repmat(k, numel(tvec), 1)];
    time_index_SENH = [time_index_SENH; (1:numel(tvec))'];

end

[ftime_SENH, ia] = unique(ftime_SENH, 'stable');
file_index_SENH  = file_index_SENH(ia);
time_index_SENH  = time_index_SENH(ia);
%%%%%================================================================
%%% read climatological SST data
%%%%%===============================================================
pathcli='/media/sust/5173010b-2665-404a-9e8d-a1754c2cc675/lgb/CESM/linux/';
% % % pathcli='K:\CESM\SSTA_eddy_normal\climate_month_SST/';
filenamecli='CESM_SST_monthly_clim_1990_2020.nc';
ncdisp([pathcli filenamecli]);
lon_cli=ncread([pathcli filenamecli],'lon');
lat_cli=ncread([pathcli filenamecli],'lat');
SST_cli=ncread([pathcli filenamecli],'SST_clim');
%%%%%================================================================
%%%  read climatological HFA data
%%%%%%%%=============================================================
pathcli='/media/sust/5173010b-2665-404a-9e8d-a1754c2cc675/lgb/CESM/linux/heat_flux/climate_month_HFA/';
% % % pathcli='K:\CESM\SSTA_eddy_normal\climate_month_SST/';
filenamecli1='CESM_LHF_monthly_clim_1990_2020.nc';
ncdisp([pathcli filenamecli1]);
lon_cliH=ncread([pathcli filenamecli1],'lon');
lat_cliH=ncread([pathcli filenamecli1],'lat');
LHF_cli=ncread([pathcli filenamecli1],'LHF_clim');
filenamecli2='CESM_SENH_F_monthly_clim_1990_2020.nc';
ncdisp([pathcli filenamecli2]);
SHF_cli=ncread([pathcli filenamecli2],'SENH_F_clim');
%%%%=========================================

Eddy_alpha=cell(size(rank,1),1);
Eddy_SSTA_block=cell(size(rank,1),1);
core_n=24;
parpool('local',core_n);
parfor ra=1:size(rank,1)
    ra
    Eddy_series=Eddy_track(rank(ra,2):rank(ra,3),:);
    Time=datevec(Eddy_series(1,3));
    year=Time(1);
    mon=Time(2);
    day=Time(3);
    Year = sprintf('%04d',year); Mon = sprintf('%02d',mon); Day = sprintf('%02d',day);
    t = Eddy_series(1,3);
    index_sst = find(t == ftime_SST, 1, 'first');
    index_lhf = find(t == ftime_LHF, 1, 'first');

    if isempty(index_sst) || isempty(index_lhf)
        Eddy_series(:,9:11) = nan;
        local_SSTA = cell(size(Eddy_series,1),1);
        continue;
    else
        filename_SST = fullfile(SST_file_in, ...
            file_SST(file_index_SST(index_sst)).name);
        it_sst = time_index_SST(index_sst);
        filename_lhf = fullfile(LHF_file_in, ...
            file_LHF(file_index_LHF(index_lhf)).name);
        it_lhf = time_index_LHF(index_lhf);
        % The temporal coverage of SENH_F matches that of LHF;
        % therefore, the time layers from LHF are used directly.
        lhf_name = file_LHF(file_index_LHF(index_lhf)).name;
        senh_name = strrep(lhf_name, 'LHF_', 'SENH_F_');
        filename_senh = fullfile(LHF_file_in, senh_name);
        it_senh = it_lhf;

        % % % %     ncdisp([filepath filename])
        %%%%===============read SST data================
        lon=ncread(filename_SST,'lon');
        lat=ncread(filename_SST,'lat');
        lon_in=find(lon>=ln1-5.01&lon<=ln2+5.01);
        lat_in=find(lat>=lt1-5.01&lat<=lt2+5.01);
        lon3=lon(lon_in);
        lat3=lat(lat_in);
        SST_ini=ncread(filename_SST,'SST',[lon_in(1) lat_in(1) it_sst],[length(lon_in) length(lat_in) 1]);
        %%%% First subtract the climatology, then apply high-pass filtering.
        SST=SST_ini-SST_cli(lon_in,lat_in,mon);
        SSTA=gauss_high_2d(SST,10,0.1);
        SSTA_F = griddedInterpolant({lon3,lat3}, SSTA, 'linear','none');


        lon_lhf = ncread(filename_lhf,'lon');
        lat_lhf = ncread(filename_lhf,'lat');

        lon_in_lhf = find(lon_lhf >= ln1-5.01 & lon_lhf <= ln2+5.01);
        lat_in_lhf = find(lat_lhf >= lt1-5.01 & lat_lhf <= lt2+5.01);

        lon_lhf3 = lon_lhf(lon_in_lhf);
        lat_lhf3 = lat_lhf(lat_in_lhf);

        LHF_ini = ncread(filename_lhf,'LHF', ...
            [lon_in_lhf(1) lat_in_lhf(1) it_lhf], ...
            [length(lon_in_lhf) length(lat_in_lhf) 1]);

        %%%% First subtract the climatology, then apply high-pass filtering.
        LHF=LHF_ini-LHF_cli(lon_in_lhf,lat_in_lhf,mon);
        LHFA = gauss_high_2d(LHF,10,0.1);
        LHFA_F = griddedInterpolant({lon_lhf3,lat_lhf3}, LHFA, 'linear','none');

        %% ===================== read SENH_F =====================
       % SENH_F and LHF share the same time axis, so you can use either it_lhf or it_senh directly.
      % If you have already defined it_senh = it_lhf earlier, you can also use it_senh.
        SHF_ini = ncread(filename_senh,'SENH_F', ...
            [lon_in_lhf(1) lat_in_lhf(1) it_lhf], ...
            [length(lon_in_lhf) length(lat_in_lhf) 1]);

        %%%% First subtract the climatology, then apply high-pass filtering.
        SHF=SHF_ini-SHF_cli(lon_in_lhf,lat_in_lhf,mon);
        SHFA = gauss_high_2d(SHF,10,0.1);
        SHFA_F = griddedInterpolant({lon_lhf3,lat_lhf3}, SHFA, 'linear','none');

        %%%%%============read SST gradient=================
        T_cli=SST_cli(:,:,mon);
        SST=T_cli;
        [Lat, Lon] = meshgrid(lat_cli, lon_cli);
        %%%calculate step
        R=111195;
        dlat = gradient(lat_cli);   
        dlon = gradient(lon_cli);  
        [dSST_dlat, dSST_dlon] = gradient(SST, lat_cli, lon_cli);
        %%%% transfer horizontal gradient
        SST_y = (dSST_dlat / R);% meridional 
        SST_x = (dSST_dlon / R);% zonal 
        %%%% angle
        theta_rad = atan2(SST_x, SST_y);
        % % %     theta_deg = rad2deg(theta_rad);
        % match point
        lonq = Eddy_series(:,4);
        latq = Eddy_series(:,5);
        Eddy_rad = interp2(lat_cli,lon_cli,theta_rad,latq, lonq,'linear');  
        Eddy_series(:,9)=Eddy_rad;

        %%%%%%%%%%========================================================
        %%%%% First subtract the climatology, then apply high-pass filtering
        %%%%%%%%%%========================================================
        local_SSTA = cell(size(Eddy_series,1),1);
        for en=1:size(Eddy_series,1)

            EddyRow=Eddy_series(en,:);
            lonc=EddyRow(4);
            latc=EddyRow(5);
            theta=EddyRow(end);
            Rad=EddyRow(6);
            R=111195;
       % --- Incorporate the constraint that "the gradient direction at the vortex center corresponds to a polar angle of 90°" via coordinate rotation
        % As stated in the text: (x_n, y_n) are coordinates in the transformed system; first, rotate them back to the absolute coordinate system: (xn*sinθ - yn*cosθ, xn*cosθ + yn*sinθ)            Xorig =  (XX.*cos(-theta) - YY.*sin(-theta))*Rad/R; %%%返回归一化的半径
            Yorig =  (XX.*sin(-theta) + YY.*cos(-theta))*Rad/R;
 
            lon_samp = wrapTo360(lonc + Xorig);      
            lat_samp = min(max(latc + Yorig, -90), 90);
            SSTA_patch = arrayfun(@(a,b) SSTA_F(a,b), lon_samp, lat_samp);
            SHFA_patch = arrayfun(@(a,b) SHFA_F(a,b), lon_samp, lat_samp);
            LHFA_patch = arrayfun(@(a,b) LHFA_F(a,b), lon_samp, lat_samp);

          % calcalate structural index α===============================
            Tc=SSTA_patch;
            alpha=nan;
            if isempty(Tc)==0
                if isnan(Tc(9,9))==0
                    rmax=2;
                    r=hypot(XX,YY);
                    %%% 
                    M = (r <= rmax) & isfinite(Tc);
                    if ~any(M(:))
                        error('掩膜区域内没有有效数据 (r<=%g 且 Tc 有效)。', rmax);
                    end
                    nbins=20;
                    % ----- Radial averaging (yielding T_M'(r))-----
                    edges = linspace(0, rmax, nbins+1);
                    [~,~,bin] = histcounts(r(M), edges);   % 
                    vals = Tc(M);
                    % Average of each bin
                    TM_profile = accumarray(bin(:), vals(:), [nbins 1], @mean, NaN);
                    % bin center
                    rc = 0.5*(edges(1:end-1) + edges(2:end));
                    % By interpolating the radial average back to each pixel location, the monopolar component field (TM_field) is obtained.
                    TM_field = nan(size(Tc));
                    TM_field(M) = interp1(rc, TM_profile, r(M), 'linear', 'extrap');
                    % ----- Structural index α: Pearson correlation -----
                    alpha = corr(vals(:), TM_field(M), 'Rows','complete');  % 
                end
            end
            Eddy_series(en,10)=alpha;
            HFA_com=SHFA_patch+LHFA_patch;
            eta=nan;
            r_core = [0, 1.5];   % eddy center
            if isempty(HFA_com)==0
                if isnan(HFA_com(21,21))==0
                    mask_core = (RR >= r_core(1) & RR <= r_core(2));
                    HFA_core = nanmean(HFA_com(mask_core));
                    HFA_core_abs = nanmean(abs(HFA_com(mask_core)));
                else
                    HFA_core=nan;
                    HFA_core_abs=nan;
                end
            end
            Eddy_series(en,11)=HFA_core/HFA_core_abs;

            %%%%% =============
            SSTA=[];
            SSTA(:,:,1)=single(SHFA_patch);
            SSTA(:,:,2)=single(LHFA_patch);
            SSTA(:,:,3)=single(SSTA_patch);
            local_SSTA{en} = SSTA;

        end
    end
    Eddy_SSTA_block{ra,1} = local_SSTA;
    Eddy_alpha{ra,1}=Eddy_series;
end
delete(gcp('nocreate'));

Eddy_alpha_SHO=cell2mat(Eddy_alpha);
save Eddy_alpha_SHO_new Eddy_alpha_SHO


block_len = cellfun(@numel, Eddy_SSTA_block);            
max_end   = max(rank(:,2) );             
Eddy_SHFA  = cell(max_end, 1);                           
Eddy_LHFA  = cell(max_end, 1);
Eddy_SSTA  = cell(max_end, 1);
b=0;
for ira = 1:size(rank,1)
    ira
    s = Eddy_SSTA_block{ira};          
    if isempty(s)==0
      
        shfa=cell(size(s));lhfa=cell(size(s));ssta=cell(size(s));
        for jra=1:size(s,1)
            ss=s{jra,1};
            shfa{jra,1}=single(ss(:,:,1));
            lhfa{jra,1}=single(ss(:,:,2));
            ssta{jra,1}=single(ss(:,:,3));

        end
        n = numel(s);                     
        Eddy_SHFA(b+1 : b+size(s,1)) = shfa(:);        
        Eddy_LHFA(b+1 : b+size(s,1)) = lhfa(:);       
        Eddy_SSTA(b+1 : b+size(s,1)) = ssta(:);      

        b = b+size(s,1);
    end
end

save Eddy_SHFA_SHO Eddy_SHFA
save Eddy_LHFA_SHO Eddy_LHFA
save Eddy_SSTA_SHO Eddy_SSTA


