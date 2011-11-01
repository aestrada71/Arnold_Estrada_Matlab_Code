function I=read_raw_basler2(varargin)
  [fname, fpath]= uigetfile();
  
  fp=fopen(fullfile(fpath,fname),'r');
  if(fp==-1)
    sprintf('\ncould not open %s for reading\n',fname)
    I=-1;
    return;
  end
  
  n1=fread(fp,1,'unsigned short');
  n2=fread(fp,1,'unsigned short');
  N=fread(fp,1,'unsigned short');
  T=fread(fp,1,'unsigned short');
  if(nargin==1)
    Nimages=varargin{1};
else
    Nimages=N;
end
  foo=fread(fp,n1*n2*Nimages,'uchar');
  fclose(fp);
  I=reshape(foo,[n2 n1 Nimages]);
  