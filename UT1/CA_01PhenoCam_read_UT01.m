% % Add the reference points used to reposition the images in case the camera
% % moves. To check the images and creates plots when needed
% % .......................................................................
% % flag unix: 0 if Linux/Mac 1 if MSwindows
% % note that pointers are used --modify accordingly
% % flag_read: 1 if on.
% % Reads all images, plots the SZA at the time of the photo. Makes
% % possible to select images under certain light conditions e.g. daytime,
% % high SZA
% % flag_check: 1 if on
% % Plots image at requested interval (e.g. every 5 images)
% % flag_reference_points: 1 if on
% % Creates the structure to store the location of reference points later
% % used to reposition the images to a set location
% %........................................................................
% %........................................................................
warning off
flag_unix = 10;
flag_unzip = 1;    flag_read = 10;   flag_check = 10;   flag_reference_points = 10;
flag_ROI = 1;

if flag_unix == 1
    slash = '\';
    addpath \Users\ncoupe\Documents\OZ\
    addpath \Users\ncoupe\Documents\Amazon\
else
    %     FolderTRMM = '/home/ncoupe/Documents/AmazonRS/TRMM/TRMMsites/';
    slash = '/';
    FolderImages = '/media/ncoupe/Expansion/Data/Canada/Toronto/Phenocam/UofTcamera01/';
    FolderUofT01 = '/home/ncoupe/Documents/Canada/Toronto/UofTcamera01/';
    %     Location of some of function OZ_phenocam_rename --modify accordingly
    addpath /home/ncoupe/Documents/OZ/
    addpath /home/ncoupe/Documents/Amazon/
end

% .........................................................................
% % load ('Ref_HP01.mat');
% % load ('ROI_HP01.mat')
% .........................................................................
date_target = 17;
month_name = (['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec']);

% UofT01year = (2022:2025)';
UofT01year = (2026)';

