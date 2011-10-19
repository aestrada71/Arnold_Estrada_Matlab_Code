function [avg, varargout] = avg_2p(filename)

   nout = max(nargout,1)-1;
   
   if (nargin ~= 1)   
    [fname, fpath]= uigetfile('*.dat','Select 2Photon Data File', 'c:\Data\');
    fname = fullfile(fpath,fname);
    
   else
    fname = filename;
   end


  

    [dataVals, hdr] = read_2p(fname);
    sum = dataVals(:,:,1);
    
    for n = 2:hdr.numFrames 
       sum = sum + dataVals(:,:,n);             
    end
    
    avg = sum / hdr.numFrames;
    sz=size(avg);
    avg = reshape(avg(:,:,1),[sz(1) sz(2)]);
    
    varargout(1)={hdr};