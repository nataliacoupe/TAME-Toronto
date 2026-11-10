% % Reads and "georeferences" the images, extracts the greeness indices, uses the ROI
% % calculates the daily values --no figures flag can be set as is meant to
% be run on terminal not on the matlab interface
% %Natalia Restrepo
% %211001 Toronto, Canada
%..........................................................................
%..........................................................................
warning off
flag_unix = 0;          flag_read = 1;          flag_filename = 1;
flag_process = 1;       flag_figures = 10;      flag_color_separation = 1;
flag_read_roi = 1;      flag_daily = 1;

% load ('SBG01.mat');
% matlab -nojvm -nodisplay -nosplash
parpool

if flag_unix == 1
    %     FolderOZflux = 'C:\Users\ncoupe\Documents\OZ\OZflux\';
    slash = '\';
    addpath \Users\ncoupe\Documents\OZ\
    addpath \Users\ncoupe\Documents\Amazon\
else
    FolderFlux   = '/home/ncoupe/Documents/Amazon/AllSites/';
    FolderImages = '/media/ncoupe/Expansion/Data/Canada/Toronto/Phenocam/Scarborough/';
    FolderTRMM = '/home/ncoupe/Documents/AmazonRS/TRMM/TRMMsites/';
    FolderSBG = '/home/ncoupe/Documents/Canada/Toronto/Scarborough/';
    slash = '/';
    addpath /home/ncoupe/Documents/OZ/
    addpath /home/ncoupe/Documents/Amazon/
end

[site_name_FN, lat_FN, lon_FN, site_long_FN, year_ini, year_end, siteelevation_FN,...
    height_FN, canopy_FN, ust_tresh_FN, sunrise_FN, sunset_FN, utm_FN, ust_min_FN, ust_max_FN,...
    LAI_FN]  =  textread([FolderFlux 'sites_loc.txt'],...
    '%s	%f	%f	%s	%f	%f	%f	%f %f	%f	%f	%f	%f	%f	%f	%f',...
    'delimiter',',','headerlines', 1);
ip = 17;
lat = lat_FN(ip);                           lon = lon_FN(ip);

month_name = (['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec']);

listOfFileNames = [];
SBG01year = (2025)';%2023:

if flag_filename == 1
    for ij = 1:length(SBG01year)
        FileName = [FolderImages,num2str(SBG01year(ij)),slash,'SBG_oblique_01_*.jpg'];
        [FolderImagesYear, filesYear, extension]  =  fileparts(FileName); % Separate the filenames string into parts. (The variable version is unused.)
        listOfFilesAndFolders  =  dir(fullfile(FolderImagesYear, [filesYear, extension])); % Get a list of the files and folders that match the specified filenames.
        listOfFiles  =  listOfFilesAndFolders([listOfFilesAndFolders.isdir] == 0); % Exclude folders (such as . and ..) from the list, to give a list of files only.
        listOfFileNamesYear  =  {listOfFiles.name};  % Copy the names of the files into a cell array.
        listOfFileNames = [listOfFileNames;listOfFileNamesYear'];
    end
    FileDate = NaT(length(listOfFileNames),1);
    for im = 1:length(listOfFileNames)
        x = listOfFileNames{im};
        Y = str2double(x(end-22:end-19));     M = str2double(x(end-17:end-16));   D = str2double(x(end-14:end-13));
        HR = str2double(x(end-11:end-10));	  MI = str2double(x(end-8:end-7));
        FileDate(im) = datetime(Y,M,D,HR,MI,0);
    end
    [Y,M,D,HR,MI,SS] = datevec(FileDate);
    FileDay = datetime(Y,M,D);
    [C,ia,ic] = unique(FileDay);
    selected = [];
    for ix = 1:length(ia)
        selected = ([selected;ia(ix);ia(ix)+1;ia(ix)+2;ia(ix)+3;ia(ix)+4;ia(ix)+5]);
    end
    selected = unique(selected);
    listOfFileNames = listOfFileNames(selected);
end

if flag_read == 1
    FileDate = NaT(length(listOfFileNames),1);
    for ik = 1:length(listOfFileNames)
        x = listOfFileNames{ik};
        Y = str2double(x(end-22:end-19));     M = str2double(x(end-17:end-16));   D = str2double(x(end-14:end-13));
        HR = str2double(x(end-11:end-10));	  MI = str2double(x(end-8:end-7));
        FileDate(ik) = datetime(Y,M,D,HR,MI,0);
        datestr(FileDate(ik));
        listOfFileNames(ik);
    end

    [Y,M,D,HR,MI,S] = datevec(FileDate);
    % .....................................................................

    [Y1,M1,D1] = datevec(min(FileDate));          [Y2,M2,D2] = datevec(max(FileDate));
    FileDay = ((datetime(Y1,M1,D1)):1:(datetime(Y2,M2,D2)))';

    % .....................................................................
    JD  = day(FileDate,'dayofyear');
    HRMI = HR+(MI/60);
    [SolarZenithAngleDeg,SolarElevationCorrectedForAtmRefractionDeg,SolarNoonLSThour]=...
        AM_solar_radNOAA(JD,HRMI,Y,lat,lon);
    % %         % .........................................................................
    % %         %% select the time for the sampling using SolarZenithAngleDeg
    % %         % .........................................................................
    % % %     figure('color','white');      hold on
    % % %     plot(FileDate,SolarZenithAngleDeg,'.','color',[0 0 .8]);
    % % %     ylabel('Solar Zenith Angle (Deg)');
    % % %     plot(FileDate,SolarZenithAngleDeg.*0+mean(SolarZenithAngleDeg,'omitnan'),'r');
    % % %     plot(FileDate,SolarZenithAngleDeg.*0+mean(SolarZenithAngleDeg,'omitnan'),'.r')
    % % %     datetick('x',12);      grid on;   box on;
    % % %     figure('color','white');      hold on
    % % %     plot(FileDate,SolarElevationCorrectedForAtmRefractionDeg,'.','color',[0 0 .8]);
    % % %     ylabel('Solar Elevation (Deg)');
    % % %     plot(FileDate,SolarElevationCorrectedForAtmRefractionDeg.*0+mean(SolarElevationCorrectedForAtmRefractionDeg,'omitnan'),'r');
    % % %     plot(FileDate,SolarElevationCorrectedForAtmRefractionDeg.*0+mean(SolarElevationCorrectedForAtmRefractionDeg,'omitnan'),'.r')
    % % %     datetick('x',12);      grid on;   box on;

    % .....................................................................
    ind = find((HR>15));%|(SolarZenithAngleDeg>70));
    SolarElevationCorrectedForAtmRefractionDeg(ind)  = [];      SolarZenithAngleDeg(ind) = [];
    Y(ind)  = [];   M(ind) = [];    D(ind) = [];
    HR(ind) = [];	MI(ind) = [];   S(ind) = [];                HRMI(ind) = [];
    FileDate(ind) = [];             listOfFileNames(ind) = [];

    % .....................................................................
    [Y1,M1,D1] = datevec(min(FileDate));          [Y2,M2,D2] = datevec(max(FileDate));
    FileDay = ((datetime(Y1,M1,D1)):days(1):(datetime(Y2,M2,D2)))';
    SBG01year = unique(Y);
