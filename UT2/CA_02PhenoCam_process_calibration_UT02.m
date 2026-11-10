% % Process the images --calculates average and std for DN and greenness indices
% % for different ROI and all image.  Helps to the creation of the ROI structure
% % of the image.
% % Originally designed to be run from terminal without output figures

% % .......................................................................
% % flag unix: 0 if Linux/Mac 1 if MSwindows
% % note that pointers are used --modify accordingly
% % flag_read: 1 if on.
% % Reads all images, plots the SZA at the time of the photo. Makes
% % possible to select images under certain light conditions e.g. daytime,
% % high SZA
% % flag_process: 1 if on
% % Reads the image, repositions it to a fixed location and
% % creates the structure to store the average DN of the imagegs either
% % by using single regions of interest (ROI) or the agregating them.
% % flag_create_roi: 1 if on
% % To create the regions of interest. Once you create one, you do not need
% % a second as the images are "calibration"
% % flag_read_roi: 1 if on
% % To meassure the DN and greeness indices for each ROI and each image.
% % flag_color_separation: 1 if on
% % will calculate the DN and greeness indices of all image --not to use at
% % urban areas where buldings will ocuppy most of the photo
% % flag_daily: 1 if on
% % if calculating daily rather than hourly values

%..........................................................................
%..........................................................................
% for TAME work
% Natalia Restrepo-Coupe
% Toronto, December 2025 cold and gloomy
%..........................................................................
%..........................................................................
warning off
flag_unix = 0;                  flag_read = 1;
flag_process = 1;               flag_figures = 10;
flag_create_roi = 10;           flag_read_roi = 1;
flag_color_separation = 1;      flag_daily = 1;
flag_create_calibration = 10;    flag_read_calibration = 1;

% load ('UofT02.mat');
% matlab -nojvm -nodisplay -nosplash

if flag_unix == 1
    %     FolderOZflux = 'C:\Users\ncoupe\Documents\OZ\OZflux\';
    slash = '\';
    addpath \Users\ncoupe\Documents\OZ\
    addpath \Users\ncoupe\Documents\Amazon\
else
    FolderFlux   = '/home/ncoupe/Documents/Amazon/AllSites/';
    FolderImages = '/media/ncoupe/Expansion/Data/Canada/Toronto/Phenocam/UofTcamera02/';
    FolderTRMM   = '/home/ncoupe/Documents/AmazonRS/TRMM/TRMMsites/';
    FolderUofT02 = '/home/ncoupe/Documents/Canada/Toronto/UofTcamera02/';
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

UofT02year = (2025)';

% .....................................................................
% .....................................................................
FileDay     = ((datetime(2025,5,27)):days(1):(datetime(2025,6,8)))';
[Yday,Mday,Dday,HRday,MIday,SSday] = datevec(FileDay);
UofT02year = unique(Yday);

% .........................................................................
%% Reads all images, plots the SZA at the time of the photo
% .........................................................................
if flag_read == 1
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

    % .....................................................................
    if flag_figures==1
        figure('color','white');      hold on
        plot(FileDate,SolarZenithAngleDeg,'.','color',[0 0 .8]);
        ylabel('Solar Zenith Angle (Deg)');
        plot(FileDate,SolarZenithAngleDeg.*0+mean(SolarZenithAngleDeg,'omitnan'),'r');
        plot(FileDate,SolarZenithAngleDeg.*0+mean(SolarZenithAngleDeg,'omitnan'),'.r')
        datetick('x',12);      grid on;   box on;
        figure('color','white');      hold on
        plot(FileDate,SolarElevationCorrectedForAtmRefractionDeg,'.','color',[0 0 .8]);
        ylabel('Solar Elevation (Deg)');
        plot(FileDate,SolarElevationCorrectedForAtmRefractionDeg.*0+mean(SolarElevationCorrectedForAtmRefractionDeg,'omitnan'),'r');
        plot(FileDate,SolarElevationCorrectedForAtmRefractionDeg.*0+mean(SolarElevationCorrectedForAtmRefractionDeg,'omitnan'),'.r')
        datetick('x',12);      grid on;   box on;
    end

end
close all;

