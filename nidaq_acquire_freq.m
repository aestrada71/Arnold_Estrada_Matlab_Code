function nidaq_acquire_ade(device_name,channel_number,samples_per_second,collection_duration_in_seconds,freq,data_filename)
ai = analoginput('nidaq',device_name);

sampsPerTrig = samples_per_second/freq;


set(ai,'SampleRate',samples_per_second);
set(ai,'SamplesPerTrigger',sampsPerTrig);

set(ai,'LoggingMode','Disk');
set(ai,'LogFileName',data_filename);
addchannel(ai,channel_number);
set(ai,'InputType','SingleEnded');
tChan = addchannel(ai,6,'TrigChan');
set(ai,'TriggerChannel',tChan);
set(ai,'TriggerType','Software');
set(ai,'TriggerCondition','Rising');
set(ai,'TriggerConditionValue',1.5);
set(ai,'TriggerRepeat',(collection_duration_in_seconds*samples_per_second/sampsPerTrig)-1);
%set(ai,'TriggerRepeat',101);
start(ai);
wait(ai,collection_duration_in_seconds + 10);
delete(ai);
clear ai