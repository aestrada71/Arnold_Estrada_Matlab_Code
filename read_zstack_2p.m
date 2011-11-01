setappdata(0,'UseNativeSystemDialogs',false);
[fname, fpath]= uigetfile('*.dat', 'Select 2Photon Data Files', 'c:\Data\','MultiSelect','on');

numFiles = size(fname,2);

tempName = fullfile(fpath,fname{1});
data = avg_2p(tempName);
dataSize = size(data);
Stack = zeros(dataSize(1), dataSize(2), numFiles);

for (n=1:numFiles)
   
   tempName = fullfile(fpath,fname{n});
   [Stack(:,:,n),hdr(n)] = avg_2p(tempName);
end

clear numFiles;
clear tempName;
clear data;
clear dataSize;
clear fpath;
clear fname
clear n;