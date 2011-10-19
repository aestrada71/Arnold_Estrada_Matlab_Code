function [elapsedTime reShapedData sensorTimeAverages] = ProcessNanoMuxFile()

%This script processes the data file produced by Austin Goodwin's software
%to read out the NanoMux board.
clear all;
close all;

%%  Define Constants
HAVE_HOBO_DATA = 0;
FILTER_DATA = 0;
FILTER_HALF_WIDTH = 1;

makePlots = 1;
savePlots = 1;
writeGroupDataFiles = 0;
fluidChannelFlagTextCols=[3 4 5 6];
startColumn=166;
firstValidDataColumn = 7;       %% In text cell array

%% Read in corresponding HOBO data if available
if(HAVE_HOBO_DATA)

    HOBO_SAMPLE_PERIOD = 10;    %seconds
    HOBOtemp = ImportHOBOFile();
    HOBOData = HOBOtemp.data;
    clear HOBOtemp;
    HOBOtime = 1:size(HOBOData,1);
    HOBOtime = HOBO_SAMPLE_PERIOD.*HOBOtime';

end
%%  Read in the file

%The following function reads file and places data in base workspace
[newFileData fname] = ImportNanoMuxFile();      % Function skips first 9 rows and reads everything from there
tic
textData = newFileData.textdata;                % This will be entire file contents as a cell array
elapsedTime = newFileData.formattedData{2};     % Grab elapsed time vector
numericData = newFileData.formattedData{4};     % Trim data
reShapedData = newFileData.reShapedData;

%lop off the last measurment for all sensors.  That timepoint allways
%contains some NaNs since we never stop the test at exactly the last sensor
reShapedData = reShapedData(:,:,1:end-1);
elapsedTime = elapsedTime(1:end-1);

TN = newFileData.formattedData{3};
timeNotation = TN(1:end-1,1);
%plotColumns = [startColumn:numel(elapsedTime)];

%% Filter data using Running average (boxcar) if desired
if (FILTER_DATA) 
    reShapedData = runmean(reShapedData,FILTER_HALF_WIDTH,3,'mean');
end




%% Parse column headers to know what data is what

% tempTextArray = textData(9-2,firstValidDataColumn:end);  %row vector
% 
% 
% groupNum = 0;
% lastWidth = 0;
% lastPitch = 0;
% 
% for ii = 1:numel(tempTextArray)
%     tempText = tempTextArray{ii};
%     DataStruct(ii).Label = tempText;
%     
%     % Make sure column header is of form aaaXbbb (ccc, ddd)
%     if (~isletter(tempText(1)))  %This is easier option
% 
%         [token, remain] = strtok(tempText,'x');
%         DataStruct(ii).NanoWireWidth =  str2num(token);
%         currentWidth = DataStruct(ii).NanoWireWidth;
%         if (ii==1)
%             lastWidth = DataStruct(ii).NanoWireWidth;
%         end
% 
%         tempText = remain(2:end);
%         [token, remain] = strtok(tempText,' (');
%         DataStruct(ii).NanoWirePitch =  str2num(token);
%         currentPitch = DataStruct(ii).NanoWirePitch;
%         if (ii==1)
%             lastPitch = DataStruct(ii).NanoWirePitch;
%         end
%     
%     else
%         remain = tempText;
%         token = tempText;
%         if (strcmp(token, 'solid'))
%             DataStruct(ii).NanoWireWidth = 1e6;
%             currentWidth = 1e6;
%             DataStruct(ii).NanoWirePitch = 1e6;
%             currentPitch = 1e6;
%         else
%             DataStruct(ii).NanoWireWidth = 0;
%             currentWidth = 0;
%             DataStruct(ii).NanoWirePitch = 1e6;
%             currentPitch = 1e6;
%         end
%         
%     end
%     
%     %I think its best to organize data by grouping togeth like width X pitch
%     %data.  So I will include a field to keep track
% 
%     if (currentWidth ~= lastWidth) || (currentPitch ~= lastPitch)
%         groupNum = groupNum + 1;
%     end
%     DataStruct(ii).GroupNum = groupNum;
%     
%     %updat lastWidth and lastPitch
%     lastWidth = currentWidth;
%     lastPitch = currentPitch;
%     
%     tempText = remain(regexp(remain,'(')+1:end);
%     [token, remain] = strtok(tempText,',');
%     DataStruct(ii).SensorCol =  str2num(token);
%     
%     %temp code to swap column numbering to correct wrong numbering
%     DataStruct(ii).SensorCol =  24-(DataStruct(ii).SensorCol-9);
%     
%     %Store flow channel grouping designation
%     if (DataStruct(ii).SensorCol >=17)&&(DataStruct(ii).SensorCol <=20)
%         DataStruct(ii).FlowGroup = 3;
%         
%     elseif (DataStruct(ii).SensorCol >=21)&&(DataStruct(ii).SensorCol <=24)
%         DataStruct(ii).FlowGroup = 4;
%         
%     elseif (DataStruct(ii).SensorCol >=13)&&(DataStruct(ii).SensorCol <=16)
%         DataStruct(ii).FlowGroup = 2;
%         
%     elseif (DataStruct(ii).SensorCol >=9)&&(DataStruct(ii).SensorCol <=12)
%         DataStruct(ii).FlowGroup = 1;
%     end
%         
%     
%     tempText = remain(regexp(remain,',')+1:end);
%     [token, remain] = strtok(tempText,' )');
%     DataStruct(ii).SensorRow =  str2num(token);
% 
%     
%     DataStruct(ii).CurrentData = numericData(:,ii);
%     
% end



