% % Fiures for correlation and seasonal analysis2023
% % Natalia Restrepo
% % 121208 Sydney, Australia
%..........................................................................
%..........................................................................
warning off
flag_unix = 0;
flag_read = 1;               flag_filename = 1;             flag_video = 10;        flag_video_avi = 0;
flag_color_figure_all = 1;   flag_color_figure_roi = 1;     flag_color_figure_roi_std = 1;
flag_year2year = 1;          flag_meteo = 1;
% UTM = LT-4

if flag_unix == 1
    %     FolderOZflux = 'C:\Users\ncoupe\Documents\OZ\OZflux\';
    slash = '\';
    addpath \Users\ncoupe\Documents\OZ\
    addpath \Users\ncoupe\Documents\Amazon\C
else
    FolderFlux   = '/home/ncoupe/Documents/Amazon/AllSites/';
    % FolderTRMM = '/home/ncoupe/Documents/AmazonRS/TRMM/TRMMsites/';
    % FolderGPM = '/home/ncoupe/Documents/AmazonRS/TRMM/GPMsites/';
    FolderUofT02 = '/home/ncoupe/Documents/Canada/Toronto/UofTcamera02/';
    FolderImages = '/media/ncoupe/Expansion/Data/Canada/Toronto/Phenocam/UofTcamera02/';
    slash = '/';
    addpath /home/ncoupe/Documents/OZ/
    addpath /home/ncoupe/Documents/Amazon/
    load 'dayUofT02.mat'
end


[site_name_FN, lat_FN, lon_FN, site_long_FN, year_ini, year_end, siteelevation_FN,...
    height_FN, canopy_FN, ust_tresh_FN, sunrise_FN, sunset_FN, utm_FN, ust_min_FN, ust_max_FN,...
    LAI_FN]  =  textread([FolderFlux 'sites_loc.txt'],...
    '%s	%f	%f	%s	%f	%f	%f	%f %f	%f	%f	%f	%f	%f	%f	%f',...
    'delimiter',',','headerlines', 1);
month_name = (['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec']);
month_avg = (datetime(0,1:12,1))';    JD_avg = day(month_avg,'dayofyear');
day_avg = (1:1:365)';

ip = 17;
UofT02year = (2022:2025)';        EndDate = datetime(2025,4,20);
lat = lat_FN(ip);                 lon = lon_FN(ip);

[MeteoY,MeteoM,MeteoD,MeteoHR,~,~] =  datevec(MeteoDateloc); MeteoJD = day(MeteoDateloc,'dayofyear');
[~,~,MeteoDayLength] = AM_solar_rad(MeteoJD,12,lat,lon);
[MeteoTempCeight,~,~,MeteoTempCmin_eight,MeteoTempCmax_eight,eight_std,MeteoEight] = AM_eightday_rs(MeteoTempC,MeteoDateloc);
[MeteoEigthY,MeteoEigthM,MeteoEigthD] =  datevec(MeteoEight);
MeteoEigthJD = day(MeteoEight,'dayofyear');

