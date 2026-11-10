% % Fiures for correlation and seasonal analysis2023
% % Natalia Restrepo Coupe
% % 121208 Sydney, Australia
%..........................................................................
%..........................................................................
warning off
flag_unix = 0;
flag_read = 1;         flag_filename = 1;     flag_calibration = 10;
flag_figures = 1;      flag_roi = 1;

if flag_unix == 1
    %     FolderOZflux = 'C:\Users\ncoupe\Documents\OZ\OZflux\';
    slash = '\';
    addpath \Users\ncoupe\Documents\OZ\
    addpath \Users\ncoupe\Documents\Amazon\C
else
    FolderFlux   = '/home/ncoupe/Documents/Amazon/AllSites/';
    FolderTRMM = '/home/ncoupe/Documents/AmazonRS/TRMM/TRMMsites/';
    FolderGPM = '/home/ncoupe/Documents/AmazonRS/TRMM/GPMsites/';
    FolderUofT02 = '/home/ncoupe/Documents/Canada/Toronto/UofTcamera02/';
    FolderImages = '/media/ncoupe/Expansion/Data/Canada/Toronto/Phenocam/UofTcamera02/';
    slash = '/';
    addpath /home/ncoupe/Documents/OZ/
    addpath /home/ncoupe/Documents/Amazon/
    % load 'dayUofT02.mat'
end

[site_name_FN, lat_FN, lon_FN, site_long_FN, year_ini, year_end, siteelevation_FN,...
    height_FN, canopy_FN, ust_tresh_FN, sunrise_FN, sunset_FN, utm_FN, ust_min_FN, ust_max_FN,...
    LAI_FN]  =  textread([FolderFlux 'sites_loc.txt'],...
    '%s	%f	%f	%s	%f	%f	%f	%f %f	%f	%f	%f	%f	%f	%f	%f',...
    'delimiter',',','headerlines', 1);
month_name = (['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec']);
month_avg = (1:1:365)';       [~,~,x] = datevec(month_avg);     month_avg(x~= 1) = [];
day_avg = (1:1:365)';

ip = 17;
%
UofT02year = (2025)';