%%  Process Data by groups
% numGroups = max([DataStruct.GroupNum]);
% for ii = 1:numGroups  
%     indicesOfCurrentGroup = find([DataStruct.GroupNum] ==ii);%These are global column indices
%     
%     %Plot the data if desired
%     if (makePlots || savePlots)
%         figure(ii)
%         hold all 
%         legendLabels = {};
%         for jj = 1:numel(indicesOfCurrentGroup) %counter of columns within a group               
%             plot(elapsedTime(plotColumns),DataStruct(indicesOfCurrentGroup(jj)).CurrentData(plotColumns), '') 
%             tempString1 = sprintf('(R%i,C%i)',DataStruct(indicesOfCurrentGroup(jj)).SensorRow, ...
%                 DataStruct(indicesOfCurrentGroup(jj)).SensorCol);
%             legendLabels(jj) = {tempString1};
%         end
%         
%         tempString = sprintf('Width %i nm x Pitch %i nm',DataStruct(indicesOfCurrentGroup(1)).NanoWireWidth, ...
%             DataStruct(indicesOfCurrentGroup(1)).NanoWirePitch);
%         
%         %added this logic because some width x pitch combinations are
%         %repeated
%         groupLabels(ii).labels = tempString;    %Store all previous labels
%         counter=0;
%         for zz=1:ii
%             if (strcmp(groupLabels(zz).labels,tempString))
%                 counter = counter+1;
%             end
%         end
%         tempSuffix = sprintf('_%i',counter);
%         tempString = [tempString tempSuffix];
%         title(tempString);
%         xlabel('Elapsed Time (s)');
%         ylabel('Current (uA)');
%         legend(legendLabels);
%         
%         %Add experiment notations
%         for jj = 1:numel(timeNotation)
%            if (~strcmpi(timeNotation(jj),''))
%                tempString2 = ['\downarrow ' timeNotation{jj}]; 
%                tempString2 = timeNotation{jj};
%                text((elapsedTime(jj)/max(elapsedTime)),0.1,tempString2,'Rotation',90,'units','normalized',...
%                    'HorizontalAlignment','left'); 
%            end
%         end
%         
%         
%         
%         if(savePlots)
%            saveas(gcf,tempString,'png') 
%         end
%         
%         close(ii);
%     end
%     
%     if (writeGroupDataFiles)
%         outputMatrix = zeros(numel(elapsedTime), numel(indicesOfCurrentGroup)+1);
%         outputMatrix(:,1)=elapsedTime;
%         
%         for jj = 1:numel(indicesOfCurrentGroup) %counter of columns within a group               
%             outputMatrix(:,jj+1) = DataStruct(indicesOfCurrentGroup(jj)).CurrentData;            
%         end
%         
%         tempString = sprintf('Width %inm x Pitch %inm',DataStruct(indicesOfCurrentGroup(1)).NanoWireWidth, ...
%             DataStruct(indicesOfCurrentGroup(1)).NanoWirePitch);
%         
%         %added this logic because some width x pitch combinations are
%         %repeated
%         groupLabels(ii).labels = tempString;    %Store all previous labels
%         counter=0;
%         for zz=1:ii
%             if (strcmpi(groupLabels(zz).labels,tempString))
%                 counter = counter+1;
%             end
%         end
%         tempSuffix = sprintf('_%i.txt',counter);
%         tempString = [tempString tempSuffix];
% 
%         dlmwrite(tempString,outputMatrix);
% 
%     end
%         
%         
% 
%     
% end



