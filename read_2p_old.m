
function [I, varargout] = read_2p(fileName)

  if (nargin ~= 1)   
    [fname, fpath]= uigetfile('*.dat','Select 2Photon Data File', 'c:\Data\');
    fname = fullfile(fpath,fname);
    
  else
      fname = fileName;
  end
    
  nout = max(nargout,1)-1;
  

  fp=fopen(fname,'rb', 'ieee-le');
  
  if(fp==-1)
    sprintf('\ncould not open %s for reading\n',fname);
    I=-1;
    varargout(1) = {[]};
    return;
  end
 % ftell(fp);
 %NOTE: VERSION NEEDS TO BE REMOVED TO WORK WITH OLD FILES
   [hdr.Version, readCount] = fread(fp, 1,'float32');
  [hdr.headerSize, readCount] = fread(fp, 1,'int32');

  [hdr.typeSize, readCount] = fread(fp, 1,'int32');
  % ftell(fp);
  [hdr.n1, readCount]=fread(fp,1,'int32');
  % ftell(fp);
  [hdr.n2, readCount]=fread(fp,1,'int32');
   ftell(fp);
  [hdr.numFrames, readCount]=fread(fp,1,'int32');
  [hdr.validX, readCount]=fread(fp,1,'int32');
  [hdr.validY, readCount]=fread(fp,1,'int32');
  [hdr.mag, readCount]=fread(fp,1,'float32');
  [hdr.xMin, readCount]=fread(fp,1,'float32');
  [hdr.xMax, readCount]=fread(fp,1,'float32');
  [hdr.yMin, readCount]=fread(fp,1,'float32');
  [hdr.yMax, readCount]=fread(fp,1,'float32');
  [hdr.zPos, readCount]=fread(fp,1,'float32');
  
  [hdr.xPos, readCount]=fread(fp,1,'float32');
  [hdr.yPos, readCount]=fread(fp,1,'float32');
  
  [hdr.ADC_Min_V, readCount]=fread(fp,1,'float32');
  [hdr.ADC_Max_V, readCount]=fread(fp,1,'float32');
  [hdr.NumBits, readCount]=fread(fp,1,'int32');
  [hdr.ADC_Min_Count, readCount]=fread(fp,1,'int32');
  
  %%Added for linescan
  [hdr.LineRate, readCount] = fread(fp,1,'float32');
  [hdr.LineLength, readCount] = fread(fp,1,'float32');
  
  %Added for scaling
  [hdr.objScaling, readCount] = fread(fp,1,'float32');
  
  
  position = ftell(fp);
  
  fseek(fp,hdr.headerSize,'bof');
  
  %vals = zeros(hdr.n2, hdr.n1,hdr.numFrames, 'double');
   vals = zeros(hdr.validX, hdr.validY,hdr.numFrames, 'double');
    
  scaleFactor = (hdr.ADC_Max_V-hdr.ADC_Min_V)/2^hdr.NumBits;
  for i=1:hdr.numFrames
   % [temp, readCount]=fread(fp,[hdr.n1, hdr.n2],'float64');
   [temp, readCount]=fread(fp,[hdr.validY, hdr.validX],'int16');
    vals(:,:,i) = ((temp - hdr.ADC_Min_Count).* scaleFactor)' + hdr.ADC_Min_V;
    %vals(:,:,i) = temp;
  end
  % ftell(fp);
  fclose(fp);
  %foo = vals(1:hdr.validY, 1:hdr.validX,:);
  foo = vals(1:hdr.validX, 1:hdr.validY,:);
 I = foo;
 varargout(1)={hdr};