FolderUofT01 = [];      listOfFilesAndFolders01 = [];   listOfFiles01 = [];     listOfFileNames01 = [];
if flag_unzip==1
    for iy = 1:length(UofT01year)
        [Yday,Mday,Dday] = datevec(datetime(UofT01year(iy),1,1:yeardays(UofT01year(iy)))');
        for in=1:length(Yday)
            for im = 11:14
                command = append('tar -zxvf ', FolderImages, num2str(UofT01year(iy)),slash,'phenocam.',...
                    num2str(UofT01year(iy)), num2str(Mday(in),'%02i'), num2str(Dday(in),'%02i'), '.tgz',...
                    ' --wildcards "',...
                    'netcam*', num2str(UofT01year(iy)), num2str(Mday(in),'%02i'),...
                    num2str(Dday(in),'%02i'), '_', num2str(im), '*.jpg"',...
                    '  -C  ', FolderImages);
                system (command);
            end
        end
    end
end

% .....................................................................
% .....................................................................
% FileDay     = ((datetime(2022,7,6)):1:(datetime(2024,05,31)))';
% [Yday,Mday,Dday,HRday,MIday,SSday] = datevec(FileDay);
% UofT01year = unique(Yday);

% .........................................................................
%% Reads all images, plots the SZA at the time of the photo
% .........................................................................
if flag_read == 1
    for iy = 1:length(UofT01year)
        if iy ==1
            FolderUofT01 = [];      listOfFilesAndFolders01 = [];
            listOfFiles01 = [];     listOfFileNames01 = [];
        end
        [Yday,Mday,Dday] = datevec(datetime(UofT01year(iy),1,1:yeardays(UofT01year(iy)))');

        % FileName = [FolderImages, num2str(UofT01year(iy)), slash, 'netcam*', num2str(UofT01year(iy)), '*.jpg'];
        FileName = [FolderImages, 'netcam*', '.',num2str(UofT01year(iy)), '*.jpg'];

        [FolderUofTcam, files, extension] =  fileparts(FileName); % Separate the filenames string into parts. (The variable version is unused.)
        listOfFilesAndFolders          =  dir(fullfile(FolderUofTcam, [files, extension])); % Get a list of the files and folders that match the specified filenames.
        listOfFiles      =  listOfFilesAndFolders([listOfFilesAndFolders.isdir] == 0); % Exclude folders (such as . and ..) from the list, to give a list of files only.
        listOfFileNames  =  {listOfFiles.name};  % Copy the names of the files into a cell array

        listOfFilesAndFolders01 = [ listOfFilesAndFolders01; listOfFilesAndFolders];
        listOfFiles01 = [listOfFiles01;listOfFiles];
        listOfFileNames01 = [listOfFileNames01;listOfFileNames'];

        FileDate = NaT(length(listOfFileNames),1);
        for ik = 1:length(listOfFileNames)
            x = listOfFileNames{ik};
            Y = str2num(x(end-18:end-15));        M = str2double(x(end-14:end-13));   D = str2double(x(end-12:end-11));
            HR = str2double(x(end-9:end-8));	  MI = str2double(x(end-7:end-6));
            FileDate(ik) = datetime(Y,M,D,HR,MI,0);
            display(FileDate(ik));
        end

        [Y,M,D,HR,MI,S] = datevec(FileDate);
        %% .....................................................................
        JD  = day(FileDate,'dayofyear');
        lat = 43.663889;                           lon = -43.663889;
        HRMI = HR+(MI/60);
        [SolarZenithAngleDeg,SolarElevationCorrectedForAtmRefractionDeg,SolarNoonLSThour]=...
            AM_solar_radNOAA(JD,HRMI,Y,lat,lon);

        % .....................................................................
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

        % .....................................................................
        ind = find((HR<10)|(HR>15));%|(SolarZenithAngleDeg>80));
        SolarElevationCorrectedForAtmRefractionDeg(ind)  = [];      SolarZenithAngleDeg(ind) = [];
        Y(ind)  = [];       M(ind) = [];    D(ind) = [];
        HR(ind) = [];       MI(ind) = [];   S(ind) = [];            HRMI(ind) = [];
        FileDate(ind) = [];                 listOfFileNames(ind) = [];
        % .....................................................................

        [Y1,M1,D1] = datevec(min(FileDate)); [Y2,M2,D2] = datevec(max(FileDate));
        FileDay = ((datetime(Y1,M1,D1)):1:(datetime(Y2,M2,D2)))';

        %% ....................................................................
        [Yini,Mini,~] = datevec(min(FileDate));  [Ymax,Mmax,~] = datevec(max(FileDate));
        if Mmax == 12;    Ymax = Ymax+1;         Mmax = 1; end
        month_all  = (datetime(Yini,Mini,1):1:datetime(Ymax,Mmax+1,1))';
        [~,~,x]    = datevec(month_all);         month_all(x~=1) = [];
        month_tick = month_all(1:2:end);
    end
end

if flag_reference_points == 1
    FileDate = [];
    GCC   = [];   GCCstd   = [];    GRRI  = [];   GRRIstd  = [];
    RCC   = [];   RCCstd   = [];    GREEN = [];   GREENstd = [];
    RED   = [];   REDstd   = [];    BLUE  = [];   BLUEstd  = [];

    for iy = 1:length(UofT01year)
        FileName = [FolderUofT01,'netcam.phenocam1.', num2str(UofT01year(iy)), '*.jpg'];
        [~, files, extension] =  fileparts(FileName); % Separate the filenames string into parts. (The variable version is unused.)
        listOfFilesAndFolders =  dir(fullfile(FolderUofT01, [files, extension])); % Get a list of the files and folders that match the specified filenames.
        listOfFiles      =  listOfFilesAndFolders([listOfFilesAndFolders.isdir] == 0); % Exclude folders (such as . and ..) from the list, to give a list of files only.
        listOfFileNames  =  {listOfFiles.name};  % Copy the names of the files into a cell array.

        count = 0;
        for iw = 2:length(listOfFileNames)

            x = listOfFileNames{iw};
            Y = str2double(x(end-18:end-15));     M = str2double(x(end-14:end-13));   D = str2double(x(end-12:end-11));
            HR = str2double(x(end-9:end-8));	  MI = str2double(x(end-7:end-6));

            count = count+1;

            display(listOfFileNames(iw));

            [ImageFile] = imread([FolderImages,slash,listOfFileNames{iw}]);


            if flag_figures ==1
                imshow(ImageFile);      axis image;            axis off          % Remove axis ticks and numbers
                text (50,50,['University of Toronto roof camera 01  ' datestr(datetime(Y,M,D,HR,MI,SS))],'FontSize',18);
                close;
            end
        end
    end
end

if flag_check==1
    for im = 1:1:length(listOfFileNames)
        figure('color','white');
        [ImageFile] = importdata([FolderImages,slash,listOfFileNames{im}]);
        imshow(ImageFile);      axis image;                 axis off          % Remove axis ticks and numbers
        text (30,50,['Toronto: ' listOfFileNames{im}],'FontSize',18,'color','white');
        close;
    end
end

%%
if flag_reference_points == 1
    % GCC = NaN(length(FileDate),1);     RCC  = NaN(length(FileDate),1);     GRRI  = NaN(length(FileDate),1);
    % GCCstd = NaN(length(FileDate),1);  RCCstd = NaN(length(FileDate),1);   GRRIstd = NaN(length(FileDate),1);
    % BCC  = NaN(length(FileDate),1);
    [Y,M,D,HR,MI,~] = datevec(FileDate);
    FileDateDay = datetime(Y,M,D);

    listOfFileNamesPeriods = ["netcam.20220707_120001.jpg";...
        "netcam.20220707_133001.jpg";...
        ];
    pixels = 0;

    for im = 1:length(listOfFileNamesPeriods)
        FileName = listOfFileNamesPeriods{im};
        figure('color','white');
        % [ImageFile] = importdata([FolderUofT01,slash,FileName(24:27),slash,'unzip',slash,FileName]);
        [ImageFile] = importdata([FolderImages,slash,FileName]);
        ImageFile = padarray(ImageFile,[pixels pixels],NaN,'both');
        imshow(ImageFile.*1);      axis image;           axis off          % Remove axis ticks and numbers
        text (30,100,['University of Toronto 01 Netcam ' datestr(FileDay(im))],'FontSize',18);
        if im==1
            ImageFileOriginal=ImageFile;
            RefOriginal = [957,1185;572,820;1227,567;1457,571;843,427;...
                1924,540;1802,752;1281,382;1296,877;1985,225;2304,1587;2288,1127;...
                1790,1139;2426,605;1616,1442;...
                2522,878;2072,1499];
            RefOriginal = RefOriginal+pixels;
            Ref{im}.Distorted = RefOriginal;
            Ref{im}.Date = datetime(2022,07,07,09,0,0);
        end
        if im==2
            RefDistorted =  [957,1185;572,820;1227,567;1457,571;843,427;...
                1924,540;1802,752;1281,382;1296,877;1985,225;2304,1587;2288,1127;...
                1790,1139;2426,605;1616,1442;...
                2522,878;2072,1499];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2022,07,07,14,0,0);
        end
        hold on;
        pause (5);
        %         plot(RefOriginal(:,1),RefOriginal(:,2), 'co', 'MarkerSize', 15);
        plot(RefOriginal(:,1),RefOriginal(:,2), 'c.', 'MarkerSize', 15);
        for ij=1:length(RefOriginal)
            text(RefOriginal(ij,1),RefOriginal(ij,2), num2str(ij),'color','c','FontSize',20);
        end
        plot(Ref{im}.Distorted(:,1),Ref{im}.Distorted(:,2), 'ro', 'MarkerSize', 15);
        plot(Ref{im}.Distorted(:,1),Ref{im}.Distorted(:,2), 'r.', 'MarkerSize', 15);
        for ij=1:length(Ref{im}.Distorted)
            text(Ref{im}.Distorted(ij,1),Ref{im}.Distorted(ij,2), num2str(ij),'color','r','FontSize',20);
        end
        axis image off;   hold off;

        % .................................................................
        %% Estimate transformation
        % .................................................................
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
    end
    %%
    figure('color','white');
    imshow(Recovered);
    hold on;
    plot(RefOriginal(:,1),RefOriginal(:,2), 'ro', 'MarkerSize', 15);
    plot(RefOriginal(:,1),RefOriginal(:,2), 'r.', 'MarkerSize', 15);
    plot(Ref{1}.Distorted(:,1),Ref{1}.Distorted(:,2), 'b.', 'MarkerSize', 15);
    for ij=1:length(RefOriginal)
        text(RefOriginal(ij,1),RefOriginal(ij,2),num2str(ij),'color','r','FontSize',20);
        text(Ref{1}.Distorted(ij,1),Ref{1}.Distorted(ij,2),num2str(ij),'color','B','FontSize',20);
    end
    axis image off;   hold off;
    save ('Ref_UofT01_20220701.mat','Ref','pixels','RefOriginal')
end

%% ....................................................................
if flag_reference_points == 1
    GCC = NaN(length(FileDate),1);     RCC  = NaN(length(FileDate),1);     GRRI  = NaN(length(FileDate),1);
    GCCstd = NaN(length(FileDate),1);  RCCstd = NaN(length(FileDate),1);   GRRIstd = NaN(length(FileDate),1);
    BCC  = NaN(length(FileDate),1);
    [Y,M,D,HR,MI,~] = datevec(FileDate);
    FileDateDay = datetime(Y,M,D);

    listOfFileNamesPeriods = ["netcam.phenocam.20230604_110001.jpg";
        "netcam.phenocam.20221204_133001.jpg";...
        "netcam.phenocam.20230604_110001.jpg";...
        "netcam.phenocam.20240229_133001.jpg";...
        "netcam.phenocam.20240419_143001.jpg";...
        "netcam.phenocam.20240502_133002.jpg";...
        "netcam.phenocam.20250228_140001.jpg";...
        ];
    pixels = 0;

    for im = 1:length(listOfFileNamesPeriods)
        FileName = listOfFileNamesPeriods{im};
        figure('color','white');
        % [ImageFile] = importdata([FolderUofT01,slash,FileName(24:27),slash,'unzip',slash,FileName]);
        [ImageFile] = importdata([FolderImages,slash,FileName]);
        ImageFile = padarray(ImageFile,[pixels pixels],NaN,'both');
        imshow(ImageFile.*1);      axis image;           axis off          % Remove axis ticks and numbers
        text (30,100,['University of Toronto 01 Netcam ' datestr(FileDay(im))],'FontSize',18);
        if im==1
            ImageFileOriginal=ImageFile;
            RefOriginal = [828,1196;450,850;1077,573;1309,567;692,451;1780,515;... %6
                1664,737;1127,385;1161,884;1838,203;2214,1544;2171,1086;...   %12
                1667,1124;2303,566;1508,1430;...
                2405,830;1973,1466];
            RefOriginal = RefOriginal+pixels;
            Ref{im}.Distorted = RefOriginal;
            Ref{im}.Date = datetime(2022,12,04,09,0,0);   %fake
        end
        if im==2
            RefDistorted =  [860,1193;473,845;1115,566;1346,566;725,473;1820,518;...
                1697,740;1139,368;1192,880;1874,201;2237,1550;2204,1088;...
                1703,1121;2330,572;1532,1433;...
                2438,836;1997,1469];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2022,12,04,14,0,0);
        end
        if im==3
            RefDistorted =  [828,1196;450,850;1077,573;1309,567;692,451;1780,515;... %6
                1664,737;1127,385;1161,884;1838,203;2214,1544;2171,1086;...   %12
                1667,1124;2303,566;1508,1430;...
                2405,830;1973,1466];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2023,06,03,14,0,0);
        end
        if im==4
            RefDistorted =  [828,1196;450,850;1077,573;1309,567;692,451;1780,515;... %6
                1664,737;1127,385;1161,884;1838,203;2214,1544;2171,1086;...   %12
                1667,1124;2303,566;1508,1430;...
                2405,830;1973,1466];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2024,02,29,14,0,0);
        end
        if im==5
            RefDistorted =  [839,1202;449,851;1091,572;1321,563;703,448;1790,515;...
                1675,733;1137,386;1168,885;1850,200;2233,1544;2188,1081;...
                1682,1115;2315,566;1517,1433;...
                2420,830;1982,1457];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2024,04,19,14,0,0);
        end
        if im==6
            RefDistorted =  [841,1201;449,851;1088,572;1322,568;704,450;1788,516;...
                1671,733;1139,384;1175,881;1850,200;2237,1550;2185,1086;...
                1682,1115;2315,566;1517,1433;...
                2420,830;1982,1457];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2024,05,02,14,0,0);
        end
        if im==7
            RefDistorted =  [841,1201;449,851;1088,572;1322,568;704,450;1788,516;...
                1671,733;1139,384;1175,881;1850,200;2237,1550;2185,1086;...
                1682,1115;2315,566;1517,1433;...
                2420,830;1982,1457];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2025,02,02,14,0,0);
        end

        hold on;
        pause (5);
        %         plot(RefOriginal(:,1),RefOriginal(:,2), 'co', 'MarkerSize', 15);
        plot(RefOriginal(:,1),RefOriginal(:,2), 'c.', 'MarkerSize', 15);
        for ij=1:length(RefOriginal)
            text(RefOriginal(ij,1),RefOriginal(ij,2), num2str(ij),'color','c','FontSize',20);
        end
        plot(Ref{im}.Distorted(:,1),Ref{im}.Distorted(:,2), 'ro', 'MarkerSize', 15);
        plot(Ref{im}.Distorted(:,1),Ref{im}.Distorted(:,2), 'r.', 'MarkerSize', 15);
        for ij=1:length(Ref{im}.Distorted)
            text(Ref{im}.Distorted(ij,1),Ref{im}.Distorted(ij,2), num2str(ij),'color','r','FontSize',20);
        end
        axis image off;   hold off;

        % .................................................................
        %% Estimate transformation
        % .................................................................
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

        % % %                 %Compare recovered to original by looking at them side-by-side
        % % %                 figure('color','white');
        % % %                 %-- Original figure
        % % %                 subplot(221)
        % % %                 imshow(ImageFile);
        % % %                 % -- Distorted figure
        % % %                 subplot(222)
        % % %                 imshow(ImageFileOriginal);
        % % %                 % -- Transformed figure
        % % %                 subplot(223)
        % % %                 imshow(TransformedMap);
        % % %                 % -- Transformed Resized figure
        % % %                 subplot(224)
        % % %                 imshow(Recovered);
    end
    %%
    figure('color','white');
    imshow(Recovered);
    hold on;
    plot(RefOriginal(:,1),RefOriginal(:,2), 'ro', 'MarkerSize', 15);
    plot(RefOriginal(:,1),RefOriginal(:,2), 'r.', 'MarkerSize', 15);
    plot(Ref{1}.Distorted(:,1),Ref{1}.Distorted(:,2), 'b.', 'MarkerSize', 15);
    for ij=1:length(RefOriginal)
        text(RefOriginal(ij,1),RefOriginal(ij,2),num2str(ij),'color','r','FontSize',20);
        text(Ref{1}.Distorted(ij,1),Ref{1}.Distorted(ij,2),num2str(ij),'color','B','FontSize',20);
    end
    axis image off;   hold off;
    save ('Ref_UofT01_20221201.mat','Ref','pixels','RefOriginal')
end

%%
if flag_ROI==1
    load('ROI_UofT01_20220701.mat')
    [ImageFile] = importdata([FolderImages,'netcam.phenocam.20220901_113002.jpg']);

    figure('color','white')
    imshow(ImageFile);
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
    %
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
    % text(100,100,datestr(FileDate(ik)));
    % save 'ROI_UofT01_20220701.mat' 'ROI' -v7.3;
end

%%
if flag_ROI==1
    load 'ROI_UofT01_20221201.mat';
    [ImageFile] = importdata([FolderImages,'netcam.phenocam.20230604_110001.jpg']);

    figure('color','white')
    imshow(ImageFile);
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
    %
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

    % save 'ROI_UofT01_20221201.mat' 'ROI' -v7.3;
end