%% Generate plots grouping like flow channel data
% maxFlowGroup = max([DataStruct(:).FlowGroup]);
% for ii=1:maxFlowGroup
%     indicesOfCurrentGroup = find([DataStruct.FlowGroup] ==ii);%These are global column indices
%     
%     %Plot the data if desired
%     savePlots = 1;
%     if (makePlots || savePlots)
%         figure(ii)
%         hold all 
%         legendLabels = {};
%         for jj = 1:numel(indicesOfCurrentGroup) %counter of columns within a group               
%             plot(elapsedTime(plotColumns),DataStruct(indicesOfCurrentGroup(jj)).CurrentData(plotColumns), '') 
%             tempString1 = DataStruct(indicesOfCurrentGroup(jj)).Label;
%             legendLabels(jj) = {tempString1};
%         end
%         
%         tempString = sprintf('Flow Channel #%i',ii);
%         
%         %added this logic because some width x pitch combinations are
%         %repeated
%        
%         title(tempString);
%         xlabel('Elapsed Time (s)');
%         ylabel('Current (uA)');
%         ylim([0 1.5]);
%         %if ii==3
%         %    ylim([0 0.13]);
%         %end
%         legend(legendLabels);
%         
%         %Add experiment notations
%         for jj = 1:numel(timeNotation)
%            if (~strcmpi(timeNotation(jj),''))
%                tempString2 = ['\downarrow ' timeNotation{jj}]; 
%                tempString2 = timeNotation{jj};
%                text((elapsedTime(jj)/max(elapsedTime)),0.1,tempString2,'Rotation',90,'units','normalized',...
%                    'HorizontalAlignment','left'); 
%            end
%         end
%         
%         
%         
%         if(savePlots)
%            saveas(gcf,tempString,'png') 
%         end
%         
%         
%         %write out the data
%         outputMatrix = zeros(numel(elapsedTime), numel(indicesOfCurrentGroup)+1);
%         outputMatrix(:,1)=elapsedTime;
%         
%         for jj = 1:numel(indicesOfCurrentGroup) %counter of columns within a group               
%             outputMatrix(:,jj+1) = DataStruct(indicesOfCurrentGroup(jj)).CurrentData;            
%         end
%         
% 
%         
%         tempString = [tempString '.txt'];
% 
%         dlmwrite(tempString,outputMatrix);
% 
%         close(ii);
%     end
% end