% .....................................................................
% .....................................................................
FileDay     = ((datetime(2025,5,27)):days(1):(datetime(2025,6,8)))';
[Yday,Mday,Dday,HRday,MIday,SSday] = datevec(FileDay);
UofT02year = unique(Yday);
%
% .........................................................................
% %% Reads all images, plots the SZA at the time of the photo
% % .........................................................................
if flag_read == 1
    load('ROI_UofT02_20240101.mat')
    load('Ref_UofT02_20240101.mat')

    for iy = 1:length(FileDay)
        if iy ==1
            FolderUofT02 = [];      listOfFilesAndFolders02 = [];
            listOfFiles02 = [];     listOfFileNames02 = [];
        end
        [Yday,Mday,Dday] = datevec(FileDay);

        % FileName = [FolderImages, num2str(UofT02year(iy)), slash, 'netcam*', num2str(UofT02year(iy)), '*.jpg'];
        FileName = [FolderImages, num2str(UofT02year),slash,'phenocam2.',datestr(FileDay(iy),'YYYYmmDD'),slash, 'netcam*', '.',datestr(FileDay(iy),'YYYYmmDD'), '*.jpg'];

        [FolderUofTcam, files, extension] =  fileparts(FileName); % Separate the filenames string into parts. (The variable version is unused.)
        listOfFilesAndFolders          =  dir(fullfile(FolderUofTcam, [files, extension])); % Get a list of the files and folders that match the specified filenames.
        listOfFiles      =  listOfFilesAndFolders([listOfFilesAndFolders.isdir] == 0); % Exclude folders (such as . and ..) from the list, to give a list of files only.
        listOfFileNames  =  {listOfFiles.name};  % Copy the names of the files into a cell array

        listOfFilesAndFolders02 = [ listOfFilesAndFolders02; listOfFilesAndFolders];
        listOfFiles02 = [listOfFiles02;listOfFiles];
        listOfFileNames02 = [listOfFileNames02;listOfFileNames'];
    end
    FileDate = NaT(length(listOfFileNames02),1);
    for ik = 1:length(listOfFileNames02)
        x = listOfFileNames02{ik};
        Y = str2double(x(end-18:end-15));  M = str2double(x(end-14:end-13));   D = str2double(x(end-12:end-11));
        HR = str2double(x(end-9:end-8));   MI = str2double(x(end-7:end-6));
        FileDate(ik) = datetime(Y,M,D,HR,MI,0);
        display(datetime(Y,M,D,HR,MI,0));
    end

    [Y,M,D,HR,MI,S] = datevec(FileDate);
    %% .....................................................................
    JD  = day(FileDate,'dayofyear');
    lat = 43.663889;                           lon = -43.663889;
    HRMI = HR+(MI/60);
    [SolarZenithAngleDeg,SolarElevationCorrectedForAtmRefractionDeg,SolarNoonLSThour]=...
        AM_solar_radNOAA(JD,HRMI,Y,lat,lon);

    if flag_roi==1
        load('Calibration_UofT02.mat')
        ik = 12;
        [ImageFile] = importdata([FolderImages,num2str(UofT02year),slash,'phenocam2.',...
            datestr(FileDate(ik),'YYYYmmDD'),slash, listOfFileNames02{ik}]);
        % % %             display(listOfFileNames02{ik});
        % % %             imshow(ImageFile);      axis image;                 axis off          % Remove axis ticks and numbers
        % % %             text (50,50,['East Trout Lake TCCON Site  ' datestr(FileDate(ik))],'FontSize',18);
        % % %             close;
        %%
        REDsample   = (ImageFile(1:end,1:end,1));
        GREENsample = (ImageFile(1:end,1:end,2));
        BLUEsample  = (ImageFile(1:end,1:end,3));
        % if count==1
        %     [a,b] = size(BLUEsample);
        %     [NameCol,NameRow] = meshgrid(1:b,1:a);
        % end
        % iw = find((REDsample>150)&(GREENsample>150)&(BLUEsample>150));     % Sky
        % REDsample(iw) = NaN;     GREENsample(iw) = NaN;     BLUEsample(iw) = NaN;
        % iw = find((REDsample<60)&(GREENsample<60)&(BLUEsample<60));     % Snow
        % REDsample(iw) = NaN;     GREENsample(iw) = NaN;     BLUEsample(iw) = NaN;
        % ImageFile = cat(3,REDsample,GREENsample,BLUEsample);

        % % %             imshow(ImageFile);      axis image;            axis off          % Remove axis ticks and numbers
        % % %             text (50,50,['UofT rooftop Site 02 ' datestr(FileDate(ik))],'FontSize',18);
        % % %             close;

        % .................................................................
        %% Estimate transformation
        % .................................................................
        in = 1;     im=1;
        while in <= length(Ref)
            if (FileDate(ik)>=Ref{in}.Date)
                im = in;
                in = in+1;
            else
                in = length(Ref)+1;
            end
        end

        %         tform = fitgeotrans(Ref{im}.Distorted, RefOriginal(1:length(Ref{im}.Distorted),:),'lwm',12);
        %         'nonreflectivesimilarity' | 'similarity' | 'affine' | 'projective'
        tform = fitgeotrans(Ref{im}.Distorted, RefOriginal(1:length(Ref{im}.Distorted),:),'affine');      %affine
        %pause(1)%ask matlab to wait to be sure all variables are updated

        TransformedMap  = imwarp(ImageFile,tform);

        %         tformInv = invert(tform);               Tinv = tformInv.T;
        %         ss = Tinv(2,1);                         sc = Tinv(1,1);
        %         scale_recovered = sqrt(ss*ss + sc*sc);  theta_recovered = atan2(ss,sc)*180/pi;

        Roriginal = imref2d(size(ImageFile));
        Recovered = imwarp(TransformedMap,tform,'OutputView',Roriginal);

        % .............................................................
        %% Separation
        % .............................................................
        REDsample   =  (Recovered(:,:,1));
        GREENsample =  (Recovered(:,:,2));
        BLUEsample  =  (Recovered(:,:,3));

        ImageFile = cat(3,uint8(REDsample),uint8(GREENsample),uint8(BLUEsample));
        figure('color','white')
        imshow(ImageFile);                hold on;   pause(2);
        % % %                 ROI{1}.poly = roipoly
        % % %                 ROI{2}.poly = roipoly
        % % %                 ROI{3}.poly = roipoly
        % % %                 ROI{4}.poly = roipoly
        % % %                 ROI{5}.poly = roipoly
        % % %                 ROI{6}.poly = roipoly
        % % %                 ROI{7}.poly = roipoly
        % % %                 ROI{8}.poly = roipoly
        % % %                 ROI{9}.poly = roipoly
        % % %                 ROI{10}.poly = roipoly
        % % %                 ROI{11}.poly = roipoly
        % % %                 ROI{12}.poly = roipoly
        % % %                 ROI{13}.poly = roipoly
        %%
        for ix = 1:length(Calibration)
            Calibration{ix}.poly = double(Calibration{ix}.poly);
            Calibration{ix}.poly(Calibration{ix}.poly==0) = NaN;
        end
        hold on;
        for ix = 1:length(Calibration)
            [B] = bwboundaries(int16(Calibration{ix}.poly),'noholes');
            Boundary{ix}.poly = B;
        end

        color_mxt=flipud(jet(length(Calibration)));
        for ix = 1:length(Boundary)
            % display (ix)
            boundary = cell2mat(Boundary{ix}.poly);
            plot(boundary(:,2), boundary(:,1), 'color',color_mxt(ix,:), 'LineWidth', 2)
            pgon = polyshape(boundary(:,2), boundary(:,1));
            [x,y] = centroid(pgon);
            text(x,y,num2str(ix),'color',color_mxt(ix,:),'FontSize',18);
            Calibration{ix}.centroidX = x;
            Calibration{ix}.centroidY = y;
        end
        % text(100,100,datestr(FileDate(ik)));

    end
    [Yini,Mini,~] = datevec(min(FileDate));    [Ymax,Mmax,~] = datevec(max(FileDate));
    if Mmax == 12;    Ymax = Ymax+1;         Mmax = 1; end
    month_all  = (min(FileDate):days(1):max(FileDate))';
    % [~,~,x]    = datevec(month_all);                month_all(x~=1) = [];
    month_tick = month_all(1:2:end);

    load('UofT02yearCAL2025.mat');
    run('/home/ncoupe/Documents/Canada/Toronto/UofTcamera02/CA_03PhenoCam_meteo_UT02.m')

end

%% ....................................................................
if flag_calibration ==1
    calibrationSurface = {'50%','blk shade','blk','white'};

    figure('color','white','position',[100,300,1200,800]);   hold on;
    % bar(MeteoDateloc,MeteoPrecipAmountmm,1,'FaceColor',[ 0.4 0.4 0.4],'EdgeColor',[ 0.4 0.4 0.4]);
    yyaxis right
    w1 = 5;    w2 = 30;     w3 = w1:((w2-w1)/5):w2;        w4 = w1:((w2-w1)/(5+length(ROI))):w2;
    plot(MeteoDateloc,MeteoTempC,'Color',[ 0.9 0.4 0.4]);
    xlim([FileDate(1) FileDate(end)]);                       ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XLim',[month_tick(1) month_tick(end)],...
        'XTickLabel',datestr(month_tick,'dd'),...
        'YTick',w3,'YTick',w3,'YTickLabel',w3,'FontSize',11,'FontName','Arial');
    ax1  =  gca;                                              box on;
    set(ax1,'XColor','k','YColor',[0.9 0.4 0.4],'Position',[0.2 0.55 0.70 0.40]);
    ylabel ({'T_{air}\circC)'},'FontSize',12,'Color',[0.9 0.4 0.4],...
        'FontSize',11,'FontName','Arial'); box on;

    hold on;
    yyaxis left
    w1 = 1.;    w2 = 1.3;     w3 = w1:((w2-w1)/4):w2;   w4 = w1:((w2-w1)/20):w2;
    color_mxt=flipud(turbo(length(Calibration)));
    for ix = 1:length(Calibration)
        GRRI = AM_fill_plus(TableGRRIcalibrationAvg(:,ix));
        scatter(FileDate,GRRI,50,'o','MarkerFaceColor',color_mxt(ix,:),...
            'MarkerEdgeColor', color_mxt(ix,:));alpha(0.5);
        line(FileDate,GRRI,'color', color_mxt(ix,:))
        text(month_all(4)+hours(2),w4(length(w4)-ix),calibrationSurface{ix},'FontSize',12);  %num2str(ix)
        plot(month_all(4),w4(length(w4)-ix),'.','MarkerSize',20,'color',color_mxt(ix,:),'LineWidth',2)
        hold on
    end
    xlim([month_all(1) month_all(end)]);            ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XLim',[month_tick(1) month_tick(end)],...
        'YTick',w3,'YTick',w3,'YColor','k',...
        'FontSize',12,'FontName','Arial'); %'XTickLabelFormat','mDD',
    xtickformat('MM-dd');
    ylabel ({'GRRI'},'FontSize',12,'Color','k','FontName','Arial'); box on;

    % hl2  =  line(FileEight,AM_fill_plus(GRRIeight),'LineStyle','-','color',[.0 .0 .0],'LineWidth',2);
    xtickangle(0);

    %% ....................................................................
    figure('color','white','position',[100,300,1200,800]);   hold on;
    % bar(MeteoDateloc,MeteoPrecipAmountmm,1,'FaceColor',[ 0.4 0.4 0.4],'EdgeColor',[ 0.4 0.4 0.4]);
    yyaxis right
    w1 = 5;    w2 = 30;     w3 = w1:((w2-w1)/5):w2;        w4 = w1:((w2-w1)/(5+length(ROI))):w2;
    plot(MeteoDateloc,MeteoTempC,'Color',[ 0.9 0.4 0.4]);
    xlim([FileDate(1) FileDate(end)]);                       ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XLim',[month_tick(1) month_tick(end)],...
        'XTickLabel',datestr(month_tick,'dd'),...
        'YTick',w3,'YTick',w3,'YTickLabel',w3,'FontSize',11,'FontName','Arial');
    ax1  =  gca;                                              box on;
    set(ax1,'XColor','k','YColor',[0.9 0.4 0.4],'Position',[0.2 0.55 0.70 0.40]);
    ylabel ({'T_{air}\circC)'},'FontSize',12,'Color',[0.9 0.4 0.4],...
        'FontSize',11,'FontName','Arial'); box on;

    hold on;
    yyaxis left
    w1 = 1.;    w2 = 1.3;     w3 = w1:((w2-w1)/4):w2;   w4 = w1:((w2-w1)/20):w2;
    color_mxt=flipud(turbo(length(Calibration)));
    for ix = 1:length(Calibration)
        GRRI = AM_fill_plus(TableGRRIcalibrationAvg(:,ix));
        scatter(FileDate,GRRI,50,'o','MarkerFaceColor',color_mxt(ix,:),...
            'MarkerEdgeColor', color_mxt(ix,:));alpha(0.5);
        line(FileDate,GRRI,'color', color_mxt(ix,:))
        text(month_all(4)+hours(2),w4(length(w4)-ix),calibrationSurface{ix},'FontSize',12);  %num2str(ix)
        plot(month_all(4),w4(length(w4)-ix),'.','MarkerSize',20,'color',color_mxt(ix,:),'LineWidth',2)
        hold on
    end
    xlim([month_all(1) month_all(end)]);            ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XLim',[month_tick(1) month_tick(end)],...
        'YTick',w3,'YTick',w3,'YColor','k',...
        'FontSize',12,'FontName','Arial'); %'XTickLabelFormat','mDD',
    xtickformat('MM-dd');
    ylabel ({'GRRI'},'FontSize',12,'Color','k','FontName','Arial'); box on;

    % hl2  =  line(FileEight,AM_fill_plus(GRRIeight),'LineStyle','-','color',[.0 .0 .0],'LineWidth',2);
    xtickangle(0);

    % .....................................................................
    %% RED
    % .....................................................................
    figure('color','white','position',[100,300,1200,800]);   hold on;
    % bar(MeteoDateloc,MeteoPrecipAmountmm,1,'FaceColor',[ 0.4 0.4 0.4],'EdgeColor',[ 0.4 0.4 0.4]);
    yyaxis right
    w1 = 5;    w2 = 30;     w3 = w1:((w2-w1)/5):w2;        w4 = w1:((w2-w1)/(5+length(ROI))):w2;
    plot(MeteoDateloc,MeteoTempC,'Color',[ 0.9 0.4 0.4]);
    xlim([FileDate(1) FileDate(end)]);                       ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XLim',[month_tick(1) month_tick(end)],...
        'XTickLabel',datestr(month_tick,'dd'),...
        'YTick',w3,'YTick',w3,'YTickLabel',w3,'FontSize',11,'FontName','Arial');
    ax1  =  gca;                                              box on;
    set(ax1,'XColor','k','YColor',[0.9 0.4 0.4],'Position',[0.2 0.55 0.70 0.40]);
    ylabel ({'T_{air}\circC)'},'FontSize',12,'Color',[0.9 0.4 0.4],...
        'FontSize',11,'FontName','Arial'); box on;

    hold on;
    yyaxis left
    w1 = 0;    w2 = 260;     w3 = w1:((w2-w1)/4):w2;   w4 = w1:((w2-w1)/20):w2;
    color_mxt=flipud(turbo(length(Calibration)));
    for ix = 1:length(Calibration)
        RED = AM_fill_plus(TableREDcalibrationAvg(:,ix));
        scatter(FileDate,RED,50,'o','MarkerFaceColor',color_mxt(ix,:),...
            'MarkerEdgeColor', color_mxt(ix,:));alpha(0.5);
        line(FileDate,RED,'color', color_mxt(ix,:))
        text(month_all(4)+hours(2),w4(length(w4)-ix),calibrationSurface{ix},'FontSize',12);  %num2str(ix)
        plot(month_all(4),w4(length(w4)-ix),'.','MarkerSize',20,'color',color_mxt(ix,:),'LineWidth',2)
        hold on
    end
    xlim([month_all(1) month_all(end)]);            ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XLim',[month_tick(1) month_tick(end)],...
        'YTick',w3,'YTick',w3,'YColor','k',...
        'FontSize',12,'FontName','Arial'); %'XTickLabelFormat','mDD',
    xtickformat('MM-dd');
    ylabel ({'RED'},'FontSize',12,'Color','k','FontName','Arial'); box on;

    % hl2  =  line(FileEight,AM_fill_plus(REDeight),'LineStyle','-','color',[.0 .0 .0],'LineWidth',2);
    xtickangle(0);

    % .....................................................................
    %% BLUE
    % .....................................................................
    figure('color','white','position',[100,300,1200,800]);   hold on;
    % bar(MeteoDateloc,MeteoPrecipAmountmm,1,'FaceColor',[ 0.4 0.4 0.4],'EdgeColor',[ 0.4 0.4 0.4]);
    yyaxis right
    w1 = 5;    w2 = 30;     w3 = w1:((w2-w1)/5):w2;        w4 = w1:((w2-w1)/(5+length(ROI))):w2;
    plot(MeteoDateloc,MeteoTempC,'Color',[ 0.9 0.4 0.4]);
    xlim([FileDate(1) FileDate(end)]);                       ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XLim',[month_tick(1) month_tick(end)],...
        'XTickLabel',datestr(month_tick,'dd'),...
        'YTick',w3,'YTick',w3,'YTickLabel',w3,'FontSize',11,'FontName','Arial');
    ax1  =  gca;                                              box on;
    set(ax1,'XColor','k','YColor',[0.9 0.4 0.4],'Position',[0.2 0.55 0.70 0.40]);
    ylabel ({'T_{air}\circC)'},'FontSize',12,'Color',[0.9 0.4 0.4],...
        'FontSize',11,'FontName','Arial'); box on;

    hold on;
    yyaxis left
    w1 = 0;    w2 = 260;     w3 = w1:((w2-w1)/4):w2;   w4 = w1:((w2-w1)/20):w2;
    color_mxt=flipud(turbo(length(Calibration)));
    for ix = 1:length(Calibration)
        BLUE = AM_fill_plus(TableBLUEcalibrationAvg(:,ix));
        scatter(FileDate,BLUE,50,'o','MarkerFaceColor',color_mxt(ix,:),...
            'MarkerEdgeColor', color_mxt(ix,:));alpha(0.5);
        line(FileDate,BLUE,'color', color_mxt(ix,:))
        text(month_all(4)+hours(2),w4(length(w4)-ix),calibrationSurface{ix},'FontSize',12);  %num2str(ix)
        plot(month_all(4),w4(length(w4)-ix),'.','MarkerSize',20,'color',color_mxt(ix,:),'LineWidth',2)
        hold on
    end
    xlim([month_all(1) month_all(end)]);            ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XLim',[month_tick(1) month_tick(end)],...
        'YTick',w3,'YTick',w3,'YColor','k',...
        'FontSize',12,'FontName','Arial'); %'XTickLabelFormat','mDD',
    xtickformat('MM-dd');
    ylabel ({'BLUE'},'FontSize',12,'Color','k','FontName','Arial'); box on;

    % hl2  =  line(FileEight,AM_fill_plus(BLUEeight),'LineStyle','-','color',[.0 .0 .0],'LineWidth',2);
    xtickangle(0);

    % .....................................................................
    %% GREEN
    % .....................................................................
    figure('color','white','position',[100,300,1200,800]);   hold on;
    % bar(MeteoDateloc,MeteoPrecipAmountmm,1,'FaceColor',[ 0.4 0.4 0.4],'EdgeColor',[ 0.4 0.4 0.4]);
    yyaxis right
    w1 = 5;    w2 = 30;     w3 = w1:((w2-w1)/5):w2;        w4 = w1:((w2-w1)/(5+length(ROI))):w2;
    plot(MeteoDateloc,MeteoTempC,'Color',[ 0.9 0.4 0.4]);
    xlim([FileDate(1) FileDate(end)]);                       ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XLim',[month_tick(1) month_tick(end)],...
        'XTickLabel',datestr(month_tick,'dd'),...
        'YTick',w3,'YTick',w3,'YTickLabel',w3,'FontSize',11,'FontName','Arial');
    ax1  =  gca;                                              box on;
    set(ax1,'XColor','k','YColor',[0.9 0.4 0.4],'Position',[0.2 0.55 0.70 0.40]);
    ylabel ({'T_{air}\circC)'},'FontSize',12,'Color',[0.9 0.4 0.4],...
        'FontSize',11,'FontName','Arial'); box on;

    hold on;
    yyaxis left
    w1 = 0;    w2 = 260;     w3 = w1:((w2-w1)/4):w2;   w4 = w1:((w2-w1)/20):w2;
    color_mxt=flipud(turbo(length(Calibration)));
    for ix = 1:length(Calibration)
        GREEN = AM_fill_plus(TableGREENcalibrationAvg(:,ix));
        scatter(FileDate,GREEN,50,'o','MarkerFaceColor',color_mxt(ix,:),...
            'MarkerEdgeColor', color_mxt(ix,:));alpha(0.5);
        line(FileDate,GREEN,'color', color_mxt(ix,:))
        text(month_all(4)+hours(2),w4(length(w4)-ix),calibrationSurface{ix},'FontSize',12);  %num2str(ix)
        plot(month_all(4),w4(length(w4)-ix),'.','MarkerSize',20,'color',color_mxt(ix,:),'LineWidth',2)
        hold on
    end
    xlim([month_all(1) month_all(end)]);            ylim([w1 w2]);
    set(gca,'XTick',month_tick,'XLim',[month_tick(1) month_tick(end)],...
        'YTick',w3,'YTick',w3,'YColor','k',...
        'FontSize',12,'FontName','Arial'); %'XTickLabelFormat','mDD',
    xtickformat('MM-dd');
    ylabel ({'GREEN'},'FontSize',12,'Color','k','FontName','Arial'); box on;

    % hl2  =  line(FileEight,AM_fill_plus(GREENeight),'LineStyle','-','color',[.0 .0 .0],'LineWidth',2);
    xtickangle(0);

    % .....................................................................
    %% REGRESION
    % .....................................................................
    figure('color','white','position',[100,100,700,700]);
    x1 = 0;     x2 = 260;    x3 = x1:((x2-x1)/20):x2;    x4 = x1:((x2-x1)/4):x2;
    subplot(2,2,1);          hold on;
    x = TableGREENcalibrationAvg(:,1);    y = TableGREENcalibrationAvg(:,2);
    % ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);                 y = y(ind);
    scatter(x,y,50,'o','MarkerFaceColor',[.0 0.4 .5]);   hold on;
    [p,r2,~,p_val] = AM_compute_regression_zero(x,y,[.0 0.2 .3],1);  hold on;
       AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),x3(17),['R^2 = ',num2str(r2,2.1)],'color','k');
    text(x3(2),x3(18),['pval = ',num2str(p_val(1,1),2.1),' R^2 = ',num2str(r2,2.1)],'color','k');
    text(x3(2),x3(19),['GREEN_{blk shd} = ',num2str(p(1,1),2.1), 'GREEN_{50%}'],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[x1 x2],'YTick',x4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('Reference 50%','color','k');	ylabel('Black [shade]','color','k');
    xtickangle(0);

    subplot(2,2,2);          hold on;
    x = TableGREENcalibrationAvg(:,1);    y = TableGREENcalibrationAvg(:,3);
    % ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);                 y = y(ind);
    scatter(x,y,50,'o','MarkerFaceColor',[.0 0.4 .5]);   hold on;
    [p,r2,~,p_val] = AM_compute_regression_zero(x,y,[.0 0.2 .3],1);  hold on;
       AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),x3(18),['pval = ',num2str(p_val(1,1),2.1),' R^2 = ',num2str(r2,2.1)],'color','k');
    text(x3(2),x3(19),['GREEN_{blk} = ',num2str(p(1,1),2.1), 'GREEN_{50%}'],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[x1 x2],'YTick',x4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('Reference 50%','color','k');	ylabel('Black','color','k');
    xtickangle(0);

        subplot(2,2,3);          hold on;
    x = TableGREENcalibrationAvg(:,1);    y = TableGREENcalibrationAvg(:,4);
    % ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);                 y = y(ind);
    scatter(x,y,50,'o','MarkerFaceColor',[.0 0.4 .5]);   hold on;
    [p,r2,~,p_val] = AM_compute_regression_zero(x,y,[.0 0.2 .3],1);  hold on;
       AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),x3(18),['pval = ',num2str(p_val(1,1),2.1),' R^2 = ',num2str(r2,2.1)],'color','k');
    text(x3(2),x3(19),['GREEN_{white} = ',num2str(p(1,1),2.1), 'GREEN_{50%}'],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[x1 x2],'YTick',x4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('Reference 50%','color','k');	ylabel('White','color','k');
    xtickangle(0);

        subplot(2,2,4);          hold on;
        ind = find((HR>9)&(HR<17));
    x = TableGREENcalibrationAvg(ind,1);    y = TableGREENcalibrationAvg(ind,2);
    % ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);                 y = y(ind);
    scatter(x,y,50,'o','MarkerFaceColor',[.0 0.4 .5]);   hold on;
    [p,r2,~,p_val] = AM_compute_regression_zero(x,y,[.0 0.2 .3],1);  hold on;
       AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),x3(17),'HR: 10:00 - 17:00','color','k');
    text(x3(2),x3(18),['pval = ',num2str(p_val(1,1),2.1),' R^2 = ',num2str(r2,2.1)],'color','k');
    text(x3(2),x3(19),['GREEN_{blk shd} = ',num2str(p(1,1),2.1), 'GREEN_{50%}'],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[x1 x2],'YTick',x4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('Reference 50%','color','k');	ylabel('Black [shade]','color','k');
    xtickangle(0);


%% ...................................................................
    figure('color','white','position',[100,100,700,700]);
    x1 = 0;     x2 = 260;    x3 = x1:((x2-x1)/20):x2;    x4 = x1:((x2-x1)/4):x2;
    subplot(2,2,1);          hold on;
    x = TableBLUEcalibrationAvg(:,1);    y = TableBLUEcalibrationAvg(:,2);
    % ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);                 y = y(ind);
    scatter(x,y,50,'o','MarkerFaceColor',[.0 0.4 .5]);   hold on;
    [p,r2,~,p_val] = AM_compute_regression_zero(x,y,[.0 0.2 .3],1);  hold on;
       AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),x3(18),['pval = ',num2str(p_val(1,1),2.1),' R^2 = ',num2str(r2,2.1)],'color','k');
    text(x3(2),x3(19),['BLUE_{blk shd} = ',num2str(p(1,1),2.1), 'BLUE_{50%}'],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[x1 x2],'YTick',x4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('Reference 50%','color','k');	ylabel('Black [shade]','color','k');
    xtickangle(0);

    subplot(2,2,2);          hold on;
    x = TableBLUEcalibrationAvg(:,1);    y = TableBLUEcalibrationAvg(:,3);
    % ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);                 y = y(ind);
    scatter(x,y,50,'o','MarkerFaceColor',[.0 0.4 .5]);   hold on;
    [p,r2,~,p_val] = AM_compute_regression_zero(x,y,[.0 0.2 .3],1);  hold on;
       AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),x3(18),['pval = ',num2str(p_val(1,1),2.1),' R^2 = ',num2str(r2,2.1)],'color','k');
    text(x3(2),x3(19),['BLUE_{blk} = ',num2str(p(1,1),2.1), 'BLUE_{50%}'],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[x1 x2],'YTick',x4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('Reference 50%','color','k');	ylabel('Black','color','k');
    xtickangle(0);

        subplot(2,2,3);          hold on;
    x = TableBLUEcalibrationAvg(:,1);    y = TableBLUEcalibrationAvg(:,4);
    % ind = ((~isnan(x))&(~isnan(y)));    x = x(ind);                 y = y(ind);
    scatter(x,y,50,'o','MarkerFaceColor',[.0 0.4 .5]);   hold on;
    [p,r2,~,p_val] = AM_compute_regression_zero(x,y,[.0 0.2 .3],1);  hold on;
       AM_bin(x,y,20,2,10,[.9 0 0]);
    text(x3(2),x3(18),['pval = ',num2str(p_val(1,1),2.1),' R^2 = ',num2str(r2,2.1)],'color','k');
    text(x3(2),x3(19),['BLUE_{white} = ',num2str(p(1,1),2.1), 'BLUE_{50%}'],'color',[0. 0. 0.],'FontSize',8);
    set(gca,'Ylim',[x1 x2],'YTick',x4,'Xlim',[x1 x2],'XTick',x4,'FontSize',10);  box on;         grid on;
    xlabel('Reference 50%','color','k');	ylabel('White','color','k');
    xtickangle(0);



end
