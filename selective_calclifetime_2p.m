%Selective_calclifetime_2p
%
%Written by Alex Greis
%10/17/2007
%Last Updated: 10/24/2007
%
%Processes one .dat file from a Two-Photon Lifetime Acquisition
    %General Algorithm:
    %1. Calculate overall lifetime data with all triggers, get b
    %2. Go through data again, average/calculate lifetime for every set of 10 triggers
    %3. If set has a b that is greater than 50% off of original b, discard
    %4. Keep good triggers, log discarded data
    %5. Do a lifetime fit on all good data
    %6. Return a struct with fit data and discarded data log
    %7. Return the threshold, overall lifetime, and overall magnitude
    %NOTE: If data is integer, use 30e-6 for delay; if double, use 60e-6
    
function [f_result,o_mag,o_life,thresh] = selective_calclifetime_2p(fpath,window)
%If no path is given, prompt user for one
if (nargin == 0)
    [fileName,pathName] = uigetfile('*.dat','Select Lifetime Acquisition Data','c:\Data\');
    fpath=strcat(pathName,fileName);
    window=10;
end
%If one argument is give, define window as 10
if (nargin == 1)
    window =10;
end
[data, hdr] = read_lifetime(fpath);
%set delay depending on data type
if (hdr.typeSize==4)
    delay = 30e-6;
else
    delay = 60e-6;
end
%calculate overall b
%----------------------------------------------------------------------
        f_result = lowlevel_lifetime(data,hdr);
        overall_b=f_result.m(2);
 %----------------------------------------------------------------------
 %set return values 
 o_mag=overall_b;
 o_life=f_result.m(3);
 thresh=o_mag*.5;
 
%go through every set of 10 triggers and average it, discard if local b
%varies by 50% or more 
%#####################################################################################
%variables
data_10_trigs = zeros(hdr.sampsPerTrig*window,1);       %temp data array for trigger sets
good_start = 0;                               %flag to indicate good data has been written to
k=1;                                          %index for total data array
good_trigs = 0;
bad_trigs  = 0;
temp_b = 0.0;
totalTrigs = hdr.numTrigs/window;                   %total number of sets of 10 trigs

for i=1:(hdr.numTrigs/window)
    %create temporary array of data for 10 triggers
    for n=1:(hdr.sampsPerTrig*window)
        data_10_trigs(n,1)=data(k);
        k=k+1;
    end
    %calculate b for 10 triggers
    %----------------------------------------------------------------------
    hdr.numTrigs=window;
    f_result = lowlevel_lifetime(data_10_trigs,hdr);
    temp_b=f_result.m(2);
    %----------------------------------------------------------------------
    %test to see if data is bad
    if(.5*overall_b>temp_b)
        data_temp_bad(bad_trigs+1)=f_result;
        %if bad, discard
        bad_trigs = bad_trigs+1;
    else
    %if good, add to final dataset
    %--------------------------------
        if (good_start==0)
          %if good data set hasn't been written to yet, then start good data array
          data_good = data_10_trigs;
          good_start=1;
        else
          %otherwise, just cat data
          data_good=cat(1,data_good,data_10_trigs);
        end
        data_temp_good(good_trigs+1)=f_result;
    %--------------------------------
    good_trigs = good_trigs+1;
    end
end
%#####################################################################################
%Write discarded data to dump file
if (bad_trigs > 0)
    fpath2=strrep(fpath,'.dat','_bad_dump.txt');
    fid = fopen(fpath2, 'wt');
    
    line = int2str(bad_trigs);
    line = strcat(line,'/',int2str(totalTrigs),' sets of [',int2str(window),'] triggers detected as bad. ');
    fprintf(fid,'%s\n',line);
    line = num2str(overall_b*.5);
    line = strcat(line,'. threshold value.');
    fprintf(fid,'%s\n',line);
    line = 'r       a               b               tau';
    fprintf(fid,'%s\n',line);
    
    for i=1:numel(data_temp_bad)
        temp_struct = data_temp_bad(i);
        line =[temp_struct.r,temp_struct.m(1),temp_struct.m(2),temp_struct.m(3)];
        fprintf(fid,'%.5f\t%.8f\t%.8f\t%e\n',line);
    end
    fclose(fid);
end
%Write good data to dump file
if (good_trigs > 0)
    fpath2=strrep(fpath,'.dat','_good_dump.txt');
    fid = fopen(fpath2, 'wt');
    
    line = int2str(good_trigs);
    line = strcat(line,'/',int2str(totalTrigs),' sets of [',int2str(window),'] triggers detected as good. ');
    fprintf(fid,'%s\n',line);
    line = num2str(overall_b*.5);
    line = strcat(line,'. threshold value.');
    fprintf(fid,'%s\n',line);
    line = 'r       a               b               tau';
    fprintf(fid,'%s\n',line);
    
    for i=1:numel(data_temp_good)
        temp_struct = data_temp_good(i);
        line =[temp_struct.r,temp_struct.m(1),temp_struct.m(2),temp_struct.m(3)];
        fprintf(fid,'%.5f\t%.8f\t%.8f\t%e\n',line);
    end
    fclose(fid);
end
%Calculate good lifetime from selected values
        hdr.numTrigs=(numel(data_good)/hdr.sampsPerTrig);
        f_result = lowlevel_lifetime(data_good,hdr);