listOfFileNames = [];
if flag_filename == 1
    for ij = 1:length(UofT02year)
        FileName = [FolderImages,'netcam.*.jpg'];
        [FolderImagesYear, filesYear, extension]  =  fileparts(FileName); % Separate the filenames string into parts. (The variable version is unused.)
        listOfFilesAndFolders  =  dir(fullfile(FolderImagesYear, [filesYear, extension])); % Get a list of the files and folders that match the specified filenames.
        listOfFiles  =  listOfFilesAndFolders([listOfFilesAndFolders.isdir] == 0); % Exclude folders (such as . and ..) from the list, to give a list of files only.
        listOfFileNamesYear  =  {listOfFiles.name};  % Copy the names of the files into a cell array.
        listOfFileNames = [listOfFileNames;listOfFileNamesYear'];
    end
    FileDate = NaT(length(listOfFileNames),1);
    for ik = 1:length(listOfFileNames)
        x = listOfFileNames{ik};
        Y = str2double(x(end-18:end-15));     M = str2double(x(end-14:end-13));   D = str2double(x(end-12:end-11));
        HR = str2double(x(end-09:end-08));	  MI = str2double(x(end-7:end-6));
        FileDate(ik) = datetime(Y,M,D,HR,MI,0);
    end
    [Y,M,D,HR,MI,SS] = datevec(FileDate);
    FileDay = datetime(Y,M,D);
    [C,ia,ic] = unique(FileDay);
    % selected = [];
    % for ix = 1:length(ia)
    %     selected = ([selected;ia(ix);ia(ix)+1;ia(ix)+2;ia(ix)+3;ia(ix)+4;ia(ix)+5]);
    % end
    % selected = unique(selected);
    % listOfFileNames = listOfFileNames(selected);

    load 'dayUofT02.mat'
end

% .........................................................................
if flag_read == 1
    FileDate = NaT(length(listOfFileNames),1);
    for ik = 1:length(listOfFileNames)
        x = listOfFileNames{ik};
        Y = str2double(x(end-18:end-15));        M = str2double(x(end-14:end-13));   D = str2double(x(end-12:end-11));
        HR = str2double(x(end-09:end-08));	     MI = str2double(x(end-7:end-6));
        FileDate(ik) = datetime(Y,M,D,HR,MI,0);
        datestr(FileDate(ik));
        listOfFileNames(ik);
    end

    [Y,M,D,HR,MI,S] = datevec(FileDate);
    % .....................................................................

    %     [Y1,M1,D1] = datevec(min(FileDate));          [Y2,M2,D2] = datevec(max(FileDate));
    %     FileDay = ((datetime(Y1,M1,D1)):1:(datetime(Y2,M2,D2)))';

    % %         % .........................................................................
    % %         %% select the time for the sampling using SolarZenithAngleDeg
    % %         % .........................................................................
    JD  = day(FileDate,'dayofyear');
    HRMI = HR+(MI+(S/60))/60;
    [SolarZenithAngleDeg,SolarElevationCorrectedForAtmRefractionDeg,SolarNoonLSThour]=...
        AM_solar_radNOAA(JD,HRMI,Y,lat,lon);

    % .....................................................................
    ind = find((HR>19)|(SolarZenithAngleDeg>80));
    SolarElevationCorrectedForAtmRefractionDeg(ind)  = [];      SolarZenithAngleDeg(ind) = [];
    Y(ind)  = [];   M(ind) = [];    D(ind) = [];
    HR(ind) = [];	MI(ind) = [];   S(ind) = [];                HRMI(ind) = [];
    FileDate(ind) = [];             listOfFileNames(ind) = [];

    % .....................................................................
    [Y1,M1,D1] = datevec(min(FileDate));          [Y2,M2,D2] = datevec(max(FileDate));
    %     FileDay = ((datetime(Y1,M1,D1)):1:(datetime(Y2,M2,D2)))';
    UofT02year = unique(Y);
end

%% ....................................................................
[Yini,Mini,~] = datevec(min(FileDate));     [Ymax,Mmax,~] = datevec(max(FileDate));
if Mmax==12;    Ymax = Ymax+1;              Mmax = 1; end
month_all  = (datetime(Yini,Mini-2,1):1:datetime(Ymax,Mmax+2,1))';
[~,~,x]    = datevec(month_all);            month_all(x~=1) = [];
month_tick = month_all(1:1:end);
%
% [Y_trmm,M_trmm,D_trmm,prec_trmm] = ...
%     textread([FolderTRMM 'TOR_trmm.dat'],'%f %f %f %f','headerlines',1);
% month_date_trmm = datetime(Y_trmm,M_trmm,D_trmm);
% month_prec_trmm = interp1(month_date_trmm,prec_trmm,month_all);
% month_avgTRMM = AM_month_avg(month_prec_trmm,month_all);
%
% [Y_gpm,M_gpm,D_gpm,prec_gpm] = ...
%     textread([FolderGPM 'TOR_gpm.dat'],'%f %f %f %f','headerlines',1);
% month_date_gpm = datetime(Y_gpm,M_gpm,D_gpm);
% month_prec_gpm = interp1(month_date_gpm,prec_gpm,month_all);
% month_avgGPM = AM_month_avg(month_prec_gpm,month_all);
%
% % % %% ....................................................................
% % % %% ....................................................................
% % % [FolderImages, files, extension]  =  fileparts(FileName); % Separate the filenames string into parts. (The variable version is unused.)
% % % listOfFilesAndFolders  =  dir(fullfile(FolderImages, [files, extension])); % Get a list of the files and folders that match the specified filenames.
% % % listOfFiles  =  listOfFilesAndFolders([listOfFilesAndFolders.isdir] == 0); % Exclude folders (such as . and ..) from the list, to give a list of files only.
% % % listOfFileNames  =  {listOfFiles.name};  % Copy the names of the files into a cell array.

date_target = 11;
month_name = (['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec']);

color_mtx = [0.0 0.8 0.4;0.0 0.5 0.4;0.0 0.4 0.8;0.9 0.8 0.0;0.9 0.4 0.2;0.8 0.0 0.0;0.4 0.4 0.4];
colorscheme = jet(6);%othercolor('Dark28',16);

UofT02year = (2022:2025)';

% % % ROI......................................................................
% .............................................................
ExGREENall = [];          GCCall = [];              DATEall = [];
REDall = [];                    GREENall = [];          BLUEall = [];
ExGREENallROI = [];    GCCallROI = [];
REDallROI = [];     GREENallROI = [];   BLUEallROI = [];
GCCroi = [];
FileDateAll = [];
for ik = 1:length(UofT02year)
    FolderUofT02 = '/home/ncoupe/Documents/Canada/Toronto/UofTcamera02/';
    load ([FolderUofT02 'UofT02year' num2str(UofT02year(ik)) '.mat']);
    UofT02year = (2022:2025)';
    %                 load ([FolderUofT02 'matlabSOC.SampleTable' num2str(UofT02year(ik)) '.mat']);

    % %     figure('color','white');
    % %     plot(listOfFileDates,ExGREENtime,'.');         datetick('x')
    % %     ExGREENtimeSM = smooth(ExGREENtime,12);           ExGREENtimeSM(isnan(ExGREENtime)) = NaN;      hold on
    % %     plot(listOfFileDates,ExGREENtimeSM,'.');       ylabel('ExGREEN','FontSize',12)
    % %                 [YYYY,MM,DD,HR,MI,~] = datevec(FileDateYear);

    TableExGREENroiAvg(TableExGREENroiAvg==0) = NaN;  TableGCCroiAvg(TableGCCroiAvg==0) = NaN;
    TableBLUEroiAvg(TableBLUEroiAvg==0) = NaN;        TableREDroiAvg(TableREDroiAvg==0) = NaN;
    TableGREENroiAvg(TableGREENroiAvg==0) = NaN;

    GCCroi        = [GCCroi;TableGCCroiAvg];
    ExGREENallROI = [ExGREENallROI;mean(TableExGREENroiAvg,2,'omitnan')];
    GCCallROI   = [GCCallROI;mean(TableGCCroiAvg,2,'omitnan')];
    REDallROI   = [REDallROI;mean(TableREDroiAvg,2,'omitnan')];
    GREENallROI = [GREENallROI;mean(TableGREENroiAvg,2,'omitnan')];
    BLUEallROI  = [BLUEallROI;mean(TableBLUEroiAvg,2,'omitnan')];

    GCCall   = [GCCall;GCC];
    ExGREENall = [ExGREENall;ExGREEN];
    REDall   = [REDall;RED];
    GREENall = [GREENall;GREEN];
    BLUEall  = [BLUEall;BLUE];
    FileDateAll = [FileDateAll;FileDateYear];
    ExGREEN = (2.*GREENall) - REDall - BLUEall;
    %                 figure('color','white');    hold on
    %                 plot(FileDateYear,mean(TableGCCroiAvg,2,'omitnan'),'LineWidth',2,'color','k');
    %                 plot(FileDateYear,TableGCCroiAvg);  plot(FileDateYear,mean(TableGCCroiAvg,2,'omitnan'),'LineWidth',2,'color','k');
    %                 plot(FileDateYear,GCC,'LineWidth',2,'color',[1 .0 .0]); grid on;    datetick('x');  ylabel('GCC');

    % %                 figure('color','white');    hold on
    % %                 plot(FileDateYear,mean(TableRCCroiAvg,2,'omitnan'),'LineWidth',2,'color','k');
    % %                 plot(FileDateYear,TableRCCroiAvg);  plot(FileDateYear,mean(TableRCCroiAvg,2,'omitnan'),'LineWidth',2,'color','k');
    % %                 plot(FileDateYear,RCC,'LineWidth',2,'color',[1 .0 .0]); grid on;    datetick('x');  ylabel('RCC');
end

%% ..........................................................................
if flag_color_figure_all == 1
    %     date_ini = find(min(FileDate));    date_end = find(max(FileDate));
    %     month_all = (datetime(Y(date_ini),M(date_ini),1):1:datetime(Y(date_end),1+M(date_end),1))';
    %     [~,~,x] = datevec(month_all);      month_all(x~ = 1) = [];
    %%
    [Yini,Mini,~] = datevec(min(FileDate));   [Ymax,Mmax,~] = datevec(max(FileDate));
    if Mmax == 12;    Ymax = Ymax+1;    Mmax = 1; end
    month_all  = (datetime(Yini,Mini,1):1:datetime(Ymax,Mmax+2,1))';
    [~,~,x]    = datevec(month_all);         month_all(x~=1) = [];
    month_tick = month_all(1:6:end);

    %% ....................................................................
    w1 = 0.32;                 w2 = 0.4;                     w3 = w1:((w2-w1)/4):w2; %LOD
    figure('color','white','position',[100,300,900,500]);       hold on;
    y = [GCCeight-GCCeightStd,(2.*GCCeightStd)];
    h  =  area(FileEight,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.8 .8 .8],'EdgeColor',[.8 .8 .8]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);

    % set(gcf,'DefaultAxesColorOrder',colorscheme);
    scatter(FileDateAll,GCCall','.','MarkerFaceColor',colorscheme(1,:),'MarkerFaceAlpha',0.7);
    plot(FileEight,GCCeight','LineStyle','-');
    datetick('x','mmm');                  ylabel('GCC');       box on;
    xlim([month_all(1) month_all(end)]);                     ylim([w1 w2]);

    h = gca;            h.XAxis.MinorTick = 'on';        h.XAxis.MinorTickValues = month_all(1:end);
    set(gca,'XTick',month_tick,'XTickLabel',datestr(month_tick,'mmm'),'YTick',w3,'YAxisLocation','left','FontSize',12,'XMinorGrid','on');
    xtickangle(0);        ax2  =  gca;                            box on;
    set(ax2,'XColor','k','YColor',[0.35 0.35 0.35],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'GCC'},'FontSize',12,'Color',[0.35 0.35 0.35]); box on;
    pause(2);             xtickangle(0);                           grid on;

    %% ....................................................................
    w1 = 0;         w2 = 25.0;           w3 = w1:((w2-w1)/3):w2; %LOD
    figure('color','white','position',[100,300,900,500]);       hold on;
    y = [ExGREENeight-ExGREENeightStd,(2.*ExGREENeightStd)];
    h  =  area(FileEight,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.8 .8 .8],'EdgeColor',[.8 .8 .8]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);

    scatter(FileDateAll,ExGREENall','.','MarkerFaceColor',colorscheme(3,:),'MarkerFaceAlpha',0.7);
    plot(FileEight,ExGREENeight','LineStyle','-');
    datetick('x','mmm');    ylabel('ExGREEN');     box on;
    xlim([month_all(1) month_all(end)]);      ylim([w1 w2]);

    h = gca;            h.XAxis.MinorTick = 'on';        h.XAxis.MinorTickValues = month_all(1:end);
    set(gca,'XTick',month_tick,'XTickLabel',datestr(month_tick,'mmm'),'YTick',w3,'YAxisLocation','left',...
        'FontSize',12,'XMinorGrid','on','XColor','k','YColor',[0.35 0.35 0.35],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'ExGREEN'},'FontSize',12,'Color',[0.35 0.35 0.35]); box on;      xtickangle(0);

    %%
    w1 = 0.3;                 w2 = 1.1;                   w3 = w1:((w2-w1)/4):w2; %LOD
    figure('color','white','position',[100,300,900,500]);       hold on;
    y = [GCCeight-GCCeightStd,(2.*GCCeightStd)]./max(GCCeight,[],'omitnan');
    h  =  area(FileEight,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',colorscheme(1,:),'EdgeColor',colorscheme(1,:));       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);          alpha(h,.5);
    y = [ExGREENeight-ExGREENeightStd,(2.*ExGREENeightStd)]./max(ExGREENeight,[],'omitnan');
    h  =  area(FileEight,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',colorscheme(6,:),'EdgeColor',colorscheme(6,:));       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);          alpha(h,.5);

    hl1 = line(FileEight,ExGREENeight./max(ExGREENeight,[],'omitnan')','LineStyle','none','Marker','o','color',colorscheme(6,:),'markersize',4);
    hl3 = line(FileEight,GCCeight./max(GCCeight,[],'omitnan')','LineStyle','none','Marker','o','color',colorscheme(1,:),'markersize',4);
    hl2 = line(FileEight,ExGREENeight./max(ExGREENeight,[],'omitnan')','LineStyle','-','color',colorscheme(6,:),'LineWidth',2);
    hl4 = line(FileEight,GCCeight./max(GCCeight,[],'omitnan')','LineStyle','-','color',colorscheme(1,:),'LineWidth',2);

    % datetick('x','mmm');    ylabel('ExGREEN');          box on;
    % xlim([month_all(1) month_all(end)]);            ylim([w1 w2]);
    % set(gca,'XTick',month_tick,'XTickLabel',datestr(month_tick,'mmm'),'YTick',w3,'YAxisLocation','left','FontSize',12);
    % ax2  =  gca;                                      box on;
    % set(ax2,'XColor','k','YColor',[0.35 0.35 0.35],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'Index'},'FontSize',12,'Color',[0.35 0.35 0.35]); box on;
    legend([hl2,hl4],'ExGREEN','GCC','color','none');      legend box off

    h = gca;            h.XAxis.MinorTick = 'on';        h.XAxis.MinorTickValues = month_all(1:end);
    set(gca,'XTick',month_tick,'XTickLabel',datestr(month_tick,'mmm'),'YTick',w3,'YAxisLocation','left','FontSize',12,'XMinorGrid','on');
    xtickangle(0);        ax2  =  gca;                            box on;
    % set(ax2,'XColor','k','YColor',[0.35 0.35 0.35],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'GCC'},'FontSize',12,'Color',[0.35 0.35 0.35]); box on;
    pause(2);             xtickangle(0);                           grid on;

end

%% ........................................................................
if flag_color_figure_roi == 1
    % ik = 2545;
    ik = 1342;
    load 'ROI_UofT02_20240101.mat';
    [ImageFile] = imread([FolderImages,slash,listOfFileNames{ik}],'JPG');
    %     FileName = 'UofT02_overstory_oblique_03_2019_04_26_22_00_00.jpg';
    %     [ImageFile] = imread([FolderImages,slash,FileName],'JPG');
    %Cut the top of the image if has sky
    ImageFile   =  ImageFile(1:end,1:end,:);
    PixelCut = 1;
    REDsample   =  (ImageFile(PixelCut:end,1:end,1));
    GREENsample =  (ImageFile(PixelCut:end,1:end,2));
    BLUEsample  =  (ImageFile(PixelCut:end,1:end,3));
    ImageFile = cat(3,uint8(REDsample),uint8(GREENsample),uint8(BLUEsample));
    % %     ia = Red+Green+Blue;
    % %     GCC_matrix      = Green./ia;                GCC_matrix(isinf(GCC_matrix)) = NaN;
    % %     GCC_matrix_ROI  = GCC_matrix.*NaN;
    % %     ExGREEN_matrix     = Green./Red;               ExGREEN_matrix(isinf(ExGREEN_matrix)) = NaN;
    % %     ExGREEN_matrix_ROI = ExGREEN_matrix.*NaN;
    %
    figure('color','white');
    imshow(ImageFile.*1.1);      axis image;                 axis off          % Remove axis ticks and numbers
    text (50,50,['UofT02 camera ' datestr(FileDateAll(ik))],'FontSize',18);
    %                                     h = drawpolygon('Position',ROIa);
    hold on;
    color_mtx = jet(length(ROI));
    for ix = 1:length(ROI)
        [B] = bwboundaries(int16(ROI{ix}.poly),'noholes');      Boundary{ix}.poly = B;
    end
    for ix = 1:length(Boundary)
        boundary = cell2mat(Boundary{ix}.poly);
        plot(boundary(:,2), boundary(:,1), 'color',color_mtx(ix,:), 'LineWidth', 3)
        pgon = polyshape(boundary(:,2), boundary(:,1));
        [x,y] = centroid(pgon);
        text(x,y,num2str(ix),'color',color_mtx(ix,:),'FontSize',18);
        ROI{ix}.centroidX = x;                                  ROI{ix}.centroidY = y;
    end
    pause(2)

    %%
    w1 = 0.32;       w2 = 0.4;         w3 = w1:((w2-w1)/4):w2; %LOD
    y1 = 0;             y2 = 100;           y3 = y1:((40-y1)/4):40; %LOD
    figure('color','white','position',[100,300,900,500]);
    hl1 = plot(MeteoDateloc,MeteoTempC,'Color',colorscheme(1,:));     hold on;
    hl2 = plot(MeteoDateloc,MeteoDayLength.*2,'Color',[.5 .5 .5]);
    xlim([month_all(1) month_all(end)]);                            ylim([y1 y2]);
    set(gca,'XTick',month_tick,'XTickLabel',datestr(month_tick,'mmm'),'YTick',y3,'YTickLabel',y3,...
        'YAxisLocation','right','FontSize',10,'FontName','Arial');
    ax1  =  gca;                                  ax1.XAxis.MinorTick = 'on';        ax1.XAxis.MinorTickValues = month_all(1:end);
    set(ax1,'XColor','k','YColor',[0.25 0.25 0.25],'Position',[0.25 0.55 0.50 0.40],'XMinorGrid','on');
    ylabel ({'T_{air}(C)'},'FontSize',10,'Color',[0.25 0.25 0.25],'FontName','Arial'); box on;
    xtickangle(0);                                                      pause(2);
    ax2  =  axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
        'YAxisLocation','right','Color','none','XColor','k','YColor','k');             hold on;

    hl3 = scatter(FileDateAll,GCCall,'.','MarkerEdgeColor',colorscheme(6,:),'MarkerFaceAlpha',0.7);
    datetick('x','mmm');    ylabel('GCC');                   box off;                      hold on;
    xlim([month_all(1) month_all(end)]);                  ylim([w1 w2]);
    ax2.XAxis.MinorTick = 'on';        ax2.XAxis.MinorTickValues = month_all(1:end);
    set(gca,'XTick',month_tick,'XTickLabel',datestr(month_tick,'YYYY'),'YTick',w3,'YAxisLocation','left',...
        'FontSize',10,'XMinorGrid','on','XColor','k','YColor',[0.35 0.35 0.35],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'GCC'},'FontSize',10,'Color',[0.35 0.35 0.35],'FontName','Arial'); box on;
    grid on;                                        xtickangle(0);
    legend([hl1,hl2,hl3],'T_{air}','Day length','GCC','Location','south','Orientation','horizontal');   legend('boxoff');

    %%
    w1 = -5.;         w2 = 25.0;           w3 = w1:((w2-w1)/3):w2; %LOD
    y1 = 0;             y2 = 100;           y3 = y1:((40-y1)/4):40; %LOD
    figure('color','white','position',[100,300,900,500]);    hold on;
    hl1 = plot(MeteoDateloc,MeteoTempC,'Color',colorscheme(1,:));     hold on;
    hl2 = plot(MeteoDateloc,MeteoDayLength,'Color',[.5 .5 .5]);
    xlim([month_all(1) month_all(end)]);                            ylim([y1 y2]);
    set(gca,'XTick',month_tick,'XTickLabel',datestr(month_tick,'mmm'),'YTick',y3,'YTickLabel',y3,...
        'YAxisLocation','right','FontSize',11,'FontName','Arial');
    ax1  =  gca;                                  ax1.XAxis.MinorTick = 'on';        ax1.XAxis.MinorTickValues = month_all(1:end);
    set(ax1,'XColor','k','YColor',[0.25 0.25 0.25],'Position',[0.25 0.55 0.50 0.40],'XMinorGrid','on');
    ylabel ({'T_{air}(C)'},'FontSize',12,'Color',[0.25 0.25 0.25],'FontSize',11,'FontName','Arial'); box on;
    xtickangle(0);                                                      pause(2);
    ax2  =  axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
        'YAxisLocation','right','Color','none','XColor','k','YColor','k');             hold on;

    hl3 = scatter(FileDateAll,ExGREENall,'.','MarkerEdgeColor',colorscheme(6,:),'MarkerFaceAlpha',0.7);
    datetick('x','mmm');    ylabel('ExGREEN');                   box on;                      hold on;
    xlim([month_all(1) month_all(end)]);                  ylim([w1 w2]);
    ax2.XAxis.MinorTick = 'on';        ax2.XAxis.MinorTickValues = month_all(1:end);
    set(gca,'XTick',month_tick,'XTickLabel',datestr(month_tick,'YYYY'),'YTick',w3,'YAxisLocation','left',...
        'FontSize',12,'XMinorGrid','on','XColor','k','YColor',[0.35 0.35 0.35],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'ExGREEN'},'FontSize',12,'Color',[0.35 0.35 0.35],'FontSize',11,'FontName','Arial'); box on;
    grid on;                                        xtickangle(0);
    legend([hl1,hl2,hl3],'T_{air}','Day length','ExGREEN','Location','south','Orientation','horizontal');   legend boxoff;

    %% ....................................................................
    color_mxt=flipud(jet(length(ROI)+1));
    y1 = 0;             y2 = 100;           y3 = y1:((40-y1)/4):40; %LOD
    w1 = 0.32;      	w2 = 0.38;     w3 = w1:((w2-w1)/6):w2;     w4 = w1:((w2-w1)/(length(ROI)+5)):w2;%LOD

    figure('color','white','position',[100,300,1200,800]);       hold on;
    plot(MeteoDateloc,MeteoTempC,'Color',[ 0.7 0.7 0.7]);
    plot(MeteoDateloc,MeteoDayLength.*2,'Color',[ 0.5 0.5 0.5]);
    % bar(MeteoDateloc,MeteoPrecipAmountmm,1,'FaceColor',[ 0.4 0.4 0.4],'EdgeColor',[ 0.4 0.4 0.4]);
    xlim([month_all(1) month_all(end)]);                        ylim([y1 y2]);
    set(gca,'XTick',month_tick,'XLim',[month_tick(1) month_tick(end)],...
        'XTickLabel',datestr(month_tick,'mmm'),...
        'YTick',w3,'YAxisLocation','left','YTick',y3,'YTickLabel',y3,...
        'YAxisLocation','right','FontSize',11,'FontName','Arial');
    ax1  =  gca;                                                box on;
    set(ax1,'XColor','k','YColor',[0.25 0.25 0.25],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'Day Length x 2';'T_{air}(C)'},'FontSize',12,'Color',[0.25 0.25 0.25],'FontSize',11,'FontName','Arial'); box on;

    ax2  =  axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
        'YAxisLocation','right','Color','none','XColor','k','YColor','k');

    hold on;
    for ix = 1:length(ROI)
        GCCtime_day = AM_fill_plus(FileDayGCC(ix).ROIavg);     %GCCtime_day(GCCtime_day>3.4) = NaN;
        GCCtime_eight = AM_fill_plus(FileEightGCC(ix).ROIavg); %GCCtime_eight(GCCtime_eight>3.4) = NaN;
        scatter(FileDay,GCCtime_day,'.','MarkerEdgeColor',color_mxt(ix,:),'MarkerFaceAlpha',0.7);
        plot(FileEight,GCCtime_eight,'-','color',color_mxt(ix,:));
        %                  plot(FileDay,GCCtimeSM,'-','color',color_mxt(ix,:));
        text(month_all(1)+days(20),w4(length(ROI)+3-ix),num2str(ix),'FontSize',6)
        plot(month_all(1)+days(10),w4(length(ROI)+3-ix),'.','MarkerSize',20,'color',color_mxt(ix,:),'LineWidth',2)
        hold on
    end
    %              plot(listOfFileDates(ind),SampleTableIndexAll(ind),'.k');
    datetick('x','mmm-YYYY');    ylabel('GCC camera 02');          box on;
    xlim([month_all(1) month_all(end)]);            ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XLim',[month_tick(1) month_tick(end)],...
        'XTickLabel',[''],'YTick',w3,'YAxisLocation','left',...
        'YTick',w3,'YAxisLocation','left','FontSize',12,'FontName','Arial');
    % ax2  =  gca;                                      box on;
    set(ax2,'XColor','k','YColor',[0.35 0.35 0.35],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'GCC'},'FontSize',12,'Color',[0.35 0.35 0.35],'FontSize',12,'FontName','Arial'); box on;
    hl2  =  line(FileEight,AM_fill_plus(GCCeight),'LineStyle','-','color',[.0 .0 .0],'LineWidth',2);
    xtickangle(0);

    %% ....................................................................
    w1 = -5;    w2 = 25;       w3 = w1:((w2-w1)/4):w2;        w4 = w1:(w2-w1)/(length(ROI)+1):w2;
    y1 = 0;             y2 = 100;           y3 = y1:((40-y1)/4):40; %LOD

    figure('color','white','position',[100,300,1200,800]);       hold on;
    plot(MeteoDateloc,MeteoTempC,'Color',[ 0.7 0.7 0.7]);
    plot(MeteoDateloc,MeteoDayLength.*2,'Color',[ 0.5 0.5 0.5]);
    % bar(MeteoDateloc,MeteoPrecipAmountmm,1,'FaceColor',[ 0.4 0.4 0.4],'EdgeColor',[ 0.4 0.4 0.4]);
    xlim([month_all(1) month_all(end)]);                        ylim([y1 y2]);
    set(gca,'XTick',month_tick,'XLim',[month_tick(1) month_tick(end)],...
        'XTickLabel',datestr(month_tick,'mmm'),...
        'YTick',w3,'YAxisLocation','left','YTick',y3,'YTickLabel',y3,...
        'YAxisLocation','right','FontSize',11,'FontName','Arial');
    ax1  =  gca;                                                box on;
    set(ax1,'XColor','k','YColor',[0.25 0.25 0.25],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'DayLenghtx2';'T_{air}(C)'},'FontSize',12,'Color',[0.25 0.25 0.25],'FontSize',11,'FontName','Arial'); box on;

    ax2  =  axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
        'YAxisLocation','right','Color','none','XColor','k','YColor','k');

    hold on;
    color_mxt=flipud(jet(length(ROI)+1));
    for ix = 1:length(ROI)
        ExGREENtime_day = AM_fill_plus(FileDayExGREEN(ix).ROIavg);     %ExGREENtime_day(ExGREENtime_day>3.4) = NaN;
        ExGREENtime_eight = AM_fill_plus(FileEightExGREEN(ix).ROIavg); %ExGREENtime_eight(ExGREENtime_eight>3.4) = NaN;
        scatter(FileDay,ExGREENtime_day,'.','MarkerEdgeColor',color_mxt(ix,:),'MarkerFaceAlpha',0.7);
        plot(FileEight,ExGREENtime_eight,'-','color',color_mxt(ix,:));
        %                  plot(FileDay,ExGREENtimeSM,'-','color',color_mxt(ix,:));
        text(month_all(1)+days(20),w4(length(ROI)+3-ix),num2str(ix),'FontSize',6)
        plot(month_all(1)+days(10),w4(length(ROI)+3-ix),'.','MarkerSize',20,'color',color_mxt(ix,:),'LineWidth',2)
        hold on
    end
    %              plot(listOfFileDates(ind),SampleTableIndexAll(ind),'.k');
    datetick('x','mmm');    ylabel('ExGREEN camera 02');          box on;
    xlim([month_all(1)-30 month_all(end)]);            ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XLim',[month_tick(1) month_tick(end)],...
        'XTickLabel',[''],'YTick',w3,'YAxisLocation','left',...
        'YTick',w3,'YAxisLocation','left','FontSize',12,'FontName','Arial');
    %     ax2  =  gca;                                      box on;
    set(ax2,'XColor','k','YColor',[0.35 0.35 0.35],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'ExGREEN'},'FontSize',12,'Color',[0.35 0.35 0.35],'FontSize',12,'FontName','Arial'); box on;

    hl2  =  line(FileEight,AM_fill_plus(ExGREENeight),'LineStyle','-','color',[.0 .0 .0],'LineWidth',2);
    xtickangle(0);