end

%% ........................................................................
if flag_process == 1
    for ij = 1:length(SBG01year)
        ind = find(Y==SBG01year(ij));
        count = 0;
        for ik = ind(1):1:ind(end) %1485=May 27, 2023 when camera is at its finally possition
        % for ik = 320:1:ind(end) %1485=May 27, 2023 when camera is at its finally possition
            % used 100 to ROI before 2023
            %used 3185 [2024] to ROI May 2023 onwards
            count = count+1;
            display(datestr(FileDate(ik)))

            % The camera moved in 2023/05/05
            load 'Ref_SBG01_20230501.mat';        load 'ROI_SBG01_20230501.mat';
            if (FileDate(ik)<datetime(2023,5,20))
                load 'Ref_SBG01_20220101.mat';    load 'ROI_SBG01_20220101.mat';
            end

            [ImageFile] = importdata([FolderImages,num2str(SBG01year(ij)),slash,listOfFileNames{ik}]);
            %             display(listOfFileNames{ik});
            if flag_figures==1
                imshow(ImageFile);      axis image;                 axis off          % Remove axis ticks and numbers
                text (50,50,['K67 RGB1  ' datestr(FileDate(ik))],'FontSize',18);
                close;
            end

            PixelCut = 700;
            if (FileDate(ik)<datetime(2023,5,20))
                PixelCut = 2200;
            end
            REDsample   = (ImageFile(PixelCut:end-200,1:end,1));
            GREENsample = (ImageFile(PixelCut:end-200,1:end,2));
            BLUEsample  = (ImageFile(PixelCut:end-200,1:end,3));
            if count==1
                [a,b] = size(BLUEsample);
                [NameCol,NameRow] = meshgrid(1:b,1:a);
            end
            iw = find((REDsample>50)&(GREENsample>130)&(BLUEsample>150));     % Sky
            REDsample(iw) = NaN;     GREENsample(iw) = NaN;     BLUEsample(iw) = NaN;
            % iw = find((REDsample>90)&(GREENsample>90)&(BLUEsample>90));     % Snow
            % REDsample(iw) = NaN;     GREENsample(iw) = NaN;     BLUEsample(iw) = NaN;

            ImageFile = cat(3,REDsample,GREENsample,BLUEsample);

            % %                         imshow(ImageFile);      axis image;            axis off          % Remove axis ticks and numbers
            % %                         text (50,50,['Scarborough Site  ' datestr(FileDate(ik))],'FontSize',18,'color','white');
            % %                         close;

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
            %         ss = Tinv(2,0);                         sc = Tinv(1,0);
            %         scale_recovered = sqrt(ss*ss + sc*sc);  theta_recovered = atan2(ss,sc)*180/pi;

            Roriginal = imref2d(size(ImageFile));
            Recovered = imwarp(TransformedMap,tform,'OutputView',Roriginal);

            % .............................................................
            %% Separation
            % .............................................................
            REDsample   =  (Recovered(:,:,1));
            GREENsample =  (Recovered(:,:,2));
            BLUEsample  =  (Recovered(:,:,3));

            REDsample = double(REDsample);          GREENsample = double(GREENsample);              BLUEsample = double(BLUEsample);
            ia  = REDsample+GREENsample+BLUEsample;
            GCC_matrix  = GREENsample./ia;          GCC_matrix(isinf(GCC_matrix)) = NaN;
            RCC_matrix  = REDsample./ia;            RCC_matrix(isinf(RCC_matrix)) = NaN;
            GRRI_matrix = GREENsample./REDsample;   GRRI_matrix(isinf(GRRI_matrix)) = NaN;
            ExGREEN_matrix = (2.*GREENsample) - REDsample - BLUEsample;
            ExGREEN_matrix(isinf(ExGREEN_matrix)) = NaN;

            % %             figure('color','white');
            % %             imagesc(GRRI_matrix);      axis image;                 axis off
            % %             caxis([1.1 1.3]);       colormap turbo

            if flag_color_separation == 1
                if count==1
                    GCC   = NaN.*ind;       GCCstd = NaN.*ind;
                    GRRI  = NaN.*ind;       GRRIstd  = NaN.*ind;
                    RCC   = NaN.*ind;       RCCstd   = NaN.*ind;
                    GREEN = NaN.*ind;       GREENstd = NaN.*ind;
                    RED   = NaN.*ind;       REDstd = NaN.*ind;
                    BLUE  = NaN.*ind;       BLUEstd  = NaN.*ind;
                    ExGREEN   = NaN.*ind;   ExGREENstd = NaN.*ind;

                    FileDateDay = datetime(Y,M,D,HR,MI,0);
                end
                GCC(count)     = mean(mean(AM_rm_outlier(GCC_matrix,3),'omitnan'),'omitnan');
                GCCstd(count)  = std(std(AM_rm_outlier(GCC_matrix,3),'omitnan'),'omitnan');
                RCC(count)     = mean(mean(AM_rm_outlier(RCC_matrix,3),'omitnan'),'omitnan');
                RCCstd(count)  = std(std(AM_rm_outlier(RCC_matrix,3),'omitnan'),'omitnan');
                GRRI(count)    = mean(mean(AM_rm_outlier(GRRI_matrix,3),'omitnan'),'omitnan');
                GRRIstd(count) = std(std(AM_rm_outlier(GRRI_matrix,3),'omitnan'),'omitnan');
                ExGREEN(count) = mean(mean(AM_rm_outlier(ExGREEN_matrix,3),'omitnan'),'omitnan');
                ExGREENstd(count)  = std(std(AM_rm_outlier(ExGREEN_matrix,3),'omitnan'),'omitnan');
                RED(count)     = mean(mean(AM_rm_outlier(REDsample,3),'omitnan'),'omitnan');
                REDstd(count)  = std(std(AM_rm_outlier(REDsample,3),'omitnan'),'omitnan');
                GREEN(count)   = mean(mean(AM_rm_outlier(GREENsample,3),'omitnan'),'omitnan');
                GREENstd(count) = std(std(AM_rm_outlier(GREENsample,3),'omitnan'),'omitnan');
                BLUE(count)    = mean(mean(AM_rm_outlier(BLUEsample,3),'omitnan'),'omitnan');
                BLUEstd(count) = std(std(AM_rm_outlier(BLUEsample,3),'omitnan'),'omitnan');
                %         end
            end

            %..............................................................
            if flag_read_roi == 1

                load 'ROI_SBG01_20230501.mat';
                if (FileDate(ik)<datetime(2023,5,20)); load 'ROI_SBG01_20220101.mat'; end
                if count==1
                    TableBLUEroiAvg  = NaN(length(ind),length(ROI));
                    TableBLUEroiStd  = TableBLUEroiAvg;    TableBLUEroiMax  = TableBLUEroiAvg;
                    TableGREENroiAvg = TableBLUEroiAvg;    TableGREENroiStd = TableBLUEroiAvg;  TableGREENroiMax = TableBLUEroiAvg;
                    TableREDroiAvg   = TableBLUEroiAvg;    TableREDroiStd   = TableBLUEroiAvg;  TableREDroiMax   = TableBLUEroiAvg;
                    TableGCCroiAvg   = TableBLUEroiAvg;    TableGCCroiStd   = TableBLUEroiAvg;  TableGCCroiMax   = TableBLUEroiAvg;
                    TableGRRIroiAvg  = TableBLUEroiAvg;    TableGRRIroiStd  = TableBLUEroiAvg;  TableGRRIroiMax  = TableBLUEroiAvg;
                    TableRCCroiAvg   = TableBLUEroiAvg;    TableRCCroiStd   = TableBLUEroiAvg;  TableRCCroiMax   = TableBLUEroiAvg;
                    TableExGREENroiAvg = TableBLUEroiAvg;  TableExGREENroiStd = TableBLUEroiAvg;TableExGREENroiMax = TableBLUEroiAvg;
                end

                ImageFile = cat(3,uint8(REDsample),uint8(GREENsample),uint8(BLUEsample));

                if flag_figures==1
                    % Image = (ImageFile.*.5);        %image = rgb2gray(ImageFile./95);
                    figure('color','white')
                    imshow(ImageFile);
                    % % %                     ROI{1}.poly = roipoly
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
                    for ix = 1:length(ROI)
                        ROI{ix}.poly = double(ROI{ix}.poly);
                        ROI{ix}.poly(ROI{ix}.poly==0) = NaN;
                    end
                    hold on;
                    for ix = 1:length(ROI)
                        [B] = bwboundaries(int16(ROI{ix}.poly),'noholes');      Boundary{ix}.poly = B;
                    end

                    color_mxt=flipud(jet(length(ROI)));

                    for ix = 1:length(Boundary)
                        display (ix)
                        boundary = cell2mat(Boundary{ix}.poly);
                        plot(boundary(:,2), boundary(:,1), 'color',color_mxt(ix,:), 'LineWidth', 2)
                        pgon = polyshape(boundary(:,2), boundary(:,1));
                        [x,y] = centroid(pgon);
                        text(x,y,num2str(ix),'color',color_mxt(ix,:),'FontSize',18);
                        ROI{ix}.centroidX = x;
                        ROI{ix}.centroidY = y;
                    end

                    text(100,100,datestr(FileDate(ik)));
                end
                % % %           save 'ROI_SBG01_20220101.mat' 'ROI' -v7.3;
                % % %           save 'ROI_SBG01_20230501.mat' 'ROI' -v7.3;
                % % %           load ('ROI_SBG01.mat')

                %..................................................................
                %% ROI
                %..................................................................
                % if (FileDate(ik)>=datetime(2023,5,20))
                for ix = 1:length(ROI)
                    E = double(ROI{ix}.poly);       E(E==0) = NaN;

                    ir = GCC_matrix.*E;                 %ir = AM_rm_outlier(ir,3);
                    ia = mean(mean(ir,'omitnan'),'omitnan');
                    is = std(std(ir,'omitnan'),'omitnan');
                    iw = max(max(ir,[],'omitnan'),[],'omitnan');
                    TableGCCroiAvg(count,ix) = ia;      TableGCCroiStd(count,ix) = is;      TableGCCroiMax(count,ix) = is;

                    ir = GRRI_matrix.*E;                 %ir = AM_rm_outlier(ir,3);
                    ia = mean(mean(ir,'omitnan'),'omitnan');
                    is = std(std(ir,'omitnan'),'omitnan');
                    iw = max(max(ir,[],'omitnan'),[],'omitnan');
                    TableGRRIroiAvg(count,ix) = ia;     TableGRRIroiStd(count,ix) = is;     TableGRRIroiMax(count,ix) = iw;

                    ir = RCC_matrix.*E;                 %ir = AM_rm_outlier(ir,3);
                    ia = mean(mean(ir,'omitnan'),'omitnan');
                    is = std(std(ir,'omitnan'),'omitnan');
                    iw = max(max(ir,[],'omitnan'),[],'omitnan');
                    TableRCCroiAvg(count,ix) = ia;      TableRCCroiStd(count,ix) = is;      TableRCCroiMax(count,ix) = iw;

                    ir = GREENsample.*E;
                    ia = mean(mean(ir,'omitnan'),'omitnan');
                    is = std(std(ir,'omitnan'),'omitnan');
                    iw = max(max(ir,[],'omitnan'),[],'omitnan');
                    TableGREENroiAvg(count,ix) = ia;    TableGREENroiStd(count,ix) = is;    TableGREENroiMax(count,ix) = iw;

                    ir = REDsample.*E;
                    ia = mean(mean(ir,'omitnan'),'omitnan');
                    is = std(std(ir,'omitnan'),'omitnan');
                    iw = max(max(ir,[],'omitnan'),[],'omitnan');
                    TableREDroiAvg(count,ix) = ia;      TableREDroiStd(count,ix) = is;      TableREDroiMax(count,ix) = iw;

                    ir = BLUEsample.*E;
                    ia = mean(mean(ir,'omitnan'),'omitnan');
                    is = std(std(ir,'omitnan'),'omitnan');
                    iw = max(max(ir,[],'omitnan'),[],'omitnan');
                    TableBLUEroiAvg(count,ix) = ia;     TableBLUEroiStd(count,ix) = is;     TableBLUEroiMax(count,ix) = iw;

                    ir = ExGREEN_matrix.*E;
                    ia = mean(mean(ir,'omitnan'),'omitnan');
                    is = std(std(ir,'omitnan'),'omitnan');
                    iw = max(max(ir,[],'omitnan'),[],'omitnan');
                    TableExGREENroiAvg(count,ix) = ia;     TableExGREENroiStd(count,ix) = is;     TableExGREENroiMax(count,ix) = iw;
                end
                % end
            end
        end

        % % %         RED   = mean(TableREDroiAvg,2,'omitnan');
        % % %         GREEN = mean(TableGREENroiAvg,2,'omitnan');
        % % %         BLUE  = mean(TableBLUEroiAvg,2,'omitnan');
        % % %
        % % %         REDstd   = mean(TableREDroiStd,2,'omitnan');
        % % %         GREENstd = mean(TableGREENroiStd,2,'omitnan');
        % % %         BLUEstd  = mean(TableBLUEroiStd,2,'omitnan');

        RED   = mean(TableREDroiAvg(:,1),2,'omitnan');
        GREEN = mean(TableGREENroiAvg(:,1),2,'omitnan');
        BLUE  = mean(TableBLUEroiAvg(:,1),2,'omitnan');

        REDstd   = mean(TableREDroiStd(:,1),2,'omitnan');
        GREENstd = mean(TableGREENroiStd(:,1),2,'omitnan');
        BLUEstd  = mean(TableBLUEroiStd(:,1),2,'omitnan');

        ia  = RED+GREEN+BLUE;
        GCC  = GREEN./ia;        GCC(isinf(GCC)) = NaN;
        RCC  = RED./ia;          RCC(isinf(RCC)) = NaN;
        GRRI = GREEN./RED;       GRRI(isinf(GRRI)) = NaN;
        ExGREEN = (2.*GREEN) - RED - BLUE;

        ia  = REDstd+GREENstd+BLUEstd;
        GCCstd  = GREENstd./ia;      GCCstd(isinf(GCCstd)) = NaN;
        RCCstd  = REDstd./ia;        RCCstd(isinf(RCCstd)) = NaN;
        GRRIstd = GREENstd./REDstd;  GRRIstd(isinf(GRRIstd)) = NaN;
        ExGREENstd = (2.*GREENstd) - REDstd - BLUEstd;

        FileDateYear = FileDate(ind);       listOfFileNamesYear = listOfFileNames(ind);
        FileDateDayYear = FileDateDay(ind);
        save (['SBG01year' num2str(SBG01year(ij)) '.mat'],...
            'listOfFileNamesYear','FileDateYear','FileDateDayYear','FolderImages',...
            'GCC','GRRI','RCC','RED','BLUE','GREEN','ExGREEN',...
            'GCCstd','GRRIstd','RCCstd','REDstd','BLUEstd','GREENstd','ExGREENstd',...
            'Table*Avg','Table*Std','Table*Max','SBG01year');
    end
