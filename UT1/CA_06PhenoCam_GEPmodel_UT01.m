%..........................................................................
%..........................................................................
% for TAME work
% Natalia Restrepo-Coupe
% Toronto, December 2025 cold and gloomy
%..........................................................................
%..........................................................................
flag_unix = 10;
flag_read = 1;      flag_CERES = 1;     flag_gate = 1;
if flag_unix == 1
    slash = '\';
else
    FolderCERES  = '/run/media/ncoupe/Expansion/Data/Canada/Meteo/CERES/';
    FolderImages = '/run/media/ncoupe/Expansion/Data/Canada/Toronto/Phenocam/UofTcamera01/';
    FolderDaymet = '/run/media/ncoupe/Expansion/Data/Canada/Meteo/daymet/';
    slash = '/';
    addpath /home/ncoupe/Documents/OZ/
    addpath /home/ncoupe/Documents/Amazon/
    addpath /home/ncoupe/Documents/Fluxnet/
end

load 'dayUofT01.mat'
load('ROI_UofT01_20220701.mat');
% colormap('jet');
load ('/home/ncoupe/Documents/Canada/Toronto/Scarborough/SBG01model.mat');

gCm2_ktCha = 10000./10^9;

lat = 43.651070;                           lon = -79.347015;

opts = delimitedTextImportOptions("NumVariables", 2);   opts.DataLines = [2, Inf];
opts.VariableNames = ["UofT01", "PFT"];                 opts.Delimiter = "\t";
opts.VariableTypes = ["double", "categorical"];         opts.ExtraColumnsRule = "ignore";
opts = setvaropts(opts, "PFT", "EmptyFieldRule", "auto");opts.EmptyLineRule = "read";
UofT01funcionalType = readtable("/home/ncoupe/Documents/Canada/Toronto/UofTcamera01/UofT01funcionalType.txt", opts);
clear opts

[UofT01.dayY,UofT01.dayM,UofT01.dayD] = datevec(FileDay);
% dayfill = (datetime(2023,1,1):days(1):datetime(SBG01.dayY(end)+1,12,31))';
roiLength = width(ROI);
date2remove = datetime(2022,8,31);

