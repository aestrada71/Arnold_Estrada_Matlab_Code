function [area, varargout] = calcarea()

[fname, fpath]= uigetfile('*.asc','Select 2Photon Data File', 'c:\Data\Speckleor\');
fname = fullfile(fpath,fname);

%t=0:8.789e-7:923*8.789e-7;

a=dlmread(fname);
b=a(100:end);
area = trapz(b);
