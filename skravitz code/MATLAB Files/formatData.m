% Reads in data from the sample file and puts it in the correct format for
% the methods that extra peak data. Includes a hard-coded region of the
% file to extract data from as well as hard-coded flags for where the peaks
% should be
Data = xlsread('SampleData.xlsx','data','A2:F1326');
Data = Data(:,[1:end-2,end]);
DataSize = size(Data);
Data(:,DataSize(2)+1) = zeros(DataSize(1),1);
flagPoints = [72, 135, 195, 255, 313, 375, 435, 494]; % Indices where peaks are, roughly
flagInd = 1;
tFlag = flagPoints(1);
deltaT = 0.7; % Time between successive data points, in seconds
% Make the last row of Data contain peak information (the peak indices have
% a 1, all others are zeros).
for rowInd = 1:DataSize(1); 
    t = Data(rowInd,end-1);
    if abs(t-tFlag) < deltaT
       Data(rowInd,end) = 1;
       flagInd = flagInd+1;
       if flagInd > length(flagPoints)
          break; 
       end
       tFlag = flagPoints(flagInd);
    end
end