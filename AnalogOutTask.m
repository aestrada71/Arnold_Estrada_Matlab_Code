% once and for all: status  int32 The error code returned by the function in
% the event of an error or warning. A value of 0 indicates success. A positive
% value indicates a warning. A negative value indicates an error.

clear all
close all
clear global
if ~libisloaded('nicaiu') % checks if library is loaded
    hfile = ['C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h'];
    %hfile = ['C:\NIDAQmx.h'];
    loadlibrary('nicaiu.dll', hfile, 'mfilename', 'mxproto')
    % mxproto contains the function prototypes
end

% required constants (see NIDAQmx.h)
% Terminal Configuration
DAQmx_Val_Cfg_Default=int32(-1);        %%Default
DAQmx_Val_RSE=int32(10083);             %%RSE
DAQmx_Val_NRSE=int32(10078);            %%NRSE
DAQmx_Val_Diff=int32(10106);            %%Differential
DAQmx_Val_PseudoDiff=int32(12529);      %%Pseudodifferential
% Units
DAQmx_Val_Volts=int32(10348);           %%Volts
DAQmx_Val_FromCustomScale=int32(10065); %%From Custom Scale
% Active Edge
DAQmx_Val_Rising=int32(10280);          %%Rising
DAQmx_Val_Falling=int32(10171);         %%Falling
% Sample Mode
DAQmx_Val_FiniteSamps=int32(10178);     %%Finite Samples
DAQmx_Val_ContSamps=int32(10123);       %%Continuous Samples
DAQmx_Val_HWTimedSinglePoint=int32(12522);%%Hardware Timed Single Point
% Fill Mode
DAQmx_Val_GroupByChannel=uint32(0);     %%Group by Channel
DAQmx_Val_GroupByScanNumber=uint32(1);  %%Group by Scan Number

% either load task already created using Measurement & Automation Explorer (MAX)
% or create new task
TaskLoad=1;
GenerateOutput=1;
if TaskLoad
    if GenerateOutput
        taskh0=libpointer('uint32Ptr',0);
        [a,b,c]=calllib('nicaiu','DAQmxLoadTask','TestVoltageOutTask',taskh0);
        if (a<0)
            %int32 DAQmxGetErrorString (int32 errorCode, char errorString[], uInt32 bufferSize);
            error='Some dumb string.  Bla bla bla bla bla bla bla bla bla bla bla';
            [z,y]=calllib('nicaiu','DAQmxGetErrorString',a,error,62);
        end
        
         %configure timing for analog write
         rate=double(1000);
         activeEdge=DAQmx_Val_Rising;
         sampleMode=DAQmx_Val_ContSamps;
         BuffSize=uint64(10000);
        [a,b]=calllib('nicaiu','DAQmxCfgSampClkTiming',get(taskh0,'Value'),'OnboardClock',...
            rate,activeEdge,sampleMode,BuffSize);
        
        %start the task
        [a]=calllib('nicaiu','DAQmxStartTask',get(taskh0,'Value'));
    end
    

end

if GenerateOutput 
    a=calllib('nicaiu','DAQmxStopTask',get(taskh0,'Value'));
end

if GenerateOutput
    a=calllib('nicaiu','DAQmxClearTask',get(taskh0,'Value'));
end
%%int32 DAQmxClearTask(uint32)
%%int32 DAQmxClearTask (TaskHandle taskHandle);

%unloadlibrary 'nicaiu'; % unload library

% plot data
%figure
%plot(b)