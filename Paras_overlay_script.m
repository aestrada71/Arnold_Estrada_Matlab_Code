%Paras Mehta
%9/30/2010

%calculate po2 values from .sdt files
%output files to summary
%process text files containing X,Y coordinate data
%plot .dat file and overlay pO2 values


%process a folder of sdt files; results in file 'Lifetime_Files_Summary.txt'
process_this_folders_lifetime_data();

%process text files to obtain X and Y coordinates of pO2 values
%overlay po2 values onto plot of .dat file
Paras_process_text_files();
%[acqNo,X,Y] = textread('fake.txt', '%f %*s %f %*s %f %*s %*f %*s %*f','headerlines',5);