end

%% ........................................................................
if flag_color_figure_roi_std == 1
    colorscheme = othercolor('Paired12',12);
    % color_mtx_light = [.8 .8 .9;  .9 .8 .8;     .8 .9 .8;     .8 .9 .8];
    %     color_mtx       = [.5 .5 .9;  .9 .5 .5;     .5 .9 .5;     .5 .9 .5];

    w1 = 0.3;      w2 = 0.5;      w3 = w1:((w2-w1)/4):w2;         w4 = w1:((w2-w1)/20):w2;%LOD
    y1 = 0;          y2=100;        y3 = y1:(30-y1)/3:30;
    figure('color','white','position',[100,300,1200,800]);    hold on;
    plot(MeteoDateloc,MeteoTempC,'Color',[ 0.7 0.7 .7]);
    plot(MeteoDateloc,MeteoDayLength.*2,'Color',[ 0.4 0.4 0.4]);
    xlim([month_all(1) month_all(end)]);            ylim([y1 y2]);
    set(gca,'XTick',month_tick,'XTickLabel',datestr(month_tick,'mmm'),'YTick',y3,'YTickLabel',y3,...
        'YAxisLocation','right','FontSize',11,'FontName','Arial');
    ax1  =  gca;                                      box on;
    set(ax1,'XColor','k','YColor',[0.35 0.35 0.35],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'Precip (mm)';'T_{air}(C)'},'FontSize',12,'Color',[0.25 0.25 0.25],'FontSize',11,'FontName','Arial'); box on;

    ax2  =  axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
        'YAxisLocation','right','Color','none','XColor','k','YColor','k');
    hold on;

    ix = 1;         count = 1;
    y = [FileDayGCC(ix).ROIavg-FileDayGCC(ix).ROIstd,2.*FileDayGCC(ix).ROIstd];
    h  =  area(FileDay,y);          set(gca,'Layer','top');
    set(h(2),'FaceColor',colorscheme(count,:),'EdgeColor',colorscheme(count,:));
    set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0.33);        hold on;

    ix = 5;         count = 2;
    y = [FileDayGCC(ix).ROIavg-FileDayGCC(ix).ROIstd,2.*FileDayGCC(ix).ROIstd];
    h  =  area(FileDay,y);          set(gca,'Layer','top');
    set(h(2),'FaceColor',colorscheme(count,:),'EdgeColor',colorscheme(count,:));
    set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0.33);        hold on;

    ix = 11;        count = 3;
    y = [FileDayGCC(ix).ROIavg-FileDayGCC(ix).ROIstd,2.*FileDayGCC(ix).ROIstd];
    h  =  area(FileDay,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',colorscheme(count,:),'EdgeColor',colorscheme(count,:));
    set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0.3);

    datetick('x','dd');                                ylabel('GCC');          box on;
    xlim([month_all(1) month_all(end)]); ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XTickLabel',[],'YTick',w3,'YAxisLocation','left','FontSize',11,'FontName','Arial');
    ax2  =  gca;                                      box on;
    set(ax2,'XColor','k','YColor',[0.35 0.35 0.35],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'GCC'},'FontSize',11,'FontName','Arial','Color',[0.35 0.35 0.35]); box on;

    hold on;                ix=1;
    for count = 1:3
        ix(count==1) = 1;   ix(count==2) = 5;   ix(count==3) = 4;
        iy = [FileDayGCC(ix).ROIavg]';
        h1  =  line(FileDay,iy,'LineStyle','none','Marker','o','markersize',2,'color',colorscheme(count,:));

        hl7  =  line(FileDay,[FileDayGCC(ix).ROIavg],'LineStyle','-','color',colorscheme(count,:));
        text(FileDay(70),w4(20-count),num2str(ix))
        plot(FileDay(50),w4(20-count),'.','MarkerSize',20,'color',colorscheme(count,:),'LineWidth',2)
    end
    hl2  =  line(FileEight,FileEightGCC(ix).ROIavg,'LineStyle','-','LineWidth',2,'color',[.0 .0 .0]);
    xtickangle(0);

    %% ..........................................................................
    w1 = -40;	w2 = 100;      w3 = w1:((w2-w1)/4):w2;      w4 = w1:((w2-w1)/20):w2;
    y1 = 0;             y2=100;        y3 = y1:(30-y1)/3:30;
    colorscheme = othercolor('Paired12',10);

    figure('color','white','position',[100,300,1200,800]);    hold on;
    plot(MeteoDateloc,MeteoTempC,'Color',[ 0.9 0.7 0.]);
    plot(MeteoDateloc,MeteoDayLength,'Color',[ 0.4 0.4 0.4]);
    set(gca,'XTick',month_tick,'XTickLabel',datestr(month_tick,'mmm'),'YTick',y3,'YTickLabel',y3,...
        'YAxisLocation','right','FontSize',11,'FontName','Arial',...
        'Xlim',[month_all(1) month_all(end)],'Ylim',[y1 y2]);
    ax1  =  gca;                                      box on;
    set(ax1,'XColor','k','YColor',[0.35 0.35 0.35],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'T_{air}(C)'},'FontSize',12,'Color',[0.25 0.25 0.25],'FontSize',11,'FontName','Arial'); box on;

    ax2  =  axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
        'YAxisLocation','right','Color','none','XColor','k','YColor','k');
    hold on;
    ix = 1;     count = 1;
    y = [FileDayExGREEN(ix).ROIavg-FileDayExGREEN(ix).ROIstd,2.*FileDayExGREEN(ix).ROIstd];
    h  =  area(FileDay,y);          set(gca,'Layer','top');
    set(h(2),'FaceColor',colorscheme(count,:),'EdgeColor',colorscheme(count,:));
    set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0.33);        hold on;

    ix = 5;     count = 2;
    y = [FileDayExGREEN(ix).ROIavg-FileDayExGREEN(ix).ROIstd,2.*FileDayExGREEN(ix).ROIstd];
    h  =  area(FileDay,y);          set(gca,'Layer','top');
    set(h(2),'FaceColor',colorscheme(count,:),'EdgeColor',colorscheme(count,:));
    set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0.33);        hold on;

    ix = 4;     count = 3;
    y = [FileDayExGREEN(ix).ROIavg-FileDayExGREEN(ix).ROIstd,2.*FileDayExGREEN(ix).ROIstd];
    h  =  area(FileDay,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',colorscheme(count,:),'EdgeColor',colorscheme(count,:));
    set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0.3);

    datetick('x','mmm');    ylabel('ExGREEN');          box on;
    xlim([month_all(1) month_all(end)]);            ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XTickLabel',[],'YTick',w3,'YAxisLocation','left','FontSize',11,'FontName','Arial');
    ax2  =  gca;                                      box on;
    set(ax2,'XColor','k','YColor',[0.35 0.35 0.35],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'ExGREEN'},'FontSize',11,'FontName','Arial','Color',[0.35 0.35 0.35]); box on;

    hold on;
    for count = 1:3
        ix(count==1) = 1;   ix(count==2) = 5;   ix(count==3) = 4;
        iy = [FileDayExGREEN(ix).ROIavg]';
        h1  =  line(FileDay,iy,'LineStyle','none','Marker','o','markersize',2,'color',colorscheme(count,:));

        hl7  =  line(FileDay,[FileDayExGREEN(ix).ROIavg],'LineStyle','-','color',colorscheme(count,:));
        text(FileDay(60),w4(19-count),num2str(ix))
        plot(FileDay(50),w4(19-count),'.','MarkerSize',20,'color',colorscheme(count,:),'LineWidth',2)
    end
    hl2  =  line(FileEight,FileEightExGREEN(count).ROIavg,'LineStyle','-','LineWidth',2,'color',[.0 .0 .0]);
    hl3  =  line([datetime(2022,4,29);datetime(2022,4,29)],[w1;w2],'LineStyle',':','LineWidth',1,'color',[.0 .0 .0]);
    %     hl3  =  line(FileEight,FileEightExGREEN(4).ROIavg,'LineStyle','-','LineWidth',2,'color',[.0 .0 .8]);
    set(gca,'XTick',month_tick,'XTickLabel',[],'YTick',w3,'YAxisLocation','left','FontSize',11,'FontName','Arial',...
        'Xlim',[month_all(1) month_all(end)],'Ylim',[w1 w2]);
    xtickangle(0);


    %% ..........................................................................
    colorscheme = othercolor('Paired12',10);
    w1 = -40;                 w2 = 100;                   w3 = w1:((w2-w1)/3):w2; %LOD
    figure('color','white','position',[100,300,1200,800]);    hold on;
    plot(MeteoDateloc,MeteoTempC,'Color',[ 0.9 0.7 0.]);
    bar(MeteoDateloc,MeteoPrecipAmountmm,1,'FaceColor',[ 0.4 0.4 0.4],'EdgeColor',[ 0.4 0.4 0.4]);
    xlim([month_all(1) month_all(end)]);            ylim([y1 y2]);
    set(gca,'XTick',month_tick,'XTickLabel',datestr(month_tick,'mmm'),'YTick',y3,'YTickLabel',y3,...
        'YAxisLocation','right','FontSize',11,'FontName','Arial');
    ax1  =  gca;                                      box on;
    set(ax1,'XColor','k','YColor',[0.35 0.35 0.35],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'T_{air}(C)'},'FontSize',12,'Color',[0.25 0.25 0.25],'FontSize',11,'FontName','Arial'); box on;

    ax2  =  axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
        'YAxisLocation','right','Color','none','XColor','k','YColor','k');

    hold on;
    ix = 1;      count = 1;
    y = [FileDayExGREEN(ix).ROImax-FileDayExGREEN(ix).ROIstd,2.*FileDayExGREEN(ix).ROIstd];
    h  =  area(FileDay,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.8 .8 .9],'EdgeColor',[.8 .8 .9]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0.33);
    hold on;
    ix = 5;          count = 2;
    y = [FileDayExGREEN(ix).ROImax-FileDayExGREEN(ix).ROIstd,2.*FileDayExGREEN(ix).ROIstd];
    h  =  area(FileDay,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.8 .9 .8],'EdgeColor',[.8 .9 .8]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0.33);
    hold on;

    ix = 4;         count = 3;
    y = [FileDayExGREEN(ix).ROImax-FileDayExGREEN(ix).ROIstd,2.*FileDayExGREEN(ix).ROIstd];
    h  =  area(FileDay,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.9 .8 .8],'EdgeColor',[.9 .8 .8]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0.3);

    datetick('x','mmm');    ylabel('ExGREEN');          box on;
    xlim([month_all(1) month_all(end)]);            ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XTickLabel',[],'YTick',w3,'YAxisLocation','left','FontSize',11,'FontName','Arial');
    ax2  =  gca;                                      box on;
    set(ax2,'XColor','k','YColor',[0.35 0.35 0.35],'Position',[0.25 0.55 0.50 0.40]);
    ylabel ({'ExGREEN_{max}'},'FontSize',11,'FontName','Arial','Color',[0.35 0.35 0.35]); box on;

    hold on;
    for count = 1:3
        ix(count==1) = 1;   ix(count==2) = 5;   ix(count==3) = 11;
        iy = [FileDayExGREEN(ix).ROImax]';
        h1  =  line(FileDay,iy,'LineStyle','none','Marker','o','markersize',2,'color',color_mtx(count,:));

        hl7  =  line(FileDay,[FileDayExGREEN(ix).ROImax],'LineStyle','-','color',color_mtx(count,:));
        text(FileDay(50)-25,w4(10-count),num2str(ix))
        plot(FileDay(40)-25,w4(10-count),'.','MarkerSize',20,'color',color_mtx(count,:),'LineWidth',2)
    end
    hl2  =  line(FileDay,ExGREENdayMax','LineStyle','-','LineWidth',2,'color',[.0 .0 .0]);
    xtickangle(0);
end


%%
% [Y,M,D,HR,MI,SS] = datevec(FileDate);
% % tableUofT02hour = table(Y,M,D,HR,MI,SS,...
% %     GCC,FileDateGCCroiA,FileDateGCCroiB,FileDateGCCroiC,FileDateGCCroiD,FileDateGCCroiE,FileDateGCCroiF,...
% %     ExGREEN,FileDateExGREENroiA,FileDateExGREENroiB,FileDateExGREENroiC,FileDateExGREENroiD,FileDateExGREENroiE,FileDateExGREENroiF);
% %
% % tableUofT02hour.Properties.VariableNames = {'YYYY' 'MM' 'DD' 'HR' 'MI' 'SS' 'GCC' 'GCCroiA' 'GCCroiB' 'GCCroiC' 'GCCroiD' 'GCCroiE' 'GCCroiF' 'ExGREEN' 'ExGREENroiA' 'ExGREENroiB' 'ExGREENroiC' 'ExGREENroiD' 'ExGREENroiE' 'ExGREENroiF'};
% % writetable (tableUofT02hour,'out/tableUofT02hour.dat');

GCC1 = ([FileDayGCC(1).ROImax]);      GCC2 = ([FileDayGCC(2).ROImax]);
GCC3 = ([FileDayGCC(3).ROImax]);      GCC4 = ([FileDayGCC(4).ROImax]);
GCC5 = ([FileDayGCC(5).ROImax]);      GCC6 = ([FileDayGCC(6).ROImax]);
GCC7 = ([FileDayGCC(7).ROImax]);

ExGREEN1 = ([FileDayExGREEN(1).ROImax]);    ExGREEN2 = ([FileDayExGREEN(2).ROImax]);
ExGREEN3 = ([FileDayExGREEN(3).ROImax]);    ExGREEN4 = ([FileDayExGREEN(4).ROImax]);
ExGREEN5 = ([FileDayExGREEN(5).ROImax]);    ExGREEN6 = ([FileDayExGREEN(6).ROImax]);
ExGREEN7 = ([FileDayExGREEN(7).ROImax]);

tableUofT02day = table(Yday,Mday,Dday,GCCdayMax,GCC1,GCC2,GCC3,GCC4,GCC5,GCC6,GCC7,...
    ExGREENdayMax,ExGREEN1,ExGREEN2,ExGREEN3,ExGREEN4,ExGREEN5,ExGREEN6,ExGREEN7);
tableUofT02day.Properties.VariableNames = {'YYYY' 'MM' 'DD' 'GCC' 'GCCroi1' 'GCCroi2' 'GCCroi3' 'GCCroi4' 'GCCroi5' 'GCCroi6' 'GCCroi7' 'ExGREEN' 'ExGREENroi1' 'ExGREENroi2' 'ExGREENroi3' 'ExGREENroi4' 'ExGREENroi5' 'ExGREENroi6' 'ExGREENroi7'};
writetable (tableUofT02day,'out/tableUofT02dayMax.dat');

GCC1 = ([FileDayGCC(1).ROIavg]);      GCC2 = ([FileDayGCC(2).ROIavg]);
GCC3 = ([FileDayGCC(3).ROIavg]);      GCC4 = ([FileDayGCC(4).ROIavg]);
GCC5 = ([FileDayGCC(5).ROIavg]);      GCC6 = ([FileDayGCC(6).ROIavg]);
GCC7 = ([FileDayGCC(7).ROIavg]);

ExGREEN1 = ([FileDayExGREEN(1).ROIavg]);    ExGREEN2 = ([FileDayExGREEN(2).ROIavg]);
ExGREEN3 = ([FileDayExGREEN(3).ROIavg]);    ExGREEN4 = ([FileDayExGREEN(4).ROIavg]);
ExGREEN5 = ([FileDayExGREEN(5).ROIavg]);    ExGREEN6 = ([FileDayExGREEN(6).ROIavg]);
ExGREEN7 = ([FileDayExGREEN(7).ROIavg]);

tableUofT02day = table(Yday,Mday,Dday,GCCday,GCC1,GCC2,GCC3,GCC4,GCC5,GCC6,GCC7,...
    ExGREENday,ExGREEN1,ExGREEN2,ExGREEN3,ExGREEN4,ExGREEN5,ExGREEN6,ExGREEN7);
tableUofT02day.Properties.VariableNames = {'YYYY' 'MM' 'DD' 'GCC' 'GCCroi1' 'GCCroi2' 'GCCroi3' 'GCCroi4' 'GCCroi5' 'GCCroi6' 'GCCroi7' 'ExGREEN' 'ExGREENroi1' 'ExGREENroi2' 'ExGREENroi3' 'ExGREENroi4' 'ExGREENroi5' 'ExGREENroi6' 'ExGREENroi7'};
writetable (tableUofT02day,'out/tableUofT02day.dat');

% ........................................................................
%% Meteo
% ........................................................................
if flag_meteo==1
    [FileDayY,FileDayM,FileDayD] =  datevec(FileDay); FileDayJD = day(FileDay,'dayofyear');
    [MeteoY,MeteoM,MeteoD,MeteoHR,~,~] =  datevec(MeteoDateloc);
    [~,~,UofT02meteoDayLength] = AM_solar_rad(FileDayJD,12,lat,lon);

    % UofT02meteoStnPresskPa = interp1(MeteoDateloc,MeteoStnPresskPa,FileDay);
    UofT02meteoPrec = interp1(MeteoDateloc(MeteoHR==0),MeteoPrecipAmountmm(MeteoHR==0),FileDay);
    UofT02meteoTmin = interp1(MeteoDateloc(MeteoHR==0),MeteoTempC(MeteoHR==0),FileDay);
    UofT02meteoTmax = interp1(MeteoDateloc(MeteoHR==14),MeteoTempC(MeteoHR==14),FileDay);
    UofT02meteoRH   = interp1(MeteoDateloc(MeteoHR==0),MeteoRelHum(MeteoHR==0),FileDay);

    %% .........................................................................
    ROIselect = 1;      ROItext = '_{roi:Acer sp.}';

    figure('color','white');       hold on;
    y1 = .28;    y2 = .46;                y3 = y1:((y2-y1)/12):y2;    y4 = y1:((y2-y1)/3):y2;
    x1 = 98;     x2 = 104;               x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/3):x2;

    x1 = 10;     x2 = 16;              x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/3):x2;
    subplot(2,2,1);                     hold on;
    x = UofT02meteoDayLength;              y = FileDayGCC(ROIselect).ROIavg;
    ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);                 y = y(ind);
    [~,r2,~,p] = AM_compute_regression(x,y,[.4 0 .5],1);
    hold on;    AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(13),['pval = ',num2str(p(1,1),2.1),' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(11),['GCC = ',num2str(p(1,1),2.1), 'SW_{in}',num2str(p(1,2),2.1)],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('Day Length (hr)','color','k');	ylabel(['GCC' ROItext],'color','k');
    xtickangle(0);

    x1 = -10;     x2 = 20;                x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/3):x2;
    subplot(2,2,2);                     hold on;
    x = UofT02meteoTmin;                   y = FileDayGCC(ROIselect).ROIavg;
    ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);       y = y(ind);
    [~,r2,~,p] = AM_compute_regression(x,y,[.4 0 .5],1);
    hold on;    AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(11),['GCC = ',num2str(p(1,1),2.1), 'SW_{in}',num2str(p(1,2),2.1)],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('T_{min} (degC)','color','k');	ylabel(['GCC' ROItext],'color','k');
    xtickangle(0);

    x1 = 0;     x2 = 30;                x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/3):x2;
    subplot(2,2,3);                     hold on;
    x = UofT02meteoTmax;                   y = FileDayGCC(ROIselect).ROIavg;
    ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);       y = y(ind);
    [~,r2,~,p] = AM_compute_regression(x,y,[.4 0 .5],1);
    hold on;    AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(11),['GCC = ',num2str(p(1,1),2.1), 'SW_{in}',num2str(p(1,2),2.1)],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('T_{max} (degC)','color','k');	ylabel(['GCC' ROItext],'color','k');
    xtickangle(0);

    x1 = 0;     x2 = 100;                x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/4):x2;
    subplot(2,2,4);                     hold on;
    x = UofT02meteoRH;                   y = FileDayGCC(ROIselect).ROIavg;
    ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);       y = y(ind);
    [~,r2,~,p] = AM_compute_regression(x,y,[.4 0 .5],1);
    hold on;    AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(11),['GCC = ',num2str(p(1,1),2.1), 'SW_{in}',num2str(p(1,2),2.1)],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('RH (%)','color','k');	ylabel(['GCC' ROItext],'color','k');
    xtickangle(0);


    %    subplot(2,3,1);                     hold on;
    % x = UofT02meteoStnPresskPa;                   y = FileDayGCC(ROIselect).ROIavg;
    % ind = ((~isnan(x))&(~isnan(y))&(FileDay>datetime(2023,5,5)));    x = x(ind);                 y = y(ind);
    % [p,r2] = AM_compute_regression(x,y,[.4 0 .5],1);
    % hold on;    AM_bin(x,y,20,2,10,[.9 0 0]);
    % text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % % text(x3(2),y3(13),['pval = ',num2str(p(1,1),2.1),' R^2 = ',num2str(r2,2.1)],'color','k');
    % % text(x3(2),y3(11),['GCC = ',num2str(p(1,1),2.1), 'SW_{in}',num2str(p(1,2),2.1)],'color',[0. 0. 0.],'FontSize',8);
    % set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    % xlabel('Atm Press (Pa)','color','k');	ylabel(['GCC' ROItext],'color','k');
    % xtickangle(0);
    %
    % x1 = 0;     x2 = 15;                x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/3):x2;
    % subplot(2,2,2);                     hold on;
    % x = UofT02meteoPrec;                   y = FileDayGCC(ROIselect).ROIavg;
    % ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);       y = y(ind);
    % [~,r2,~,p] = AM_compute_regression(x,y,[.4 0 .5],1);
    % hold on;    AM_bin(x,y,20,2,10,[.9 0 0]);
    % text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % % text(x3(2),y3(13),['pval = ',num2str(p(1,1),2.1),' R^2 = ',num2str(r2,2.1)],'color','k');
    % set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    % xlabel('precip (mm day^-^1)','color','k');	ylabel(['GCC' ROItext],'color','k');
    % xtickangle(0);

    %% .........................................................................
    colorscheme = othercolor('Paired12',12);
    ROIselect = 5;      ROItext = '_{roi:Pinus sp.}';     count = 2;

    figure('color','white')
    x1 = 10;     x2 = 16;              x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/3):x2;
    subplot(2,2,1);                     hold on;
    x = UofT02meteoDayLength;              y = FileDayGCC(ROIselect).ROIavg;
    ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);                 y = y(ind);
    [~,r2,~,p] = AM_compute_regression(x,y,[.4 0 .5],1);
    hold on;    AM_bin(x,y,20,2,10,colorscheme(count,:));
    text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(13),['pval = ',num2str(p(1,1),2.1),' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(11),['GCC = ',num2str(p(1,1),2.1), 'SW_{in}',num2str(p(1,2),2.1)],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('Day Length (hr)','color','k');	ylabel(['GCC' ROItext],'color','k');
    xtickangle(0);

    x1 = -10;     x2 = 20;                x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/3):x2;
    subplot(2,2,2);                     hold on;
    x = UofT02meteoTmin;                   y = FileDayGCC(ROIselect).ROIavg;
    ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);       y = y(ind);
    [~,r2,~,p] = AM_compute_regression(x,y,[.4 0 .5],1);
    hold on;    AM_bin(x,y,20,2,10,colorscheme(count,:));
    text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(11),['GCC = ',num2str(p(1,1),2.1), 'SW_{in}',num2str(p(1,2),2.1)],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('T_{min} (degC)','color','k');	ylabel(['GCC' ROItext],'color','k');
    xtickangle(0);

    x1 = 0;     x2 = 30;                x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/3):x2;
    subplot(2,2,3);                     hold on;
    x = UofT02meteoTmax;                   y = FileDayGCC(ROIselect).ROIavg;
    ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);       y = y(ind);
    [~,r2,~,p] = AM_compute_regression(x,y,[.4 0 .5],1);
    hold on;    AM_bin(x,y,20,2,10,colorscheme(count,:));
    text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(11),['GCC = ',num2str(p(1,1),2.1), 'SW_{in}',num2str(p(1,2),2.1)],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('T_{max} (degC)','color','k');	ylabel(['GCC' ROItext],'color','k');
    xtickangle(0);

    x1 = 0;     x2 = 100;                x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/4):x2;
    subplot(2,2,4);                     hold on;
    x = UofT02meteoRH;                   y = FileDayGCC(ROIselect).ROIavg;
    ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);       y = y(ind);
    [~,r2,~,p] = AM_compute_regression(x,y,[.4 0 .5],1);
    hold on;    AM_bin(x,y,20,2,10,colorscheme(count,:));
    text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(11),['GCC = ',num2str(p(1,1),2.1), 'SW_{in}',num2str(p(1,2),2.1)],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('RH (%)','color','k');	ylabel(['GCC' ROItext],'color','k');
    xtickangle(0);


    %% ........................................................................
    ROIselect = 11;      ROItext = '_{roi:evegreen}';


    figure('color','white','position',[100,300,900,500]);       hold on;
    % y1 = .20;    y2 = .52;                y3 = y1:((y2-y1)/12):y2;    y4 = y1:((y2-y1)/4):y2;
    % x1 = 98;     x2 = 104;               x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/4):x2;
    % subplot(2,3,1);                     hold on;
    % x = UofT02meteoStnPresskPa;                   y = FileDayGCC(ROIselect).ROIavg;
    % ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);                 y = y(ind);
    % [p,r2] = AM_compute_regression(x,y,[.4 0 .5],1);
    % hold on;    AM_bin(x,y,20,2,10,[.9 0 0]);
    % text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % % text(x3(2),y3(13),['pval = ',num2str(p(1,1),2.1),' R^2 = ',num2str(r2,2.1)],'color','k');
    % % text(x3(2),y3(11),['GCC = ',num2str(p(1,1),2.1), 'SW_{in}',num2str(p(1,2),2.1)],'color',[0. 0. 0.],'FontSize',8);
    % set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    % xlabel('Atm Press (Pa)','color','k');	ylabel(['GCC' ROItext],'color','k');
    % xtickangle(0);

    x1 = 11;     x2 = 17;              x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/3):x2;
    subplot(2,3,1);                     hold on;
    x = UofT02meteoDayLength;              y = FileDayGCC(ROIselect).ROIavg;
    ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);                 y = y(ind);
    [~,r2,~,p] = AM_compute_regression(x,y,[.4 0 .5],1);
    hold on;    AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(13),['pval = ',num2str(p(1,1),2.1),' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(11),['GCC = ',num2str(p(1,1),2.1), 'SW_{in}',num2str(p(1,2),2.1)],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('Day Length (hr)','color','k');	ylabel(['GCC' ROItext],'color','k');
    xtickangle(0);

    x1 = 0;     x2 = 15;                x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/3):x2;
    subplot(2,3,2);                     hold on;
    x = UofT02meteoPrec;                   y = FileDayGCC(ROIselect).ROIavg;
    ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);       y = y(ind);
    [~,r2,~,p] = AM_compute_regression(x,y,[.4 0 .5],1);
    hold on;    AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(13),['pval = ',num2str(p(1,1),2.1),' R^2 = ',num2str(r2,2.1)],'color','k');
    set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('precip (mm day^-^1)','color','k');	ylabel(['GCC' ROItext],'color','k');
    xtickangle(0);

    x1 = -10;     x2 = 20;                x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/3):x2;
    subplot(2,3,3);                     hold on;
    x = UofT02meteoTmin;                   y = FileDayGCC(ROIselect).ROIavg;
    ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);       y = y(ind);
    [~,r2,~,p] = AM_compute_regression(x,y,[.4 0 .5],1);
    hold on;    AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(11),['GCC = ',num2str(p(1,1),2.1), 'SW_{in}',num2str(p(1,2),2.1)],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('T_{min} (degC)','color','k');	ylabel(['GCC' ROItext],'color','k');
    xtickangle(0);

    x1 = 0;     x2 = 30;                x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/3):x2;
    subplot(2,3,4);                     hold on;
    x = UofT02meteoTmax;                   y = FileDayGCC(ROIselect).ROIavg;
    ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);       y = y(ind);
    [~,r2,~,p] = AM_compute_regression(x,y,[.4 0 .5],1);
    hold on;    AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(11),['GCC = ',num2str(p(1,1),2.1), 'SW_{in}',num2str(p(1,2),2.1)],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('T_{max} (degC)','color','k');	ylabel(['GCC' ROItext],'color','k');
    xtickangle(0);

    x1 = 0;     x2 = 100;                x3 = x1:((x2-x1)/10):x2;    x4 = x1:((x2-x1)/4):x2;
    subplot(2,3,5);                     hold on;
    x = UofT02meteoRH;                   y = FileDayGCC(ROIselect).ROIavg;
    ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);       y = y(ind);
    [~,r2,~,p] = AM_compute_regression(x,y,[.4 0 .5],1);
    hold on;    AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),y3(13),[' R^2 = ',num2str(r2,2.1)],'color','k');
    % text(x3(2),y3(11),['GCC = ',num2str(p(1,1),2.1), 'SW_{in}',num2str(p(1,2),2.1)],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[y1 y2],'YTick',y4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('RH (%)','color','k');	ylabel(['GCC' ROItext],'color','k');
    xtickangle(0);

end

%% ........................................................................
if flag_year2year==1
    color_mtx = [253/255 174/255 97/255; 253/255 25/255 97/255;0.1020 0.5882 0.2549;...
        171/255 221/255 164/255;...
        0.1020 0.5882 0.2549;  0.1020 0.5882 0.2549;...
        43/255 131/255 186/255;215/255  25/255 28/255];
    JDeight  = day(FileEight,'dayofyear');

    v1 = 0;         v2 = 15.;    v3 = (v1:((v2-v1)/3):v2);
    figure('color','white');

    v1 = -10;         v2 =30;    v3 = [v1:((v2-v1)/4):v2];
    subplot(3,2,1);             hold on;
    scatter(MeteoEigthJD(MeteoEigthY==2022),AM_fill(MeteoTempCeight(MeteoEigthY==2022)),50,'o','MarkerFaceColor',color_mtx(4,:));
    scatter(MeteoEigthJD(MeteoEigthY==2023),AM_fill(MeteoTempCeight(MeteoEigthY==2023)),50,'o','MarkerFaceColor',color_mtx(1,:));
    scatter(MeteoEigthJD(MeteoEigthY==2024),AM_fill(MeteoTempCeight(MeteoEigthY==2024)),50,'o','MarkerFaceColor',color_mtx(3,:));
    scatter(MeteoEigthJD(MeteoEigthY==2025),AM_fill(MeteoTempCeight(MeteoEigthY==2025)),50,'o','MarkerFaceColor',color_mtx(2,:));

    hl5 = plot(MeteoEigthJD(MeteoEigthY==2022),AM_fill(MeteoTempCeight(MeteoEigthY==2022)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(4,:));
    hl4 = plot(MeteoEigthJD(MeteoEigthY==2023),AM_fill(MeteoTempCeight(MeteoEigthY==2023)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(1,:));
    hl6 = plot(MeteoEigthJD(MeteoEigthY==2024),AM_fill(MeteoTempCeight(MeteoEigthY==2024)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(3,:));
    hl7 = plot(MeteoEigthJD(MeteoEigthY==2025),AM_fill(MeteoTempCeight(MeteoEigthY==2025)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(5,:));
    xlim([1 365]);    ylim([v1 v2]);   grid on;
    set(gca,'XTick',JD_avg,'XTickLabel',datestr(month_avg,4),'FontSize',11);
    ax1 = gca;      set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0]);
    ylabel ({'Tair (\circC)'},'FontSize',11);
    text (day_avg(2),v2-3,'UofT02','FontSize',11);          box on;   xtickangle(0);

    v1 = 0;         v2 =14;    v3 = [v1:((v2-v1)/4):v2];
    subplot(3,2,2);             hold on;
    %     hl1 = bar(month_avg,.8+(month_avgTRMM./300),1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    %     hl2 = plot(JDeight(Yeight==2018),ExGREENeight(Yeight==2018),50,'o','MarkerFaceColor',color_mtx(1,:));
    %     hl3 = plot(JDeight(Yeight==2019),ExGREENeight(Yeight==2019),50,'o','MarkerFaceColor',color_mtx(2,:));
    scatter(JDeight(Yeight==2022),ExGREENeight(Yeight==2022),50,'o','MarkerFaceColor',color_mtx(4,:));
    scatter(JDeight(Yeight==2023),ExGREENeight(Yeight==2023),50,'o','MarkerFaceColor',color_mtx(1,:));
    scatter(JDeight(Yeight==2024),ExGREENeight(Yeight==2024),50,'o','MarkerFaceColor',color_mtx(3,:));
    scatter(JDeight(Yeight==2025),ExGREENeight(Yeight==2025),50,'o','MarkerFaceColor',color_mtx(2,:));

    %     hl2 = plot(JDeight(Yeight==2018),ExGREENeight(Yeight==2018),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(1,:));
    %     hl3 = plot(JDeight(Yeight==2019),ExGREENeight(Yeight==2019),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(2,:));
    %     hl4 = plot(JDeight(Yeight==2020),ExGREENeight(Yeight==2020),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(3,:));
    hl5 = plot(JDeight(Yeight==2022),AM_fill(ExGREENeight(Yeight==2022)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(4,:));
    hl4 = plot(JDeight(Yeight==2023),AM_fill(ExGREENeight(Yeight==2023)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(1,:));
    hl6 = plot(JDeight(Yeight==2024),AM_fill(ExGREENeight(Yeight==2024)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(3,:));
    hl7 = plot(JDeight(Yeight==2025),AM_fill(ExGREENeight(Yeight==2025)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(2,:));

    xlim([1 365]);    ylim([v1 v2]);   grid on;
    set(gca,'XTick',JD_avg,'XTickLabel',datestr(month_avg,4),'FontSize',11);
    ax1 = gca;
    set(ax1,'XColor','k','YColor','k','YTick',v3,'YTickLabel',v3,'FontSize',11);
    ylabel ({'ExGREEN'},'FontSize',11);   box on;   xtickangle(0);

    v1 = 0.33;         v2 =0.36;    v3 = [v1:((v2-v1)/3):v2];
    subplot(3,2,4);             hold on;
    %     hl1 = bar(month_avg,.25+(month_avgTRMM./400),1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    %     hl2 = plot(JDeight(Yeight==2018),GCCeight(Yeight==2018),50,'o','MarkerFaceColor',color_mtx(1,:));
    %     hl3 = plot(JDeight(Yeight==2019),GCCeight(Yeight==2019),50,'o','MarkerFaceColor',color_mtx(2,:));
    %     hl4 = plot(JDeight(Yeight==2020),GCCeight(Yeight==2020),50,'o','MarkerFaceColor',color_mtx(3,:));
    scatter(JDeight(Yeight==2022),AM_fill(GCCeight(Yeight==2022)),50,'o','MarkerFaceColor',color_mtx(4,:));
    scatter(JDeight(Yeight==2023),AM_fill(GCCeight(Yeight==2023)),50,'o','MarkerFaceColor',color_mtx(1,:));
    scatter(JDeight(Yeight==2024),AM_fill(GCCeight(Yeight==2024)),50,'o','MarkerFaceColor',color_mtx(3,:));
    scatter(JDeight(Yeight==2025),AM_fill(GCCeight(Yeight==2025)),50,'o','MarkerFaceColor',color_mtx(2,:));

    %     hl2 = plot(JDeight(Yeight==2018),GCCeight(Yeight==2018),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(1,:));
    %     hl3 = plot(JDeight(Yeight==2019),GCCeight(Yeight==2019),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(2,:));
    hl5 = plot(JDeight(Yeight==2022),AM_fill(GCCeight(Yeight==2022)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(4,:));
    hl4 = plot(JDeight(Yeight==2023),AM_fill(GCCeight(Yeight==2023)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(1,:));
    hl6 = plot(JDeight(Yeight==2024),AM_fill(GCCeight(Yeight==2024)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(3,:));
    hl7 = plot(JDeight(Yeight==2025),AM_fill(GCCeight(Yeight==2025)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(2,:));
    legend([hl5,hl4,hl6,hl7],'2022','2023','2024','2025');	legend box off;	xtickangle(0);

    xlim([1 365]);    ylim([v1 v2]);   grid on;
    set(gca,'XTick',JD_avg,'XTickLabel',datestr(month_avg,4),'FontSize',11);
    ax1 = gca;      set(ax1,'XColor','k','YColor','k','YTick',v3,'YTickLabel',v3);
    ylabel ({'GCC'},'FontSize',11);
    text (day_avg(2),v2-.3,'UofT02','FontSize',11);        box on;   xtickangle(0);

    v1 = 0.9;         v2 =1.06;    v3 = [v1:((v2-v1)/3):v2];
    subplot(3,2,3);             hold on;
    scatter(JDeight(Yeight==2022),GRRIeight(Yeight==2022),50,'o','MarkerFaceColor',color_mtx(4,:));
    scatter(JDeight(Yeight==2023),GRRIeight(Yeight==2023),50,'o','MarkerFaceColor',color_mtx(1,:));
    scatter(JDeight(Yeight==2024),GRRIeight(Yeight==2024),50,'o','MarkerFaceColor',color_mtx(3,:));
    scatter(JDeight(Yeight==2025),GRRIeight(Yeight==2025),50,'o','MarkerFaceColor',color_mtx(2,:));

    hl5 = plot(JDeight(Yeight==2022),AM_fill(GRRIeight(Yeight==2022)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(4,:));
    hl4 = plot(JDeight(Yeight==2023),AM_fill(GRRIeight(Yeight==2023)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(1,:));
    hl6 = plot(JDeight(Yeight==2024),AM_fill(GRRIeight(Yeight==2024)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(3,:));
    hl7 = plot(JDeight(Yeight==2025),AM_fill(GRRIeight(Yeight==2025)),'-','LineWidth',2,'MarkerSize',10,'Color',color_mtx(2,:));

    xlim([1 365]);    ylim([v1 v2]);   grid on;
    set(gca,'XTick',JD_avg,'XTickLabel',datestr(month_avg,4),'FontSize',11);
    ax1 = gca;
    set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0]);
    ylabel ({'GRRI'},'FontSize',11);       box on;      xtickangle(0);
    % text (day_avg(2),v2-.3,'UofT02','FontSize',11);

    %%
    figure('color','white')
    v1 = 0.34;         v2 =0.38;    v3 = [v1:((.37-v1)/3):.37];        hold on;
    % hl1 = bar(month_avg,.25+(month_avgTRMM./400),1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    hl5 = plot(JDeight(Yeight==2022),GCCeight(Yeight==2022),'-','Color',color_mtx(1,:));
    hl4 = plot(JDeight(Yeight==2023),GCCeight(Yeight==2023),'-','Color',color_mtx(2,:));
    hl6 = plot(JDeight(Yeight==2024),GCCeight(Yeight==2024),'-','Color',color_mtx(3,:));
    hl7 = plot(JDeight(Yeight==2025),GCCeight(Yeight==2025),'-','Color',color_mtx(4,:));

    hl5 =   scatter(JDeight(Yeight==2022),AM_fill(GCCeight(Yeight==2022)),'o','MarkerFaceColor',color_mtx(1,:),...
        'MarkerEdgeColor',color_mtx(1,:), 'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5); hold on;
    hl4 =   scatter(JDeight(Yeight==2023),AM_fill(GCCeight(Yeight==2023)),'o','MarkerFaceColor',color_mtx(2,:),...
        'MarkerEdgeColor',color_mtx(2,:), 'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5); hold on;
    hl6 =   scatter(JDeight(Yeight==2024),AM_fill(GCCeight(Yeight==2024)),'o','MarkerFaceColor',color_mtx(3,:),...
        'MarkerEdgeColor',color_mtx(3,:), 'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5); hold on;
    hl7 =   scatter(JDeight(Yeight==2025),AM_fill(GCCeight(Yeight==2025)),'o','MarkerFaceColor',color_mtx(4,:),...
        'MarkerEdgeColor',color_mtx(4,:), 'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5); hold on;
    XaxisTick = datetime(0,1,1:31:365);
    grid on
    legend([hl5,hl4,hl6,hl7],'2022','2023','2024','2025');	legend box off;	xtickangle(0);
    hold on;       ax2 = gca;             set(ax2,'YColor',[0.3 0.3 0.3]);
    set(ax2,'YTick',v3,'YLim',[v1 v2],'XLim',[1 365],'XTick',(1:31:365),...
        'FontSize',16,'XMinorGrid','off','XTickLabel',datestr(XaxisTick,'mmm'));    %'XTickLabelColor',[0. 0. 0.7 ]
    ylabel ('GCC','FontSize',16);   xtickangle(0);   box on;   grid on;
end