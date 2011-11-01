 
function[spectrum, lambda] = read_spectrometer_file(filename)


%% Get file name
if (nargin ~= 1)   
    [fname, fpath]= uigetfile('*.txt','Select 2Photon Data File','~/Documents/');
    fname = fullfile(fpath,fname);
    
else
    fname = filename;
end



%% Read in data
DELIMITER = ',';
HEADERLINES = 3;

% Import the file
% newData1 = importdata(fname, DELIMITER, HEADERLINES);
% spectrum = mean(newData1.data(:,3:end),1);

fileContents = dlmread(fname,DELIMITER,1,47);
lambda = fileContents(1,1:(end-10));
spectrum = mean(fileContents(3:end,1:(end-10)),1);

%% Read in wavelengths
