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
%..........................................................................
%..........................................................................
% for TAME work
% Natalia Restrepo-Coupe
% Toronto, December 2025 cold and gloomy
%..........................................................................
%..........................................................................
warning off
flag_unix = 0;

if flag_unix == 1
    slash = '\';
    addpath \Users\ncoupe\Documents\OZ\
    addpath \Users\ncoupe\Documents\Amazon\
else
    %     FolderTRMM = '/home/ncoupe/Documents/AmazonRS/TRMM/TRMMsites/';
    slash = '/';
    FolderImages = '/media/ncoupe/Expansion/Data/Canada/Toronto/Phenocam/UofTcamera02/';
    FolderUofT02 = '/home/ncoupe/Documents/Canada/Toronto/UofTcamera02/';
    %     Location of some of function OZ_phenocam_rename --modify accordingly
    addpath /home/ncoupe/Documents/OZ/
    addpath /home/ncoupe/Documents/Amazon/
end

% .........................................................................
% % load ('Ref_HP02.mat');
% % load ('ROI_HP02.mat')
% .........................................................................
flag_unzip = 1;     flag_read = 1;
flag_figures = 10;    flag_create_roi = 10;    flag_reference_points = 10;

UofT02year = (2022:2026)';
date_target = 17;
month_name = (['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec']);

FileDay     = ((datetime(2022,08,29)):days(1):(datetime(2026,3,26)))';
[Yday,Mday,Dday,HRday,MIday,SSday] = datevec(FileDay);

