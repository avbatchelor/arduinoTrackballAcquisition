function acquireTrackballData

%% Trackball settings
%{
resolution  = 8200cpi
1 inch = 25.4mm
allow for gain

%}
fprintf('\n*********** Acquiring Trial ***********\n')

sensorRes  = 8200;
mmConv = 25.4;
Dur = 10;
sampRate = 10e3;
offset = (1/6)*3.3;
gain = (4/6)* 3.3 * 4095;

%% Load settings
inChannelsUsed = 8:9;

%% Configure daq
% daqreset;
devID = 'Dev1';

%% Configure input session
sIn = daq.createSession('ni');
sIn.Rate = sampRate;
sIn.DurationInSeconds = Dur;

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
subplot(2,1,1)
plot(time,rawData(:,1))
title('x')
subplot(2,1,2)
plot(time,rawData(:,2))
title('y')

end
