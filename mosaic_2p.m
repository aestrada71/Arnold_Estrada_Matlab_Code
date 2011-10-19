%Written by Alex Greis

%Mosaic_2p: Used to generate a mosaic-tiled image from multiple image
%stacks

%Update history:

%1/11/2008
    %Read in subdirectory of image files, create a mosaic image file
%1/29/2008
    %Added functionality to read a set of z-stacks
    %Image file is written as single .RAW file
%2/1/2008
    %Now generates a text information file
%2/4/2008
    %Header info also written in 128-byte header in .RAW file
    
    
%USAGE INSTRUCTIONS:
%Image acquisitions must all havethe same Field of View!

    %Have all images in a folder by themselves. There cannot be any files with
%the .dat file extension in the folder that do not contain image data for
%the mosaic.
    %Locate folder when prompted. Then specify save filename when prompted.
%This script will generate a .RAW image file stack and a .txt header file.
%Import into imageJ using the specicifications given in the text document.
%The text file will be the same name as the specified .RAW file, except
%with a _info.txt appende to the end.
    %The .RAW file has a 128-byte header as well, which can be read as
%binary float32 data, and will contain the number of slices,
%y-resolution, x-resolution, and offset for the header.


    
function mosaic_2p
    

%User-input selected directory
fpath = uigetdir('c:\Data\');
fpath2=fpath;


fpath = strcat(fpath,'\*.dat');
tempStruct = dir(fpath);
fpath=fpath2;

numFiles = size(tempStruct,1);  %number of image files to be processed

%newplot;
%hold on;
xMax = 0;
xMin = 0;
yMax = 0;
yMin = 0;
xSize = 0;
ySize = 0;
zSize = 0;


%find the dimensions of total canvas--------------
for (n=1:numFiles)
    %update file name & read file
    tempName = fullfile(fpath,tempStruct(n).name);
    [img,hdr] = avg_2p(tempName);
    
    %compare max/min x-values
    if (hdr.xPos>xMax)
        xMax=hdr.xPos;
    end
    if (hdr.xPos<xMin)
        xMin=hdr.xPos;
    end
    %compare max/min y-values
    if (hdr.yPos>yMax)
        yMax=hdr.yPos;
    end
    if (hdr.yPos<yMin)
        yMin=hdr.yPos;
    end
end

const = hdr.objScaling/1000; %microns per millivolt - characteristic of acquisition (used to calculate FOV) 

%find the number of different z heights in all stacks--------------------
%initial file needed first to make array
tempName = fullfile(fpath,tempStruct(1).name);
[img,hdr] = avg_2p(tempName);
zList = [hdr.zPos];
%traverse remaining files
for(n=2:numFiles)
    repeat = 0;
    tempName = fullfile(fpath,tempStruct(n).name);
    [img,hdr] = avg_2p(tempName);
    %check z-depth array if height already exists, if so set trigger
    for(i=1:size(zList,2))
        if(hdr.zPos == zList(i))
           repeat=1;
        end
    end
    %Add height to z-depth array if trigger is unset
    if(repeat==0)
        zList=cat(2,zList,hdr.zPos);
    end
end
%Sort zList for later use
zList = sort(zList);
%------------------------------------------------------------------------


%Convert canvas into plot coordinates-------------
xFOV = (hdr.xMax-hdr.xMin)*1000*const;  %distance of one x FOV in microns (const is within 10%)
yFOV = (hdr.yMax-hdr.yMin)*1000*const;  %distance of one y FOV in microns (const is within 10%)

%calculate offset for step coordinates if at negative locations (image can
%only be plotted at positive coordinates)

%X Offset
xOffset = xMin/xFOV;
if(xOffset>0)
    xOffset = 0;
end
if(xOffset<0)
    xOffset = xOffset*-1;
end
%Y Offset
yOffset = yMin/yFOV;
if(yOffset>0)
    yOffset = 0;
end
if(yOffset<0)
    yOffset = yOffset*-1;
end


%Output all files into mosaic matrix-------------------------

for (n=1:numFiles)
    %open file
    tempName = fullfile(fpath,tempStruct(n).name);
    [img,hdr] = avg_2p(tempName);
    %determine location of image
    
    loc_x = (hdr.xPos/xFOV)+xOffset;
    loc_y = (hdr.yPos/yFOV)+yOffset;
    
    loc_x = ceil(loc_x*hdr.validX);    %pixel coordinates
    loc_y = ceil(loc_y*hdr.validY);    %pixel coordinates
    
    %determine height
    for(i=1:size(zList,2))
        if (hdr.zPos == zList(i))
            height = i;
        end
    end

    %copy into mosaic
    Mosaic(loc_y+1:(loc_y+hdr.validY),loc_x+1:(loc_x+hdr.validX),height)=img(:,:);
end

%--------------------------Write Output files---------------------------
%Write stack to RAW file-------------------------------

[fname, fpath]= uiputfile('*.raw','Name of data file to save', 'c:\Data\Raw\');
    fname = fullfile(fpath,fname);

fid = fopen(fname, 'wb','l');
%Write 128-Byte Header--------------------------
fwrite(fid,size(zList,2),'float32');    %number of slices
fwrite(fid,size(Mosaic,1),'float32');   %y resolution
fwrite(fid,size(Mosaic,2),'float32');   %x resolution
fwrite(fid,128,'float32');              %x resolution

for(i=0:28)
    fwrite(fid,1,'float32');
end

fwrite(fid, single(Mosaic), 'float32');
 
fclose(fid);

%Write text information file---------------------------
fname = strrep(fname,'.raw','_info.txt');
fid = fopen(fname,'wt');

%piece together strings for output, then output
line=strcat(int2str(numFiles),' files used\n');
fprintf(fid,line);

line=' slices\n';
line=strcat(num2str(size(zList,2)),line);
fprintf(fid,line);


line=int2str(size(Mosaic,1));
line=strcat(line,'x',int2str(size(Mosaic,2)),' resolution per slice\n');
fprintf(fid,line);


line='Real float32, little endian\n';
fprintf(fid,line);


line='128 byte offset to first image';
fprintf(fid,line);


fclose(fid);