%% Generate plots grouping like Senor Col data
% minSensorCol = min([DataStruct(:).SensorCol]);
% maxSensorCol = max([DataStruct(:).SensorCol]);
% for ii=minSensorCol:maxSensorCol
%     indicesOfCurrentGroup = find([DataStruct.SensorCol] ==ii);%These are global column indices
%     
%     %Plot the data if desired
%     savePlots = 1;
%     if (makePlots || savePlots)
%         figure(ii)
%         hold all 
%         legendLabels = {};
%         for jj = 1:numel(indicesOfCurrentGroup) %counter of columns within a group               
%             plot(elapsedTime(plotColumns),DataStruct(indicesOfCurrentGroup(jj)).CurrentData(plotColumns), '') 
%             tempString1 = DataStruct(indicesOfCurrentGroup(jj)).Label;
%             tempString2 = sprintf('(R%i,C%i)',DataStruct(indicesOfCurrentGroup(jj)).SensorRow, ...
%                 DataStruct(indicesOfCurrentGroup(jj)).SensorCol);
%             [token, remain] = strtok(tempString1,'(');
%             tempString1 = [token tempString2];
%             legendLabels(jj) = {tempString1};
%         end
%         
%         tempString = sprintf('Device Column #%i',ii);
%         
%         
%        
%         title(tempString);
%         xlabel('Elapsed Time (s)');
%         ylabel('Current (uA)');
%         ylim([0 1.0]);
%         %if ii==3
%         %    ylim([0 0.13]);
%         %end
%         legend(legendLabels);
%         
%         %Add experiment notations
%         for jj = 1:numel(timeNotation)
%            if (~strcmpi(timeNotation(jj),''))
%                tempString2 = ['\downarrow ' timeNotation{jj}]; 
%                tempString2 = timeNotation{jj};
%                text((elapsedTime(jj)/max(elapsedTime)),0.1,tempString2,'Rotation',90,'units','normalized',...
%                    'HorizontalAlignment','left'); 
%            end
%         end
%         
%         
%         
%         if(savePlots)
%            saveas(gcf,tempString,'png') 
%         end
%         
%         
%         %write out the data
%         outputMatrix = zeros(numel(elapsedTime), numel(indicesOfCurrentGroup)+1);
%         outputMatrix(:,1)=elapsedTime;
%         
%         for jj = 1:numel(indicesOfCurrentGroup) %counter of columns within a group               
%             outputMatrix(:,jj+1) = DataStruct(indicesOfCurrentGroup(jj)).CurrentData;            
%         end
%         
% 
%         
%         tempString = [tempString '.txt'];
% 
%         dlmwrite(tempString,outputMatrix);
% 
%         close(ii);
%     end
% end


%% Generate plots grouping like Senor Row data
if(0)
    minSensorRow = min([DataStruct(:).SensorRow]);
    minSensorRow = 64  %temp code
    maxSensorRow = max([DataStruct(:).SensorRow]);
    maxSensorRow = 64 %temp Code
    for ii=minSensorRow:maxSensorRow
        indicesOfCurrentGroup = find([DataStruct.SensorRow] ==ii);%These are global column indices

        if(numel(indicesOfCurrentGroup))
            figure('OuterPosition',[200,200,1200,900]);
            savePlots = 1;
            for ggg = 1:4
                %Plot the data if desired
                if (makePlots || savePlots)
                    subplot(2,2,ggg)
                    hold all 
                    legendLabels = {};
                    for jj = 1:numel(indicesOfCurrentGroup) %counter of columns within a group   
                        if (DataStruct(indicesOfCurrentGroup(jj)).FlowGroup==ggg)

                            plot(elapsedTime(plotColumns),DataStruct(indicesOfCurrentGroup(jj)).CurrentData(plotColumns), '') 
                            tempString1 = DataStruct(indicesOfCurrentGroup(jj)).Label;
                            tempString2 = sprintf('(R%i,C%i)',DataStruct(indicesOfCurrentGroup(jj)).SensorRow, ...
                                DataStruct(indicesOfCurrentGroup(jj)).SensorCol);
                            [token, remain] = strtok(tempString1,'(');
                            tempString1 = [token tempString2];
                            legendLabels(numel(legendLabels)+1) = {tempString1};
                        end
                    end

                    tempString = sprintf('Flow Channel #%i, Device Row #%i',ggg,ii);



                    title(tempString);
                    xlabel('Elapsed Time (s)');
                    ylabel('Current (uA)');
                    if (ii==42)||(ii==47)||(ii==48)
                        ylim([0 0.025]); 
                    else
                        ylim([0 0.025]);
                    end
                    %if ii==3
                    %    ylim([0 0.13]);
                    %end
                    legend(legendLabels,'FontSize',8);

                    %Add experiment notations
                    for jj = 1:numel(timeNotation)
                       if (~strcmpi(timeNotation(jj),''))
                           tempString2 = ['\downarrow ' timeNotation{jj}]; 
                           tempString2 = timeNotation{jj};
                           text((elapsedTime(jj)/max(elapsedTime)),0.1,tempString2,'Rotation',90,'units','normalized',...
                               'HorizontalAlignment','left','FontSize',8); 
                       end
                    end


                end
            end
            tempString = sprintf('Device Row #%i',ii);
            saveas(gcf,tempString,'jpg')
          %  h=gcf;
          %  close(h);

    %         %write out the data
    %         outputMatrix = zeros(numel(elapsedTime), numel(indicesOfCurrentGroup)+1);
    %         outputMatrix(:,1)=elapsedTime;
    % 
    %         for jj = 1:numel(indicesOfCurrentGroup) %counter of columns within a group               
    %             outputMatrix(:,jj+1) = DataStruct(indicesOfCurrentGroup(jj)).CurrentData;            
    %         end
    % 
    %         tempString = [tempString '.txt'];
    % 
    %         dlmwrite(tempString,outputMatrix);
        end



    end
