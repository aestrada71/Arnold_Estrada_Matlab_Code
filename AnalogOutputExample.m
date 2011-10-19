% General board checking
    out=daqhwinfo
    out2=daqhwinfo('nidaq')
    
% Instantiate analogoutput object
    ao = analogoutput('nidaq',1)
    
% Need to add channels to do something
   ochans = addchannel(ao,[0,1],{'xChan','yChan'})
%     ochans = addchannel(ao,[0],{'xChan'})           %single channel
   
% Configure channels
   sampleRate = 20000
   actualRate=setverify(ao,'SampleRate',sampleRate)  %set master clock to 100 kHz
   set(ao,'TriggerType','Immediate')
   
% Create the waveforms.  There are 256 lines of 1000 pts each @ 100 kHz
   numLines=256;
%    numPtsInALine = 1024;
    lineRate = 100      %Hertz
   
   [x,y] = fct_make_galv_sigs(numLines,lineRate,sampleRate);
    
    xAmplitude = 1;
    yAmplitude = 1;
    x=x*xAmplitude;
    y=y*yAmplitude;
    
 % Que up the data in the board's memory
    putdata(ao,[x y])
%      putdata(ao,[x])      %single channel
     
     
    set(ao,'RepeatOutput',1)
    
 % start the output object
    start(ao)
    
    
% %  % clean up
% %     delete(ao)
% %     clear ao