%Write a Zstack out to a raw data file so I can read into ImageJ.

function [retVal] = write_zstack_2p(data, fileName)

 if (nargin==0)
     retVal=0;
     return;
 end
 if (nargin < 2)   
    [fname, fpath]= uiputfile('*.raw','Name of file to save', 'c:\Data\Raw\');
    fname = fullfile(fpath,fname);
    
  else
      fname = fileName;
 end
  
 
 if (isequal(fpath,0)) 
     retVal = 0;
     return;
 end
     
    

 fid = fopen(fname, 'wb','l');
 fwrite(fid, single(data) , 'float32');
 
 fclose(fid);
 retVal=1;
 
end