end



%% Generate plots grouping like Senor Row data  -Using New reshaped data.  Does not rely on column headers such as (yyXzz)---

% No need to translate between sensor row and mux row anymore.  It's all
% the same now.
minSensorRow = 1;  %temp code
maxSensorRow = 32; %temp Code
sensorCols = 1:24;


 
if (1)  % here so that I can turn this code on and off easilly.
    
    minSensorRow = 1;  %temp code
    maxSensorRow = 32; %temp Code
    sensorCols = [1, 2];



    sensorTimeAverages = zeros(32,2);       %will hold time averages of every sensor element
    for rr=minSensorRow:maxSensorRow
        indicesOfCurrentGroup = size(reShapedData,2);%These are global column indices
        figure('OuterPosition',[200,200,1200,900]);
        
        count = 0;
        legendLabels = {};
        for cc = min(sensorCols): max(sensorCols)
            tempData = squeeze(reShapedData(rr,cc,:));
            tempMean = mean(tempData(isfinite(tempData)));
            sensorTimeAverages(rr,cc) = tempMean;

            if (tempMean <4.1)&& (tempMean > 0.0002)       
                if(1)
                    if ((makePlots || savePlots))
                        semilogy(elapsedTime,squeeze(reShapedData(rr,cc,:)))
                        ylim([1e-4 5]);
                    end
                else
                    if (makePlots || savePlots)
                        plot(elapsedTime,squeeze(reShapedData(rr,cc,:)))
                        ylim([1e-4 5]);
                    end
                end
                tempString1 = sprintf('Col: %i',cc);
                legendLabels(numel(legendLabels)+1) = {tempString1};
                if (makePlots || savePlots)
                    count = count+1;
                    hold all
                end
            end

        end

        if (count)
            tempString = sprintf('Device Row #%i',rr);
            title(tempString);
            xlabel('Elapsed Time (s)');
            ylabel('Current (\muA)');
            %ylim([0.000 5]);
            legend(legendLabels,'FontSize',8);
                  
            %Squash height of yaxis to accomodate notations
            hand=gca;
            currentAxes = get(hand,'Position');
            xlimits = get(hand,'XLim');
            %currentAxes(2)=0.20;
            currentAxes(4)=0.71;
            set(hand,'Position',currentAxes);
            
            %Add HOBO data if available
            if (HAVE_HOBO_DATA)
                
                addaxis(HOBOtime,HOBOData(:,1),[75 90],'m');
                addaxis(HOBOtime,HOBOData(:,2),'k');
                addaxis(HOBOtime,HOBOData(:,3),[0 60]);
               % addaxis(HOBOtime,HOBOData(:,4)); 
                addaxislabel(2,'Temp (F)');
                addaxislabel(3,'RH (%)');
                addaxislabel(4,'Light');
                %addaxislabel(5,'Dew PT (F)');               
            end
            legend(legendLabels,'FontSize',8);
            
            hand=gca;
            currentAxes = get(hand,'Position');
            
            %Add experiment notations
            for jj = 1:numel(timeNotation)
               if (~strcmpi(timeNotation(jj),''))
                   tempString2 = ['' timeNotation{jj}]; 
                   %tempString2 = timeNotation{jj};
                   text((elapsedTime(jj)/xlimits(2)),1.1,tempString2,'Rotation',85,'units','normalized',...
                       'HorizontalAlignment','center','FontSize',12); 
                 %  annotation('line',[(elapsedTime(jj)/xlimits(2))+currentAxes(1) (elapsedTime(jj)/xlimits(2))+currentAxes(1)],...
                  %     [currentAxes(2) 0.9*(currentAxes(2)+currentAxes(4))]);
                   
                   annotation('line',[(currentAxes(3)*(elapsedTime(jj)/xlimits(2)))+currentAxes(1) ((currentAxes(3)*elapsedTime(jj)/xlimits(2)))+currentAxes(1)],...
                       [currentAxes(2) 0.99*(currentAxes(2)+currentAxes(4))]);
               end
            end
            
            
            saveas(gcf,tempString,'jpg')
        end
        

        
        h=gcf;
        close(h);

    %         %write out the data
    %         outputMatrix = zeros(numel(elapsedTime), numel(indicesOfCurrentGroup)+1);
    %         outputMatrix(:,1)=elapsedTime;
    % 
    %         for jj = 1:numel(indicesOfCurrentGroup) %counter of columns within a group               
    %             outputMatrix(:,jj+1) = DataStruct(indicesOfCurrentGroup(jj)).CurrentData;            
    %         end
    % 
    %         tempString = [tempString '.txt'];
    % 
    %         dlmwrite(tempString,outputMatrix);




    end
    
    
    
    
    if(1)
        figure(09)
        plot([minSensorRow:maxSensorRow],sensorTimeAverages(:,1), '-*',[minSensorRow:maxSensorRow],...
            sensorTimeAverages(:,2), '-o');
        title('Time Averaged Current of Single Layer Chip');
        xlabel('Row #');
        ylabel('Current (uA)');
        legend('Column #1', 'Column #2', 'FontSize',8);
        ylim([0 0.2]);
    end
