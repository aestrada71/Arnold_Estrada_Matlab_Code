function nidaq_acquire_ade(device_name,channel_number,samples_per_second,collection_duration_in_seconds,freq,data_filename)
ai = analoginput('nidaq',device_name);


set(ai,'SampleRate',samples_per_second);
set(ai,'SamplesPerTrigger',collection_duration_in_seconds * samples_per_second);
set(ai,'LoggingMode','Disk');
set(ai,'LogFileName',data_filename);
addchannel(ai,channel_number);
start(ai);
wait(ai,collection_duration_in_seconds + 1);
delete(ai);
clear ai