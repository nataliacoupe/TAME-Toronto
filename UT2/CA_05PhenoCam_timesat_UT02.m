flag_unix = 10;
flag_timesat = 10;    flag_read_timesat =1;     flag_timesat_compare =1;


if flag_unix == 1
    slash = '\';
else
    FolderImages = '/media/ncoupe/Expansion/Data/Canada/Toronto/Phenocam/UofTcamera02/';
    slash = '/';
    addpath /home/ncoupe/Documents/OZ/
    addpath /home/ncoupe/Documents/Amazon/

    addpath /home/ncoupe/Documents/timesat33/timesat_matlab/main/
    addpath /home/ncoupe/Documents/timesat33/timesat_matlab/tools/
    addpath /home/ncoupe/Documents/timesat33/timesat_matlab/
end

load 'dayUofT02.mat'
load('ROI_UofT02_20240101.mat');
colormap('jet');

[UofT02.dayY,UofT02.dayM,UofT02.dayD] = datevec(FileDay);
% dayfill = (datetime(2023,1,1):days(1):datetime(SBG.dayY(end)+1,12,31))';
roiLength = width(ROI);
date2remove = datetime(2022,1,1);
if flag_timesat==1
    ind  = find(FileDay>date2remove);
    ind0 = (datetime(2022,1,1):days(1):datetime(Yday(ind(1)),Mday(ind(1)),Dday(ind(1))-1))';
    indX = (datetime(Yday(end),Mday(end),Dday(end)+1):days(1):datetime(Yday(end)+1,12,31))';
    dayfill = [ind0;FileDay(ind);indX];

    %% average VI
    ix = FileDayGRRI.ROIavg;                         ix = AM_fill_plus(ix);   %ix(ix<0.89)=NaN;
    ix(~ind) = NaN;
    ix = interp1(FileDay(ind),ix(ind),dayfill);
    [ix] = AM_fill_day_cycle(ix,dayfill,6,18);

    figure('color','white'); plot(dayfill,ix,'LineWidth',2); hold on;
    iy = dayfill;
    iy(isnan(ix)) = [];     ix(isnan(ix)) = [];
    FileDayGRRIcomposite = interp1(iy,ix,dayfill);
    plot(dayfill,FileDayGRRIcomposite);   datetick('x');  ylabel('GRRI');

    FileDayGRRIcomposite = [FileDayGRRIcomposite;FileDayGRRIcomposite;FileDayGRRIcomposite];

    tableSBGtimesat = table(FileDayGRRIcomposite);
    tableSBGtimesat.Properties.VariableNames = {'3 365 1'};
    writetable (tableSBGtimesat,'timesat/tableSBGtimesatGRRI.txt');

    %%
    ix = FileDayGCC.ROIavg;                          ix = AM_fill_plus(ix);
    ix(~ind) = NaN;
    ix = interp1(FileDay(ind),ix(ind),dayfill);
    [ix] = AM_fill_day_cycle(ix,dayfill,6,18);

    figure('color','white'); plot(dayfill,ix,'LineWidth',2); hold on;
    iy = dayfill;   iy(isnan(ix)) = [];     ix(isnan(ix)) = [];
    FileDayGCCcomposite = interp1(iy,ix,dayfill);
    plot(dayfill,FileDayGCCcomposite);   datetick('x');  ylabel('ExGREEN');

    FileDayGCCcomposite = [FileDayGCCcomposite;FileDayGCCcomposite;FileDayGCCcomposite];

    tableSBGtimesat = table(FileDayGCCcomposite);
    tableSBGtimesat.Properties.VariableNames = {'3 365 1'};
    writetable (tableSBGtimesat,'timesat/tableSBGtimesatGCC.txt');

    %% ROI
    ind  = find(FileDateAll>date2remove);
    [Y,M,D] = datevec(FileDateAll);
    ind0 = (datetime(2022,1,1):days(1):datetime(Y(ind(end)),M(ind(end)),D(ind(end))-1))';
    indX = (datetime(Y(end),M(end),D(end)+1):days(1):datetime(Y(end)+1,12,31))';

    figure('color','white');
    for ix = 1:roiLength
        iy = TableExGREENroiAvgAll(ind,ix);
        iw = smoothdata(iy,'movmean',3);        %iw(isnan(iy)) = NaN;   iy = iw;
        plot(FileDateAll(ind),iy);   hold on;
        [im,~,iz,~,daySelect] = AM_day(iw,FileDateAll(ind),1);     im(iz<1) = NaN;
        if ix==1
            dayExGREENroi = NaN(length(dayfill),width(TableExGREENroiAvgAll));
        end
        dayExGREENroi(:,ix) = interp1(daySelect,im,dayfill);
    end

    for ix = 1:roiLength
        iy = dayExGREENroi(:,ix);
        dayExGREENroi(:,ix) = AM_fill_day_avg(iy,dayfill);
    end
    v1 = -15.; v2 = 45;               v3 = v1:((v2-v1)/4):v2;
    figure('color','white','Position',[50 50 1300 500],'units','inches');
    plot(dayfill,dayExGREENroi,'.')
    set(gca,'YTick',v3,'YLim',[v1 v2],'FontSize',14);      xtickangle(0);
    ylabel ({'ExGREEN_{normalized}'}); grid on;

    header = [num2str(round(length(dayExGREENroi)./365)) ' 365 ' num2str(roiLength) ];
    writematrix (dayExGREENroi','timesat/tabletimesatExGREEN.txt','Delimiter','tab');
    S = fileread('timesat/tabletimesatExGREEN.txt');
    S = [header, newline, S];
    fid = fopen('timesat/tabletimesatExGREENroi.txt', 'w');
    if fid == -1, error('Cannot open file %s', FileName); end
    fwrite(fid, S, 'char');
    fclose(fid);

    %% .....................................................................
    figure('color','white');
    for ix = 1:roiLength
        iy = TableGCCroiAvgAll(ind,ix);
        iw = smoothdata(iy,'movmean',3);        %iw(isnan(iy)) = NaN;   iy = iw;
        plot(FileDateAll(ind),iy);   hold on;
        [im,~,iz,~,daySelect] = AM_day(iw,FileDateAll(ind),1);     im(iz<1) = NaN;
        if ix==1
            dayGCCroi = NaN(length(dayfill),width(TableGCCroiAvgAll));
        end
        dayGCCroi(:,ix) = interp1(daySelect,im,dayfill);
    end

    for ix = 1:roiLength
        iy = dayGCCroi(:,ix);
        dayGCCroi(:,ix) = AM_fill_day_avg(iy,dayfill);
    end
    v1 = 0.3; v2 = .4;               v3 = v1:((v2-v1)/5):v2;
    figure('color','white','Position',[50 50 1300 500],'units','inches');
    plot(dayfill,dayGCCroi,'.')
    set(gca,'YTick',v3,'YLim',[v1 v2],'FontSize',14);      xtickangle(0);
    ylabel ({'GCC_{normalized}'}); grid on;

    header = [num2str(round(length(dayGCCroi)./365)) ' 365 ' num2str(roiLength) ];
    writematrix (dayGCCroi','timesat/tabletimesatGCC.txt','Delimiter','tab');
    S = fileread('timesat/tabletimesatGCC.txt');
    S = [header, newline, S];
    fid = fopen('timesat/tabletimesatGCCroi.txt', 'w');
    if fid == -1, error('Cannot open file %s', FileName); end
    fwrite(fid, S, 'char');
    fclose(fid);

    %% .....................................................................
    figure('color','white');
    for ix = 1:roiLength
        iy = TableRCCroiAvgAll(ind,ix);
        iw = smoothdata(iy,'movmean',3);        %iw(isnan(iy)) = NaN;   iy = iw;
        plot(FileDateAll(ind),iy);   hold on;
        [im,~,iz,~,daySelect] = AM_day(iw,FileDateAll(ind),1);     im(iz<1) = NaN;
        if ix==1
            dayRCCroi = NaN(length(dayfill),width(TableRCCroiAvgAll));
        end
        dayRCCroi(:,ix) = interp1(daySelect,im,dayfill);
    end

    for ix = 1:roiLength
        iy = dayRCCroi(:,ix);
        dayRCCroi(:,ix) = AM_fill_day_avg(iy,dayfill);
    end

    v1 = 0.25; v2 = .5;               v3 = v1:((v2-v1)/5):v2;
    figure('color','white','Position',[50 50 1300 500],'units','inches');
    plot(dayfill,dayRCCroi)
    set(gca,'YTick',v3,'YLim',[v1 v2],'FontSize',14);      xtickangle(0);
    ylabel ({'RCC_{normalized}'}); grid on;

    % 'tabletimesatRCCabsroi'
    header = [num2str(round(length(dayRCCroi)./365)) ' 365 ' num2str(roiLength) ];
    writematrix (1-dayRCCroi','timesat/tabletimesatRCCabsroi.txt','Delimiter','tab');
    S = fileread('timesat/tabletimesatRCCabsroi.txt');
    S = [header, newline, S];
    fid = fopen('timesat/tabletimesatRCCabsroi.txt', 'w');
    if fid == -1, error('Cannot open file %s', FileName); end
    fwrite(fid, S, 'char');
    fclose(fid);

    %% GRRI
    figure('color','white');
    for ix = 1:roiLength
        iy = TableGRRIroiAvgAll(ind,ix);
        iw = smoothdata(iy,'movmean',3);        %iw(isnan(iy)) = NaN;   iy = iw;
        plot(FileDateAll(ind),iy);   hold on;
        [im,~,iz,~,daySelect] = AM_day(iw,FileDateAll(ind),1);     im(iz<1) = NaN;
        if ix==1
            dayGRRIroi = NaN(length(dayfill),width(TableGRRIroiAvgAll));
        end
        dayGRRIroi(:,ix) = interp1(daySelect,im,dayfill);
    end

    for ix = 1:roiLength
        iy = dayGRRIroi(:,ix);
        dayGRRIroi(:,ix) = AM_fill_day_avg(iy,dayfill);
    end
    v1 = .7; v2 = 1.2;               v3 = v1:((v2-v1)/4):v2;
    figure('color','white','Position',[50 50 1300 500],'units','inches');
    plot(dayfill,dayGRRIroi,'.')
    set(gca,'YTick',v3,'YLim',[v1 v2],'FontSize',14);      xtickangle(0);
    ylabel ({'GRRI_{normalized}'}); grid on;

    header = [num2str(round(length(dayGRRIroi)./365)) ' 365 ' num2str(roiLength) ];
    writematrix (dayGRRIroi','timesat/tabletimesatGRRI.txt','Delimiter','tab');
    S = fileread('timesat/tabletimesatGRRI.txt');
    S = [header, newline, S];
    fid = fopen('timesat/tabletimesatGRRIroi.txt', 'w');
    if fid == -1, error('Cannot open file %s', FileName); end
    fwrite(fid, S, 'char');
    fclose(fid);

    % save('matlab_leaf.mat','camera','-append');
    % timesat
end


%% ........................................................................
if flag_read_timesat==1
    count = 0;
    dayfill = (datetime(Yday(1),1,1):days(1):datetime(Yday(end)+1,12,31))';
    % Initialize variables.
    filename = (char(strcat('/home/ncoupe/Documents/Canada/Toronto/UofTcamera02/timesat/GCCseasonalityROI.txt')));
    startRow = 2;
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%3f%13f%13f%13f%13f%13f%13f%13f%13f%13f%13f%13f%13f%13f%C%[^\n\r]';
    % Open the text file.
    fileID = fopen(filename,'r');
    % Read columns of data according to the format.
    % This call is based on the structure of the file used to generate this code. If an error occurs for a different file, try regenerating the code from the Import Tool.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    % Close the text file.
    fclose(fileID);
    % Allocate imported array to column variable names
    idROI = dataArray{:, 1};      Col = dataArray{:, 2};
    Seas = dataArray{:, 3};       BegTtemp = dataArray{:, 4};    EndTtemp = dataArray{:, 5};
    LengthVal= dataArray{:, 6};   Baseval = dataArray{:, 7};     MaxTtemp = dataArray{:, 8};
    MaxVal = dataArray{:, 9};     Ampl = dataArray{:, 10};       Lder = dataArray{:, 11};
    Rder = dataArray{:, 12};      Linteg = dataArray{:, 13};     Sinteg = dataArray{:, 14};
    StartVal = dataArray{:, 15};  EndVa = dataArray{:, 16};    % l = dataArray{:, 17};

    BegTtemp(BegTtemp<=0) = NaN;    EndTtemp(EndTtemp<=0) = NaN;
    MaxTtemp(MaxTtemp<=0) = NaN;    LengthVal(LengthVal<=0) = NaN;
    LengthVal = AM_fill_plus(LengthVal);

    % .................................................................
    BegTdate = NaT(length(BegTtemp),1);     EndTdate = BegTdate;
    MaxTdate = BegTdate;
    for ix = 1:length(BegTtemp)
        % % while BegT(ix)>365;     BegT(ix) = BegT(ix)-365;	end
        % % while EndT(ix)>365;     EndT(ix) = EndT(ix)-365;	end
        % % while MaxT(ix)>365;     MaxT(ix) = MaxT(ix)-365;	end
        if ~isnan(BegTtemp(ix));   BegTdate(ix) = dayfill(ceil(BegTtemp(ix)));   end
        if ~isnan(EndTtemp(ix));   EndTdate(ix) = dayfill(floor(EndTtemp(ix)));  end
        if ~isnan(MaxTtemp(ix));   MaxTdate(ix) = dayfill(floor(MaxTtemp(ix)));  end
    end

    BegTjd = day(BegTdate,'dayofyear');
    EndTjd = day(EndTdate,'dayofyear');
    MaxTjd = day(MaxTdate,'dayofyear');

    ind = find((BegTdate<FileDay(1))|(BegTdate>FileDay(end)));
    BegT = BegTjd;   BegT(ind) = NaN;   BegTdate(ind) = NaT;   LengthVal(ind) = NaN;
    ind = find((EndTdate<FileDay(1))|(EndTdate>FileDay(end)));
    EndT = EndTjd;   EndTjd(ind) = NaN;   EndTdate(ind) = NaT;
    ind = find((MaxTdate<FileDay(1))|(MaxTdate>FileDay(end)));
    MaxT = MaxTjd;   MaxTjd(ind) = NaN;   MaxTdate(ind) = NaT;

    % Clear temporary variables
    clearvars filename startRow formatSpec fileID dataArray ans;


    ind = find((BegT>160)|(BegT<80)|(isnan(BegT)));
    BegTdate(ind) = NaT;     BegT(ind) = NaN;      BegTjd(ind) = NaN;
    LengthVal(LengthVal>300) = NaN;
    ind = find(EndT<200);
    EndTdate(end) = NaT;     EndT(ind) = NaN;      EndTjd(ind) = NaN;

    %% ..................................................
    disp('Grass')
    select = find(ismember(idROI, [2,4]));
    disp('SGS: '); round(mean(day(BegTdate(select),'dayofyear'),'omitnan'))
    round(std(day(BegTdate(select),'dayofyear'),'omitnan'))
    disp('EGS: '); round(mean(day(EndTdate(select),'dayofyear'),'omitnan'))
    round(std(day(EndTdate(select),'dayofyear'),'omitnan'))
    disp('LGS: '); round(mean(LengthVal(select),'omitnan'))
    round(std(LengthVal(select),'omitnan'))

    % % disp('Evergreen')
    % % select = find(ismember(idROI, [44, 45, 95, 96]));
    % % disp('SGS: '); round(mean(day(BegTdate(select),'dayofyear'),'omitnan'))
    % % round(std(day(BegTdate(select),'dayofyear'),'omitnan'))
    % % disp('EGS: '); round(mean(day(EndTdate(select),'dayofyear'),'omitnan'))
    % % round(std(day(EndTdate(select),'dayofyear'),'omitnan'))
    % % disp('LGS: '); round(mean(LengthVal(select),'omitnan'))
    % % round(std(LengthVal(select),'omitnan'))

    disp('Deciduous')
    select = find(ismember(idROI, [1,5,6,40,14]));
    disp('SGS: '); round(mean(day(BegTdate(select),'dayofyear'),'omitnan'))
    round(std(day(BegTdate(select),'dayofyear'),'omitnan'))
    disp('EGS: '); round(mean(day(EndTdate(select),'dayofyear'),'omitnan'))
    round(std(day(EndTdate(select),'dayofyear'),'omitnan'))
    disp('LGS: '); round(mean(LengthVal(select),'omitnan'))
    round(std(LengthVal(select),'omitnan'))

    %% ..................................................
    color_mtx_dark = [0.67,0.87,0.64;0.1,0.17,0.73;0.89,0.68,0.38;0.84,0.10,0.11;...
        0.64,0.10,0.11;0.47,0.67,0.44];%jet(6);%othercolor('Dark28',16);
    color_mtx_light =color_mtx_dark;
    NofBins = 50;

    x = 0:1:365;         count =2;
    y1=0;     y2=40;     y3 = (y1:(y2-y1)/4:y2)';
    x1=0;     x2=365;    x4 = x1:50:x2;       x3 = (x1:50:x2)';
    figure('color','white','Position',[100 100 800 700]);
    subplot(2,2,1);
    [muhat.BegT,sigmahat.BegT,muci.BegT,sigmaci.BegT]= normfit(BegT(~isnan(BegT)));
    n = numel(BegT);
    [bincounts,binedges] = histcounts(BegT,NofBins);
    bincenters = binedges(1:end-1)+diff(binedges)/2;
    hh = bar(bincenters,bincounts,1,'FaceColor',color_mtx_light(count,:),'EdgeColor',color_mtx_light(count,:));
    alpha(hh,.3);          hold on
    binwidth = binedges(2)-binedges(1); % Finds the width of each bin
    areabin = n * binwidth;
    %         pd = fitdist(BegT,'Gamma');  mu = pd.a*pd.b;    sigma = sqrt(pd.a*pd.b^2);
    pd = fitdist(BegT,'tLocationScale');  mu = pd.mu;    sigma = pd.sigma;
    y = areabin * pdf(pd,x);
    hh1 = plot(x,y,'-','color',color_mtx_dark(count,:),'LineWidth',2);
    axis ([x1 x2 0 15]);
    %         xlabel({'start season (DOY)';['\mu DOY:' num2str(round(muhat.BegT)) ' \sigma:' num2str(round(sigmahat.BegT)) 'days']});
    xlabel({'start season (DOY)';...
        ['\mu DOY:' num2str(round(mu)) ' \sigma:' num2str(round(sigma)) ' [CI\sigma:' num2str(round(sigmaci.BegT(1))) '-' num2str(round(sigmaci.BegT(2))) '] days']});
    ylabel({'% individual crowns';['ROI:' num2str(roiLength) ' years:' num2str(round(length(FileDay)/365))]});
    %returns 95% confidence intervals for the rgsameter estimates on the mean
    % text(50,8,[site_name(ip)],'FontWeight','normal');
    set(gca,'XTick',x4,'XTickLabel',x3,'YTick',y3,'XLim',[x1 x2],'YLim',[y1 y2],'FontSize',12);
    xtickangle(0);    grid on;

    subplot(2,2,2);
    % if ip==3
    %     EndT(EndT<200) = EndT(EndT<200)+365;
    %     x1=200;     x2=565;     x4 = [(200:50:365)';(415:50:565)'];
    %     x3 = [(200:50:365)';(50:50:200)'];
    %     x = 200:1:565;
    % end
    [muhat.EndT,sigmahat.EndT,muci.EndT,sigmaci.EndT]= normfit(EndT);
    n = numel(EndT);
    [bincounts,binedges] = histcounts(EndT,NofBins);
    bincenters = binedges(1:end-1)+diff(binedges)/2;
    hh = bar(bincenters,bincounts,1,'FaceColor',color_mtx_light(count,:),'EdgeColor',color_mtx_light(count,:));
    alpha(hh,.3);      hold on
    binwidth = binedges(2)-binedges(1); % Finds the width of each bin
    areabin = n * binwidth;
    %         pd = fitdist(EndT,'Gamma');  mu = pd.a*pd.b;    sigma = sqrt(pd.a*pd.b^2);
    pd = fitdist(EndT,'tLocationScale');  mu = pd.mu;    sigma = pd.sigma;
    y = areabin * pdf(pd,x);
    hh1 = plot(x,y,'-','color',color_mtx_dark(count,:),'LineWidth',2);
    axis ([x1 x2 0 15]);
    %         xlabel({'end season (DOY)';['\mu DOY:' num2str(round(muhat.EndT)) ' \sigma:' num2str(round(sigmahat.EndT)) 'days']});
    % if ip==3
    %     mu = mu-365;
    % end
    xlabel({'end season (DOY)';...
        ['\mu DOY:' num2str(round(mu)) ' \sigma:' num2str(round(sigma)) 'days']});
    set(gca,'XTick',x4,'XTickLabel',x3,'YTick',y3,'XLim',[x1 x2],'YLim',[y1 y2],'FontSize',12);
    xtickangle(0);   grid on;

    x = 1:1:365;
    x1=0;     x2=365;     x4 = x1:50:x2;       x3 = [(x1:50:x2)'];
    subplot(2,2,3);
    [muhat.LengthVal,sigmahat.LengthVal,muci.LengthVal,sigmaci.LengthVal]= normfit(LengthVal);
    n = numel(LengthVal);
    [bincounts,binedges] = histcounts(LengthVal,NofBins);
    bincenters = binedges(1:end-1)+diff(binedges)/2;
    hh = bar(bincenters,bincounts,1,'FaceColor',color_mtx_light(count,:),'EdgeColor',color_mtx_light(count,:));
    alpha(hh,.3);      hold on
    binwidth = binedges(2)-binedges(1); % Finds the width of each bin
    areabin = n * binwidth;
    %         pd = fitdist(LengthVal,'Gamma');  mu = pd.a*pd.b;    sigma = sqrt(pd.a*pd.b^2);
    pd = fitdist(LengthVal,'tLocationScale');  mu = pd.mu;    sigma = pd.sigma;
    y = areabin * pdf(pd,x);
    hh1 = plot(x,y,'-','color',color_mtx_dark(count,:),'LineWidth',2);
    axis ([x1 x2 0 15]);
    %         xlabel({'length season (no. days)';['\mu:' num2str(round(muhat.LengthVal)) 'days \sigma:' num2str(round(sigmahat.LengthVal)) 'days']});
    xlabel({'length season (no. days)';...
        ['\mu DOY:' num2str(round(mu)) ' \sigma:' num2str(round(sigma)) 'days']});
    ylabel({'% individual crowns';['ROI:' num2str(roiLength) ' years:' num2str(round(length(FileDay)/365))]});
    set(gca,'XTick',x3,'XTickLabel',x3,'YTick',y3,'XLim',[x1 x2],'YLim',[y1 y2],'FontSize',12);
    xtickangle(0);   grid on;

    y1=0;         y2=40;     y3 = (y1:(y2-y1)/4:y2)';
    x = 1:1:365;
    x1=0;         x2=365;    x4 = x1:50:x2;       x3 = [(x1:50:x2)'];
    subplot(2,2,4);
    %         if ip==5
    [muhat.MaxT,sigmahat.MaxT,muci.MaxT,sigmaci.MaxT]= normfit(MaxT);
    % Do histogram calculations
    n = numel(MaxT);
    [bincounts,binedges] = histcounts(MaxT,NofBins);
    bincenters = binedges(1:end-1)+diff(binedges)/2;
    % Plot the histogram with no gap between bars.
    hh = bar(bincenters,bincounts,1,'FaceColor',color_mtx_light(count,:),'EdgeColor',color_mtx_light(count,:));
    alpha(hh,.3);      hold on
    % Normalize the density to match the total area of the histogram
    binwidth = binedges(2)-binedges(1); % Finds the width of each bin
    areabin = n * binwidth;
    %         pd = fitdist(MaxT,'Gamma');  mu = pd.a*pd.b;    sigma = sqrt(pd.a*pd.b^2);
    pd = fitdist(MaxT,'tLocationScale');  mu = pd.mu;    sigma = pd.sigma;
    y = areabin * pdf(pd,x);
    % Overlay the density
    hh1 = plot(x,y,'-','color',color_mtx_dark(count,:),'LineWidth',2);
    axis ([x1 x2 0 15]);   grid on;
    %         xlabel({'time of maximum greennes (DOY)';['\mu DOY:' num2str(round(muhat.MaxT)) ' \sigma:' num2str(round(sigmahat.MaxT)) 'days']});
    xlabel({'time of maximum greennes (DOY)';...
        ['\mu DOY:' num2str(round(mu)) ' \sigma:' num2str(round(sigma)) 'days']});
    set(gca,'XTick',x4,'XTickLabel',x3,'YTick',y3,'XLim',[x1 x2],'YLim',[y1 y2],'FontSize',12);
    xtickangle(0);

    save ('UofT02timesat.mat','BegT','EndT','LengthVal','MaxT','roiLength','FileDay');

    %%
    ik = 3205;
    load 'ROI_UofT02_20240101.mat';
    [ImageFile] = imread([FolderImages,'netcam.phenocam2.20230619_123011.jpg'],'JPG');
    %     FileName = 'UofT02_overstory_oblique_03_2019_04_26_22_00_00.jpg';
    %     [ImageFile] = imread([FolderImages,slash,FileName],'JPG');
    %Cut the top of the image if has sky
    ImageFile   =  ImageFile(1:end,1:end,:);
    PixelCut = 1;  %             if (FileDate(ik)<datetime(2024,5,1));  PixelCut = 2200; end
    REDsample   =  (ImageFile(PixelCut:end,1:end,1));
    GREENsample =  (ImageFile(PixelCut:end,1:end,2));
    BLUEsample  =  (ImageFile(PixelCut:end,1:end,3));
    ImageFile = cat(3,uint8(REDsample),uint8(GREENsample),uint8(BLUEsample));
    % %     ia = Red+Green+Blue;
    % %     GCC_matrix     = Green./ia;                GCC_matrix(isinf(GCC_matrix)) = NaN;
    % %     GCC_matrix_ROI = GCC_matrix.*NaN;
    % %     ExGREEN_matrix = Green./Red;               ExGREEN_matrix(isinf(ExGREEN_matrix)) = NaN;
    % %     ExGREEN_matrix_ROI = ExGREEN_matrix.*NaN;
    %
    figure('color','white');
    imshow(ImageFile.*1.1);      axis image;                 axis off          % Remove axis ticks and numbers
    text (50,50,['UofT02 camera ' datestr(FileDateAll(ik))],'FontSize',18);
    %                                     h = drawpolygon('Position',ROIa);
    hold on;
    color_mtx = jet(60);
    for ix = 1:length(ROI)
        [B] = bwboundaries(int16(ROI{ix}.poly),'noholes');      Boundary{ix}.poly = B;
    end
    for ix = 1:length(Boundary)
        boundary = cell2mat(Boundary{ix}.poly);
        select = find(idROI==ix);
        BegTdateAvg = round(mean(day(BegTdate(select),'dayofyear'),'omitnan'));
        if BegTdateAvg<160
            plot(boundary(:,2), boundary(:,1), 'color',color_mtx(BegTdateAvg-90,:), 'LineWidth', 2)
            pgon = polyshape(boundary(:,2), boundary(:,1));
            [x,y] = centroid(pgon);
            text(x,y,num2str(BegTdateAvg),'color',color_mtx(BegTdateAvg-90,:),'FontSize',10);
            ROI{ix}.centroidX = x;                              ROI{ix}.centroidY = y;
        end
    end
    pause(2)

end
