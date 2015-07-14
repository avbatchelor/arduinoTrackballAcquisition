function acquireBallTrialRecord

%% Close serial connection if already open 
newobjs = instrfind;
fclose(newobjs);

%% Create stimulus if needed
stim = PipStimulus;
stim.startPadDur = 0; 
stim.endPadDur = 0; 
stim.numPips = 100; 

%% Load settings
settings = ballSettings(stim);

%% Configure session
s = daq.createSession('ni');
s.Rate = settings.sampRate.out;

% Add analog out channel (speaker)
s.addAnalogOutputChannel(settings.devID,0,'Voltage');
s.Rate = settings.sampRate.out;

%% Setup serial acquisition
s1 = serial(settings.serialPort);            % define serial port
s1.BaudRate=settings.baudRate;               % define baud rate
set(s1, 'terminator', 'LF');    % define the terminator for println
s1.RecordName = 'C:\Users\Alex\Documents\Data\MyRecord.txt';
s1.RecordMode = 'index';
s1.RecordDetail = 'verbose';

%% Send analog out
s.queueOutputData([stim.stimulus]);
s.startBackground;

%% Acquire ball data
fopen(s1);
fprintf('\n*********** Opened serial connection ***********')

record(s1)
disp('Recording serial')

pause(6)
record(s1,'off')
fclose(s1);
delete(s1);

%% Close daq objects
s.stop;


end

