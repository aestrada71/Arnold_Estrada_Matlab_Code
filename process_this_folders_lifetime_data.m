function [varargout] = process_this_folders_lifetime_data()
%analize a folder's worth of sdt files and stores lifetime data in a file

clear all
showPlots = 1;
bDoubleExp = 0;
goodnessOfFitThreshold = 0.97;

%% get file names
if ispc
    fpath = uigetdir('c:\Data\');
else
    fpath = uigetdir('/Volumes/RUGGED/Data/2010_09_14/');
end

fpath2 = [fpath '/*.sdt'];

tempStruct = dir(fpath2);

numFiles = size(tempStruct,1);

%% Open results file
if ispc
    temp = [fpath '\Lifetime_Files_Summary.txt'];
else
    temp = [fpath '/Lifetime_Files_Summary.txt'];
end
fid=fopen(temp,'w');
if bDoubleExp
    fprintf(fid, 'FileName \t Lifetime(s) \t pO2(mmHg)\t Eguation\t a\t b\t c\t tau1\t tau2\t r\n');
else
    fprintf(fid, 'FileName \t Lifetime(s) \t pO2(mmHg)\t Eguation\t a\t b\t tau\t r\n');
end

%reads data files individualy
for (n=1:numFiles)
    tempName = fullfile(fpath,tempStruct(n).name);
    [tau,f] = find_lifetime_sdt(bDoubleExp,tempName);


    pO2Val = po2_2pp(tau);
    name = tempStruct(n).name;
    if bDoubleExp
       fprintf(fid,'"%s"\t %e\t %3.3f\t "%s"\t %3.3f\t %3.3f\t %3.3f\t %3.3f\t %3.3f\t %e\n',name, tau, pO2Val, f.eq, ...
       f.m(1),f.m(2),f.m(3), f.m(4), f.m(5), f.r); 
    else
        fprintf(fid,'"%s"\t %e\t %3.3f\t "%s"\t %3.3f\t %3.3f\t %3.3f\t %e\n',name, tau, pO2Val, f.eq, ...
        f.m(1),f.m(2),f.m(3),f.r);
    end
    resultStruct(n).name = name;
    resultStruct(n).tau = tau;
    resultStruct(n).pO2Val = pO2Val;
    resultStruct(n).info = f;
    
end

status = fclose(fid);
varargout(1) = {resultStruct};

end