end
%
%..........................................................................
%% Daily values
%..........................................................................
if flag_daily == 1
    GRRIallROI = [];       GCCallROI = [];       RCCallROI = [];
    REDallROI = [];        GREENallROI = [];     BLUEallROI = [];
    REDall = [];           GREENall = [];        BLUEall = [];
    GCCstdall = [];        GRRIstdall = [];      RCCstdall = [];
    REDstdall = [];        GREENstdall = [];     BLUEstdall = [];
    GRRIallROIstd = [];    GCCallROIstd = [];    RCCallROIstd = [];
    REDallROIstd = [];     GREENallROIstd = [];  BLUEallROIstd = [];
    % ExGREENallROI = [];
    FileDateAll = [];

    TableREDroiAvgAll  = [];    TableGREENroiAvgAll =[];    TableBLUEroiAvgAll =[];
    TableGRRIroiAvgAll = [];    TableGCCroiAvgAll = [];     TableRCCroiAvgAll = [];
    TableExGREENroiAvg = [];
    TableREDroiStdAll  = [];    TableGREENroiStdAll =[];    TableBLUEroiStdAll =[];
    TableGRRIroiStdAll = [];    TableGCCroiStdAll = [];     TableRCCroiStdAll = [];
    % TableExGREENroiAvgAll = [];

    SBG01year = (2022:2025)';

    for ik = 1:length(SBG01year)
        load ([FolderSBG 'SBG01year' num2str(SBG01year(ik)) '.mat']);
        SBG01year = (2022:2025)';

        % %         TableGRRIroiAvg(TableGRRIroiAvg==0) = NaN;  TableGCCroiAvg(TableGCCroiAvg==0) = NaN;
        % %         TableBLUEroiAvg(TableBLUEroiAvg==0) = NaN;  TableREDroiAvg(TableREDroiAvg==0) = NaN;
        % %         TableGREENroiAvg(TableGREENroiAvg==0) = NaN;

        %     GCCroi = [GCCroi;TableGCCroiAvg];
        GRRIallROI  = [GRRIallROI;mean(TableGRRIroiAvg(:,1),2,'omitnan')];
        GCCallROI   = [GCCallROI;mean(TableGCCroiAvg(:,1),2,'omitnan')];
        RCCallROI   = [RCCallROI;mean(TableRCCroiAvg(:,1),2,'omitnan')];
        REDallROI   = [REDallROI;mean(TableREDroiAvg(:,1),2,'omitnan')];
        GREENallROI = [GREENallROI;mean(TableGREENroiAvg(:,1),2,'omitnan')];
        BLUEallROI  = [BLUEallROI;mean(TableBLUEroiAvg(:,1),2,'omitnan')];
        % ExGREENallROI  = [ExGREENallROI;mean(TableExGREENroiAvg(:,1),2,'omitnan')];

        GRRIallROIstd  = [GRRIallROIstd;std(TableGRRIroiStd(:,1),0,2)];
        GCCallROIstd   = [GCCallROIstd;std(TableGCCroiStd(:,1),0,2)];
        RCCallROIstd   = [RCCallROIstd;std(TableRCCroiStd(:,1),0,2)];
        REDallROIstd   = [REDallROIstd;std(TableREDroiStd(:,1),0,2)];
        GREENallROIstd = [GREENallROIstd;std(TableGREENroiStd(:,1),0,2)];
        BLUEallROIstd  = [BLUEallROIstd;std(TableBLUEroiStd(:,1),0,2)];
        % ExGREENallROIstd  = [ExGREENallROIstd;std(TableExGREENroiStd(:,1),0,2)];

        % %         GCCall   = [GCCall;GCC];        GCCstdall   = [GCCstdall;GCCstd];
        % %         GRRIall  = [GRRIall;GRRI];      GRRIstdall  = [GRRIstdall;GRRIstd];
        % %         REDall   = [REDall;RED];        REDstdall   = [REDstdall;REDstd];
        % %         GREENall = [GREENall;GREEN];    GREENstdall = [GREENstdall;GREENstd];
        % %         BLUEall  = [BLUEall;BLUE];      BLUEstdall  = [BLUEstdall;BLUEstd];
        FileDateAll = [FileDateAll;FileDateYear];
        % %         ExGREEN = (2.*GREENall) - REDall - BLUEall;
        % %         RCCall = REDall./(GREENall + REDall + BLUEall);
        % %         RCCstdall = REDstdall./(GREENstdall + REDstdall + BLUEstdall);

        TableGRRIroiAvgAll = [TableGRRIroiAvgAll;TableGRRIroiAvg];
        TableGCCroiAvgAll  = [TableGCCroiAvgAll;TableGCCroiAvg];
        TableRCCroiAvgAll  = [TableRCCroiAvgAll;TableRCCroiAvg];
        TableREDroiAvgAll  = [TableREDroiAvgAll;TableREDroiAvg];
        TableGREENroiAvgAll = [TableGREENroiAvgAll;TableGREENroiAvg];
        TableBLUEroiAvgAll  = [TableBLUEroiAvgAll;TableBLUEroiAvg];
        % TableExGREENroiAvgAll = [TableExGREENroiAvgAll;TableExGREENroiAvg];

        TableGRRIroiStdAll = [TableGRRIroiStdAll;TableGRRIroiStd];
        TableGCCroiStdAll  = [TableGCCroiStdAll;TableGCCroiStd];
        TableRCCroiStdAll  = [TableRCCroiStdAll;TableRCCroiStd];
        TableREDroiStdAll  = [TableREDroiStdAll;TableREDroiStd];
        TableGREENroiStdAll = [TableGREENroiStdAll;TableGREENroiStd];
        TableBLUEroiStdAll  = [TableBLUEroiStdAll;TableBLUEroiStd];
        % TableExGREENroiStdAll = [TableExGREENroiStdAll;TableExGREENroiStd];
    end
    ExGREENallROI = (2.*GREENallROI) - REDallROI - BLUEallROI;
    ExGREENallROIstd = (2.*GREENallROIstd) - REDallROIstd - BLUEallROIstd;
    TableExGREENroiAvg = (2.*TableGREENroiAvg) - TableREDroiAvg - TableBLUEroiAvg;
    TableExGREENroiAvgAll = (2.*TableGREENroiAvgAll) - TableREDroiAvgAll - TableBLUEroiAvgAll;
    TableExGREENroiStdAll = (2.*TableGREENroiStdAll) - TableREDroiStdAll - TableBLUEroiStdAll;

    [GCCday,~,~,~,FileDay,~,GCCdayMax] = AM_day(GCCallROI,FileDateAll,1);
    GCCdayStd = AM_day(GCCallROIstd,FileDateAll,1);
    GCCday    = AM_fill_plus(GCCday);  GCCdayMax = AM_fill_plus(GCCdayMax);
    GCCdayStd = AM_fill_plus(GCCdayStd);

    [GRRIday,~,~,~,~,~,GRRIdayMax] = AM_day(GRRIallROI,FileDateAll,1);
    GRRIdayStd = AM_day(GRRIallROIstd,FileDateAll,1);
    GRRIday    = AM_fill_plus(GRRIday);  GRRIdayMax = AM_fill_plus(GRRIdayMax);
    GRRIdayStd = AM_fill_plus(GRRIdayStd);

    [ExGREENday,~,~,~,~,~,ExGREENdayMax] = AM_day(ExGREENallROI,FileDateAll,1);
    ExGREENdayStd = AM_day(ExGREENallROIstd,FileDateAll,1);
    ExGREENday    = AM_fill_plus(ExGREENday);  ExGREENdayMax = AM_fill_plus(ExGREENdayMax);
    ExGREENdayStd = AM_fill_plus(ExGREENdayStd);

    [RCCday,~,~,~,~,~,RCCdayMax]     = AM_day(RCCallROI,FileDateAll,1);
    RCCdayStd = AM_day(RCCallROIstd,FileDateAll,1);
    RCCday    = AM_fill_plus(RCCday);  RCCdayMax = AM_fill_plus(RCCdayMax);
    RCCdayStd = AM_fill_plus(RCCdayStd);

    [REDday,~,~,~,~,~,REDdayMax]    = AM_day(REDallROI,FileDateAll,1);
    REDdayStd = AM_day(REDallROIstd,FileDateAll,1);
    REDday    = AM_fill_plus(REDday);  REDdayMax = AM_fill_plus(REDdayMax);
    REDdayStd = AM_fill_plus(REDdayStd);

    [GREENday,~,~,~,~,~,GREENdayMax]    = AM_day(GREENallROI,FileDateAll,1);
    GREENdayStd = AM_day(GREENallROIstd,FileDateAll,1);
    GREENday    = AM_fill_plus(GREENday);  GREENdayMax = AM_fill_plus(GREENdayMax);
    GREENdayStd = AM_fill_plus(GREENdayStd);

    [BLUEday,~,~,~,~,~,BLUEdayMax]    = AM_day(BLUEallROI,FileDateAll,1);
    BLUEdayStd = AM_day(BLUEallROIstd,FileDateAll,1);
    BLUEday    = AM_fill_plus(BLUEday);  BLUEdayMax = AM_fill_plus(BLUEdayMax);
    BLUEdayStd = AM_fill_plus(BLUEdayStd);

    [Yday,Mday,Dday] = datevec(FileDay);

    [GCCeight,~,~,~,~,GCCeightStd,FileEight] = AM_eightday_rs(GCCday,FileDay);
    [GRRIeight,~,~,~,~,GRRIeightStd]         = AM_eightday_rs(GRRIday,FileDay);
    [REDeight,~,~,~,~,REDeightStd]            = AM_eightday_rs(REDday,FileDay);
    [GREENeight,~,~,~,~,GREENeightStd]  = AM_eightday_rs(GREENday,FileDay);
    [BLUEeight,~,~,~,~,BLUEeightStd]         = AM_eightday_rs(BLUEday,FileDay);
    [ExGREENeight,~,~,~,~,ExGREENeightStd]         = AM_eightday_rs(ExGREENday,FileDay);

    GCCeight = AM_fill_plus(GCCeight);        GRRIeight = AM_fill_plus(GRRIeight);
    REDeight = AM_fill_plus(REDeight);        GREENeight = AM_fill_plus(GREENeight);
    BLUEeight = AM_fill_plus(BLUEeight);      ExGREENeight = AM_fill_plus(ExGREENeight);
    GCCeightStd = AM_fill_plus(GCCeightStd);  GRRIeightStd = AM_fill_plus(GRRIeightStd);
    REDeightStd = AM_fill_plus(REDeightStd);  GREENeightStd = AM_fill_plus(GREENeightStd);
    BLUEeightStd = AM_fill_plus(BLUEeightStd);ExGREENeightStd = AM_fill_plus(ExGREENeightStd);

    [Yeight,Meight,Deight] = datevec(FileEight);

    load 'ROI_SBG01_20230501.mat';
    if (FileDate(ik)<datetime(2023,5,20)); load 'ROI_SBG01_20220101.mat'; end
    for ix = 1:length(ROI)
        ia = [TableGCCroiAvgAll(:,ix)];    ib = [TableGCCroiStdAll(:,ix)];
        [in,~,~,~,~,~,im] = AM_day(ia,FileDateAll,1);
        FileDayGCC(ix).ROIavg = AM_fill_plus(in);
        FileDayGCC(ix).ROImax = AM_fill_plus(im);
        in = AM_day(ib,FileDateAll,1);
        FileDayGCC(ix).ROIstd = AM_fill_plus(in);

        ia = TableGRRIroiAvgAll(:,ix);    ib = TableGRRIroiStdAll(:,ix);
        [in,~,~,~,~,~,im] = AM_day(ia,FileDateAll,1);
        FileDayGRRI(ix).ROIavg = AM_fill_plus(in);
        FileDayGRRI(ix).ROImax = AM_fill_plus(im);
        in = AM_day(ib,FileDateAll,1);
        FileDayGRRI(ix).ROIstd = AM_fill_plus(in);

        ia = TableExGREENroiAvgAll(:,ix);    ib = TableExGREENroiStdAll(:,ix);
        [in,~,~,~,~,~,im] = AM_day(ia,FileDateAll,1);
        FileDayExGREEN(ix).ROIavg = AM_fill_plus(in);
        FileDayExGREEN(ix).ROImax = AM_fill_plus(im);
        in = AM_day(ib,FileDateAll,1);
        FileDayExGREEN(ix).ROIstd = AM_fill_plus(in);

        ia = [TableRCCroiAvgAll(:,ix)];    ib = [TableRCCroiStdAll(:,ix)];
        [in,~,~,~,~,~,im] = AM_day(ia,FileDateAll,1);
        FileDayRCC(ix).ROIavg = AM_fill_plus(in);
        FileDayRCC(ix).ROImax = AM_fill_plus(im);
        in = AM_day(ib,FileDateAll,1);
        FileDayRCC(ix).ROIstd = AM_fill_plus(in);

        ia = [TableREDroiAvgAll(:,ix)];    ib = [TableREDroiStdAll(:,ix)];
        [in,~,~,~,~,~,im] = AM_day(ia,FileDateAll,1);
        FileDayRED(ix).ROIavg = AM_fill_plus(in);
        FileDayRED(ix).ROIstd = AM_fill_plus(im);
        in = AM_day(ib,FileDateAll,1);
        FileDayRED(ix).ROImax = AM_fill_plus(in);

        ia = [TableGREENroiAvgAll(:,ix)];    ib = [TableGREENroiStdAll(:,ix)];
        [in,~,~,~,~,~,im] = AM_day(ia,FileDateAll,1);
        FileDayGREEN(ix).ROIavg = AM_fill_plus(in);
        FileDayGREEN(ix).ROIstd = AM_fill_plus(im);
        in= AM_day(ib,FileDateAll,1);
        FileDayGREEN(ix).ROImax = AM_fill_plus(in);

        ia = [TableBLUEroiAvgAll(:,ix)];    ib = [TableBLUEroiStdAll(:,ix)];
        [in,~,~,~,~,~,im] = AM_day(ia,FileDateAll,1);
        FileDayBLUE(ix).ROImax = AM_fill_plus(in);
        FileDayBLUE(ix).ROIavg = AM_fill_plus(im);
        in = AM_day(ib,FileDateAll,1);
        FileDayBLUE(ix).ROIstd = AM_fill_plus(in);

        [FileEightGCC(ix).ROIavg]  = AM_eightday_rs(FileDayGCC(ix).ROIavg,FileDay);
        [FileEightGRRI(ix).ROIavg] = AM_eightday_rs(FileDayGRRI(ix).ROIavg,FileDay);
        [FileEightRED(ix).ROIavg]  = AM_eightday_rs(FileDayRED(ix).ROIavg,FileDay);
        [FileEightBLUE(ix).ROIavg] = AM_eightday_rs(FileDayBLUE(ix).ROIavg,FileDay);
        [FileEightGREEN(ix).ROIavg] = AM_eightday_rs(FileDayGREEN(ix).ROIavg,FileDay);
        [FileEightExGREEN(ix).ROIavg] = AM_eightday_rs(FileDayExGREEN(ix).ROIavg,FileDay);
    end
    save ('daySBG01.mat',...
        'FileDay*','FileEight*','FileDateAll',...
        'GCC*','GRRI*','RCC*','RED*','BLUE*','GREEN*','ExGREEN*',...
        'Table*roiAvg','Table*roiAvgAll','Y*','M*','D*',...
        'FileDay');%,...
    % %         'FileDayGCC*','FileDayGRRI*','FileDayRCC*',...
    % %         'FileDayRED*','FileDayGREEN*','FileDayBLUE*');
end

%..........................................................................
%..........................................................................
% GCC  = NaN(length(FileDate),1);      RCC = NaN(length(FileDate),1);
% GRRI = NaN(length(FileDate),1);      GCCstd = NaN(length(FileDate),1);
% RCCstd = NaN(length(FileDate),1);    GRRIstd = NaN(length(FileDate),1);
% BCC = NaN(length(FileDate),1);
