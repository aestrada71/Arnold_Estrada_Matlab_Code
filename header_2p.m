function [full_output_name] = header_2p(fpath)
     if nargin~=1
         fpath= uigetdir('C:\Data\','Select Directory');
         fname_struct = dir(fpath);
     else
         fname_struct = dir(fpath);
     end
    
     %% Number of files in selected directory
     number_files=numel(fname_struct);
     
     %% Output File Name
     out_file_name='header_data.txt';
     
     %% Check if file already exists (will overwrite existing)
     if exist(fullfile(fpath,out_file_name))~=0
         number_files=number_files-1;
     end
     
     %% Loop Index for files begins at 3 as first two indices in directory listing are pointers
     for k=3:number_files
         fname = fname_struct(k).name;
         fname_full=fullfile(fpath,fname);         
         
         %% Opens each successive file in selected directory upon loop iteration
         [a hdr]=read_2p(fname_full);
        
         %% Opens output file for writing
         full_output_name=fullfile(fpath,out_file_name);
         if k==3 % Decides to create new file or append to existing
             file_1 = fopen(full_output_name,'w');
         else
             file_1 = fopen(full_output_name,'a');
         end
         
         %% Writes header data label to first line of output file (tab delimited)
         if k==3
             fprintf(file_1, ['File\tVersion\theaderSize\ttypeSize\tn1\tn2\tnumFrames\tvalidX\tvalidY\tmag\txMin\txMax\tyMin\tyMax\tzPos\txPos\tyPos\tADC_Min_V\tADC_Max_V\tNumBits\tADC_Min_Count\tLineRate\tLineLength\tobjScaling\tlsx1\tlsy1\tlsx2\tlsy2', '\n']);
         end
        
         %% Begin writing header data to output file for each file in
         %% directory (tab delimited)
         fprintf(file_1,fname);
         fprintf(file_1,'\t%f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d\t%d\t%f\t%f\t%f\t%d\t%d\t%d\t%d\n', hdr.Version, hdr.headerSize, hdr.typeSize, hdr.n1, hdr.n2, hdr.numFrames, hdr.validX, hdr.validY, hdr.mag, hdr.xMin, hdr.xMax, hdr.yMin,...
             hdr.yMax, hdr.zPos, hdr.xPos, hdr.yPos, hdr.ADC_Min_V, hdr.ADC_Max_V, hdr.NumBits, hdr.ADC_Min_Count, hdr.LineRate, hdr.LineLength, hdr.objScaling, hdr.lsx1, hdr.lsy1,...
             hdr.lsx2, hdr.lsy2);
         fclose(file_1);
        clear hdr; 
     end
     
  

     

