% % Reads the images, visual checks and help you set the georeference points
% % Natalia Restrepo Coupe
% % 121208 Sydney, Australia
% % Toronto	construction camera video
%..........................................................................
%..........................................................................
% sudo matlab -nojvm -nodisplay -nosplash
warning off

flag_unix = 0;                       flag_filename =1;
flag_read = 1;                      flag_figures = 1;
flag_check = 1;
flag_reference_points = 1;

if flag_unix == 1
    %     FolderOZflux = 'C:\Users\ncoupe\Documents\OZ\OZflux\';
    slash = '\';
    addpath \Users\ncoupe\Documents\OZ\
    addpath \Users\ncoupe\Documents\Amazon\
else
    FolderFlux   = '/home/ncoupe/Documents/Amazon/AllSites/';
    FolderImages = '/media/ncoupe/Expansion/Data/Canada/Toronto/Phenocam/Scarborough/';
    FolderTRMM   = '/home/ncoupe/Documents/AmazonRS/TRMM/TRMMsites/';
    FolderSBG    = '/home/ncoupe/Documents/Canada/Toronto/Scarborough/';
    slash = '/';
    addpath /home/ncoupe/Documents/OZ/
    addpath /home/ncoupe/Documents/Amazon/
end

% .........................................................................
% % load ('Ref_HP01.mat');
% % load ('ROI_HP01.mat')
% %
% .........................................................................
month_name = (['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec']);


[site_name_FN, lat_FN, lon_FN, site_long_FN, year_ini, year_end, siteelevation_FN,...
    height_FN, canopy_FN, ust_tresh_FN, sunrise_FN, sunset_FN, utm_FN, ust_min_FN, ust_max_FN,...
    LAI_FN]  =  textread([FolderFlux 'sites_loc.txt'],...
    '%s	%f	%f	%s	%f	%f	%f	%f %f	%f	%f	%f	%f	%f	%f	%f',...
    'delimiter',',','headerlines', 1);
ip = 17;
lat = lat_FN(ip);                           lon = lon_FN(ip);
date_target = 17;

%% camera movements: 1176-1177, 2173-2174 (different poster green shack... may have a lag
listOfFileNames = [];
SBG01year = (2025:2026)';

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
    for ik = 1:length(listOfFileNames)
        x = listOfFileNames{ik};
        Y = str2double(x(end-22:end-19));     M = str2double(x(end-17:end-16));   D = str2double(x(end-14:end-13));
        HR = str2double(x(end-11:end-10));	  MI = str2double(x(end-8:end-7));
        FileDate(ik) = datetime(Y,M,D,HR,MI,0);
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
    JD  = day(FileDate,'dayofyear');
    lat = 43.663889;                           lon = -43.663889;
    HRMI = HR+(MI/60);
    [SolarZenithAngleDeg,SolarElevationCorrectedForAtmRefractionDeg,SolarNoonLSThour]=...
        AM_solar_radNOAA(JD,HRMI,Y,lat,lon);

    % %     % .....................................................................
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

    % %     % .....................................................................
    ind = find(HR>19);              %|(SolarZenithAngleDeg>80));
    SolarElevationCorrectedForAtmRefractionDeg(ind)  = [];      SolarZenithAngleDeg(ind) = [];
    Y(ind)  = [];   M(ind) = [];    D(ind) = [];
    HR(ind) = [];	MI(ind) = [];   S(ind) = [];                HRMI(ind) = [];
    FileDate(ind) = [];             listOfFileNames(ind) = [];
    % .....................................................................

    [Y1,M1,D1] = datevec(min(FileDate));          [Y2,M2,D2] = datevec(max(FileDate));
    FileDay = ((datetime(Y1,M1,D1)):1:(datetime(Y2,M2,D2)))';

    % % %     %% ....................................................................
    % % %     [Yini,Mini,~] = datevec(min(FileDate));  [Ymax,Mmax,~] = datevec(max(FileDate));
    % % %     if Mmax == 12;    Ymax = Ymax+1;         Mmax = 1; end
    % % %     month_all  = (datetime(Yini,Mini,1):1:datetime(Ymax,Mmax+1,1))';
    % % %     [~,~,x]    = datevec(month_all);         month_all(x~=1) = [];
    % % %     month_tick = month_all(1:2:end);
    % % %
    % % %     [Y_gpm,M_gpm,D_gpm,month_prec_gpm] = ...
    % % %         textread([FolderGPM 'TOR_gpm.dat'],'%f %f %f %f','headerlines',1);
    % % %     month_date_gpm = datetime(Y_gpm,M_gpm,D_gpm);listOfFileNames
    % % %     month_prec_gpm = interp1(month_prec_gpm,month_date_gpm,month_all);
    % % %
    % % %     month_avgGPM = AM_month_avg(month_prec_gpm(~isnan(month_prec_gpm)),month_date_gpm(~isnan(month_prec_gpm)));
end
close all;

%%
if flag_check==1
    for ik = 1:300:length(listOfFileNames)
        ij = listOfFileNames{ik};     FolderImagesYear = [FolderImages, ij(16:19)];
        figure('color','white');
        [ImageFile] = importdata([FolderImagesYear,slash,listOfFileNames{ik}]);
        imshow(ImageFile);      axis image;                 axis off          % Remove axis ticks and numbers
        text (30,50,['Toronto: ' listOfFileNames{ik}],'FontSize',18,'color','white');
        hold on;
        RefPoints = [100,100;200,200;300,300];
        for ij=1:length(RefPoints)
            text(RefPoints(ij,1),RefPoints(ij,2), num2str(ij),'color','r','FontSize',20);
        end
        close
    end
