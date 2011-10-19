
function I=read_2p(fileName)

  if (nargin ~= 1)   
    [fname, fpath]= uigetfile('*.dat');
    fname = fullfile(fpath,fname);
    
  else
      fname = fileName;
  end
      
  
  fp=fopen(fname,'rb');
  if(fp==-1)
    sprintf('\ncould not open %s for reading\n',fname);
    I=-1;
    return;
  end
 % ftell(fp);


  [typeSize, readCount] = fread(fp, 1,'int32');
  % ftell(fp);
  [n1, readCount]=fread(fp,1,'int32');
  % ftell(fp);
  [n2, readCount]=fread(fp,1,'int32');
%    ftell(fp);
%   [validX, readCount]=fread(fp,1,'int32');
%   [validY, readCount]=fread(fp,1,'int32');
%   [mag, readCount]=fread(fp,1,'int32');
%   [xMin, readCount]=fread(fp,1,'float32');
%   [xMax, readCount]=fread(fp,1,'float32');
%   [yMin, readCount]=fread(fp,1,'float32');
%   [yMax, readCount]=fread(fp,1,'float32');
%   [mag, readCount]=fread(fp,1,'float32');
%   position = ftell(fp);
  
 % fseek(fp,headerSize,'bof');
  
  [foo, readCount]=fread(fp,[n1, n2],'float32');
  % ftell(fp);
  fclose(fp);
 %foo = foo(1:validY, 1:validX);
 I = foo';