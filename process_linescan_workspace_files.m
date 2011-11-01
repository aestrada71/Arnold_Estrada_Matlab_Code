% this script goes through all the saved data files to determine which ones
% are scan data and which are image data.  Then produces text file to store
% needed info to calc line scan speed

function process_linescan_workspace_files()
%%  Constants
objScale = 31.5;      % microns per volt (full swing);
sampRate = 350000;


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

fid=fopen('~/LS_velocities.txt','w');
fprintf(fid, 'FileName \t Average Velocity (mm/s)\n');

%reads data files individualy
for (n=3:numFiles)
   
   tempName = fullfile(fpath,tempStruct(n).name);
   load(tempName);

   vel = mean(Result(:,3));
   
   name = tempStruct(n).name;
   
   fprintf(fid,'%s\t  %3.3f\n',name, vel);
   
end



status = fclose(fid);

