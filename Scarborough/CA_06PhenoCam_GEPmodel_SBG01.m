flag_unix = 10;
flag_read = 1;      flag_CERES = 1;     flag_gate = 1;
if flag_unix == 1
    slash = '\';
else
    FolderCERES  = '/run/media/ncoupe/Expansion/Data/Canada/Meteo/CERES/';
    FolderDaymet = '/run/media/ncoupe/Expansion/Data/Canada/Meteo/daymet/';
    FolderImages = '/run/media/ncoupe/Expansion/Data/Canada/Toronto/Phenocam/Scarborough/';
    slash = '/';
    addpath /home/ncoupe/Documents/OZ/
    addpath /home/ncoupe/Documents/Amazon/
    addpath /home/ncoupe/Documents/Fluxnet/
    FolderFlux = '/home/ncoupe/Documents/Fluxnet/';
end

load 'daySBG01.mat'
load('ROI_SBG01_20230501.mat');
% colormap('jet');

[site_name_FN, lat_FN, lon_FN, site_long_FN, year_ini, year_end, siteelevation_FN,...
    height_FN, canopy_FN, ust_tresh_FN, sunrise_FN, sunset_FN, utm_FN, ust_min_FN, ust_max_FN,...
    LAI_FN]  =  textread([FolderFlux 'sites_loc.txt'],...
    '%s	%f	%f	%s	%f	%f	%f	%f %f	%f	%f	%f	%f	%f	%f	%f',...
    'delimiter','\t','headerlines', 1);
ip = 17;
lat = lat_FN(ip);                           lon = lon_FN(ip);

gCm2_ktCha = 10000./10^9;

opts = delimitedTextImportOptions("NumVariables", 2);
opts.DataLines = [2, Inf];              opts.Delimiter = "\t";
opts.VariableNames = ["SBG01", "PFT"];  opts.VariableTypes = ["double", "categorical"];
opts.ExtraColumnsRule = "ignore";       opts.EmptyLineRule = "read";
opts = setvaropts(opts, "PFT", "EmptyFieldRule", "auto");
SBG01funcionalType = readtable('/home/ncoupe/Documents/Canada/Toronto/Scarborough/SBG01funcionalType.txt', opts);
clear opts

[SBG01.dayY,SBG01.dayM,SBG01.dayD] = datevec(FileDay);
% dayfill = (datetime(2023,1,1):days(1):datetime(SBG.dayY(end)+1,12,31))';
roiLength = width(ROI);
date2remove = datetime(2023,5,1);

colorGrass = [0.00 0.27 0.53];%'#0000a2';%'#203A43';
colorDeciduous = [0.00 0.45 0.74];%'#98c127';%'#98c127';%'#2C5364';  % Deep Pink / Crimson Red
colorEvergreen  = [0.00 0.60 0.50];  
ColorDeciduousTotal = [0.20 0.55 0.32];%'#62c8d3';
colorForest = [0.45 0.70 0.45];%'#007191';%'#4E6E5D';
% 0.15 0.55 0.65;  % blue-green

