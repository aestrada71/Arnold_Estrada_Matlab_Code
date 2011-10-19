% This script does PCA on data from nucleoVolt VOC sensor.

clear all
close all
%%  Define needed constants
RUNNING_AVERAGE = 0;
TIME_WINDOW_AROUND_EDGE = 8;       %# of seconds before and after edge (this is half width of time window)
DETECTION_THRESHOLD = 0.02;
NORMALIZE_DATA = 1;

%%  Read in the data

%The following function reads file and places data in base workspace
[newFileData fname] = ImportNanoMuxFile();      % Function skips first 9 rows and reads everything from there
data = newFileData.reShapedData;
elapsedTime = newFileData.formattedData{2};     % Grab elapsed time vector


%lop off the last measurment for all sensors.  That timepoint allways
%contains some NaNs since we never stop the test at exactly the last sensor
data = data(:,:,1:end-1);
elapsedTime =elapsedTime(1:end-1);

sizeOfData = size(data);


%% Filter data using Running average (boxcar) if desired
if (RUNNING_AVERAGE) 
    data = runmean(data,3,3,'mean');
end

%%  Find sensor detection events

% detection events will be defined as the occurence of a significant
% current shift in at least one sensor.

% %first normalize
% normalizedData = data - repmat(min(data,[],3),[1,1,size(data,3)]);
% normalizedData = data ./ repmat(max(data,[],3),[1,1,size(data,3)]);
% 
% 
% %find peaks using diff
% diffData = diff(normalizedData,1,3);


%useableData = zeros(1,numel(squeeze(data(1,1,:))));
useableData = [];
for rr=1:size(data,1)
   for cc=1:size(data,2)
       useData=0;
       temp = squeeze(data(rr,cc,:));
       if (NORMALIZE_DATA)
          normalizedTemp = temp - min(temp(30:end));
          normalizedTemp = normalizedTemp / max(normalizedTemp(30:end));
       else
           normalizedTemp = temp;
       end
       
       derivTemp = zeros(numel(normalizedTemp),1);
       for ss = 2:numel(normalizedTemp)-1
            derivTemp(ss) = (normalizedTemp(ss)- normalizedTemp(ss-1)) / (elapsedTime(ss) - elapsedTime(ss-1));
       end
       derivTemp(1) = derivTemp(2);
       derivTemp(end)=derivTemp(end-1);
       
       figure(1)
       clf
       plot(elapsedTime,temp)
       ylim([1e-4 5]);
       addaxis(elapsedTime,derivTemp,[-0.1 0.1]);
       
       
       %find peaks from derivative
       ind = find(abs(derivTemp)>=DETECTION_THRESHOLD);
       
       %Make sure I dont double count a peak.
       dt = elapsedTime(2)-elapsedTime(1);
       numSampsInWindow = round(TIME_WINDOW_AROUND_EDGE/dt); %half width
       
       indDiff = diff(ind);
       uniqueInds = ind(find(indDiff > numSampsInWindow*2));
       
       hand=gca;
       currentAxes = get(hand,'Position');
       xlimits = get(hand,'XLim');
       for ii=1:numel(uniqueInds)
            annotation('line',[(currentAxes(3)*(elapsedTime(uniqueInds(ii))/xlimits(2)))+currentAxes(1) ((currentAxes(3)*elapsedTime(uniqueInds(ii)))/xlimits(2))+currentAxes(1)],...
                        [currentAxes(2) 0.99*(currentAxes(2)+currentAxes(4))]);
       end
       
       tempString = sprintf('Row: %i, Col: %i, num peaks: %i',rr,cc, numel(uniqueInds));
       title(tempString);
       button = questdlg('Use The data from this sensor?','','Yes')
       switch button
           case 'Yes'
               useData=1;
               useableData(end+1,:)=temp;
               figure(2)
               hold on
               plot(elapsedTime,useableData(end,:))
               figure(1)
               break
           case 'No'
               useData=0;
               break
           case 'Cancel'
               useData=0;
               %bail out of program
               return
           
       end
         

        %pause(0.75);
        close(gcf)

   
   end
end





% IND = squeeze(find(abs(diffData)>DETECTION_THRESHOLD));
% [r,c,sampleNums] = ind2sub(size(diffData),IND);
% 
% 
% %Since data is collected serially, peaks are not all detected at the exact
% %same time.  Group the found peaks that are close in time.
% dt = elapsedTime(2)-elapsedTime(1);
% numSampsInWindow = round(TIME_WINDOW_AROUND_EDGE/dt); %half width
% 
% 
% temp = diff(sampleNums);
% 
% %unique events have to be separated in time by at least the width of the
% %defined time window.
% uniqueEventIndices = find(temp > 2*numSampsInWindow);
% uniqueSampleNums = sampleNums(uniqueEventIndices);
% r=r(uniqueEventIndices);
% c=c(uniqueEventIndices);
% numSampsInWindow = 20;
% %verify I've found a peak
% if (1)
%     for xx = 1:numel(uniqueSampleNums)
%         temp = (uniqueSampleNums(xx)-numSampsInWindow):(uniqueSampleNums(xx)+numSampsInWindow);
% 
%         figure(10)
%         hold on
%         rr = r(xx);
%         cc = c(xx);
%         %plot(elapsedTime(temp),squeeze(data(rr,cc,temp)));
%         plot(elapsedTime,data(rr,cc,:));
%         
%         tempString = sprintf('row: %i, col; %i, event: %i',rr,cc,xx)
%         title(tempString);
%    %     annotation('line',[(currentAxes(3)*(elapsedTime(jj)/xlimits(2)))+currentAxes(1) ((currentAxes(3)*elapsedTime(jj)/xlimits(2)))+currentAxes(1)],...
%    %                    [currentAxes(2) 0.99*(currentAxes(2)+currentAxes(4))]);
%         pause(1);
%     end
% end

%% Extract features (ie variables) associated with events and store in
% format that the PCA routine is looging for
% 
% dt = elapsedTime(2)-elapsedTime(1);
% eventHalfWidthSamples = round(TIME_WINDOW_AROUND_EDGE/dt);