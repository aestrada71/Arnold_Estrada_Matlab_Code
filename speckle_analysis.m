%This script was written to analyse speckle contrast data

%%Clear everything
clear all
close all
clc


%% Initialize stuff
% xStart = int32(10);
% xEnd = int32(200);
% yStart = int32(10);
% yEnd = int32(200);
% numFrames = 1;
% windowSizeSpatial = 4;
% windowSizeTemporal = 15;
bTemporal = 1;      %Turn on for temporal speckle
bSpatial = 0;
bMixed = 0;
bDisplay=0;
bReadRaw = 0;
bWriteStack=0;
bWriteSTDev = 0;
bWriteMean = 0;
bWriteSC = 0;
integrationTime = 12;       %ms

%% Get file names
[str,maxsize,endian] = computer;
if ispc
    fpath = uigetdir('c:\Data');
else
    fpath = uigetdir('/Volumes/RUGGED/Data/2010_05_21/1_frame_per_sequence/');
end

fpath2 = fpath;
if ispc
    tempString = sprintf('\*_%ims.0*',integrationTime);
    fpath2 = strcat(fpath,tempString);
else
    tempString = sprintf('/*_%ims.0*',integrationTime);
    fpath2 = strcat(fpath,tempString);
end
tempStruct = dir(fpath2);
%fpath = fpath2;

numFiles = size(tempStruct,1);



%% Read the data in.
%find size of images and create 3d array to hold data
tempName = fullfile(fpath,tempStruct(1).name);
tempData = read_raw_basler(tempName);
scStack = zeros([size(tempData) numFiles]);

if (bReadRaw)
    %loads data into stack sequentially
    for (n=1:numFiles)

       tempName = fullfile(fpath,tempStruct(n).name);
       scStack(:,:,n) = read_raw_basler(tempName);

       if bDisplay
           imagesc(scStack(:,:,n));
       end

    end
end

%% Possibly write stack data to file
if (bReadRaw && bWriteStack)
    [fname, fpath]= uiputfile('*.dat','Name of raw data file to save', fpath);
    fname = fullfile(fpath,fname);
    fid = fopen(fname, 'wb','n');
    fwrite(fid, scStack , 'float64');
    fclose(fid);
end

%% Write stdev file
if (bReadRaw && bWriteSTDev)
    [fname, fpath]= uiputfile('*.dat','Name of STDEV file to save', fpath);
    fname = fullfile(fpath,fname);
    fid = fopen(fname, 'wb','n');
    fwrite(fid, std(scStack,0,3) , 'float64');
    fclose(fid);
    
end

%% Write mean file
if (bReadRaw && bWriteMean)
    [fname, fpath]= uiputfile('*.dat','Name of Mean file to save', fpath);
    fname = fullfile(fpath,fname);
    fid = fopen(fname, 'wb','n');
    fwrite(fid, mean(scStack,3) , 'float64');
    fclose(fid);
    
end


%% Write speckle contrast file
if (bReadRaw && bWriteSC)
    [fname, fpath]= uiputfile('*.dat','Name of SC file to save', fpath);
    fname = fullfile(fpath,fname);
    fid = fopen(fname, 'wb','n');
    fwrite(fid, std(scStack,0,3)./mean(scStack,3) , 'float64');
    fclose(fid);
    
end

%% plot stdev, mean and sc vs integration time trend data

intTimes = [2 4 6 8 10 12];
for i=1:numel(intTimes)
    tempString = sprintf('/stdev_%ims.dat',intTimes(i));
    fname = strcat(fpath,tempString);
    fid = fopen(fname, 'rb','n');
    a = fread(fid, [656, 491] , 'float64');
    fclose(fid);
    %stdevTrend(i) = mean(mean(a));
    stdevTrend(i) = mean(mean(a(200:300,1:50)));
    
    tempString = sprintf('/mean_%ims.dat',intTimes(i));
    fname = strcat(fpath,tempString);
    fid = fopen(fname, 'rb','n');
    a = fread(fid, [656, 491] , 'float64');
    fclose(fid);
    %meanTrend(i) = mean(mean(a));
    meanTrend(i) = mean(mean(a(200:300,1:50)));
    
    tempString = sprintf('/sc_%ims.dat',intTimes(i));
    fname = strcat(fpath,tempString);
    fid = fopen(fname, 'rb','n');
    a = fread(fid, [656, 491] , 'float64');
    fclose(fid);
    %scTrend(i) = (nansum(nansum(a)))/numel(a);
    scTrend(i) = (nansum(nansum(a(200:300,1:50))))/numel(a(200:300,1:50));
    
    
end
figure(2)
subplot(1,3,1)
plot(intTimes,stdevTrend,'-ro',intTimes,(meanTrend).^0.5)
title('Stdev')
subplot(1,3,2)
plot(intTimes,meanTrend,'-ro')
title('mean')
subplot(1,3,3)
plot(intTimes,scTrend,'-ro',intTimes,1./(meanTrend).^0.5)
title('Speckle Contrast')



