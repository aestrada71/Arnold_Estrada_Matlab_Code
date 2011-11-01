%Edited by Alex Greis on 9/24/07
%Last update - 9/26/07
%Reads in Directory with exclusively .dat Two-photon files, sorts it by z_depth
%Outputs one .RAW file


[str,maxsize,endian] = computer;

if ispc
    fpath = uigetdir('c:\Data');
else
    fpath = uigetdir('/Volumes/');
end

fpath2 = fpath;

if ispc
    fpath = strcat(fpath,'\*.dat');
else
    fpath = strcat(fpath,'/*.dat');
end
tempStruct = dir(fpath);
fpath = fpath2;

numFiles = size(tempStruct,1);

tempName = fullfile(fpath,tempStruct(1).name);

data = avg_2p(tempName);
dataSize = size(data);
Stack = zeros(dataSize(1), dataSize(2), numFiles);


%loads data into stack sequentially
for (n=1:numFiles)
   
   tempName = fullfile(fpath,tempStruct(n).name);
   [Stack(:,:,n),hdr(n)] = avg_2p(tempName);
end


%sort files
tempVal1=0;
tempVal2=0;
tempVal3=0.0;
n=1;
i=1;
tempFrame=zeros(256,256);

while (i < size(Stack,3))
while (n < size(Stack,3))
   tempVal1= hdr(n).zPos;
   tempVal2= hdr(n+1).zPos;
   %if 2nd value is closer to surface, swap both stack values
   if(tempVal2>tempVal1)
       %swap data
       tempFrame=Stack(:,:,n);
       Stack(:,:,n)=Stack(:,:,n+1);
       Stack(:,:,n+1)=tempFrame;
       %swap headers -just zpos for now
       %z.pos
       tempVal3=hdr(n).zPos;
       hdr(n).zPos=hdr(n+1).zPos;
       hdr(n+1).zPos=tempVal3;
   end
   n=n+1;
end
i=i+1;
end

%Write stack to RAW file
data = Stack;
if ispc
    [fname, fpath]= uiputfile('*.raw','Name of file to save', 'c:\Data\Raw\');
else
    [fname, fpath]= uiputfile('*.raw','Name of file to save', '/Volumes/');
end


fname = fullfile(fpath,fname);

fid = fopen(fname, 'wb','l');
fwrite(fid, single(data) , 'float32');
 
fclose(fid);

clear tempVal1;
clear tempVal2;
clear tempVal3;
clear tempFrame;
clear numFiles;
clear tempName;
clear data;
clear dataSize;
clear ftemp;
clear fpath;
clear fpath2;
clear fname;
clear tempStruct;
clear i;
clear n;
clear Stack;
clear hdr;