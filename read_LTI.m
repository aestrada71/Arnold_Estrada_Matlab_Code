
function I=read_LTI(fileName)

  if (nargin ~= 1)   
    [fname, fpath]= uigetfile('*.dat','Select File', '/Users/ADE/');
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
  %ftell(fp);
 
  [fn, fm, mformat] = fopen(fp);
  [rowSize, readCount] = fread(fp, 1,'int32','b');

  [colSize, readCount] = fread(fp, 1,'int32','b');

  
[foo, readCount]=fread(fp,[colSize, rowSize],'float64','b');
% [temp, readCount] = fread(fp, 1,'float32','b');
  % ftell(fp);
  fclose(fp);

 I = foo';