%% ........................................................................
if flag_process == 1
    load 'Ref_UofT02_20230101.mat';   load 'ROI_UofT02_20230101.mat';
    load('Calibration_UofT02.mat')
    count = 0;
    ind = ones(length(FileDate),1);
    for ik = 1:length(FileDate)
        count = count+1;
        display(datestr(FileDate(ik)))
        if (FileDate(ik)>=datetime(2023,4,5))
        end
        [ImageFile] = importdata([FolderImages, num2str(UofT02year),slash,'phenocam2.',datestr(FileDate(ik),'YYYYmmDD'),slash, listOfFileNames02{ik}]);
        % % %             display(listOfFileNames02{ik});
        % % %             imshow(ImageFile);      axis image;                 axis off          % Remove axis ticks and numbers
        % % %             text (50,50,['East Trout Lake TCCON Site  ' datestr(FileDate(ik))],'FontSize',18);
        % % %             close;
        %%
        REDsample   =  (ImageFile(1:end,1:end,1));
        GREENsample =  (ImageFile(1:end,1:end,2));
        BLUEsample  =  (ImageFile(1:end,1:end,3));
        if count==1
            [a,b] = size(BLUEsample);
            [NameCol,NameRow] = meshgrid(1:b,1:a);
        end
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

        REDsample = double(REDsample);          GREENsample = double(GREENsample);              BLUEsample = double(BLUEsample);
        ia  = REDsample+GREENsample+BLUEsample;
        GCC_matrix  = GREENsample./ia;          GCC_matrix(isinf(GCC_matrix)) = NaN;
        RCC_matrix  = REDsample./ia;            RCC_matrix(isinf(RCC_matrix)) = NaN;
        GRRI_matrix = GREENsample./REDsample;   GRRI_matrix(isinf(GRRI_matrix)) = NaN;
        CCI_matrix  = (GREENsample-REDsample)./(GREENsample+REDsample);
        CCI_matrix(isinf(CCI_matrix)) = NaN;
        ExGREEN_matrix = (2.*GREENsample) - REDsample - BLUEsample;
        ExGREEN_matrix(isinf(ExGREEN_matrix)) = NaN;

        % %             figure('color','white');
        % %             imagesc(GRRI_matrix);      axis image;                 axis off
        % %             caxis([1.1 1.3]);       colormap turbo

        if flag_color_separation == 1
            if count==1
                GCC   = NaN.*ind;   GCCstd = NaN.*ind;
                CCI   = NaN.*ind;   CCIstd = NaN.*ind;
                GRRI  = NaN.*ind;   GRRIstd  = NaN.*ind;
                RCC   = NaN.*ind;   RCCstd   = NaN.*ind;
                GREEN = NaN.*ind;   GREENstd = NaN.*ind;
                RED   = NaN.*ind;   REDstd = NaN.*ind;
                BLUE  = NaN.*ind;   BLUEstd  = NaN.*ind;
                ExGREEN   = NaN.*ind;   ExGREENstd = NaN.*ind;

                FileDateDay = datetime(Y,M,D,HR,MI,0);
            end
            GCC(count)     = mean(mean(AM_rm_outlier(GCC_matrix,3),'omitnan'),'omitnan');
            GCCstd(count)  = std(std(AM_rm_outlier(GCC_matrix,3),'omitnan'),'omitnan');
            ExGREEN(count) = mean(mean(AM_rm_outlier(ExGREEN_matrix,3),'omitnan'),'omitnan');
            ExGREENstd(count) = std(std(AM_rm_outlier(ExGREEN_matrix,3),'omitnan'),'omitnan');
            RCC(count)     = mean(mean(AM_rm_outlier(RCC_matrix,3),'omitnan'),'omitnan');
            RCCstd(count)  = std(std(AM_rm_outlier(RCC_matrix,3),'omitnan'),'omitnan');
            GRRI(count)    = mean(mean(AM_rm_outlier(GRRI_matrix,3),'omitnan'),'omitnan');
            GRRIstd(count) = std(std(AM_rm_outlier(GRRI_matrix,3),'omitnan'),'omitnan');

            RED(count)      = mean(mean(AM_rm_outlier(REDsample,3),'omitnan'),'omitnan');
            REDstd(count)   = std(std(AM_rm_outlier(REDsample,3),'omitnan'),'omitnan');
            GREEN(count)    = mean(mean(AM_rm_outlier(GREENsample,3),'omitnan'),'omitnan');
            GREENstd(count) = std(std(AM_rm_outlier(GREENsample,3),'omitnan'),'omitnan');
            BLUE(count)     = mean(mean(AM_rm_outlier(BLUEsample,3),'omitnan'),'omitnan');
            BLUEstd(count)  = std(std(AM_rm_outlier(BLUEsample,3),'omitnan'),'omitnan');
            %         end
        end


        if flag_create_roi==1
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
                % display (ix)
                boundary = cell2mat(Boundary{ix}.poly);
                plot(boundary(:,2), boundary(:,1), 'color',color_mxt(ix,:), 'LineWidth', 2)
                pgon = polyshape(boundary(:,2), boundary(:,1));
                [x,y] = centroid(pgon);
                text(x,y,num2str(ix),'color',color_mxt(ix,:),'FontSize',18);
                ROI{ix}.centroidX = x;
                ROI{ix}.centroidY = y;
            end
            % text(100,100,datestr(FileDate(ik)));
        end
        %..............................................................
        % % %           save 'ROI_UofT02.mat' 'ROI' -v7.3;
        % % %           load ('ROI_UofT02.mat')

        if flag_create_calibration==1
            ImageFile = cat(3,uint8(REDsample),uint8(GREENsample),uint8(BLUEsample));
            figure('color','white')
            imshow(ImageFile);                hold on;   pause(2);
            % %                 Calibration{1}.poly = roipoly
            % % r = [1804,1809,1809,1804];  c = [1271,1271,1276,1276];
            % % Calibration{1}.poly = roipoly(Recovered,c,r);
            % %                 Calibration{2}.poly = roipoly
            % % %                 Calibration{3}.poly = roipoly
            % % %                 Calibration{4}.poly = roipoly
            %%
            for ix = 1:length(Calibration)
                Calibration{ix}.poly = double(Calibration{ix}.poly);
                Calibration{ix}.poly(Calibration{ix}.poly==0) = NaN;
            end
            hold on;
            for ix = 1:length(Calibration)
                [B] = bwboundaries(int16(Calibration{ix}.poly),'noholes');      Boundary{ix}.poly = B;
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
            text(100,100,datestr(FileDate(ik)));
        end
        % % % save 'Calibration_UofT02.mat' 'Calibration' -v7.3;
        % % %           load ('Calibration_UofT02.mat')
        %..................................................................
        %% ROI
        %..................................................................
        if flag_read_roi==1
            %                 load('ROI_UofT02.mat','ROI*');
            if count==1
                TableBLUEroiAvg  = NaN(length(ind),length(ROI));
                TableBLUEroiStd  = TableBLUEroiAvg;     TableBLUEroiMax  = TableBLUEroiAvg;
                TableGREENroiAvg = TableBLUEroiAvg;     TableGREENroiStd = TableBLUEroiAvg;  TableGREENroiMax = TableBLUEroiAvg;
                TableREDroiAvg   = TableBLUEroiAvg;     TableREDroiStd   = TableBLUEroiAvg;  TableREDroiMax   = TableBLUEroiAvg;
                TableGCCroiAvg   = TableBLUEroiAvg;     TableGCCroiStd   = TableBLUEroiAvg;  TableGCCroiMax   = TableBLUEroiAvg;
                TableCCIroiAvg   = TableBLUEroiAvg;     TableCCIroiStd   = TableBLUEroiAvg;  TableCCIroiMax   = TableBLUEroiAvg;
                TableGRRIroiAvg  = TableBLUEroiAvg;     TableGRRIroiStd  = TableBLUEroiAvg;  TableGRRIroiMax  = TableBLUEroiAvg;
                TableRCCroiAvg   = TableBLUEroiAvg;     TableRCCroiStd   = TableBLUEroiAvg;  TableRCCroiMax   = TableBLUEroiAvg;
                TableExGREENroiAvg = TableBLUEroiAvg;   TableExGREENroiStd = TableBLUEroiAvg;TableExGREENroiMax = TableBLUEroiAvg;
            end


            for ix = 1:length(ROI)
                E = double(ROI{ix}.poly);       E(E==0) = NaN;

                ir = GCC_matrix.*E;                 %ir = AM_rm_outlier(ir,3);
                ia = mean(mean(ir,'omitnan'),'omitnan');
                is = std(std(ir,'omitnan'),'omitnan');
                iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableGCCroiAvg(count,ix) = ia;      TableGCCroiStd(count,ix) = is;      TableGCCroiMax(count,ix) = is;

                ir = CCI_matrix.*E;                 %ir = AM_rm_outlier(ir,3);
                ia = mean(mean(ir,'omitnan'),'omitnan');          is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableCCIroiAvg(count,ix) = ia;      TableCCIroiStd(count,ix) = is;      TableCCIroiMax(count,ix) = is;

                ir = GRRI_matrix.*E;                 %ir = AM_rm_outlier(ir,3);
                ia = mean(mean(ir,'omitnan'),'omitnan');          is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableGRRIroiAvg(count,ix) = ia;     TableGRRIroiStd(count,ix) = is;     TableGRRIroiMax(count,ix) = iw;

                ir = RCC_matrix.*E;                 %ir = AM_rm_outlier(ir,3);
                ia = mean(mean(ir,'omitnan'),'omitnan');          is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableRCCroiAvg(count,ix) = ia;      TableRCCroiStd(count,ix) = is;      TableRCCroiMax(count,ix) = iw;

                ir = GREENsample.*E;
                ia = mean(mean(ir,'omitnan'),'omitnan');          is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableGREENroiAvg(count,ix) = ia;    TableGREENroiStd(count,ix) = is;    TableGREENroiMax(count,ix) = iw;

                ir = REDsample.*E;
                ia = mean(mean(ir,'omitnan'),'omitnan');          is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableREDroiAvg(count,ix) = ia;      TableREDroiStd(count,ix) = is;      TableREDroiMax(count,ix) = iw;

                ir = BLUEsample.*E;
                ia = mean(mean(ir,'omitnan'),'omitnan');          is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableBLUEroiAvg(count,ix) = ia;     TableBLUEroiStd(count,ix) = is;     TableBLUEroiMax(count,ix) = iw;

                ir = ExGREEN_matrix.*E;                 %ir = AM_rm_outlier(ir,3);
                ia = mean(mean(ir,'omitnan'),'omitnan');          is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableExGREENroiAvg(count,ix) = ia;      TableExGREENroiStd(count,ix) = is;      TableExGREENroiMax(count,ix) = is;
            end
        end


        if flag_read_calibration==1
            if count==1
                TableBLUEcalibrationAvg  = NaN(length(ind),length(Calibration));
                TableBLUEcalibrationStd  = TableBLUEcalibrationAvg;     TableBLUEcalibrationMax  = TableBLUEcalibrationAvg;
                TableGREENcalibrationAvg = TableBLUEcalibrationAvg;     TableGREENcalibrationStd = TableBLUEcalibrationAvg;  TableGREENcalibrationMax = TableBLUEcalibrationAvg;
                TableREDcalibrationAvg   = TableBLUEcalibrationAvg;     TableREDcalibrationStd   = TableBLUEcalibrationAvg;  TableREDcalibrationMax   = TableBLUEcalibrationAvg;
                TableGCCcalibrationAvg   = TableBLUEcalibrationAvg;     TableGCCcalibrationStd   = TableBLUEcalibrationAvg;  TableGCCcalibrationMax   = TableBLUEcalibrationAvg;
                TableCCIcalibrationAvg   = TableBLUEcalibrationAvg;     TableCCIcalibrationStd   = TableBLUEcalibrationAvg;  TableCCIcalibrationMax   = TableBLUEcalibrationAvg;
                TableGRRIcalibrationAvg  = TableBLUEcalibrationAvg;     TableGRRIcalibrationStd  = TableBLUEcalibrationAvg;  TableGRRIcalibrationMax  = TableBLUEcalibrationAvg;
                TableRCCcalibrationAvg   = TableBLUEcalibrationAvg;     TableRCCcalibrationStd   = TableBLUEcalibrationAvg;  TableRCCcalibrationMax   = TableBLUEcalibrationAvg;
                TableExGREENcalibrationAvg = TableBLUEcalibrationAvg;   TableExGREENcalibrationStd = TableBLUEcalibrationAvg;TableExGREENcalibrationMax = TableBLUEcalibrationAvg;
            end

            for ix = 1:length(Calibration)
                E = double(Calibration{ix}.poly);       E(E==0) = NaN;

                ir = GCC_matrix.*E;                     %ir = AM_rm_outlier(ir,3);
                ia = mean(mean(ir,'omitnan'),'omitnan');              is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableGCCcalibrationAvg(count,ix) = ia;  TableGCCcalibrationStd(count,ix) = is;      TableGCCcalibrationMax(count,ix) = is;

                ir = CCI_matrix.*E;                     %ir = AM_rm_outlier(ir,3);
                ia = mean(mean(ir,'omitnan'),'omitnan');              is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableCCIcalibrationAvg(count,ix) = ia;  TableCCIcalibrationStd(count,ix) = is;      TableCCIcalibrationMax(count,ix) = is;

                ir = GRRI_matrix.*E;                    %ir = AM_rm_outlier(ir,3);
                ia = mean(mean(ir,'omitnan'),'omitnan');              is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableGRRIcalibrationAvg(count,ix) = ia; TableGRRIcalibrationStd(count,ix) = is;     TableGRRIcalibrationMax(count,ix) = iw;

                ir = RCC_matrix.*E;                     %ir = AM_rm_outlier(ir,3);
                ia = mean(mean(ir,'omitnan'),'omitnan');              is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableRCCcalibrationAvg(count,ix) = ia;  TableRCCcalibrationStd(count,ix) = is;      TableRCCcalibrationMax(count,ix) = iw;

                ir = GREENsample.*E;
                ia = mean(mean(ir,'omitnan'),'omitnan');              is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableGREENcalibrationAvg(count,ix) = ia;TableGREENcalibrationStd(count,ix) = is;    TableGREENcalibrationMax(count,ix) = iw;

                ir = REDsample.*E;
                ia = mean(mean(ir,'omitnan'),'omitnan');              is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableREDcalibrationAvg(count,ix) = ia;  TableREDcalibrationStd(count,ix) = is;      TableREDcalibrationMax(count,ix) = iw;

                ir = BLUEsample.*E;
                ia = mean(mean(ir,'omitnan'),'omitnan');              is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableBLUEcalibrationAvg(count,ix) = ia; TableBLUEcalibrationStd(count,ix) = is;     TableBLUEcalibrationMax(count,ix) = iw;

                ir = ExGREEN_matrix.*E;                     %ir = AM_rm_outlier(ir,3);
                ia = mean(mean(ir,'omitnan'),'omitnan');              is = std(std(ir,'omitnan'),'omitnan');            iw = max(max(ir,[],'omitnan'),[],'omitnan');
                TableExGREENcalibrationAvg(count,ix) = ia;  TableExGREENcalibrationStd(count,ix) = is;      TableExGREENcalibrationMax(count,ix) = iw;

            end
        end

        RED   = mean(TableREDroiAvg,2,'omitnan');
        GREEN = mean(TableGREENroiAvg,2,'omitnan');
        BLUE  = mean(TableBLUEroiAvg,2,'omitnan');

        REDstd   = mean(TableREDroiStd,2,'omitnan');
        GREENstd = mean(TableGREENroiStd,2,'omitnan');
        BLUEstd  = mean(TableBLUEroiStd,2,'omitnan');

        ia  = RED+GREEN+BLUE;
        GCC  = GREEN./ia;          GCC(isinf(GCC)) = NaN;
        CCI  = (GREEN-RED)./(GREEN+RED);          CCI(isinf(CCI)) = NaN;
        RCC  = GREEN./ia;          RCC(isinf(RCC)) = NaN;
        GRRI = GREEN./RED;         GRRI(isinf(GRRI)) = NaN;
        ExGREEN = (2.*GREEN) - RED - BLUE;

        ia  = REDstd+GREENstd+BLUEstd;
        GCCstd  = GREENstd./ia;          GCCstd(isinf(GCCstd)) = NaN;
        CCIstd  = (GREENstd-REDstd)./(GREENstd+REDstd);          CCIstd(isinf(CCIstd)) = NaN;
        RCCstd  = GREENstd./ia;          RCCstd(isinf(RCCstd)) = NaN;
        GRRIstd = GREENstd./REDstd;      GRRIstd(isinf(GRRIstd)) = NaN;
        ExGREENstd = (2.*GREENstd) - REDstd - BLUEstd;

        % ......................................................
        REDcal   = mean(TableREDcalibrationAvg,2,'omitnan');
        GREENcal = mean(TableGREENcalibrationAvg,2,'omitnan');
        BLUEcal  = mean(TableBLUEcalibrationAvg,2,'omitnan');

        REDcal_std   = mean(TableREDcalibrationStd,2,'omitnan');
        GREENcal_std = mean(TableGREENcalibrationStd,2,'omitnan');
        BLUEcal_std  = mean(TableBLUEcalibrationStd,2,'omitnan');
        % ......................................................

        FileDateYear = FileDate(ind);       listOfFileNamesYear = listOfFileNames02(ind);
        FileDateDayYear = FileDateDay(ind);
        save (['UofT02yearCAL' num2str(UofT02year) '.mat'],...
            'FileDate','FileDay',...
            'listOfFileNamesYear','FileDateYear','FileDateDayYear','FolderUofT02',...
            'GCC','GRRI','RCC','RED','BLUE','GREEN','CCI','ExGREEN',...
            'GCCstd','GRRIstd','RCCstd','REDstd','BLUEstd','GREENstd','CCIstd','ExGREENstd',...
            'REDcal','BLUEcal','GREENcal','REDcal_std','BLUEcal_std','GREENcal_std',...
            'Table*Avg','Table*Std','Table*Max','TableGCCcalibrationAvg','UofT02year');
    end
    delete([FolderUofT02,slash,'*.jpg'])
end

%..........................................................................
