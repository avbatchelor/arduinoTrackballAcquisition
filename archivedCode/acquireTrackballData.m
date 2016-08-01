function rawData = acquireTrackballData

% For looking at raw data from trackball 

%% Trackball settings
%{
resolution  = 8200cpi
1 inch = 25.4mm
allow for gain

%}
fprintf('\n*********** Acquiring Trial ***********\n')

%% Hard coded parameters
Dur = 10;
sampRate = 40e3;

%% Load settings
inChannelsUsed =0:1;

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
h(1) = subplot(2,1,1);
plot(time,rawData(:,1))
title('x')

h(2) = subplot(2,1,2);
plot(time,rawData(:,2));
title('y')

linkaxes(h(:))

% %% Plot processed data
% for i = 1:length(rawData,2)
%     smoothedData(:,i) = smooth(rawData(:,i),5);
%     discData(:,i) = round((smoothedData(:,i) - minVal)./intVal);
%     discDataMm(:,i) = mmPerCount.*(discData(:,i) - (numInts/2));
%     dataOut(:,i) = cumsum(discDataMm(:,i); 
% end
% 
% figure
% subplot(2,1,1) 
% plot(time,dataOut(:,1))
% title('x')
% subplot(2,1,2)
% plot(time,dataOut(:,2))
% title('y')