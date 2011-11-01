% this script goes through all the saved data files to determine which ones
% are scan data and which are image data.  Then produces text file to store
% needed info to calc line scan speed

function process_linescan_files()
%%  Constants
%objScale = 31.5;      % microns per volt (full swing);  %60x
objScale = 46.5;      % microns per volt (full swing);  %40x
sampRate = 350000;

xmin = -3;
xmax = 3;
ymin = -3;
ymax = 3;

numXPxls = 512;
numYPxls = 512;


%%
[str,maxsize,endian] = computer;

if ispc
    fpath = uigetdir('c:\Data');
else
    fpath = uigetdir('/Volumes/RUGGED/Data/');
end

fpath2 = fpath;

tempStruct = dir(fpath);
fpath = fpath2;

numFiles = size(tempStruct,1);

tempName = fullfile(fpath,tempStruct(end).name);

fid=fopen('~/LS_metaData.txt','w');
fprintf(fid, 'FileName \t Z-Position \t Pixel-Len(um) \t line-Time(ms) \t xMidPxl(#) \t yMidPxl(#) \t \n');

%reads data files individualy
for (n=3:numFiles)
   
   tempName = fullfile(fpath,tempStruct(n).name);
   [a, h] = read_2p(tempName);

   pxlLen = (objScale * sqrt((h.xMax-h.xMin)^2 + (h.yMax-h.yMin)^2))/h.validX;
   
   xMid = (h.xMax + h.xMin)/2;
   yMid = (h.yMax + h.yMax)/2;
   
   xMidPxl = round((xMid - xmin)/(xmax-xmin) * numXPxls);
   yMidPxl = round((yMid - ymin)/(ymax-ymin) * numYPxls);

   
   name = tempStruct(n).name;
   pxlLen = pxlLen;
   lineTime = 1000 * h.n1/(sampRate);
   
   fprintf(fid,'%s\t  %3.3f\t %3.3f\t  %3.3f\t  %3i\t %3i\n',name,h.zPos, pxlLen,lineTime, xMidPxl, yMidPxl);
   
end



status = fclose(fid);

