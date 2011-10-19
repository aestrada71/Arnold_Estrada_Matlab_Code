function [tau, varargout] = calc_lifetime(fileName)


if (nargin < 1)   
    [fname, fpath]= uigetfile('*.dat','Name of lifetime files to read', 'c:\Data\','MultiSelect','off');
    fname=strcat(fpath,fname);
else
    fname = fileName;
end


%Set delay time
[data, hdr] = read_lifetime(fname);

f_results = lowlevel_lifetime(data, hdr);

tau = f_results.m(3);
varargout = {f_results};
