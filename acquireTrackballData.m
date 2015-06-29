function rawData = acquireTrackballData

%% Trackball settings
%{
resolution  = 8200cpi
1 inch = 25.4mm
allow for gain

%}
fprintf('\n*********** Acquiring Trial ***********\n')

%% Hard coded parameters
sensorRes  = 8200;
mmConv = 25.4;
minVal = 0.5607;
maxVal = 2.7819;
numInts = 274;

Dur = 10;
sampRate = 10e3;

%% Calculated parameters 
intVal = (maxVal - minVal)/(numInts-1);
mmPerCount = 25.4/8200; 

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

%% Plot processed data
for i = 1:length(rawData,2)
    smoothedData(:,i) = smooth(rawData(:,i),5);
    discData(:,i) = round((smoothedData(:,i) - minVal)./intVal);
    discDataMm(:,i) = mmPerCount.*(discData(:,i) - (numInts/2));
    dataOut(:,i) = cumsum(discDataMm(:,i); 
end

figure
subplot(2,1,1) 
plot(time,dataOut(:,1))
title('x')
subplot(2,1,2)
plot(time,dataOut(:,2))
title('y')