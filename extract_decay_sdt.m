function [ t,data ] = extract_decay_sdt( numSamps,startSamp,fileName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here




%% Define needed parameters.

% numCyclesToAvg = 50;        %to match what processing script wants to see
% suffix2 = '.asc';           %suffix of output file name
% suffix1 = '.dat';           %suffix of input file name
% trigCol = 2;                %Column number of data where function generator trigger is.
% dataCol = 1;
% diagnostics = 1;

   nout = max(nargout,1)-1;
   
   if (nargin < 1) numSamps = 256; end
   if (nargin < 2) startSamp = 256; end
       
   if (nargin < 3) 
       
       if ispc
            dir = 'c:\Data\*.sdt';
       else
            dir = '/Volumes/RUGGED/Data/*.sdt';
       end
       
       [fname, fpath]= uigetfile('*.sdt','Select 2Photon Data File', dir);
       fname = fullfile(fpath,fname);
    
   else
       fname = fileName;
   end
   
%% read in data

[time i info] = read_sdt(fname);

data = i(startSamp:(startSamp+numSamps-1));
t = time(1:numSamps);


end