end

%% Display data as series of current scaled images where every image is one
% point in time
if(0)

    mkdir('./CurrentSampleImages/');
    cd('./CurrentSampleImages/')
    figure(10)
    colormap('hot')
    %for tt=1:size(reShapedData,3)
    for tt=1:30  
        v2=squeeze(reShapedData(:,:,tt));
        imagesc(log(v2), [-4 1]);
        colorbar
        tempString = sprintf('Current Sample #%05i',tt);
        title(tempString);
        saveas(gcf,tempString,'jpg')

    end
    cd('../');

end



%%  Clean up temp vars from workspace
clear token
clear tempTextArray
clear lastWidth;
clear lastPitch
clear currentWidth
clear currentPitch
clear groupNum
%clear elapsedTime
clear textData
clear tempText
clear remain
clear numericData
%clear newFileData
%clear makePlots
clear ii
clear zz
clear writeGroupData
clear tempSuffix
clear tempString1
clear tempString
clear savePlots
clear numGroups
clear newFileData
clear makePlots
clear legenLabels
clear jj
clear indicesOfCurrentGroup
clear groupLabels
clear counter
clear firstValidDataColumn
clear fluidChannelFlagTextCols
clear legendLabels
clear outputMatrix
clear writeGroupDataFiles
clear TN
clear HAVE_HOBO_DATA
clear HOBOData
clear HOBO_SAMPLE_PERIOD
clear HOBOtime
clear cc
clear currentAxes
clear h
clear hand
clear maxSensorRow
clear minSensorRow
clear plotColumns
clear rr
clear sensorCols
clear startColumn
clear tempData
clear tempMean
clear tempString2
clear xlimits
clear ans
clear timeNotation
clear count

%% Save the matlab workspace
[saveName, remain] = strtok(fname,'.txt');
saveName = [saveName '.mat'];
%save (saveName, 'DataStruct','elapsedTime');
clear saveName
clear remain
clear fname

%% finish
toc

end