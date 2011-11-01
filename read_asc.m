
function [rawData1, varargout] = read_asc(dt, fileName)

  if (nargin ~= 2)   
    [fname, fpath]= uigetfile('*.asc','Select asc Data File', '~/Desktop/');
    fname = fullfile(fpath,fname);
    
  else
      fname = fileName;
  end
  
  % Import the file
  
  
rawData1 = importdata(fname);

t = (dt .* (0:numel(rawData1)-1))'; 
varargout(1) = {t};