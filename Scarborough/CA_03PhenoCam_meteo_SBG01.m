flag_unix = 0;

if flag_unix == 1
    addpath \Users\ncoupe\Documents\OZ\
    addpath \Users\ncoupe\Documents\Amazon\
    slash = '\';
elseif flag_unix == 0
    FolderMeteo = '/run/media/ncoupe/Expansion/Data/Canada/Meteo/UofT/';
    addpath /home/ncoupe/Documents/Amazon/
    addpath /home/ncoupe/Documents/OZ/
    slash = '/';
end

MonthNum = ['01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12'];
YearNum = (2021:2025)';

MeteoYear = [];           MeteoMonth = [];          MeteoDay = [];         MeteoTimeLST = [];
MeteoTempC = [];          MeteoDewPointTempC = [];  MeteoRelHum = [];      MeteoPrecipAmountmm = [];
MeteoWindDir10sDeg = [];  MeteoWindSpdkmh = [];     MeteoVisibilitykm = [];
MeteoStnPresskPa = [];    MeteoHmdx = [];           MeteoWindChill = [];
MeteoDateTimeLST = [];
% MeteoWeather = [];

for iy = 1:length(YearNum)
    for im = 1:12 %length(MonthNum)
        FileName=[ FolderMeteo 'en_climate_hourly_ON_6158355_'  num2str(im,'%02i')  '-' num2str(YearNum(iy)) '_P1H.csv'];

        %% Set up the Import Options and import the data
        opts = delimitedTextImportOptions("NumVariables", 31, "Encoding", "UTF-8");
        % Specify range and delimiter
        opts.DataLines = [2, Inf];
        opts.Delimiter = ",";
        % Specify column names and types
        opts.VariableNames = ["Longitudex", "Latitudey", "StationName", "ClimateID", "DateTimeLST", "Year", "Month", "Day", "TimeLST", "Flag", "TempC", "TempFlag", "DewPointTempC", "DewPointTempFlag", "RelHum", "RelHumFlag", "PrecipAmountmm", "PrecipAmountFlag", "WindDir10sDeg", "WindDirFlag", "WindSpdkmh", "WindSpdFlag", "Visibilitykm", "VisibilityFlag", "StnPresskPa", "StnPressFlag", "Hmdx", "HmdxFlag", "WindChill", "WindChillFlag", "Weather"];
        opts.VariableTypes = ["double", "double", "categorical", "double", "datetime", "double", "double", "double", "categorical", "string", "double", "string", "double", "string", "double", "string", "double", "string", "double", "string", "string", "string", "string", "string", "double", "string", "string", "string", "string", "string", "categorical"];
        % Specify file level properties
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        % Specify variable properties
        opts = setvaropts(opts, ["Flag", "TempFlag", "DewPointTempFlag", "RelHumFlag", "PrecipAmountFlag", "WindDirFlag", "WindSpdkmh", "WindSpdFlag", "Visibilitykm", "VisibilityFlag", "StnPressFlag", "Hmdx", "HmdxFlag", "WindChill", "WindChillFlag"], "WhitespaceRule", "preserve");
        opts = setvaropts(opts, ["StationName", "TimeLST", "Flag", "TempFlag", "DewPointTempFlag", "RelHumFlag", "PrecipAmountFlag", "WindDirFlag", "WindSpdkmh", "WindSpdFlag", "Visibilitykm", "VisibilityFlag", "StnPressFlag", "Hmdx", "HmdxFlag", "WindChill", "WindChillFlag", "Weather"], "EmptyFieldRule", "auto");
        opts = setvaropts(opts, "DateTimeLST", "InputFormat", "yyyy-MM-dd HH:mm", "DatetimeFormat", "preserveinput");
        opts = setvaropts(opts, "WindDir10sDeg", "TrimNonNumeric", true);
        opts = setvaropts(opts, "WindDir10sDeg", "ThousandsSeparator", ",");

        % Import the data
        enclimatehourlyON6158355 = readtable(FileName, opts);

        MeteoYear = [MeteoYear;enclimatehourlyON6158355.Year];
        MeteoMonth = [MeteoMonth;enclimatehourlyON6158355.Month];
        MeteoDay = [MeteoDay;enclimatehourlyON6158355.Day];
        MeteoTimeLST = [MeteoTimeLST;enclimatehourlyON6158355.TimeLST];
        MeteoDateTimeLST = [MeteoDateTimeLST;enclimatehourlyON6158355.DateTimeLST];
        MeteoTempC = [MeteoTempC;enclimatehourlyON6158355.TempC];
        MeteoDewPointTempC = [MeteoDewPointTempC;enclimatehourlyON6158355.DewPointTempC];
        MeteoRelHum = [MeteoRelHum;enclimatehourlyON6158355.RelHum];
        MeteoPrecipAmountmm = [MeteoPrecipAmountmm;enclimatehourlyON6158355.PrecipAmountmm];
        MeteoWindDir10sDeg = [MeteoWindDir10sDeg;enclimatehourlyON6158355.WindDir10sDeg];
        MeteoWindSpdkmh = [MeteoWindSpdkmh;enclimatehourlyON6158355.WindSpdkmh];
        MeteoVisibilitykm = [MeteoVisibilitykm;enclimatehourlyON6158355.Visibilitykm];
        MeteoStnPresskPa = [MeteoStnPresskPa;enclimatehourlyON6158355.StnPresskPa];
        MeteoHmdx = [MeteoHmdx;enclimatehourlyON6158355.Hmdx];
        MeteoWindChill = [MeteoWindChill;enclimatehourlyON6158355.WindChill];
        %         MeteoWeather = [MeteoWeather;enclimatehourlyON6158355.Weather];

    end
end

MeteoDateloc = datetime(MeteoDateTimeLST);
clear opts
clear enclimatehourlyON6158355

figure('color','white')
subplot(2,1,1)
bar(MeteoDateloc,MeteoPrecipAmountmm);  datetick('x');
subplot(2,1,2)
plot(MeteoDateloc,MeteoTempC);          datetick('x');

save('SBGmeteo.mat','Meteo*')