end

%%
if flag_reference_points == 1
    [Y,M,D,HR,MI,~] = datevec(FileDate);
    FileDateDay = datetime(Y,M,D);

    listOfFileNamesPeriods = ["SBG_oblique_01_2023_05_26_19_00_00.jpg";...
        "SBG_oblique_01_2023_05_05_19_32_00.jpg";...
        "SBG_oblique_01_2023_05_26_19_00_00.jpg";...
        "SBG_oblique_01_2023_08_01_19_00_00.jpg";...
        "SBG_oblique_01_2023_08_17_19_00_00.jpg";...
        "SBG_oblique_01_2024_01_10_19_00_00.jpg";...
        "SBG_oblique_01_2024_04_10_19_00_00.jpg";...
        "SBG_oblique_01_2024_09_01_19_00_00.jpg";...
        "SBG_oblique_01_2025_03_01_19_00_00.jpg";...
        ];
    pixels = 0;

    for im = 1:length(listOfFileNamesPeriods)
        ix = listOfFileNamesPeriods{im};
        figure('color','white');
        [ImageFile] = importdata([FolderImages,slash,ix(16:19),slash,ix]);
        ImageFile = padarray(ImageFile,[pixels pixels],NaN,'both');
        imshow(ImageFile.*1);      axis image;                 axis off          % Remove axis ticks and numbers
        text (30,300,['Scarborough Toronto 01 Site ' (listOfFileNamesPeriods(im))],'FontSize',18);
        if im==1
            RefOriginal =  [1063,842;2359,883;4211,758;...
                2326,1442;2979,1358;2037,1245];
            RefOriginal = RefOriginal+pixels;
            Ref{im}.Distorted = RefOriginal;
            Ref{im}.Date = datetime(2023,05,01);
        end
        if im==2
            RefDistorted =  [47,2188;1431,1522;2063,1506;...
                39,2190;1403,2158];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2023,05,05);
        end
        if im==3
            RefDistorted =  [1063,842;2359,883;4211,758;...
                2326,1442;2979,1358;2037,1245];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2023,05,26);
        end
        if im==4
            RefDistorted =  [1074,863;2372,906;4214,782;2331,1465;2986,1376;2044,1263];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2023,08,01);
        end
        if im==5
            RefDistorted =  [1074,863;2372,906;4214,782;2331,1465;2986,1376;2044,1263];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2023,08,17);
        end
        if im==6
            RefDistorted =  [1155,870;2443,898;4290,766;...
                2419,1474;3066,1370;2123,1254];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2024,01,10);
        end
        if im==7
            RefDistorted =  [1175,870;2463,898;4310,766;...
                2399,1469;3086,1370;2144,1267];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2024,04,10);
        end
        if im==8
            RefDistorted =  [1175,870;2463,898;4310,766;...
                2399,1469;3086,1370;2144,1267];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2024,09,01);
        end
        if im==9
            RefDistorted =  [1175,870;2463,898;4310,766;...
                2399,1469;3086,1370;2144,1267];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2024,03,01);
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
    save ('Ref_SBG01_20230501.mat','Ref','pixels','RefOriginal')
end


% .........................................................................
%% Initial possition
% .........................................................................
if flag_reference_points == 1
    [Y,M,D,HR,MI,~] = datevec(FileDate);
    FileDateDay = datetime(Y,M,D);

    listOfFileNamesPeriods = ["SBG_oblique_01_2022_10_01_19_00_00.jpg";... %1
        "SBG_oblique_01_2022_09_01_19_35_00.jpg";...
        "SBG_oblique_01_2022_10_01_19_00_00.jpg";...
        "SBG_oblique_01_2023_01_01_19_00_00.jpg";...
        "SBG_oblique_01_2023_04_05_19_30_00.jpg";...
        ];
    pixels = 0;

    for im = 1:length(listOfFileNamesPeriods)
        ix = listOfFileNamesPeriods{im};
        figure('color','white');
        [ImageFile] = importdata([FolderImages,slash,ix(16:19),slash,ix]);
        ImageFile = padarray(ImageFile,[pixels pixels],NaN,'both');
        imshow(ImageFile.*1);      axis image;                 axis off          % Remove axis ticks and numbers
        text (30,300,['Scarborough Toronto 01 Site ' (listOfFileNamesPeriods(im))],'FontSize',18);
        if im==1
            ImageFileOriginal=ImageFile;
            RefOriginal = [6023,2526;...
                4691,3105;2491,2298;81,2234];
            RefOriginal = RefOriginal+pixels;
            Ref{im}.Distorted = RefOriginal;
            Ref{im}.Date = datetime(2020,01,1);
        end
        if im==2
            RefDistorted =  [6023,2526;...
                4691,3105;2491,2298;81,2234];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2022,09,01);
        end
        if im==3
            RefDistorted =  [6023,2526;...
                4691,3105;2491,2298;81,2234];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2022,10,01);
        end
        if im==4
            RefDistorted =  [6023,2526;...
                4691,3105;2491,2298;81,2234];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2023,01,01);
        end
        if im==5
            RefDistorted =  [6023,2526;...
                4691,3105;2491,2298;81,2234];
            Ref{im}.Distorted = RefDistorted+pixels;
            Ref{im}.Date = datetime(2023,04,05);
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
    save ('Ref_SBG01_20220101.mat','Ref','pixels','RefOriginal')
end
% close all