if flag_read==1
    ind  = find(FileDay>date2remove);
    ind0 = (datetime(2022,1,1):days(1):datetime(Yday(ind(1)),Mday(ind(1)),Dday(ind(1))-1))';
    indX = (datetime(Yday(end),Mday(end),Dday(end)+1):days(1):datetime(Yday(end),12,31))';
    dayfill = [ind0;FileDay(ind);indX];

    %% ....................................................................
    ix = FileDayGCC.ROIavg;                          ix = AM_fill_plus(ix);
    ix(~ind) = NaN;
    ix = interp1(FileDay(ind),ix(ind),dayfill);
    [ix] = AM_fill_day_cycle(ix,dayfill,6,18);

    figure('color','white'); plot(dayfill,ix,'LineWidth',2); hold on;
    iy = dayfill;   iy(isnan(ix)) = [];     ix(isnan(ix)) = [];
    FileDayGCCcomposite = interp1(iy,ix,dayfill);
    plot(dayfill,FileDayGCCcomposite);   datetick('x');  ylabel('GCC');

    FileDayGCCcomposite = [FileDayGCCcomposite;FileDayGCCcomposite;FileDayGCCcomposite];

    %% .....................................................................
    y1 = 0.24;  y2 = 0.56;   y3 = .3:(.5-.3)/2:.5;
    dayGCCroiGEP = NaN(length(dayfill),roiLength);
    color_mtx = flipud(jet(roiLength));
    figure('color','white');
    for ix = 1:roiLength-1
        iy = FileDayGCC(ix).ROIavg;    iw = smoothdata(iy,'movmean',5);
        iw(~ind) = NaN;
        iw = interp1(FileDay(ind),iw(ind),dayfill);
        [iw] = AM_fill_day_cycle(iw,dayfill,6,18);

        plot(FileDay,iy,'LineWidth',.5,'Color',color_mtx(ix,:)); hold on;
        iy = dayfill;   iy(isnan(iw)) = [];     iw(isnan(iw)) = [];
        FileDayGCCcomposite = interp1(iy,iw,dayfill);
        plot(dayfill,FileDayGCCcomposite,':','Color',color_mtx(ix,:));   
        datetick('x');          ylabel('GCC');

        dayGCCroiGEP(:,ix) = FileDayGCCcomposite;
    end
    set(gca, 'LineWidth', 1,'Ylim',[y1 y2],'YTick',y3,...
        'xlim',[dayfill(1), dayfill(end)+days(1)],'FontSize',16, 'XTickLabelRotation', 0);
    grid on;

    %% ............ Calculate PFT Averages .................
    % Pull labels from your table
    pft_labels = SBG01funcionalType.PFT;

    % Group columns by their plant functional type
    % is_G = (pft_labels == 'G'); % Grass
    is_E = (pft_labels == 'E'); % Evergreen
    is_D = (pft_labels == 'D'); % Deciduous

    % Calculate row-wise averages across matching ROI columns
    % GCC_avg_Grass     = mean(dayGCCroiGEP(:, is_G), 2,'omitnan');
    GCC_avg_Evergreen = mean(dayGCCroiGEP(:, is_E), 2,'omitnan');
    GCC_avg_Deciduous = mean(dayGCCroiGEP(:, is_D), 2,'omitnan');
    SBG01.GCC_avg_Forest = mean(dayGCCroiGEP, 2,'omitnan');

    %% ............ Plot the Integrated PFT Trends .................
    y1 =0.24; y2=0.48;   y3 = y1:(y2-y1)/4:y2;
    % color_mtx = [0.5, 0.0, 0.5;0.0, 0.5, 0.;0.95, 0.55, 0.0];
    figure('Color', 'white', 'Position', [100 100 1000 500]); hold on;
    % hl1 = plot(dayfill, smooth(GCC_avg_Grass,31), 'color',colorGrass, 'LineWidth', 1.); hold on;
    hl2 = plot(dayfill, smooth(GCC_avg_Evergreen,31),  'color',colorEvergreen, 'LineWidth', 1.);hold on;
    hl3 = plot(dayfill, smooth(GCC_avg_Deciduous,31), 'color',colorDeciduous, 'LineWidth', 1.);hold on;
    hl4 = plot(dayfill, smooth(SBG01.GCC_avg_Forest,31), 'color',colorGrass, 'LineWidth', 1.);hold on;
    % scatter(dayfill, GCC_avg_Grass,20, 'filled', 'MarkerFaceColor', colorGrass, ...
    %     'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);
    scatter(dayfill, GCC_avg_Evergreen,20, 'filled', 'MarkerFaceColor', colorEvergreen, ...
        'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);hold on;
    scatter(dayfill, GCC_avg_Deciduous,20, 'filled', 'MarkerFaceColor', colorDeciduous, ...
        'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);
    scatter(dayfill, SBG01.GCC_avg_Forest,20, 'filled', 'MarkerFaceColor', colorForest, ...
        'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);
    set(gca,'Ylim',[y1 y2],'YTick',y3,'FontSize',16); hold on;
    legend([hl2,hl3], 'Evergreen', 'Deciduous', 'All', 'Location', 'best','fontSize',12);
    ylabel('GCC','fontSize',12);      grid on;     datetick('x', 'yyyy-mm');
    % title('Integrated Average GCC Time Series Per Plant Functional Type');
    legend box off;  box on;

end

%%
if flag_CERES==1
    CA_03PhenoCam_meteo_SBG01;
    % .........................................................................
    % CERES Create a structure to store imported netCDF data
    % .........................................................................
    CERES = struct();
    filename = [FolderCERES 'CERES_SYN1deg-Day_Terra-Aqua-NOAA20_Ed4.2_Subset_20050101-20251231.nc'];
    fileInfo = ncinfo(filename);
    variableNames = {fileInfo.Variables.Name}';
    disp('*** Variable names in CERES NetCDF file ***');
    disp(variableNames);
disp('***                                               ***')

    CERES.Variables(1).Name = 'time';
    ix = ncread(filename, '/time');     %'days since 2000-03-01 00:00:00'
    CERES.daydate = datetime(2000,03,01) + days(reshape(ix,[],1));

    CERES.Variables(2).Name = 'adj_atmos_sw_up_all_toa_daily';
    ix = ncread(filename, '/adj_atmos_sw_up_all_toa_daily');
    CERES.SWupTOA = reshape(ix,[],1);

    CERES.Variables(3).Name = 'adj_atmos_sw_up_all_surface_daily';
    ix = ncread(filename, '/adj_atmos_sw_up_all_surface_daily');
    CERES.SWup = reshape(ix,[],1);

    CERES.Variables(4).Name = 'adj_atmos_sw_down_all_toa_daily';
    ix = ncread(filename, '/adj_atmos_sw_down_all_toa_daily');
    CERES.SWdownTOA = reshape(ix,[],1);

    CERES.Variables(5).Name = 'adj_atmos_sw_down_all_surface_daily';
    ix = ncread(filename, '/adj_atmos_sw_down_all_surface_daily');
    CERES.SWdown = reshape(ix,[],1);

    CERES.Variables(6).Name = 'adj_atmos_lw_up_all_toa_daily';
    ix = ncread(filename, '/adj_atmos_lw_up_all_toa_daily');
    CERES.LWupTOA = reshape(ix,[],1);

    CERES.Variables(7).Name = 'adj_atmos_lw_up_all_surface_daily';
    ix = ncread(filename, '/adj_atmos_lw_up_all_surface_daily');
    CERES.LWup = reshape(ix,[],1);

    CERES.Variables(8).Name = 'adj_atmos_lw_down_all_toa_daily';
    ix = ncread(filename, '/adj_atmos_lw_down_all_toa_daily');
    CERES.LWdownTOA = reshape(ix,[],1);

    CERES.Variables(9).Name = 'adj_atmos_lw_down_all_surface_daily';
    ix = ncread(filename, '/adj_atmos_lw_down_all_surface_daily');
    CERES.LWdown = reshape(ix,[],1);

    % CERES.Variables(10).Name = 'adj_sfc_sw_direct_all_daily';
    % ix = ncread(filename, '/adj_sfc_sw_direct_all_daily');
    % CERES.SWdirect = reshape(ix,[],1);
    %
    % CERES.Variables(11).Name = 'adj_sfc_sw_diff_all_daily';
    % ix = ncread(filename, '/adj_sfc_sw_diff_all_daily');
    % CERES.SWdiff = reshape(ix,[],1);
    %
    CERES.Variables(12).Name = 'adj_sfc_par_direct_all_daily';
    ix = ncread(filename, '/adj_sfc_par_direct_all_daily');
    CERES.PARdirect = reshape(ix,[],1);

    CERES.Variables(13).Name = 'adj_sfc_par_diff_all_daily';
    ix = ncread(filename, '/adj_sfc_par_diff_all_daily');
    CERES.PARdiff = reshape(ix,[],1);

    CERES.dayPAR = CERES.PARdiff+CERES.PARdirect;
    clear filename

    CERES.dayPAR = CERES.dayPAR.*4.75;     % from W m-2 to umol m-2 s-1
    CERES.dayJD = day(CERES.daydate,'dayofyear');
    [CERES.daySo,~,CERES.daylyDayLength] = AM_solar_rad(CERES.dayJD,(CERES.dayJD.*0)+12,lat,lon);
    % Daytime SW Flux = Daily Average SW Flux\Fraction of Day that is Sunlit
    CERES.dayPARday = CERES.dayPAR.*24./(CERES.daylyDayLength);

    %% Add Daymet
    opts = delimitedTextImportOptions('NumVariables', 9);
    opts.DataLines = [8, Inf];    opts.Delimiter = ',';
    opts.VariableNames = ["year", "yday", "dayl_s", "prcp_mm_day", "srad_W_m_2", "swe_kg_m_2", "tmax_degC", "tmin_degC", "vp_Pa"];
    opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = 'ignore';    opts.EmptyLineRule = 'read';
    % opts = setvaropts(opts, ['year', 'yday', 'dayl_s', 'prcp_mm_day', 'srad_W_m_2', 'swe_kg_m_2', 'tmax_degC', 'tmin_degC', 'vp_Pa'], 'WhitespaceRule', 'preserve');
    % opts = setvaropts(opts, ['year', 'yday', 'dayl_s', 'prcp_mm_day', 'srad_W_m_2', 'swe_kg_m_2', 'tmax_degC', 'vp_Pa'], 'EmptyFieldRule', 'auto');
    daymet = readtable([FolderDaymet '11931_lat_43.65107_lon_-79.347015_2026-06-02_163933.csv'], opts);

    daymet.dayPARday = daymet.srad_W_m_2.*2;
    daymet.daydate   = datetime(daymet.year,1,daymet.yday);
    daymet.daytairday = (daymet.tmax_degC+daymet.tmin_degC)./2;

    clear opts

    %%
    figure('color','white');
    subplot(1,2,1);plot(CERES.daydate,CERES.dayPARday);   hold on;
    CERES_dayPARday = interp1(CERES.daydate,CERES.dayPARday,dayfill);
    % plot(dayfill,CERES_dayPARday,'c');
    plot(daymet.daydate,daymet.dayPARday,'m');
    daymet_dayPARday = interp1(daymet.daydate,daymet.dayPARday,dayfill);
    legend('CERES','Daymet'); legend box off;
    subplot(1,2,2);     hold on;
    METEO_tair = interp1(MeteoDateloc,MeteoTempC,dayfill);
    % METEO_tair = interp1(MeteoDateloc,MeteoTempC,dayfill);
    % plot(dayfill,METEO_tair,'m');
    plot(daymet.daydate,daymet.tmax_degC,'b');
    plot(daymet.daydate,daymet.daytairday,'c');
    plot(daymet.daydate,daymet.tmin_degC,'r');
    plot(MeteoDateloc,MeteoTempC,'g');
    plot(dayfill,METEO_tair,'k');
    legend('Daymet max','Daymet avg day','Daymet min','Environment Canada'); legend box off;
    hold off;
end

%%
if flag_gate==1
    % (1)GEPmax, (2)k, (3)x0, (4)k, (5)x0, (6)PARhalf, (7)Topt, (8)Tamplitude
    % best_paramsGrass = [17.303   2.109
    %     7.164    3.014
    %     0.1091   0.0391
    %     2.434    0.989
    %     0.184    0.145
    %     123.04   77.93
    %     15.000   0.000
    %     24.622   11.596];

    best_paramsEvergreen = [27.072   0.851
        3.590    0.160
        0.5523   0.0240
        2.936    0.279
        0.296    0.035
        265.10   56.19
        22.250   1.226
        14.620   0.099];

    best_paramsDeciduous = [26.532   1.837
        2.252    0.126
        0.7567   0.0121
        5.068    0.250
        0.356    0.013
        249.24   49.93
        24.413   0.456
        15.477   0.416];

    numberSimulations = 1000;
    numberTimesteps   = length(dayfill);
    % threshold_spike = 1.5;

    % SBG01.GEPurbanGrass = FN_computeGEPphotosynthesisGCCgn2br(best_paramsGrass(:, 1)', days(dayfill-dayfill(1)), ...
    %     daymet_dayPARday, METEO_tair, GCC_avg_Grass, 1);

    SBG01.GEPurbanDeciduous = FN_computeGEPphotosynthesisGCCgn2br(best_paramsDeciduous(:, 1)', days(dayfill-dayfill(1)), ...
        daymet_dayPARday, METEO_tair, GCC_avg_Deciduous, 0);

    SBG01.GEPurbanEvergreen = FN_computeGEPphotosynthesisGCCgn2br(best_paramsEvergreen(:, 1)', days(dayfill-dayfill(1)), ...
        daymet_dayPARday, METEO_tair, GCC_avg_Evergreen, 0);

    SBG01.GEPurbanForest = FN_computeGEPphotosynthesisGCCgn2br(best_paramsDeciduous(:, 1)', days(dayfill-dayfill(1)), ...
        daymet_dayPARday, METEO_tair, SBG01.GCC_avg_Forest, 0);

    % Monte Carlo Simulations
    % GEPsimulationsGrass     = zeros(numberTimesteps, numberSimulations);
    GEPsimulationsDeciduous = zeros(numberTimesteps, numberSimulations);
    GEPsimulationsEvergreen = zeros(numberTimesteps, numberSimulations);
    GEPsimulationsForest = zeros(numberTimesteps, numberSimulations);

    fprintf('Running Monte Carlo simulations...\n');
    for ix = 1:numberSimulations
        % % Grass
        % sim_paramsGrass = best_paramsGrass(:,1) + (randn(size(best_paramsGrass,1), 1) .* best_paramsGrass(:,2));
        %
        % if best_paramsGrass(7,2) == 0; sim_paramsGrass(7) = best_paramsGrass(7,1); end
        % if sim_paramsGrass(6,1) < 5;   sim_paramsGrass(6,1) = 5; end
        % GEPsimulationsGrass(:, ix) = FN_computeGEPphotosynthesisGCCgn2br(...
        %     sim_paramsGrass', days(dayfill-dayfill(1)), daymet_dayPARday, METEO_tair, GCC_avg_Grass, 1);

        % Deciduous
        sim_paramsDeciduous = best_paramsDeciduous(:,1) + (randn(size(best_paramsDeciduous,1), 1) .* best_paramsDeciduous(:,2));

        if best_paramsDeciduous(7,2) == 0; sim_paramsDeciduous(7) = best_paramsDeciduous(7,1); end
        if sim_paramsDeciduous(6,1) < 5;   sim_paramsDeciduous(6,1) = 5; end
        GEPsimulationsDeciduous(:, ix) = FN_computeGEPphotosynthesisGCCgn2br(...
            sim_paramsDeciduous', day(dayfill,'dayofyear'), daymet_dayPARday, METEO_tair, GCC_avg_Deciduous, 0);
        GEPsimulationsForest(:, ix) = FN_computeGEPphotosynthesisGCCgn2br(...
            sim_paramsDeciduous', day(dayfill,'dayofyear'), daymet_dayPARday, METEO_tair, SBG01.GCC_avg_Forest, 0);

        % Evergreen Simulations
        sim_paramsEvergreen = best_paramsEvergreen(:,1) + (randn(size(best_paramsEvergreen,1), 1) .* best_paramsEvergreen(:,2));
        if best_paramsEvergreen(7,2) == 0; sim_paramsEvergreen(7) = best_paramsEvergreen(7,1); end
        if sim_paramsEvergreen(6,1) < 5;   sim_paramsEvergreen(6,1) = 5; end
        GEPsimulationsEvergreen(:, ix) = FN_computeGEPphotosynthesisGCCgn2br(...
            sim_paramsEvergreen', day(dayfill,'dayofyear'), daymet_dayPARday, METEO_tair, GCC_avg_Evergreen, 0);
    end

    % Post-processing & Outlier Removal
    % GEPsimulationsGrass(GEPsimulationsGrass < 0 | GEPsimulationsGrass > 100) = NaN;
    GEPsimulationsDeciduous(GEPsimulationsDeciduous < 0 | GEPsimulationsDeciduous > 100) = NaN;
    GEPsimulationsForest(GEPsimulationsForest < 0 | GEPsimulationsForest > 100) = NaN;
    GEPsimulationsEvergreen(GEPsimulationsEvergreen < 0 | GEPsimulationsEvergreen > 100) = NaN;

    % Standard Error Bounds Calculations
    % Grass
    % GEPgateGrass_std = std(GEPsimulationsGrass, 0, 2, 'omitnan');
    % GEPgateGrass_SE  = GEPgateGrass_std;% ./ sqrt(numberSimulations);
    % CI_low_grass = max(0, SBG01.GEPurbanGrass(:) - GEPgateGrass_SE(:));
    % CI_up_grass  = SBG01.GEPurbanGrass(:) + GEPgateGrass_SE(:);

    % Deciduous
    GEPgateDecid_std = std(GEPsimulationsDeciduous, 0, 2, 'omitnan');
    GEPgateDecid_SE  = GEPgateDecid_std;% ./ sqrt(numberSimulations);
    CI_low_deciduous = max(0, SBG01.GEPurbanDeciduous(:) - GEPgateDecid_SE(:));
    CI_up_deciduous  = SBG01.GEPurbanDeciduous(:) + GEPgateDecid_SE(:);

    % Deciduous
    GEPgateForest_std = std(GEPsimulationsForest, 0, 2, 'omitnan');
    GEPgateForest_SE  = GEPgateForest_std;% ./ sqrt(numberSimulations);
    CI_low_forest = max(0, SBG01.GEPurbanForest(:) - GEPgateForest_SE(:));
    CI_up_forest  = SBG01.GEPurbanForest(:) + GEPgateForest_SE(:);

    % Evergreen
    GEPgateEver_std = std(GEPsimulationsEvergreen, 0, 2, 'omitnan');
    GEPgateEver_SE  = GEPgateEver_std;% ./ sqrt(numberSimulations);
    CI_low_ever  = max(0, SBG01.GEPurbanEvergreen(:) - GEPgateEver_SE(:));
    CI_up_ever   = SBG01.GEPurbanEvergreen(:) + GEPgateEver_SE(:);

    %%
    y1 = 0;           y2 =20;          y3 = y1:(y2-y1)/4:y2;
    figure('Color', 'white', 'Position', [100, 100, 900, 500]);   hold on;

    % % Grass
    % SBG01.hAreaGrass = area(dayfill, [CI_low_grass, CI_up_grass - CI_low_grass]);
    % set(SBG01.hAreaGrass(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    % set(SBG01.hAreaGrass(2), 'FaceColor', colorGrass, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');

    % Deciduous
    SBG01.hAreaDeciduous = area(dayfill, [CI_low_deciduous, CI_up_deciduous - CI_low_deciduous]);
    set(SBG01.hAreaDeciduous(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(SBG01.hAreaDeciduous(2), 'FaceColor', colorDeciduous, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');
    pause(2)

    % Forest
    SBG01.hAreaForest = area(dayfill, [CI_low_forest, CI_up_forest - CI_low_forest]);
    set(SBG01.hAreaForest(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(SBG01.hAreaForest(2), 'FaceColor', colorForest, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

    pause(2)
    % Evergreen
    SBG01.hAreaEver = area(dayfill, [CI_low_ever, CI_up_ever - CI_low_ever]);
    set(SBG01.hAreaEver(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(SBG01.hAreaEver(2), 'FaceColor', colorEvergreen, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

    % scatter(dayfill, SBG01.GEPurbanGrass(:),20, 'filled', 'MarkerFaceColor', colorGrass, ...
    %     'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);
    scatter(dayfill, SBG01.GEPurbanDeciduous(:),20, 'filled', 'MarkerFaceColor', colorDeciduous, ...
        'MarkerFaceAlpha', 0.7,'MarkerEdgeAlpha', 0.5);  hold on;
    scatter(dayfill, SBG01.GEPurbanForest(:),20, 'filled', 'MarkerFaceColor', colorForest, ...
        'MarkerFaceAlpha', 0.7,'MarkerEdgeAlpha', 0.5);
    scatter(dayfill, SBG01.GEPurbanEvergreen(:),20, 'filled', 'MarkerFaceColor', colorEvergreen, ...
        'MarkerFaceAlpha', 0.7,'MarkerEdgeAlpha', 0.5);   

    % hGrass = plot(dayfill, smooth(SBG01.GEPurbanGrass(:),15), 'Color', colorGrass, 'LineWidth', 1, ...
    %     'DisplayName', 'Grass');
    hDeciduous = plot(dayfill, smooth(SBG01.GEPurbanDeciduous(:),15), 'Color', colorDeciduous, 'LineWidth', 1, ...
        'DisplayName', 'Deciduous');   hold on;
    hForest = plot(dayfill, smooth(SBG01.GEPurbanForest(:),15), 'Color', colorForest, 'LineWidth', 1, ...
        'DisplayName', 'Forest');
    hEvergreen = plot(dayfill, smooth(SBG01.GEPurbanEvergreen(:),15), 'Color', colorEvergreen, 'LineWidth', 1, ...
        'DisplayName', 'Evergreen');

    ylabel('GEP (gC m^{-2} d^{-1})', 'FontSize', 16);
    set(gca, 'GridAlpha', 0.15, 'LineWidth', 1.1,'Ylim',[y1 y2],'YTick',y3,...
        'xlim',[dayfill(1), dayfill(end)],'FontSize',16, 'XTickLabelRotation', 0);
    grid on;      box on;        grid on;     datetick('x', 'yyyy-mm');
    % legend([hGrass, hDeciduous, hEvergreen], 'Location', 'NorthWest', 'Box', 'on', 'FontSize', 16); legend box off;
    % legend([hDeciduous, hEvergreen], 'Location', 'NorthWest', 'Box', 'on', 'FontSize', 16); legend box off;
    hold off

    %%
    y1 = 0;             y2 =1.2;          y3 = y1:(y2-y1)/4:y2;
    figure('Color', 'white', 'Position', [100, 100, 900, 500]);
    hold on;

    % % SBG01.hAreaTOcarbonGrass     = area(dayfill, [CI_low_grass, CI_up_grass - CI_low_grass].*8617.*gCm2_ktCha);
    SBG01.hAreaTOcarbonDeciduous = area(dayfill, [CI_low_deciduous, CI_up_deciduous - CI_low_deciduous].*11136.*gCm2_ktCha.*15.14./30.5);
    set(SBG01.hAreaTOcarbonDeciduous(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(SBG01.hAreaTOcarbonDeciduous(2), 'FaceColor', colorDeciduous, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');

    SBG01.hAreaTOcarbonForest = area(dayfill, [CI_low_forest, CI_up_forest - CI_low_forest].*11136.*gCm2_ktCha.*15.14./30.5);
    set(SBG01.hAreaTOcarbonForest(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(SBG01.hAreaTOcarbonForest(2), 'FaceColor', colorForest, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');

    SBG01.hAreaTOcarbonEvergreen = area(dayfill, [CI_low_ever, CI_up_ever - CI_low_ever].*0.*gCm2_ktCha.*0.52./35.9);
    %
    % % SBG01.GEPurbanTOcarbonGrass     = SBG01.GEPurbanGrass.*8617.*gCm2_ktCha; %gC m-2 d-1  ha>m2  gC>ktC  gC
    SBG01.GEPurbanTOcarbonDeciduous = SBG01.GEPurbanDeciduous.*11136.*gCm2_ktCha.*15.14./30.5; %gC m-2 d-1  ha>m2  gC>ktC  gC
    SBG01.GEPurbanTOcarbonEvergreen = SBG01.GEPurbanEvergreen.*0.*gCm2_ktCha.*0.52./35.9; %gC m-2 d-1  ha>m2  gC>ktC  gC BA [m2/ha]
    SBG01.GEPurbanTOcarbonForest    = SBG01.GEPurbanForest.*11136.*gCm2_ktCha.*15.14./30.5; %gC m-2 d-1  ha>m2  gC>ktC  gC
    SBG01.ciGEPurbanTOcarbonForest  = GEPgateForest_SE(:).*11136.*gCm2_ktCha.*15.14./30.5; %gC m-2 d-1  ha>m2  gC>ktC  gC

    SBG01.GEPurbanTOcarbonForestXm2   = SBG01.GEPurbanForest.*15.14./30.5; %gC m-2 d-1  ha>m2  gC>ktC  gC
    SBG01.ciGEPurbanTOcarbonForestXm2 = GEPgateForest_SE(:).*15.14./30.5;  %gC m-2 d-1  ha>m2  gC>ktC  gC

    % % Grass
    % set(SBG01.hAreaGrass(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    % set(SBG01.hAreaGrass(2), 'FaceColor', colorGrass, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');

    % Plot Standard Errors (Area method)
    % % Grass
    % set(SBG01.hAreaGrass(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    % set(SBG01.hAreaGrass(2), 'FaceColor', colorGrass, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');

    % Deciduous
    set(SBG01.hAreaDeciduous(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(SBG01.hAreaDeciduous(2), 'FaceColor', colorDeciduous, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off'); hold on;

    % Forest
    set(SBG01.hAreaForest(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(SBG01.hAreaForest(2), 'FaceColor', colorForest, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off'); hold on;

    % Evergreen
    % set(SBG01.hAreaEver(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    % set(SBG01.hAreaEver(2), 'FaceColor', colorEvergreen, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

    % Plot Main Model Best Estimate Trendlines
    % scatter(dayfill, SBG01.GEPurbanTOcarbonGrass(:),20, 'filled', 'MarkerFaceColor', colorGrass, ...
    %     'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);
    scatter(dayfill, SBG01.GEPurbanTOcarbonForest(:),20, 'filled', 'MarkerFaceColor', colorForest, ...
        'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);   hold on;
    scatter(dayfill, SBG01.GEPurbanTOcarbonDeciduous(:),20, 'filled', 'MarkerFaceColor', colorDeciduous, ...
        'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);
    % scatter(dayfill, SBG01.GEPurbanTOcarbonEvergreen(:),20, 'filled', 'MarkerFaceColor', colorEvergreen, ...
    %     'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);

    % hGrass = plot(dayfill, smooth(SBG01.GEPurbanTOcarbonGrass(:),15), 'Color', colorGrass, 'LineWidth', 1, ...
    %     'DisplayName', 'Grass');
    hDeciduous = plot(dayfill, smooth(SBG01.GEPurbanTOcarbonDeciduous(:),15), 'Color', colorDeciduous, 'LineWidth', 1, ...
        'DisplayName', 'Deciduous');
    hForest = plot(dayfill, smooth(SBG01.GEPurbanTOcarbonForest(:),15), 'Color', colorForest, 'LineWidth', 1, ...
        'DisplayName', 'Forest');
    hEvergreen = plot(dayfill, smooth(SBG01.GEPurbanTOcarbonEvergreen(:),15), 'Color', colorEvergreen, 'LineWidth', 1, ...
        'DisplayName', 'Evergreen');

    ylabel('C-uptake (tC day^-^1)', 'FontSize', 16);
    set(gca, 'GridAlpha', 0.15, 'LineWidth', 1.1,'Ylim',[y1 y2],'YTick',y3,...
        'xlim',[dayfill(1), dayfill(end)],'FontSize',16, 'XTickLabelRotation', 0);
    grid on;      box on;        grid on;     datetick('x', 'yyyy-mm');
    legend([hDeciduous,hForest, hEvergreen], 'Location', 'NorthWest', 'Box', 'on', 'FontSize', 16); legend box off;

    SBG01.CI_low_forest = CI_low_forest;    SBG01.CI_up_forest = CI_up_forest;
    SBG01.dayfill = dayfill;
    save ('SBG01model.mat','SBG01');
end
