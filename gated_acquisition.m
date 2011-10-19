ai=analoginput('nidaq','Dev1');
chan=addchannel(ai, 0);

samp_rate=1e6; 
duration=750e-6; % acquisition duration (s)
num_triggers=100;

set(ai, 'SampleRate', samp_rate);
ActualRate=get(ai,'SampleRate');
set(ai, 'SamplesPerTrigger', ActualRate*duration);
set(ai, 'TriggerType', 'HwDigital');
set(ai, 'TriggerRepeat', num_triggers);

start(ai);

while strcmp(ai.Running,'On');
        disp( sprintf('%d',ai.SamplesAcquired) )
        drawnow
        pause(2);
end
[i,t]=getdata(ai,num_triggers*ActualRate*duration);
delete(ai); clear ai


