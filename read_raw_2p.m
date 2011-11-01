%read zstack data that has written to raw data file.

function [retVal] = read_raw_2p(dims, fileName)

 if (nargin==0)
     retVal=0;
     return;
 end
 if (nargin < 2)   
    [fname, fpath]= uigetfile('*.raw','Name of file to read', 'c:\Data\Raw\');
    fname = fullfile(fpath,fname);
    
  else
      fname = fileName;
 end

fileID = fopen(fname, 'r', 'l');
retVal = fread(fileID, prod(dims), 'float32');


retVal = reshape(retVal,dims);

fclose(fileID);