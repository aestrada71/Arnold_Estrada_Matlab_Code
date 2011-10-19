function avg = avg_2p()

    [fname, fpath]= uigetfile('*.dat', 'MultiSelect', 'on');
    
    numNames = size(fname,2);
    
    sum = 0;
    
    for n = 1:numNames
        
       tempName = fullfile(fpath,fname{1,n});
       temp = old_read_2p(tempName);
       
       sum = sum + temp;             
       
        
    end
    
    avg = sum ./ numNames;
    
    