colorGrass = '#0000a2';%'#203A43';
colorDeciduous = '#98c127';%'#2C5364';  % Deep Pink / Crimson Red
colorEvergreen  = [0.23, 0.53, 0.23];
ColorDeciduousTotal = '#62c8d3';
colorForest = '#18ede6';%'#62c8d3';%'#ea801c';'#f1a226';%'#007191';%'#4E6E5D';

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
    y1 = 0.33;  y2 = 0.4;   y3 = .32:(y2-.32)/4:y2;
    dayGCCroiGEP = NaN(length(dayfill),roiLength);
    color_mtx = flipud(jet(roiLength));
    figure('color','white');
    for ix = 1:roiLength-1
        iy = FileDayGCC(ix).ROIavg;    iw = smoothdata(iy,'movmean',5);
        iw(~ind) = NaN;
        iw = interp1(FileDay(ind),iw(ind),dayfill);
        [iw] = AM_fill_day_cycle(iw,dayfill,6,18);

        plot(FileDay,iy,'LineWidth',1,'Color',color_mtx(ix,:)); hold on;
        iy = dayfill;   iy(isnan(iw)) = [];     iw(isnan(iw)) = [];
        FileDayGCCcomposite = interp1(iy,iw,dayfill);
        plot(dayfill,FileDayGCCcomposite,':','Color',color_mtx(ix,:));
        datetick('x');  ylabel('GCC');
        dayGCCroiGEP(:,ix) = FileDayGCCcomposite;
    end
    set(gca, 'LineWidth', 1,'Ylim',[y1 y2],'YTick',y3,...
        'xlim',[dayfill(1), dayfill(end)],'FontSize',14, 'XTickLabelRotation', 0);
    grid on;

    %% ............ Calculate PFT Averages .................
    % Pull labels from your table
    pft_labels = UofT01funcionalType.PFT;

    % Group columns by their plant functional type
    is_G = (pft_labels == 'G'); % Grass
    is_E = (pft_labels == 'E'); % Evergreen
    is_D = (pft_labels == 'D'); % Deciduous

    % Calculate row-wise averages across matching ROI columns
    % ix = dayGCCroiGEP(:, is_G);

    %%
    y1 = 0.34;  y2 = 0.39;   y3 = y1:(y2-y1)/4:y2;
    figure('color','white');
    ind = (1:roiLength)';   iy = ind(is_G);   color_mxt = jet(8);
    for ix = 1:length(iy)
        plot(dayfill,dayGCCroiGEP(:, iy(ix)),'color',color_mxt(ix,:));  hold on;
        text (dayfill(20),0.37+ix.*.005,num2str(iy(ix)),'FontSize',16)
        plot(dayfill(15),0.37+ix.*.005,'.','MarkerSize',20,'color',color_mxt(ix,:),'LineWidth',2)
    end
    set(gca, 'LineWidth', 1,'Ylim',[y1 y2],'YTick',y3,...
        'xlim',[dayfill(1), dayfill(end)],'FontSize',16, 'XTickLabelRotation', 0);
    grid on;
    GCC_avg_Grass     = mean(dayGCCroiGEP(:, is_G), 2,'omitnan');
    [~,GCC_avg_Grass] = AM_spike_detection(GCC_avg_Grass,3);
    GCC_avg_Evergreen = mean(dayGCCroiGEP(:, is_E), 2,'omitnan');
    GCC_avg_Deciduous = mean(dayGCCroiGEP(:, is_D), 2,'omitnan');
    plot(dayfill,GCC_avg_Grass,'color',[.7 .7 .7]);  hold on;

    % .................................................................................................
    %% GCC from MCD43A1 downloaded using Earth Engine
    % .................................................................................................
    % Import as 'string' first to avoid the NaT error
    opts = delimitedTextImportOptions("NumVariables", 4);
    opts.DataLines = [2, Inf]; % Skip the header row
    opts.VariableNames = ["rawDate", "r_mean", "g_mean", "b_mean"];
    opts.VariableTypes = ["string", "double", "double", "double"];
    MCD43grass = readtable("/run/media/ncoupe/Expansion/Data/Canada/MODIS/TorontoPlesantGRASSee-chart.csv", opts);
    dateParts = split(MCD43grass.rawDate, "-");
    MCD43grass.daydate = datetime(str2double(dateParts(:,1)), 1, 1) + days(str2double(dateParts(:,3)) - 1);
    MCD43grass.rawDate = [];
    head(MCD43grass)
    MCD43grass.r_mean((MCD43grass.r_mean>0.2)|(MCD43grass.b_mean>0.15)) = NaN;
    MCD43grass.g_mean((MCD43grass.g_mean>0.2)|(MCD43grass.b_mean>0.15)) = NaN;
    MCD43grass.b_mean(MCD43grass.b_mean>0.15) = NaN;

    [MCD43grass.dayY,MCD43grass.dayM,MCD43grass.dayD] = datevec(MCD43grass.daydate);

    MCD43grass.rcc_mean  = MCD43grass.r_mean./(MCD43grass.r_mean+MCD43grass.b_mean+MCD43grass.g_mean);
    MCD43grass.gcc_mean  = MCD43grass.g_mean./(MCD43grass.r_mean+MCD43grass.b_mean+MCD43grass.g_mean);
    MCD43grass.GRRI_mean = MCD43grass.g_mean./MCD43grass.r_mean;
    MCD43grass.GRIVI_mean = (MCD43grass.g_mean-MCD43grass.r_mean)./(MCD43grass.g_mean+MCD43grass.r_mean);
    MCD43grass.cci_mean  = (MCD43grass.g_mean-MCD43grass.r_mean)./(MCD43grass.g_mean+MCD43grass.r_mean);
    MCD43grass.exgreen_mean = ((2.*MCD43grass.g_mean)-MCD43grass.r_mean-MCD43grass.b_mean);%./(MCD43grass.g_mean+MCD43grass.r_mean+MCD43grass.b_mean);

    hl1 = plot(MCD43grass.daydate, MCD43grass.gcc_mean, 'g');
    %%
    y1 = 0.33;  y2 = 0.39;   y3 = y1:(y2-y1)/3:y2;
    figure('color','white');
    ind = (1:roiLength)';   iy = ind(is_G);   color_mxt = jet(8);
    hl1 = plot(MCD43grass.daydate, MCD43grass.gcc_mean, 'Color',[0.5 .5 .5]);   hold on;
    for ix = 1:length(iy)
        plot(dayfill,dayGCCroiGEP(:, iy(ix)),'color',color_mxt(ix,:));  hold on;
        text (dayfill(30),0.373+ix.*.004,num2str(iy(ix)),'FontSize',16)
        plot(dayfill(15),0.373+ix.*.004,'.','MarkerSize',20,'color',color_mxt(ix,:),'LineWidth',2)
    end
    grid on;
    legend ([hl1],'MCD43A urban golf course');
    set(gca, 'LineWidth', 1,'Ylim',[y1 y2],'YTick',y3,...
        'xlim',[dayfill(1), dayfill(end)+days(1)],'FontSize',16, 'XTickLabelRotation', 0);
    xtickformat('yyyy-MM');

    %% .................................................................................................
    %% INa just for curiosity
    % .................................................................................................
    INAeddy = readtable("/run/media/ncoupe/Backup/Data/Fluxnet/US-INa-googleEE/INA_EDDYee-chart.csv", opts);
    dateParts = split(INAeddy.rawDate, "-");
    INAeddy.daydate = datetime(str2double(dateParts(:,1)), 1, 1) + days(str2double(dateParts(:,3)) - 1);
    INAeddy.rawDate = [];
    head(INAeddy)

    INAgrass = readtable("/run/media/ncoupe/Backup/Data/Fluxnet/US-INa-googleEE/INA_GRASSee-chart.csv", opts);
    dateParts = split(INAgrass.rawDate, "-");
    INAgrass.daydate = datetime(str2double(dateParts(:,1)), 1, 1) + days(str2double(dateParts(:,3)) - 1);
    INAgrass.rawDate = [];
    head(INAgrass)

    INAcementery = readtable("/run/media/ncoupe/Backup/Data/Fluxnet/US-INa-googleEE/INA_CEMENTERYee-chart.csv", opts);
    dateParts = split(INAcementery.rawDate, "-");
    INAcementery.daydate = datetime(str2double(dateParts(:,1)), 1, 1) + days(str2double(dateParts(:,3)) - 1);
    INAcementery.rawDate = [];
    head(INAcementery)
    clear opts

    INAeddy.r_mean((INAeddy.r_mean>0.2)|(INAeddy.b_mean>0.15)) = NaN;
    INAeddy.g_mean((INAeddy.g_mean>0.2)|(INAeddy.b_mean>0.15)) = NaN;
    INAeddy.b_mean(INAeddy.b_mean>0.15) = NaN;
    [INAeddy.dayY,INAeddy.dayM,INAeddy.dayD] = datevec(INAeddy.daydate);
    INAeddy.rcc_mean = INAeddy.r_mean./(INAeddy.r_mean+INAeddy.b_mean+INAeddy.g_mean);
    INAeddy.gcc_mean = INAeddy.g_mean./(INAeddy.r_mean+INAeddy.b_mean+INAeddy.g_mean);

    INAgrass.r_mean((INAgrass.r_mean>0.2)|(INAgrass.b_mean>0.15)) = NaN;
    INAgrass.g_mean((INAgrass.g_mean>0.2)|(INAgrass.b_mean>0.15)) = NaN;
    INAgrass.b_mean(INAgrass.b_mean>0.15) = NaN;
    [INAgrass.dayY,INAgrass.dayM,INAgrass.dayD] = datevec(INAgrass.daydate);
    INAgrass.rcc_mean = INAgrass.r_mean./(INAgrass.r_mean+INAgrass.b_mean+INAgrass.g_mean);
    INAgrass.gcc_mean = INAgrass.g_mean./(INAgrass.r_mean+INAgrass.b_mean+INAgrass.g_mean);

    INAcementery.r_mean((INAcementery.r_mean>0.2)|(INAcementery.b_mean>0.15)) = NaN;
    INAcementery.g_mean((INAcementery.g_mean>0.2)|(INAcementery.b_mean>0.15)) = NaN;
    INAcementery.b_mean(INAcementery.b_mean>0.15) = NaN;
    [INAcementery.dayY,INAcementery.dayM,INAcementery.dayD] = datevec(INAcementery.daydate);
    INAcementery.rcc_mean = INAcementery.r_mean./(INAcementery.r_mean+INAcementery.b_mean+INAcementery.g_mean);
    INAcementery.gcc_mean = INAcementery.g_mean./(INAcementery.r_mean+INAcementery.b_mean+INAcementery.g_mean);

    h1 = plot(MCD43grass.daydate, MCD43grass.gcc_mean, 'g');
    h2 = plot(INAeddy.daydate, INAeddy.gcc_mean, 'color', color_mxt(6,:));
    h3 = plot(INAgrass.daydate, INAgrass.gcc_mean, 'color', color_mxt(7,:));
    h4 = plot(INAcementery.daydate, INAcementery.gcc_mean, 'color', color_mxt(8,:));
    grid on; ylabel('GCC'); hold on;
    legend([h1, h2, h3, h4], {'MCD43 Grass', 'INA flux tower', 'INA grass', 'INA cementery'});

    %% ............ Plot the Integrated PFT Trends .................
    y1 =0.34; y2=0.38;   y3 = y1:(y2-y1)/4:y2;
    color_mtx = [0.5, 0.0, 0.5;0.0, 0.5, 0.;0.95, 0.55, 0.0];
    figure('Color', 'white', 'Position', [[100 100 1000 350]]); hold on;
    hl1 = plot(dayfill, smooth(GCC_avg_Grass,15), 'color',colorGrass, 'LineWidth', 2.); hold on;
    hl2 = plot(dayfill, smooth(GCC_avg_Evergreen,15),  'color',colorEvergreen, 'LineWidth', 2.);
    hl3 = plot(dayfill, smooth(GCC_avg_Deciduous,15), 'color',colorDeciduous, 'LineWidth', 2.);
    hl4 = plot(SBG01.dayfill, smooth(SBG01.GCC_avg_Forest.*0.33+.235,15), 'color',colorForest, 'LineWidth', 2.);
    scatter(dayfill, GCC_avg_Grass,20, 'filled', 'MarkerFaceColor', colorGrass, ...
        'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
    scatter(dayfill, GCC_avg_Evergreen,20, 'filled', 'MarkerFaceColor', colorEvergreen, ...
        'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
    scatter(dayfill, GCC_avg_Deciduous,20, 'filled', 'MarkerFaceColor', colorDeciduous, ...
        'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
    scatter(SBG01.dayfill, SBG01.GCC_avg_Forest.*0.33+.235,20, 'filled', 'MarkerFaceColor', colorForest, ...
        'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
    set(gca,'Ylim',[y1 y2],'YTick',y3,'FontSize',16); hold on;
    legend([hl1,hl2,hl3,hl4],'Grass', 'Evergreen', 'Deciduous', 'Forest','Location', 'best','fontSize',16,'orientation','horizontal');
    ylabel('GCC','fontSize',16);
    grid on;     datetick('x', 'yyyy-mm');
    % title('Integrated Average GCC Time Series Per Plant Functional Type');
    legend box off;  box on;

end

%%
if flag_CERES==1
    CA_03PhenoCam_meteo_UT01;
    % .........................................................................
    % CERES Create a structure to store imported netCDF data
    % .........................................................................
    CERES = struct();
    filename = [FolderCERES 'CERES_SYN1deg-Day_Terra-Aqua-NOAA20_Ed4.2_Subset_20050101-20251231.nc'];
    fileInfo = ncinfo(filename);
    variableNames = {fileInfo.Variables.Name}';
    disp('*** Variable names in CERES NetCDF file ***');
    disp(variableNames);
disp('***                                                        ***')
    CERES.Variables(1).Name = "time";
    ix = ncread(filename, "/time");     %'days since 2000-03-01 00:00:00'
    CERES.daydate = datetime(2000,03,01) + days(reshape(ix,[],1));

    CERES.Variables(2).Name = "adj_atmos_sw_up_all_toa_daily";
    ix = ncread(filename, "/adj_atmos_sw_up_all_toa_daily");
    CERES.SWupTOA = reshape(ix,[],1);

    CERES.Variables(3).Name = "adj_atmos_sw_up_all_surface_daily";
    ix = ncread(filename, "/adj_atmos_sw_up_all_surface_daily");
    CERES.SWup = reshape(ix,[],1);

    CERES.Variables(4).Name = "adj_atmos_sw_down_all_toa_daily";
    ix = ncread(filename, "/adj_atmos_sw_down_all_toa_daily");
    CERES.SWdownTOA = reshape(ix,[],1);

    CERES.Variables(5).Name = "adj_atmos_sw_down_all_surface_daily";
    ix = ncread(filename, "/adj_atmos_sw_down_all_surface_daily");
    CERES.SWdown = reshape(ix,[],1);

    CERES.Variables(6).Name = "adj_atmos_lw_up_all_toa_daily";
    ix = ncread(filename, "/adj_atmos_lw_up_all_toa_daily");
    CERES.LWupTOA = reshape(ix,[],1);

    CERES.Variables(7).Name = "adj_atmos_lw_up_all_surface_daily";
    ix = ncread(filename, "/adj_atmos_lw_up_all_surface_daily");
    CERES.LWup = reshape(ix,[],1);

    CERES.Variables(8).Name = "adj_atmos_lw_down_all_toa_daily";
    ix = ncread(filename, "/adj_atmos_lw_down_all_toa_daily");
    CERES.LWdownTOA = reshape(ix,[],1);

    CERES.Variables(9).Name = "adj_atmos_lw_down_all_surface_daily";
    ix = ncread(filename, "/adj_atmos_lw_down_all_surface_daily");
    CERES.LWdown = reshape(ix,[],1);

    % CERES.Variables(10).Name = "adj_sfc_sw_direct_all_daily";
    % ix = ncread(filename, "/adj_sfc_sw_direct_all_daily");
    % CERES.SWdirect = reshape(ix,[],1);
    %
    % CERES.Variables(11).Name = "adj_sfc_sw_diff_all_daily";
    % ix = ncread(filename, "/adj_sfc_sw_diff_all_daily");
    % CERES.SWdiff = reshape(ix,[],1);
    %
    CERES.Variables(12).Name = "adj_sfc_par_direct_all_daily";
    ix = ncread(filename, "/adj_sfc_par_direct_all_daily");
    CERES.PARdirect = reshape(ix,[],1);

    CERES.Variables(13).Name = "adj_sfc_par_diff_all_daily";
    ix = ncread(filename, "/adj_sfc_par_diff_all_daily");
    CERES.PARdiff = reshape(ix,[],1);

    CERES.dayPAR = CERES.PARdiff+CERES.PARdirect;
    clear filename

    CERES.dayPAR = CERES.dayPAR.*4.75;     % from W m-2 to umol m-2 s-1
    CERES.dayJD = day(CERES.daydate,'dayofyear');
    [CERES.daySo,~,CERES.daylyDayLength] = AM_solar_rad(CERES.dayJD,(CERES.dayJD.*0)+12,lat,lon);
    % Daytime SW Flux = Daily Average SW Flux\Fraction of Day that is Sunlit
    CERES.dayPARday = CERES.dayPAR./(CERES.daylyDayLength./24);

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
    best_paramsGrass = [16.31	0.00
        6.91	2.57
        0.13	0.05
        2.67	1.66
        0.21	0.13
        99.8	77.6
        15.00	0.00
        29.16	3.60];

    best_paramsEvergreen = [25.30	0.34
        3.59	0.17
        0.52	0.04
        3.10	0.34
        0.26	0.06
        207.65	32.05
        25.00	0.00
        16.37	0.80];

    best_paramsDeciduous = [27.68	1.02
        2.26	0.13
        0.75	0.02
        5.16	0.20
        0.34	0.03
        303.32	11.37
        24.99	0.01
        16.02	0.69];

    numberSimulations = 1000;
    numberTimesteps   = length(dayfill);
    BAfluxnetDeciduous = 30.5;
    BAfluxnetEvergreen = 35.9;
    TOinv_uncertainty = 0.093;
    TOgrass_uncertainty = 0.1;
    % threshold_spike = 1.5;

    UT01.GEPurbanGrass = FN_computeGEPphotosynthesisGCCgn2br(best_paramsGrass(:, 1)', days(dayfill-dayfill(1)), ...
        daymet_dayPARday, METEO_tair, GCC_avg_Grass, 0);

    % [Ha1.dayGEPdaymodel] = FN_computeGEPphotosynthesisGCCgn2br(best_params,counter,...
    %     Ha1.dayPARday, Ha1.daytairday, Ha1.ROIgccQA, 1);  %, Ha1.dayLength
    UT01.GEPurbanDeciduous = FN_computeGEPphotosynthesisGCCgn2br(best_paramsDeciduous(:, 1)', days(dayfill-dayfill(1)), ...
        daymet_dayPARday, METEO_tair, GCC_avg_Deciduous, 0);

    UT01.GEPurbanEvergreen = FN_computeGEPphotosynthesisGCCgn2br(best_paramsEvergreen(:, 1)', days(dayfill-dayfill(1)), ...
        daymet_dayPARday, METEO_tair, GCC_avg_Evergreen, 0);

    % Monte Carlo Simulations
    GEPsimulationsGrass     = zeros(numberTimesteps, numberSimulations);
    GEPsimulationsDeciduous = zeros(numberTimesteps, numberSimulations);
    GEPsimulationsEvergreen = zeros(numberTimesteps, numberSimulations);

    fprintf('Running Monte Carlo simulations...\n');
    for ix = 1:numberSimulations
        % Grass
        sim_paramsGrass = best_paramsGrass(:,1) + (randn(size(best_paramsGrass,1), 1) .* best_paramsGrass(:,2));

        if best_paramsGrass(7,2) == 0; sim_paramsGrass(7) = best_paramsGrass(7,1); end
        if best_paramsGrass(1,2) == 0; sim_paramsGrass(1) = best_paramsGrass(1,1); end
        if sim_paramsGrass(6) < 5;   sim_paramsGrass(6) = 5; end
        GEPsimulationsGrass(:, ix) = FN_computeGEPphotosynthesisGCCgn2br(...
            sim_paramsGrass', days(dayfill-dayfill(1)), daymet_dayPARday, METEO_tair, GCC_avg_Grass, 0);

        % Deciduous
        sim_paramsDeciduous = best_paramsDeciduous(:,1) + (randn(size(best_paramsDeciduous,1), 1) .* best_paramsDeciduous(:,2));

        if best_paramsDeciduous(7,2) == 0; sim_paramsDeciduous(7) = best_paramsDeciduous(7,1); end
        if sim_paramsDeciduous(6) < 5;   sim_paramsDeciduous(6) = 5; end
        GEPsimulationsDeciduous(:, ix) = FN_computeGEPphotosynthesisGCCgn2br(...
            sim_paramsDeciduous', day(dayfill,'dayofyear'), daymet_dayPARday, METEO_tair, GCC_avg_Deciduous, 0);

        % Evergreen Simulations
        sim_paramsEvergreen = best_paramsEvergreen(:,1) + (randn(size(best_paramsEvergreen,1), 1) .* best_paramsEvergreen(:,2));
        if best_paramsEvergreen(7,2) == 0; sim_paramsEvergreen(7) = best_paramsEvergreen(7,1); end
        if sim_paramsEvergreen(6) < 5;   sim_paramsEvergreen(6) = 5; end
        GEPsimulationsEvergreen(:, ix) = FN_computeGEPphotosynthesisGCCgn2br(...
            sim_paramsEvergreen', day(dayfill,'dayofyear'), daymet_dayPARday, METEO_tair, GCC_avg_Evergreen, 0);
    end

    % Post-processing & Outlier Removal
    GEPsimulationsGrass(GEPsimulationsGrass < 0 | GEPsimulationsGrass > 100) = NaN;
    GEPsimulationsDeciduous(GEPsimulationsDeciduous < 0 | GEPsimulationsDeciduous > 100) = NaN;
    GEPsimulationsEvergreen(GEPsimulationsEvergreen < 0 | GEPsimulationsEvergreen > 100) = NaN;

    % Standard Error Bounds Calculations
    % Grass
    GEPgateGrass_std = std(GEPsimulationsGrass, 0, 2, 'omitnan');
    GEPgateGrass_SE  = GEPgateGrass_std;% ./ sqrt(numberSimulations);
    CI_low_grass = max(0, UT01.GEPurbanGrass(:) - GEPgateGrass_SE(:));
    CI_up_grass  = UT01.GEPurbanGrass(:) + GEPgateGrass_SE(:);

    % Deciduous
    GEPgateDeciduous_std = std(GEPsimulationsDeciduous, 0, 2, 'omitnan');
    GEPgateDeciduous_SE  = GEPgateDeciduous_std;% ./ sqrt(numberSimulations);
    CI_low_deciduous = max(0, UT01.GEPurbanDeciduous(:) - GEPgateDeciduous_SE(:));
    CI_up_deciduous  = UT01.GEPurbanDeciduous(:) + GEPgateDeciduous_SE(:);

    % Evergreen
    GEPgateEvergreen_std = std(GEPsimulationsEvergreen, 0, 2, 'omitnan');
    GEPgateEvergreen_SE  = GEPgateEvergreen_std;% ./ sqrt(numberSimulations);
    CI_low_evergreen  = max(0, UT01.GEPurbanEvergreen(:) - GEPgateEvergreen_SE(:));
    CI_up_evergreen   = UT01.GEPurbanEvergreen(:) + GEPgateEvergreen_SE(:);

    %%
    % Compute relative standard errors from Monte Carlo model simulations
    rel_SE_grass     = GEPgateGrass_SE(:)     ./ max(1e-6, abs(UT01.GEPurbanGrass(:)));
    rel_SE_deciduous = GEPgateDeciduous_SE(:) ./ max(1e-6, abs(UT01.GEPurbanDeciduous(:)));
    rel_SE_evergreen = GEPgateEvergreen_SE(:) ./ max(1e-6, abs(UT01.GEPurbanEvergreen(:)));

    % Combine model relative SE with inventory uncertainty in quadrature
    comb_rel_SE_grass     = sqrt(rel_SE_grass.^2     + TOgrass_uncertainty^2);
    comb_rel_SE_deciduous = sqrt(rel_SE_deciduous.^2 + TOinv_uncertainty^2);
    comb_rel_SE_evergreen = sqrt(rel_SE_evergreen.^2 + TOinv_uncertainty^2);
    
    %% UT01.hAreaTOcarbonGrass     = area(dayfill, [CI_low_grass, CI_up_grass - CI_low_grass].*8617.*gCha_ktCm2);
    %
    UT01.GEPurbanTOcarbonGrassXm2     = UT01.GEPurbanGrass; %gC m-2 d-1
    % UT01.ciGEPurbanTOcarbonGrassXm2   = GEPgateGrass_SE(:); %gC m-2 d-1
    UT01.ciGEPurbanTOcarbonGrassXm2   = abs(UT01.GEPurbanTOcarbonGrassXm2) .* comb_rel_SE_grass;

    UT01.GEPurbanTOcarbonDeciduousXm2 = UT01.GEPurbanDeciduous.*1.76./BAfluxnetDeciduous; %gC m-2 d-1  ha>m2  gC>ktC  gC BA [m2/ha]
    % UT01.ciGEPurbanTOcarbonDeciduousXm2 = GEPgateDeciduous_SE(:).*1.76./BAfluxnetDeciduous; %gC m-2 d-1  ha>m2  gC>ktC  gC BA [m2/ha]
  UT01.ciGEPurbanTOcarbonDeciduousXm2 = abs(UT01.GEPurbanTOcarbonDeciduousXm2) .* comb_rel_SE_deciduous;

    UT01.GEPurbanTOcarbonEvergreenXm2   = UT01.GEPurbanEvergreen.*0.52./BAfluxnetEvergreen; %gC m-2 d-1  ha>m2  gC>ktC gC BA [m2/ha]
    % UT01.ciGEPurbanTOcarbonEvergreenXm2 = GEPgateEvergreen_SE(:).*0.52./BAfluxnetEvergreen; %gC m-2 d-1  ha>m2  gC>ktC gC BA [m2/ha]
UT01.ciGEPurbanTOcarbonEvergreenXm2 = abs(UT01.GEPurbanTOcarbonEvergreenXm2) .* comb_rel_SE_evergreen;

    UT01.GEPurbanTOcarbonGrass     = UT01.GEPurbanGrass.*8617.*gCm2_ktCha; %gC m-2 d-1  ha>m2  gC>ktC  gC
    % UT01.ciGEPurbanTOcarbonGrass   = GEPgateGrass_SE(:).*8617.*gCm2_ktCha; %gC m-2 d-1  ha>m2  gC>ktC  gC
UT01.ciGEPurbanTOcarbonGrass   = abs(UT01.GEPurbanTOcarbonGrass) .* comb_rel_SE_grass;

UT01.GEPurbanTOcarbonDeciduous = UT01.GEPurbanDeciduous.*45131.*gCm2_ktCha.*1.76./BAfluxnetDeciduous; %gC m-2 d-1  ha>m2  gC>ktC  gC
    % UT01.ciGEPurbanTOcarbonDeciduous = GEPgateDeciduous_SE(:).*45131.*gCm2_ktCha.*1.76./BAfluxnetDeciduous; %gC m-2 d-1  ha>m2  gC>ktC  gC
UT01.ciGEPurbanTOcarbonDeciduous = abs(UT01.GEPurbanTOcarbonDeciduous) .* comb_rel_SE_deciduous;

    UT01.GEPurbanTOcarbonEvergreen   = UT01.GEPurbanEvergreen.*20457.*gCm2_ktCha.*0.52./BAfluxnetEvergreen; %gC m-2 d-1  ha>m2  gC>ktC  gC BA [m2/ha]
    % UT01.ciGEPurbanTOcarbonEvergreen = GEPgateEvergreen_SE(:).*20457.*gCm2_ktCha.*0.52./BAfluxnetEvergreen; %gC m-2 d-1  ha>m2  gC>ktC  gC BA [m2/ha]
UT01.ciGEPurbanTOcarbonEvergreen = abs(UT01.GEPurbanTOcarbonEvergreen) .* comb_rel_SE_evergreen;

%% figures
    y1 = 0;           y2 =24;          y3 = y1:(y2-y1)/4:y2;
    figure('Color', 'white', 'Position', [100, 100, 1000, 400]);
    hold on;

    % Grass
    UT01.hAreaGrass = area(dayfill, [CI_low_grass, CI_up_grass - CI_low_grass]);
    set(UT01.hAreaGrass(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(UT01.hAreaGrass(2), 'FaceColor', colorGrass, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');

    % Deciduous
    UT01.hAreaDeciduous = area(dayfill, [CI_low_deciduous, CI_up_deciduous - CI_low_deciduous]);
    set(UT01.hAreaDeciduous(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(UT01.hAreaDeciduous(2), 'FaceColor', colorDeciduous, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

    % Forest
    SBG01.hAreaForest = area(SBG01.dayfill, [SBG01.CI_low_forest, SBG01.CI_up_forest - SBG01.CI_low_forest]);
    set(SBG01.hAreaForest(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(SBG01.hAreaForest(2), 'FaceColor', colorForest, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

    % Evergreen
    UT01.hAreaEver = area(dayfill, [CI_low_evergreen, CI_up_evergreen - CI_low_evergreen]);
    set(UT01.hAreaEver(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(UT01.hAreaEver(2), 'FaceColor', colorEvergreen, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

    scatter(dayfill, UT01.GEPurbanGrass(:),20, 'filled', 'MarkerFaceColor', colorGrass, ...
        'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);
    scatter(dayfill, UT01.GEPurbanDeciduous(:),20, 'filled', 'MarkerFaceColor', colorDeciduous, ...
        'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);
    scatter(SBG01.dayfill, SBG01.GEPurbanForest(:),20, 'filled', 'MarkerFaceColor', colorForest, ...
        'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);
    scatter(dayfill, UT01.GEPurbanEvergreen(:),20, 'filled', 'MarkerFaceColor', colorEvergreen, ...
        'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);

    hGrass = plot(dayfill, smooth(UT01.GEPurbanGrass(:),15), 'Color', colorGrass, 'LineWidth', 1, ...
        'DisplayName', 'Grass');
    hDeciduous = plot(dayfill, smooth(UT01.GEPurbanDeciduous(:),15), 'Color', colorDeciduous, 'LineWidth', 1, ...
        'DisplayName', 'Deciduous');
    hForest = plot(SBG01.dayfill, smooth(SBG01.GEPurbanForest(:),15), 'Color', colorForest, 'LineWidth', 1, ...
        'DisplayName', 'Forest');
    hEvergreen = plot(dayfill, smooth(UT01.GEPurbanEvergreen(:),15), 'Color', colorEvergreen, 'LineWidth', 1, ...
        'DisplayName', 'Evergreen');

    ylabel('GEP (gC m^{-2} d^{-1})', 'FontSize', 16);
    set(gca, 'GridAlpha', 0.15, 'LineWidth', 1,'Ylim',[y1 y2],'YTick',y3,...
        'xlim',[dayfill(1), dayfill(end)],'FontSize',16, 'XTickLabelRotation', 0);
    grid on;      box on;        grid on;     datetick('x', 'yyyy-mm');
    legend([hGrass, hDeciduous, hEvergreen, hForest], 'Location', 'NorthWest', 'orientation','horizontal','Box', 'on', 'FontSize', 16); legend box off;

    %%
    y1 = 0;             y2 =1.600;          y3 = y1:(y2-y1)/4:y2;
    figure('Color', 'white', 'Position', [100, 100, 900, 500]);
    hold on;
    % Grass
    UT01.hAreaTOcarbonGrass = area(dayfill, [CI_low_grass, CI_up_grass - CI_low_grass].*8617.*gCm2_ktCha);
    set(UT01.hAreaTOcarbonGrass(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(UT01.hAreaTOcarbonGrass(2), 'FaceColor', colorGrass, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');

    % Deciduous
    UT01.hAreaTOcarbonDeciduous = area(dayfill, [CI_low_deciduous, CI_up_deciduous - CI_low_deciduous].*45131.*gCm2_ktCha.*1.76./BAfluxnetDeciduous);
    set(UT01.hAreaTOcarbonDeciduous(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(UT01.hAreaTOcarbonDeciduous(2), 'FaceColor', colorDeciduous, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

    % Evergreen
    UT01.hAreaTOcarbonEvergreen = area(dayfill, [CI_low_evergreen, CI_up_evergreen - CI_low_evergreen].*20457.*gCm2_ktCha.*0.52./BAfluxnetEvergreen);
    set(UT01.hAreaTOcarbonEvergreen(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(UT01.hAreaTOcarbonEvergreen(2), 'FaceColor', colorEvergreen, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

    % Plot Main Model Best Estimate Trendlines
    scatter(dayfill, UT01.GEPurbanTOcarbonGrass(:),20, 'filled', 'MarkerFaceColor', colorGrass, ...
        'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);
    scatter(dayfill, UT01.GEPurbanTOcarbonDeciduous(:),20, 'filled', 'MarkerFaceColor', colorDeciduous, ...
        'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);
    scatter(dayfill, UT01.GEPurbanTOcarbonEvergreen(:),20, 'filled', 'MarkerFaceColor', colorEvergreen, ...
        'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);

    hGrass = plot(dayfill, smooth(UT01.GEPurbanTOcarbonGrass(:),15), 'Color', colorGrass, 'LineWidth', 2, ...
        'DisplayName', 'Grass');
    hDeciduous = plot(dayfill, smooth(UT01.GEPurbanTOcarbonDeciduous(:),15), 'Color', colorDeciduous, 'LineWidth', 2, ...
        'DisplayName', 'Deciduous');
    hEvergreen = plot(dayfill, smooth(UT01.GEPurbanTOcarbonEvergreen(:),15), 'Color', colorEvergreen, 'LineWidth', 2, ...
        'DisplayName', 'Evergreen');

    ylabel('C-uptake (tC day^-^1)', 'FontSize', 16);
    set(gca, 'GridAlpha', 0.15, 'LineWidth', 1,'Ylim',[y1 y2],'YTick',y3,...
        'xlim',[dayfill(1), dayfill(end)],'FontSize',16, 'XTickLabelRotation', 0);
    grid on;      box on;        grid on;     datetick('x', 'yyyy-mm');
    legend([hGrass, hDeciduous, hEvergreen], 'Location', 'NorthWest', 'Box', 'on', 'FontSize', 16); legend box off;

    %% all together including ravines

    y1 = 0;             y2 =1.600;          y3 = y1:(y2-y1)/4:y2;
    figure('Color', 'white', 'Position', [100, 100, 1000, 400]);
    hold on;
    % Grass
    UT01.hAreaTOcarbonGrass = area(dayfill, [CI_low_grass, CI_up_grass - CI_low_grass].*8617.*gCm2_ktCha);
    set(UT01.hAreaTOcarbonGrass(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(UT01.hAreaTOcarbonGrass(2), 'FaceColor', colorGrass, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');

    % Deciduous
    UT01.hAreaTOcarbonDeciduous = area(dayfill, [CI_low_deciduous, CI_up_deciduous - CI_low_deciduous].*45131.*gCm2_ktCha.*1.76./BAfluxnetDeciduous);
    set(UT01.hAreaTOcarbonDeciduous(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(UT01.hAreaTOcarbonDeciduous(2), 'FaceColor', colorDeciduous, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

    % Evergreen
    UT01.hAreaTOcarbonEvergreen = area(dayfill, [CI_low_evergreen, CI_up_evergreen - CI_low_evergreen].*45131.*gCm2_ktCha.*1.76./BAfluxnetDeciduous);
    set(UT01.hAreaTOcarbonEvergreen(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(UT01.hAreaTOcarbonEvergreen(2), 'FaceColor', colorEvergreen, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

    % % Evergreen
    % UT01.hAreaTOcarbonEvergreen = area(dayfill, [CI_low_evergreen, CI_up_evergreen - CI_low_evergreen].*20457.*gCm2_ktCha.*0.52./BAfluxnetEvergreen);
    % set(UT01.hAreaTOcarbonEvergreen(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    % set(UT01.hAreaTOcarbonEvergreen(2), 'FaceColor', colorEvergreen, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

    % Plot Main Model Best Estimate Trendlines
    scatter(dayfill, UT01.GEPurbanTOcarbonGrass(:),20, 'filled', 'MarkerFaceColor', colorGrass, ...
        'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
    scatter(dayfill, UT01.GEPurbanTOcarbonEvergreen(:),20, 'filled', 'MarkerFaceColor', colorEvergreen, ...
        'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
    scatter(dayfill, UT01.GEPurbanTOcarbonEvergreen(:)+UT01.GEPurbanTOcarbonDeciduous(:),20, 'filled', 'MarkerFaceColor', colorDeciduous, ...
        'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
    scatter(dayfill, UT01.GEPurbanTOcarbonDeciduous(:)+[SBG01.GEPurbanTOcarbonForest(:);NaN]+...
        UT01.GEPurbanTOcarbonEvergreen(:),20, 'filled', 'MarkerFaceColor', ColorDeciduousTotal, ...
        'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);

    hGrass = plot(dayfill, smooth(UT01.GEPurbanTOcarbonGrass(:),15), 'Color', colorGrass, 'LineWidth', 2, ...
        'DisplayName', 'Grass');
    hEvergreen = plot(dayfill, smooth(UT01.GEPurbanTOcarbonEvergreen(:),15), 'Color', colorEvergreen, 'LineWidth', 2, ...
        'DisplayName', 'City Evergreen');
    hEvergreenDeciduous = plot(dayfill, smooth(UT01.GEPurbanTOcarbonDeciduous(:)+UT01.GEPurbanTOcarbonEvergreen(:),15),...
        'Color', colorDeciduous, 'LineWidth', 2, 'DisplayName','City Evergreen+Deciduous');
    hForest = plot(dayfill, smooth(UT01.GEPurbanTOcarbonEvergreen(:)+...
        UT01.GEPurbanTOcarbonDeciduous(:)+[SBG01.GEPurbanTOcarbonForest(:);NaN],15),...
        'Color', ColorDeciduousTotal, 'LineWidth', 2, ...
        'DisplayName', 'Ravine+City Evergreen+Deciduous');

    ylabel('C-uptake (kt C day^-^1)', 'FontSize', 16);
    set(gca, 'GridAlpha', 0.15, 'LineWidth', 1,'Ylim',[y1 y2],'YTick',y3,...
        'xlim',[dayfill(1), dayfill(end)],'FontSize',16, 'XTickLabelRotation', 0);
    grid on;      box on;        grid on;     datetick('x', 'yyyy-mm');
    legend([hGrass, hEvergreen, hEvergreenDeciduous, hForest], 'Orientation','Horizontal','Location', 'NorthWest', 'Box', 'on', 'FontSize', 14); legend box off;

    %% annual forests
    ind = find(year(dayfill)==2023);
    annualTOcarbon2023 = sum(UT01.GEPurbanTOcarbonDeciduous(ind)+UT01.GEPurbanTOcarbonEvergreen(ind)+...
        SBG01.GEPurbanTOcarbonForest(ind));
    display (annualTOcarbon2023)
    ind = find(year(dayfill)==2024);
    annualTOcarbon2024 = sum(UT01.GEPurbanTOcarbonDeciduous(ind)+UT01.GEPurbanTOcarbonEvergreen(ind)+...
        SBG01.GEPurbanTOcarbonForest(ind));
    display (annualTOcarbon2024)
    ind = find(year(dayfill)==2025);
    annualTOcarbon2025 = sum(UT01.GEPurbanTOcarbonDeciduous(ind)+UT01.GEPurbanTOcarbonEvergreen(ind)+...
        [SBG01.GEPurbanTOcarbonForest(ind(1:end-1));0],'omitnan');
    display (annualTOcarbon2025)

    deciduousTOcarbon = sum(UT01.GEPurbanTOcarbonDeciduous,'omitnan')/length(unique(year(dayfill)));
    display (deciduousTOcarbon)
    forestTOcarbon = sum(SBG01.GEPurbanTOcarbonForest,'omitnan')/length(unique(year(SBG01.dayfill)));
    display (forestTOcarbon)
    evergreenTOcarbon = sum(UT01.GEPurbanTOcarbonEvergreen,'omitnan')/length(unique(year(dayfill)));
    display (evergreenTOcarbon)
    grassTOcarbon = sum(UT01.GEPurbanTOcarbonGrass,'omitnan')/length(unique(year(dayfill)));
    display (grassTOcarbon)

    % ERROR PROPAGATION (Quadrature divided by number of years)
    CIdeciduousTOcarbon = sqrt(sum(UT01.ciGEPurbanTOcarbonDeciduous,'omitnan'))/length(unique(year(dayfill)));
    display (CIdeciduousTOcarbon)
    CIforestTOcarbon = sqrt(sum(SBG01.ciGEPurbanTOcarbonForest,'omitnan'))/length(unique(year(SBG01.dayfill)));
    display (CIforestTOcarbon)
    CIevergreenTOcarbon = sqrt(sum(UT01.ciGEPurbanTOcarbonEvergreen,'omitnan'))/length(unique(year(dayfill)));
    display (CIevergreenTOcarbon)
    CIgrassTOcarbon = sqrt(sum(UT01.ciGEPurbanTOcarbonGrass,'omitnan'))/length(unique(year(dayfill)));
    display (CIgrassTOcarbon)
    CItreeTOcarbon      = sqrt(CIdeciduousTOcarbon^2 + CIforestTOcarbon^2 + CIevergreenTOcarbon^2);
    display (CItreeTOcarbon)

    deciduousTOcarbonXm2 = sum(UT01.GEPurbanTOcarbonDeciduousXm2,'omitnan')/length(unique(year(dayfill)));
    display (deciduousTOcarbonXm2)
    forestTOcarbonXm2 = sum(SBG01.GEPurbanTOcarbonForestXm2,'omitnan')/length(unique(year(SBG01.dayfill)));
    display (forestTOcarbonXm2)
    evergreenTOcarbonXm2 = sum(UT01.GEPurbanTOcarbonEvergreenXm2,'omitnan')/length(unique(year(dayfill)));
    display (evergreenTOcarbonXm2)
    grassTOcarbonXm2 = sum(UT01.GEPurbanTOcarbonGrassXm2,'omitnan')/length(unique(year(dayfill)));
    display (grassTOcarbonXm2)

    CIdeciduousTOcarbonXm2 = sqrt(sum(UT01.ciGEPurbanTOcarbonDeciduousXm2,'omitnan'))/length(unique(year(dayfill)));
    display (CIdeciduousTOcarbonXm2)
    CIforestTOcarbonXm2 = sqrt(sum(SBG01.ciGEPurbanTOcarbonForest,'omitnan'))/length(unique(year(SBG01.dayfill)));
    display (CIforestTOcarbonXm2)
    CIevergreenTOcarbonXm2 = sqrt(sum(UT01.ciGEPurbanTOcarbonEvergreen,'omitnan'))/length(unique(year(dayfill)));
    display (CIevergreenTOcarbonXm2)
    CIgrassTOcarbonXm2 = sqrt(sum(UT01.ciGEPurbanTOcarbonGrass,'omitnan'))/length(unique(year(dayfill)));
    display (CIgrassTOcarbonXm2)
    CItreeTOcarbonXm2      = sqrt(CIdeciduousTOcarbonXm2^2 + CIforestTOcarbonXm2^2 + CIevergreenTOcarbonXm2^2);
    display (CItreeTOcarbonXm2)

    %%
    y1 = 0;             y2 = 1.600;          y3 = y1:(y2-y1)/4:y2;
    colorGrass           = validatecolor('#1e6628');  % Deep Forest Green
    ColorDeciduousTotal  = validatecolor('#e15e1a');  % Burnt Orange (Total Cumulative Stack)
    colorDeciduous       = validatecolor('#b28033');  % Muted Ochre
    colorEvergreen       = validatecolor('#1e7080');  % Dark Ocean Teal

    figure('Color', 'white', 'Position', [100, 100, 1000, 400]);
    hold on;

    UT01.GEPurbanTOcarbonGrass     = UT01.GEPurbanGrass.*8617.*gCm2_ktCha;
    UT01.GEPurbanTOcarbonDeciduous = UT01.GEPurbanDeciduous.*45131.*gCm2_ktCha.*1.76./BAfluxnetDeciduous;
    UT01.GEPurbanTOcarbonEvergreen = UT01.GEPurbanEvergreen.*20457.*gCm2_ktCha.*0.52./BAfluxnetEvergreen;

    % Compute the individual base line heights for stacking
    baseGrass     = UT01.GEPurbanTOcarbonGrass(:);
    baseEvergreen = UT01.GEPurbanTOcarbonEvergreen(:);
    baseDecidTotal = baseEvergreen + UT01.GEPurbanTOcarbonDeciduous(:);
    baseForestTotal = baseDecidTotal + [SBG01.GEPurbanTOcarbonForest(:); NaN];

    % Grass sits independently on the bottom
    CI_grass_L = CI_low_grass(:) .* 8617 .* gCm2_ktCha;
    CI_grass_U = CI_up_grass(:)  .* 8617 .* gCm2_ktCha;

    % Layer 1 of the City stack: Evergreen
    CI_evergreen_L = CI_low_evergreen(:) .* 20457 .* gCm2_ktCha .* 0.52 ./ 33;
    CI_evergreen_U = CI_up_evergreen(:)  .* 20457 .* gCm2_ktCha .* 0.52 ./ 33;

    % Layer 2 of the City stack: Evergreen + Deciduous (Adding up the uncertainties)
    CI_deciduous_L = CI_evergreen_L + (CI_low_deciduous(:) .* 45131 .* gCm2_ktCha .* 1.76 ./ 35);
    CI_deciduous_U = CI_evergreen_U + (CI_up_deciduous(:)  .* 45131 .* gCm2_ktCha .* 1.76 ./ 35);

    % Total Cumulative Deciduous + Evergreen Bounds
    hAreaDecidTotal = area(dayfill, [CI_deciduous_L,  CI_deciduous_U  - CI_deciduous_L]);
    set(hAreaDecidTotal(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(hAreaDecidTotal(2), 'FaceColor', ColorDeciduousTotal, 'EdgeColor', 'none', 'FaceAlpha', 0.12, 'HandleVisibility', 'off');

    % City Evergreen Area Layer
    hAreaEvergreen = area(dayfill, [CI_evergreen_L, CI_evergreen_U - CI_evergreen_L]);
    set(hAreaEvergreen(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(hAreaEvergreen(2), 'FaceColor', colorEvergreen, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

    % Baseline Grass Area Layer
    hAreaGrass = area(dayfill, [CI_grass_L, CI_grass_U - CI_grass_L]);
    set(hAreaGrass(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
    set(hAreaGrass(2), 'FaceColor', colorGrass, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

    scatter(dayfill, baseGrass, 15, 'filled', 'MarkerFaceColor', colorGrass, ...
        'MarkerFaceAlpha', 0.15, 'MarkerEdgeAlpha', 0.15);
    scatter(dayfill, baseEvergreen, 15, 'filled', 'MarkerFaceColor', colorEvergreen, ...
        'MarkerFaceAlpha', 0.15, 'MarkerEdgeAlpha', 0.15);
    scatter(dayfill, baseDecidTotal, 15, 'filled', 'MarkerFaceColor', colorDeciduous, ...
        'MarkerFaceAlpha', 0.15, 'MarkerEdgeAlpha', 0.15);
    scatter(dayfill, baseForestTotal, 15, 'filled', 'MarkerFaceColor', ColorDeciduousTotal, ...
        'MarkerFaceAlpha', 0.15, 'MarkerEdgeAlpha', 0.15);
    hGrass = plot(dayfill, smooth(baseGrass, 15), 'Color', colorGrass, 'LineWidth', 2.5, ...
        'DisplayName', 'Grass Base');
    hEvergreen = plot(dayfill, smooth(baseEvergreen, 15), 'Color', colorEvergreen, 'LineWidth', 2.5, ...
        'DisplayName', 'City Evergreen');
    hEvergreenDeciduous = plot(dayfill, smooth(baseDecidTotal, 15), ...
        'Color', colorDeciduous, 'LineWidth', 2.5, 'DisplayName', 'City Evergreen + Deciduous');
    hForest = plot(dayfill, smooth(baseForestTotal, 15), ...
        'Color', ColorDeciduousTotal, 'LineWidth', 3, ...
        'DisplayName', 'Total (Ravine + City)');
    ylabel('C-uptake (kt C day^{-1})', 'FontSize', 16);
    set(gca, 'GridAlpha', 0.12, 'LineWidth', 1.1, 'Ylim', [y1 y2], 'YTick', y3,...
        'XLim', [dayfill(1), dayfill(end)+days(1)], 'FontSize', 14, 'Box', 'off');

    grid on;
    box on;
    datetick('x', 'yyyy-mm', 'keeplimits');

    legend([hGrass, hEvergreen, hEvergreenDeciduous, hForest], ...
        'Orientation', 'Horizontal', 'Location', 'NorthWest', 'FontSize', 12);
    legend boxoff;

end


%% ............ Plot the Integrated PFT Trends .................
figure('Color', 'white', 'Position', [100 100 1000 900]); hold on;
y1 =0.34; y2=0.38;   y3 = y1:(y2-y1)/4:y2;
okabeItoColors = [
    0.9020, 0.6235, 0.0000;  % Orange
    0.3373, 0.7059, 0.9137;  % Sky Blue
    0.0000, 0.6196, 0.4510;  % Bluish Green
    0.9412, 0.8941, 0.2588;  % Yellow
    0.0000, 0.4471, 0.6980;  % Blue
    0.8353, 0.3686, 0.0000;  % Vermillion
    0.8000, 0.4745, 0.6549   % Reddish Purple
    ];
okabeItoColors =[
    0.2667, 0.4667, 0.6667;  % Blue (#4477AA)
    0.4000, 0.7333, 0.6000;  % Cyan (#66CCEE)
    0.1333, 0.5333, 0.2000;  % Green (#228833)
    0.8000, 0.6667, 0.1333;  % Yellow (#CCBB44)
    0.9333, 0.4000, 0.1333;  % Red (#EE6677)
    0.6667, 0.2000, 0.4667;  % Purple (#AA3377)
    0.7333, 0.7333, 0.7333   % Grey (#BBBBBB)
    ];
okabeItoColors =[
    0.1333, 0.5333, 0.2000;  % Green (#228833)
    0.2000, 0.5333, 0.6667;  % Indigo (#332288)
    0.5333, 0.8000, 0.9333;  % Sand (#DDCC77)
    0.0667, 0.4667, 0.2000;  % Green (#117733)
    0.5333, 0.6000, 0.2000;  % Cyan (#88CCEE)
    0.6000, 0.4000, 0.2000;  % Wine (#882255)
    0.7333, 0.1333, 0.3333;  % Teal (#44AA99)
    0.8627, 0.0784, 0.2353;  % Hot Pink (#DC267F)
    1.0000, 0.4353, 0.1333;  % Orange/Coral (#FE6100)
    ];
% color_mtx = [okabeItoColors(2,:);okabeItoColors(3,:);okabeItoColors(5,:);okabeItoColors(7,:);okabeItoColors(6,:)];
colorGrass = okabeItoColors(2,:); colorEvergreen = okabeItoColors(3,:); colorDeciduous = okabeItoColors(1,:);
colorForest = okabeItoColors(8,:); colorTotal = 'k';

subplot(3,1,1);  hold on;
scatter(dayfill, GCC_avg_Grass,10, 'filled', 'MarkerFaceColor', colorGrass, ...
    'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
scatter(dayfill, GCC_avg_Evergreen,10, 'filled', 'MarkerFaceColor', colorEvergreen, ...
    'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
scatter(dayfill, GCC_avg_Deciduous,10, 'filled', 'MarkerFaceColor', colorDeciduous, ...
    'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
scatter(SBG01.dayfill, SBG01.GCC_avg_Forest.*0.33+.235,10, 'filled', 'MarkerFaceColor', colorForest, ...
    'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
hl1 = plot(dayfill, smooth(GCC_avg_Grass,15), 'color',colorGrass, 'LineWidth', 1.); hold on;
hl2 = plot(dayfill, smooth(GCC_avg_Evergreen,15),  'color',colorEvergreen, 'LineWidth', 1.);
hl3 = plot(dayfill, smooth(GCC_avg_Deciduous,15), 'color',colorDeciduous, 'LineWidth', 1.);
hl4 = plot(SBG01.dayfill, smooth(SBG01.GCC_avg_Forest.*0.33+.235,15), 'color',colorForest, 'LineWidth', 1.);
set(gca,'Ylim',[y1 y2],'YTick',y3,'XTickLabel',[],'FontSize',14); hold on;
set(gca,'xminortick','on')
legend([hl1,hl2,hl3,hl4],'Grass', 'Evergreen', 'Deciduous', 'Forest','Location', 'best','fontSize',14,'orientation','horizontal');
ylabel('GCC','fontSize',14);      grid on;     %datetick('x', 'yyyy-mm');
% title('Integrated Average GCC Time Series Per Plant Functional Type');
legend box off;  box on;

y1 = 0;           y2 =24;          y3 = y1:(y2-y1)/4:y2;
subplot(3,1,2);   hold on;
scatter(dayfill, UT01.GEPurbanGrass(:),10, 'filled', 'MarkerFaceColor', colorGrass, ...
    'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);
scatter(dayfill, UT01.GEPurbanDeciduous(:),10, 'filled', 'MarkerFaceColor', colorDeciduous, ...
    'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);
scatter(SBG01.dayfill, SBG01.GEPurbanForest(:),10, 'filled', 'MarkerFaceColor', colorForest, ...
    'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);
scatter(dayfill, UT01.GEPurbanEvergreen(:),10, 'filled', 'MarkerFaceColor', colorEvergreen, ...
    'MarkerFaceAlpha', 0.5,'MarkerEdgeAlpha', 0.5);

% Grass
UT01.hAreaGrass = area(dayfill, [CI_low_grass, CI_up_grass - CI_low_grass]);
set(UT01.hAreaGrass(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
set(UT01.hAreaGrass(2), 'FaceColor', colorGrass, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');

% Deciduous
UT01.hAreaDeciduous = area(dayfill, [CI_low_deciduous, CI_up_deciduous - CI_low_deciduous]);
set(UT01.hAreaDeciduous(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
set(UT01.hAreaDeciduous(2), 'FaceColor', colorDeciduous, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

% Forest
SBG01.hAreaForest = area(SBG01.dayfill, [SBG01.CI_low_forest, SBG01.CI_up_forest - SBG01.CI_low_forest]);
set(SBG01.hAreaForest(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
set(SBG01.hAreaForest(2), 'FaceColor', colorForest, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

% Evergreen
UT01.hAreaEver = area(dayfill, [CI_low_evergreen, CI_up_evergreen - CI_low_evergreen]);
set(UT01.hAreaEver(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
set(UT01.hAreaEver(2), 'FaceColor', colorEvergreen, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

hGrass = plot(dayfill, smooth(UT01.GEPurbanGrass(:),15), 'Color', colorGrass, 'LineWidth', 1, ...
    'DisplayName', 'Grass');
hDeciduous = plot(dayfill, smooth(UT01.GEPurbanDeciduous(:),15), 'Color', colorDeciduous, 'LineWidth', 1, ...
    'DisplayName', 'Deciduous');
hForest = plot(SBG01.dayfill, smooth(SBG01.GEPurbanForest(:),15), 'Color', colorForest, 'LineWidth', 1, ...
    'DisplayName', 'Forest');
hEvergreen = plot(dayfill, smooth(UT01.GEPurbanEvergreen(:),15), 'Color', colorEvergreen, 'LineWidth', 1, ...
    'DisplayName', 'Evergreen');

ylabel('GEP (gC m^{-2} d^{-1})', 'FontSize', 14);
set(gca, 'GridAlpha', 0.15, 'LineWidth', .5,'Ylim',[y1 y2],'YTick',y3,'XTickLabel',[],...
    'xlim',[dayfill(1), dayfill(end)],'FontSize',14, 'XTickLabelRotation', 0);
set(gca,'xminortick','on')
grid on;      box on;        %grid on;     datetick('x', 'yyyy-mm');
legend([hGrass, hEvergreen, hDeciduous, hForest], 'Location', 'NorthWest', 'orientation','horizontal','Box', 'on', 'FontSize', 14); legend box off;

y1 = 0;             y2 =1.600;          y3 = y1:(y2-y1)/4:y2;
subplot(3,1,3);     hold on;
% Plot main model best estimate trend-lines
scatter(dayfill, UT01.GEPurbanTOcarbonGrass(:),10, 'filled', 'MarkerFaceColor', colorGrass, ...
    'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
scatter(dayfill, UT01.GEPurbanTOcarbonEvergreen(:),10, 'filled', 'MarkerFaceColor', colorEvergreen,...
    'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
scatter(dayfill, UT01.GEPurbanTOcarbonDeciduous(:),10, 'filled', 'MarkerFaceColor', colorDeciduous,...
    'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
scatter(dayfill, [SBG01.GEPurbanTOcarbonForest(:);NaN],10, 'filled', 'MarkerFaceColor', colorForest,...
    'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2);
scatter(dayfill, UT01.GEPurbanTOcarbonDeciduous(:)+[SBG01.GEPurbanTOcarbonForest(:);NaN]+...
    UT01.GEPurbanTOcarbonEvergreen(:),10, 'filled', 'MarkerFaceColor', colorTotal, ...
    'MarkerFaceAlpha', 0.1,'MarkerEdgeAlpha', 0.1);

% Grass
UT01.hAreaTOcarbonGrass = area(dayfill, [CI_low_grass, CI_up_grass - CI_low_grass].*8617.*gCm2_ktCha);
set(UT01.hAreaTOcarbonGrass(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
set(UT01.hAreaTOcarbonGrass(2), 'FaceColor', colorGrass, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');

% Deciduous
UT01.hAreaTOcarbonDeciduous = area(dayfill, [CI_low_deciduous, CI_up_deciduous - CI_low_deciduous].*45131.*gCm2_ktCha.*1.76./BAfluxnetDeciduous);
set(UT01.hAreaTOcarbonDeciduous(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
set(UT01.hAreaTOcarbonDeciduous(2), 'FaceColor', colorDeciduous, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

% Evergreen
UT01.hAreaTOcarbonEvergreen = area(dayfill, [CI_low_evergreen, CI_up_evergreen - CI_low_evergreen].*45131.*gCm2_ktCha.*1.76./BAfluxnetDeciduous);
set(UT01.hAreaTOcarbonEvergreen(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
set(UT01.hAreaTOcarbonEvergreen(2), 'FaceColor', colorEvergreen, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

% % Evergreen
% UT01.hAreaTOcarbonEvergreen = area(dayfill, [CI_low_evergreen, CI_up_evergreen - CI_low_evergreen].*20457.*gCm2_ktCha.*0.52./BAfluxnetEvergreen);
% set(UT01.hAreaTOcarbonEvergreen(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off');
% set(UT01.hAreaTOcarbonEvergreen(2), 'FaceColor', colorEvergreen, 'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HandleVisibility', 'off');

hGrass = plot(dayfill, smooth(UT01.GEPurbanTOcarbonGrass(:),15), 'Color', colorGrass, 'LineWidth', 1, ...
    'DisplayName', 'Grass');
hEvergreen = plot(dayfill, smooth(UT01.GEPurbanTOcarbonEvergreen(:),15), 'Color', colorEvergreen, 'LineWidth', 1, ...
    'DisplayName', 'City Evergreen');
hEvergreenDeciduous = plot(dayfill, smooth(UT01.GEPurbanTOcarbonDeciduous(:),15),...
    'Color', colorDeciduous, 'LineWidth', 1, 'DisplayName','City Deciduous');
hForest = plot(dayfill, smooth([SBG01.GEPurbanTOcarbonForest(:);NaN],15),...
    'Color', colorForest, 'LineWidth', 1, ...
    'DisplayName', 'Ravine');
hTotal = plot(dayfill, smooth(UT01.GEPurbanTOcarbonEvergreen(:)+...
    UT01.GEPurbanTOcarbonDeciduous(:)+[SBG01.GEPurbanTOcarbonForest(:);NaN],15),...
    'Color', colorTotal, 'LineWidth', 1, ...
    'DisplayName', 'Total');

ylabel('C-uptake (kt C day^-^1)', 'FontSize', 14);
set(gca, 'GridAlpha', 0.15, 'LineWidth', .5, 'Ylim', [y1 y2], 'YTick', y3, ...
    'xlim', [dayfill(1), dayfill(end)+days(1)],'FontSize', 14, 'XTickLabelRotation', 0);
grid on;      box on;    xtickformat('yyyy');
ax = gca;
ax.XAxis.TickValues = dayfill(1) : years(1) : dayfill(end)+days(1);   hold on;
ax.XMinorTick = 'on';
ax.XAxis.MinorTickValues = dayfill(1) : calmonths(6) : dayfill(end)+days(1);

% ax = gca;
% ax.XMinorTick = 'on';
% ax.XAxis.MinorTickValues = dayfill(1) : calmonths(6) : dayfill(end);
% ax.XAxis.TickValues = dayfill(1) : calmonths(12) : dayfill(end);
legend([hGrass, hEvergreen, hEvergreenDeciduous, hForest, hTotal], 'Orientation','Horizontal','Location', 'NorthWest', 'Box', 'on', 'FontSize', 14);
legend box off;
