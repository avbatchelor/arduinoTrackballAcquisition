function rawData = acquireTrackballDataPWM

% For looking at raw data from trackball 
fprintf('\n*********** Acquiring Trial ***********\n')

%% Hard coded parameters
Dur = 10;
sampRate = 1e6;

%% Load settings
inChannelsUsed = 0;

%% Configure daq
% daqreset;
devID = 'Dev1';

%% Configure input session
sIn = daq.createSession('ni');
sIn.Rate = sampRate;
sIn.DurationInSeconds = Dur;

addDigitalChannel(sIn,devID,'Port0/Line0','InputOnly');

aI = sIn.addAnalogInputChannel(devID,inChannelsUsed,'Voltage');
for i = 1:length(inChannelsUsed)
    aI(i).InputType = 'SingleEnded';
end

rawData = sIn.startForeground;

%% Close daq objects
sIn.stop;

%% Plot data
time = [1/sampRate:1/sampRate:Dur];
figure()
plot(time,rawData(:,1))
title('x')
