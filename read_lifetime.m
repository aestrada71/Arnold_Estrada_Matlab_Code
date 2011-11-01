function [data, hdr] = read_lifetime(filename)

    if (nargin < 1)   
    [fname, fpath]= uigetfile('*.dat','Name of file to read', 'c:\Data\');
    fname = fullfile(fpath,fname);
    
    else
      fname = filename;
    end


    
    
    fp = fopen(fname, 'rb','l');
    
    
    [hdr.headerSize, readCount] = fread(fp, 1,'int32');

    [hdr.typeSize, readCount] = fread(fp, 1,'int32');
    % ftell(fp);
    [hdr.sampRate, readCount]=fread(fp,1,'float64');
    % ftell(fp);
    [hdr.totalSamps, readCount]=fread(fp,1,'uint32');

    [hdr.sampsPerTrig, readCount]=fread(fp,1,'int32');
    [hdr.numTrigs, readCount]=fread(fp,1,'int32');

    position = ftell(fp);

    fseek(fp,hdr.headerSize,'bof');

 
    if (hdr.typeSize == 4)
       data = fread(fp,hdr.totalSamps,'uint32'); 
    else
    data = fread(fp,hdr.totalSamps,'float64');
    end
    %plot(data)
    fclose(fp);