% .....................................................................
% .....................................................................
if flag_unzip==1
    for iy = 1:length(UofT02year)
        if iy ==1; FolderUofT02 = [];      listOfFilesAndFolders02 = [];
            listOfFiles02 = [];            listOfFileNames02 = [];
        end
        [Yday,Mday,Dday] = datevec(datetime(UofT02year(iy),1,1:yeardays(UofT02year(iy)))');

        for in=1:length(Yday)
            for im = 11:14
                command = append('tar -zxvf ', FolderImages, num2str(UofT02year(iy)),slash,'phenocam2.',...
                    num2str(UofT02year(iy)), num2str(Mday(in),'%02i'), num2str(Dday(in),'%02i'), '.tgz',...
                    ' --wildcards "',...
                    'netcam*', num2str(UofT02year(iy)), num2str(Mday(in),'%02i'),...
                    num2str(Dday(in),'%02i'), '_', num2str(im), '*.jpg"',...
                    '  -C  ', FolderImages);
                system (command);
            end
        end
    end

    % %%
    % FileName = [FolderUofT02, slash, 'netcam*', num2str(UofT02year(iy)), '*.jpg'];
    %
    % [FolderUofTcam, files, extension] =  fileparts(FileName); % Separate the filenames string into parts. (The variable version is unused.)
    % listOfFilesAndFolders          =  dir(fullfile(FolderUofTcam, [files, extension])); % Get a list of the files and folders that match the specified filenames.
    % listOfFiles      =  listOfFilesAndFolders([listOfFilesAndFolders.isdir] == 0); % Exclude folders (such as . and ..) from the list, to give a list of files only.
    % listOfFileNames  =  {listOfFiles.name};  % Copy the names of the files into a cell array
    %
    % listOfFilesAndFolders02 = [ listOfFilesAndFolders02; listOfFilesAndFolders];
    % listOfFiles02 = [listOfFiles02;listOfFiles];
    % listOfFileNames02 = [listOfFileNames02;listOfFileNames'];
end

% .........................................................................
%% Reads all images, plots the SZA at the time of the photo
% .........................................................................
if flag_read == 1
    for iy = 1:length(UofT02year)
        if iy ==1
            FolderUofT02 = [];      listOfFilesAndFolders02 = [];
            listOfFiles02 = [];     listOfFileNames02 = [];
        end
        [Yday,Mday,Dday] = datevec(datetime(UofT02year(iy),1,1:yeardays(UofT02year(iy)))');

        % FileName = [FolderImages, num2str(UofT02year(iy)), slash, 'netcam*', num2str(UofT02year(iy)), '*.jpg'];
        FileName = [FolderImages, 'netcam*', '.',num2str(UofT02year(iy)), '*.jpg'];

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
        Y = str2num(x(end-18:end-15));     M = str2double(x(end-14:end-13));   D = str2double(x(end-12:end-11));
        HR = str2double(x(end-9:end-8));   MI = str2double(x(end-7:end-6));
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

    %% .....................................................................
    ind = find((HR>19)|(HR<10)|(SolarZenithAngleDeg>80));
    SolarElevationCorrectedForAtmRefractionDeg(ind)  = [];      SolarZenithAngleDeg(ind) = [];
    Y(ind)  = [];       M(ind) = [];    D(ind) = [];
    HR(ind) = [];       MI(ind) = [];   S(ind) = [];                HRMI(ind) = [];
    FileDate(ind) = [];                 listOfFileNames02(ind) = [];
    % .....................................................................

    [Y1,M1,D1] = datevec(min(FileDate));          [Y2,M2,D2] = datevec(max(FileDate));
    FileDay = ((datetime(Y1,M1,D1)):days(1):(datetime(Y2,M2,D2)))';

    %% ....................................................................
    [Yini,Mini,~] = datevec(min(FileDate));    [Ymax,Mmax,~] = datevec(max(FileDate));
    if Mmax == 12;    Ymax = Ymax+1;         Mmax = 1; end
    month_all  = (datetime(Yini,Mini,1):days(1):datetime(Ymax,Mmax+1,1))';
    [~,~,x]    = datevec(month_all);                month_all(x~=1) = [];
    month_tick = month_all(1:2:end);
end

% .........................................................................
%% Reference
% .........................................................................
if flag_reference_points == 1
    % GCC    = NaN.*FileDate;     RCC    = NaN.*FileDate;     GRRI    = NaN.*FileDate;
    % GCCstd = NaN.*FileDate;     RCCstd = NaN.*FileDate;     GRRIstd = NaN.*FileDate;  %BCC = NaN.*FileDate;
    % [Y,M,D,HR,MI,~] = datevec(FileDate);
    % FileDateDay = datetime(Y,M,D);
    FolderUofT02 = '/home/ncoupe/Documents/Canada/Toronto/UofTcamera02/';

    % ....................................................
    listOfFileNamesPeriods = ["netcam.phenocam2.20220901_110016.jpg";...
        "netcam.phenocam2.20220829_143001.jpg";...02
        "netcam.phenocam2.20220901_110016.jpg";...
        "netcam.phenocam2.20221215_130011.jpg";...
        "netcam.phenocam2.20230101_110010.jpg";...
        "netcam.phenocam2.20230120_120011.jpg";...
        "netcam.phenocam2.20230227_110010.jpg";...
        "netcam.phenocam2.20230328_110013.jpg";...%08
        ];
    pixels = 0;

    for im = 1:length(listOfFileNamesPeriods)
        FileName = listOfFileNamesPeriods{im};
        figure('color','white');
        % [ImageFile] = importdata([FolderUofT02,slash,FileName(24:27),slash,'unzip',slash,FileName]);
        [ImageFile] = importdata([FolderImages,FileName]);
        ImageFile = padarray(ImageFile,[pixels pixels],NaN,'both');
        imshow(ImageFile.*1);      axis image;                 axis off          % Remove axis ticks and numbers
        % text (30,100,['University of Toronto 02 Netcam ' datestr(FileDay(im))],'FontSize',18);
        if im==1
            ImageFileOriginal=ImageFile;
            RefOriginal = [1499,1415;2501,911;476,680;1337,614;428,1244;1214,872;782,1829;...
                1098,1331;2330,1442;1970,548;877,987;898,739;546,895;1985,1520;1856,1103;2192,713;...
                656,1538;1595,722;1052,398;914,1247;1091,1079;1583,1174];
            RefOriginal = RefOriginal+pixels;
            Ref{im}.Distorted = RefOriginal;
            Ref{im}.Date = datetime(2022,07,07,09,0,0);
        end
        if im==2
            RefDistorted =  [1379,1388;2399,860;347,683;1202,593;311,1253;1082,851;689,1837;...
                979,1316;2228,1397;1838,509;749,974;764,725;419,887;1877,1481;1739,1067;2060,671;...
                551,1538;1454,698;905,386;794,1232;968,1058;1460,1145];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2022,08,29,14,0,0);
        end
        if im==3
            RefDistorted =  [1499,1415;2501,911;476,680;1337,614;428,1244;1214,872;782,1829;...
                1098,1331;2330,1442;1970,548;877,987;898,739;546,895;1985,1520;1856,1103;2192,713;...
                656,1538;1595,722;1052,398;914,1247;1091,1079;1583,1174];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2022,09,01,14,0,0);
        end
        if im==4
            RefDistorted =  [1421,1409;2426,881;385,709;1238,611;353,1271;1127,872;713,1847;...
                1021,1335;2270,1415;1880,533;791,995;806,746;476,929;1916,1499;1775,1088;2081,680;...
                587,1556;1499,716;947,401;833,1244;1004,1088;1502,1166];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2022,12,15,14,0,0);
        end
        if im==5
            RefDistorted =  [1421,1409;2426,881;388,707;1238,614;353,1271;1127,872;731,1850;...
                1022,1335;2270,1415;1874,533;791,992;809,746;467,908;1916,1502;1775,1088;2081,683;...
                587,1550;1496,716;947,410;827,1238;1011,1076;1496,1163];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2023,01,01,14,0,0);
        end
        if im==6
            RefDistorted =  [1407,1406;2411,875;369,704;1221,617;338,1274;1108,875;715,1850;...%8
                1006,1335;2253,1410;1859,534;788,1012;786,752;442,916;1899,1498;1757,1089;2069,678;...%next 17
                580,1561;1480,715;935,410;811,1243;991,1086;1481,1169];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2023,01,20,14,0,0);
        end
        if im==7
            RefDistorted =  [1421,1409;2426,881;388,707;1238,614;353,1271;1127,872;731,1850;...
                1022,1335;2270,1415;1874,533;791,992;809,746;467,908;1916,1502;1775,1088;2081,683;...
                587,1550;1496,716;947,410;827,1238;1011,1076;1496,1163];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2023,02,27,14,0,0);
        end
        if im==8
            RefDistorted =  [1401,1410;2408,877;366,703;1218,617;336,1275;1102,876;715,1852;...%next 8
                1003,1336;2250,1411;1856,534;769,1000;784,752;440,917;1898,1500;1756,1088;2083,686;...%next 17
                579,1563;1478,718;925,412;818,1256;990,1088;1481,1171];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2023,03,28,14,0,0);
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
        axis off;   hold off;

        % .................................................................
        %% Estimate transformation
        % .................................................................
        %         tform = fitgeotrans(Ref{im}.Distorted, RefOriginal(1:length(Ref{im}.Distorted),:),'lwm',12);
        %         'nonreflectivesimilarity' | 'similarity' | 'affine' | 'projective'
        tform = fitgeotform2d(Ref{im}.Distorted, RefOriginal(1:length(Ref{im}.Distorted),:),'affine');%polynomial',3);  %'similarity projective'); %'polynomial',2);      % projective affine reflectivesimilarity
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
        save ('Ref_UofT02_20220901.mat','Ref','pixels','RefOriginal')

        if (im==1)& (flag_create_roi==1)
            load ('ROI_UofT02_20220901')
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
        end
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

        % save('ROI_UofT02_20220901.mat','ROI')
    end
    close all

    %% ....................................................
    listOfFileNamesPeriods = ["netcam.phenocam2.20230619_123011.jpg";...
        "netcam.phenocam2.20230405_110017.jpg";...%2
        "netcam.phenocam2.20240112_110010.jpg";...
        "netcam.phenocam2.20240403_110015.jpg";...
        "netcam.phenocam2.20240418_110011.jpg";...
        "netcam.phenocam2.20240901_123010.jpg";...%6
        "netcam.phenocam2.20241204_123011.jpg";...
        "netcam.phenocam2.20250131_123010.jpg";...
        "netcam.phenocam2.20250401_123010.jpg";...%9
        ];  %20230405_110017
    pixels = 0;

    for im = 1:length(listOfFileNamesPeriods)
        FileName = listOfFileNamesPeriods{im};
        figure('color','white');
        % [ImageFile] = importdata([FolderUofT02,slash,FileName(24:27),slash,'unzip',slash,FileName]);
        [ImageFile] = importdata([FolderImages,FileName]);
        ImageFile = padarray(ImageFile,[pixels pixels],NaN,'both');
        imshow(ImageFile.*1);      axis image;                 axis off          % Remove axis ticks and numbers
        % text (30,100,['University of Toronto 02 Netcam ' datestr(FileDay(im))],'FontSize',18);
        if im==1
            ImageFileOriginal=ImageFile;
            RefOriginal = [1226,1409;2222,812;177,774;995,629;188,1349;899,890;602,1895;...
                825,1373;2096,1355;1634,503;575,1043;575,788;263,971;1733,1463;1553,1064;1853,635;...
                440,1607;1256,710;701,437;635,1289;785,1109;1289,1163];
            RefOriginal = RefOriginal+pixels;
            Ref{im}.Distorted = RefOriginal;
            Ref{im}.Date = datetime(2023,04,05,14,0,0);
        end
        if im==2
            RefDistorted =  [1226,1409;2222,812;177,774;995,629;188,1349;899,890;602,1895;...
                825,1373;2096,1355;1634,503;575,1043;575,788;263,971;1733,1463;1553,1064;1853,635;...
                440,1607;1256,710;701,437;635,1289;785,1109;1289,1163];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2023,04,05,15,0,0);
        end
        if im==3
            RefDistorted =  [1192,1412;2194,810;150,771;963,632;162,1343;865,898;580,1899;...
                799,1362;2071,1348;1601,506;545,1042;547,796;227,980;1711,1460;1528,1065;1822,636;...
                416,1617;1224,713;671,443;605,1286;766,1115;1260,1163];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2024,01,12,14,0,0);
        end
        if im==4
            RefDistorted =  [1192,1412;2194,810;150,771;963,632;162,1343;865,898;580,1899;...
                799,1362;2071,1348;1601,506;545,1042;547,796;227,980;1711,1460;1528,1065;1822,636;...
                416,1617;1224,713;671,443;605,1286;766,1115;1260,1163];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2024,04,03,14,0,0);
        end
        if im==5
            RefDistorted =  [1144,1414;2144,792;104,788;946,601;117,1362;815,905;554,1912;...
                757,1371;2024,1336;1547,499;500,1056;496,805;184,995;1667,1454;1475,1063;1766,626;...
                375,1630;1171,715;615,452;568,1288;717,1123;1207,1166];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2024,04,18,14,0,0);
        end
        if im==6
            RefDistorted =  [1144,1414;2144,792;104,788;946,601;117,1362;815,905;554,1912;...
                757,1371;2024,1336;1547,499;500,1056;496,805;184,995;1667,1454;1475,1063;1766,626;...
                375,1630;1171,715;615,452;568,1288;717,1123;1207,1166];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2024,09,01,14,0,0);
        end
        if im==7
            RefDistorted =  [1144,1414;2144,792;104,788;946,601;117,1362;815,905;554,1912;...
                757,1371;2024,1336;1547,499;500,1056;496,805;184,995;1667,1454;1475,1063;1766,626;...
                375,1630;1171,715;615,452;568,1288;717,1123;1207,1166];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2024,12,04,14,0,0);
        end
        if im==8
            RefDistorted =  [1144,1414;2144,792;104,788;946,601;117,1362;815,905;554,1912;...
                757,1371;2024,1336;1547,499;500,1056;496,805;184,995;1667,1454;1475,1063;1766,626;...
                375,1630;1171,715;615,452;568,1288;717,1123;1207,1166];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2025,01,31,14,0,0);
        end
        if im==9
            RefDistorted =  [1144,1414;2144,792;104,788;946,601;117,1362;815,905;554,1912;...
                757,1371;2024,1336;1547,499;500,1056;496,805;184,995;1667,1454;1475,1063;1766,626;...
                375,1630;1171,715;615,452;568,1288;717,1123;1207,1166];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2025,04,01,14,0,0);
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
        tform = fitgeotform2d(Ref{im}.Distorted, RefOriginal(1:length(Ref{im}.Distorted),:),'affine');%polynomial',3);  %'similarity projective'); %'polynomial',2);      % projective affine reflectivesimilarity
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
        save ('Ref_UofT02_20230101.mat','Ref','pixels','RefOriginal')
        %%
        if (im==1)& (flag_create_roi==1)
            load('ROI_UofT02_20230101.mat')
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
        end
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
        % save ('ROI_UofT02_20220901.mat','ROI')
    end


    % % % close all;
    % % % %% ....................................................
    % % % listOfFileNamesPeriods = ["netcam.phenocam2.20240418_110011.jpg";...
    % % %     "netcam.phenocam2.20240418_110011.jpg";...
    % % %     "netcam.phenocam2.20240901_123010.jpg";...
    % % %     "netcam.phenocam2.20241204_123011.jpg";...
    % % %     ];  %20230405_110017
    % % % pixels = 0;
    % % %
    % % % for im = 1:length(listOfFileNamesPeriods)
    % % %     FileName = listOfFileNamesPeriods{im};
    % % %     figure('color','white');
    % % %     % [ImageFile] = importdata([FolderUofT02,slash,FileName(24:27),slash,'unzip',slash,FileName]);
    % % %     [ImageFile] = importdata([FolderImages,FileName]);
    % % %     ImageFile = padarray(ImageFile,[pixels pixels],NaN,'both');
    % % %     imshow(ImageFile.*1);      axis image;                 axis off          % Remove axis ticks and numbers
    % % %     % text (30,100,['University of Toronto 02 Netcam ' datestr(FileDay(im))],'FontSize',18);
    % % %     if im==1
    % % %         ImageFileOriginal=ImageFile;
    % % %         RefOriginal = [1148,1418;2138,791;107,791;908,635;119,1358;812,899;551,1910;...
    % % %             756,1373;2027,1337;1541,500;503,1055;500,803;191,998;1670,1454;1478,1058;1763,626;...
    % % %             380,1631;1169,713;614,449;563,1304;716,1121;1214,1163];
    % % %         RefOriginal = RefOriginal+pixels;
    % % %         Ref{im}.Distorted = RefOriginal;
    % % %         Ref{im}.Date = datetime(2023,04,18,14,0,0);
    % % %     end
    % % %     if im==2
    % % %         RefDistorted =  [1148,1418;2138,791;107,791;908,635;119,1358;812,899;551,1910;...
    % % %             756,1373;2027,1337;1541,500;503,1055;500,803;191,998;1670,1454;1478,1058;1763,626;...
    % % %             380,1631;1169,713;614,449;563,1304;716,1121;1214,1163];
    % % %         Ref{im}.Distorted = RefDistorted+pixels;
    % % %         Ref{im}.Date = datetime(2024,04,18,14,0,0);
    % % %     end
    % % %     if im==3
    % % %         RefDistorted =  [1148,1418;2138,791;107,791;908,635;119,1358;812,899;551,1910;...
    % % %             756,1373;2027,1337;1541,500;503,1055;500,803;191,998;1670,1454;1478,1058;1763,626;...
    % % %             380,1631;1169,713;614,449;563,1304;716,1121;1214,1163];
    % % %         Ref{im}.Distorted = RefDistorted+pixels;
    % % %         Ref{im}.Date = datetime(2024,04,18,14,0,0);
    % % %     end
    % % %     if im==4
    % % %         RefDistorted =  [1148,1418;2138,791;107,791;908,635;119,1358;812,899;551,1910;...
    % % %             756,1373;2027,1337;1541,500;503,1055;500,803;191,998;1670,1454;1478,1058;1763,626;...
    % % %             380,1631;1169,713;614,449;563,1304;716,1121;1214,1163];
    % % %         Ref{im}.Distorted = RefDistorted+pixels;
    % % %         Ref{im}.Date = datetime(2024,04,18,14,0,0);
    % % %     end
    % % %
    % % %     hold on;
    % % %     pause (5);
    % % %     %         plot(RefOriginal(:,1),RefOriginal(:,2), 'co', 'MarkerSize', 15);
    % % %     plot(RefOriginal(:,1),RefOriginal(:,2), 'c.', 'MarkerSize', 15);
    % % %     for ij=1:length(RefOriginal)
    % % %         text(RefOriginal(ij,1),RefOriginal(ij,2), num2str(ij),'color','c','FontSize',20);
    % % %     end
    % % %     plot(Ref{im}.Distorted(:,1),Ref{im}.Distorted(:,2), 'ro', 'MarkerSize', 15);
    % % %     plot(Ref{im}.Distorted(:,1),Ref{im}.Distorted(:,2), 'r.', 'MarkerSize', 15);
    % % %     for ij=1:length(Ref{im}.Distorted)
    % % %         text(Ref{im}.Distorted(ij,1),Ref{im}.Distorted(ij,2), num2str(ij),'color','r','FontSize',20);
    % % %     end
    % % %     axis image off;   hold off;
        % .................................................................
        %% Estimate transformation
        % .................................................................
    % % %     %         tform = fitgeotrans(Ref{im}.Distorted, RefOriginal(1:length(Ref{im}.Distorted),:),'lwm',12);
    % % %     %         'nonreflectivesimilarity' | 'similarity' | 'affine' | 'projective'
    % % %     tform = fitgeotform2d(Ref{im}.Distorted, RefOriginal(1:length(Ref{im}.Distorted),:),'affine');%polynomial',3);  %'similarity projective'); %'polynomial',2);      % projective affine reflectivesimilarity
    % % %     %pause(1)%ask matlab to wait to be sure all variables are updated

    % % %     TransformedMap  = imwarp(ImageFile,tform);
    % % %
    % % %     %         tformInv = invert(tform);               Tinv = tformInv.T;
    % % %     %         ss = Tinv(2,1);                         sc = Tinv(1,1);
    % % %     %         scale_recovered = sqrt(ss*ss + sc*sc);  theta_recovered = atan2(ss,sc)*180/pi;
    % % %
    % % %     Roriginal = imref2d(size(ImageFile));
    % % %     Recovered = imwarp(TransformedMap,tform,'OutputView',Roriginal);
    % % %
    % % %     % % %                 %Compare recovered to original by looking at them side-by-side
    % % %     % % %                 figure('color','white');
    % % %     % % %                 %-- Original figure
    % % %     % % %                 subplot(221)
    % % %     % % %                 imshow(ImageFile);
    % % %     % % %                 % -- Distorted figure
    % % %     % % %                 subplot(222)
    % % %     % % %                 imshow(ImageFileOriginal);
    % % %     % % %                 % -- Transformed figure
    % % %     % % %                 subplot(223)
    % % %     % % %                 imshow(TransformedMap);
    % % %     % % %                 % -- Transformed Resized figure
    % % %     % % %                 subplot(224)
    % % %     % % %                 imshow(Recovered);
    % % %     %%
    % % %     figure('color','white');
    % % %     imshow(Recovered);
    % % %     hold on;
    % % %     plot(RefOriginal(:,1),RefOriginal(:,2), 'ro', 'MarkerSize', 15);
    % % %     plot(RefOriginal(:,1),RefOriginal(:,2), 'r.', 'MarkerSize', 15);
    % % %     plot(Ref{1}.Distorted(:,1),Ref{1}.Distorted(:,2), 'b.', 'MarkerSize', 15);
    % % %     for ij=1:length(RefOriginal)
    % % %         text(RefOriginal(ij,1),RefOriginal(ij,2),num2str(ij),'color','r','FontSize',20);
    % % %         text(Ref{1}.Distorted(ij,1),Ref{1}.Distorted(ij,2),num2str(ij),'color','B','FontSize',20);
    % % %     end
    % % %     axis image off;   hold off;
    % % %     save ('Ref_UofT02_20240101.mat','Ref','pixels','RefOriginal')
    % % %     %%
    % % %     if (im==1)& (flag_create_roi==1)
    % % %         load('ROI_UofT02_20240101.mat')
    % % %         figure('color','white')
    % % %         imshow(ImageFile);                hold on;   pause(2);
    % % %         % % %                 ROI{1}.poly = roipoly
    % % %         % % %                 ROI{2}.poly = roipoly
    % % %         % % %                 ROI{3}.poly = roipoly
    % % %         % % %                 ROI{4}.poly = roipoly
    % % %         % % %                 ROI{5}.poly = roipoly
    % % %         % % %                 ROI{6}.poly = roipoly
    % % %         % % %                 ROI{7}.poly = roipoly
    % % %         % % %                 ROI{8}.poly = roipoly
    % % %         % % %                 ROI{9}.poly = roipoly
    % % %         % % %                 ROI{10}.poly = roipoly
    % % %         % % %                 ROI{11}.poly = roipoly
    % % %         % % %                 ROI{12}.poly = roipoly
    % % %         % % %                 ROI{13}.poly = roipoly
    % % %         %%
    % % %         for ix = 1:length(ROI)
    % % %             ROI{ix}.poly = double(ROI{ix}.poly);
    % % %             ROI{ix}.poly(ROI{ix}.poly==0) = NaN;
    % % %         end
    % % %         hold on;
    % % %         for ix = 1:length(ROI)
    % % %             [B] = bwboundaries(int16(ROI{ix}.poly),'noholes');      Boundary{ix}.poly = B;
    % % %         end
    % % %
    % % %         color_mxt=flipud(jet(length(ROI)));
    % % %         for ix = 1:length(Boundary)
    % % %             display (ix)
    % % %             boundary = cell2mat(Boundary{ix}.poly);
    % % %             plot(boundary(:,2), boundary(:,1), 'color',color_mxt(ix,:), 'LineWidth', 2)
    % % %             pgon = polyshape(boundary(:,2), boundary(:,1));
    % % %             [x,y] = centroid(pgon);
    % % %             text(x,y,num2str(ix),'color',color_mxt(ix,:),'FontSize',18);
    % % %             ROI{ix}.centroidX = x;
    % % %             ROI{ix}.centroidY = y;
    % % %         end
    % % %         % text(100,100,datestr(FileDate(ik)));
    % % %         % save ('ROI_UofT02_20230101.mat','ROI')
    % % %     end
    % % % end
end
