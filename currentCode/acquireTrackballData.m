%% acquireTrackballData

% For looking at raw data from trackball 

clear all 
close all


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
devID = 'Dev3';

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

%% Process ball data

%% Smooth data 
settings = ballSettings; 
rate = 2*(settings.cutoffFreq/settings.sampRate);
[kb, ka] = butter(2,rate);
smoothedData = filtfilt(kb, ka, rawData);

%% Digitize
% Calculate step sizes etc. 
xVoltsPerStep = (settings.xMaxVal - settings.xMinVal)/(settings.numInts - 1);
yVoltsPerStep = (settings.yMaxVal - settings.yMinVal)/(settings.numInts - 1);
maxInt = settings.numInts -1;

% Discretize
seq(:,1) = round((smoothedData(:,1) - settings.xMinVal)./xVoltsPerStep);
seq(:,2) = round((smoothedData(:,2) - settings.yMinVal)./yVoltsPerStep);
seq(seq>maxInt) = maxInt;
seq(seq<0) = 0;

% Discretize non-smoothed data 
seq2(:,1) = round((rawData(:,1) - settings.xMinVal)./xVoltsPerStep);
seq2(:,2) = round((rawData(:,2) - settings.yMinVal)./yVoltsPerStep);
seq2(seq>maxInt) = maxInt;
seq2(seq<0) = 0;

time = [1/sampRate:1/sampRate:Dur];

figure(1)
h(1) = subplot(2,1,1);
hold on 
plot(time,rawData(:,1))
plot(time,smoothedData(:,1),'r')
title('x')
xlabel('Time (s)')
ylabel('Voltage (V)')
legend('raw','smoothed')


h(2) = subplot(2,1,2);
hold on 
plot(time,rawData(:,2));
plot(time,smoothedData(:,2),'r');
legend('raw','smoothed')

% %% Plot data in volts
% figure(1)
% h(1) = subplot(2,1,1);
% hold on 
% plot(time,rawData(:,1)-settings.xMinVal)
% plot(time,smoothedData(:,1)-settings.xMinVal,'r')
% plot(time,seq(:,1)*xVoltsPerStep,'g')
% plot(time,seq2(:,1)*xVoltsPerStep,'k')
% title('x')
% xlabel('Time (s)')
% ylabel('Voltage (V)')
% 
% h(2) = subplot(2,1,2);
% hold on 
% plot(time,rawData(:,2)-settings.yMinVal);
% plot(time,smoothedData(:,2)-settings.yMinVal,'r');
% plot(time,seq(:,2)*yVoltsPerStep,'g');
% plot(time,seq2(:,2)*xVoltsPerStep,'k')
% title('y')
% xlabel('Time (s)')
% ylabel('Voltage (V)')
% 
% linkaxes(h(:))
% 
% %% Plot data in steps
% time = [1/sampRate:1/sampRate:Dur];
% figure(2)
% h(1) = subplot(2,1,1);
% hold on 
% plot(time,(rawData(:,1)-settings.xMinVal)./xVoltsPerStep)
% plot(time,(smoothedData(:,1)-settings.xMinVal)./xVoltsPerStep,'r')
% plot(time,seq(:,1),'g')
% plot(time,seq2(:,1),'k')
% title('x')
% xlabel('Time (s)')
% ylabel('Voltage (V)')
% 
% h(2) = subplot(2,1,2);
% hold on 
% plot(time,(rawData(:,2)-settings.yMinVal)./yVoltsPerStep);
% plot(time,(smoothedData(:,2)-settings.yMinVal)./yVoltsPerStep,'r');
% plot(time,seq(:,2),'g');
% plot(time,seq2(:,2),'k')
% title('y')
% xlabel('Time (s)')
% ylabel('Voltage (V)')
% 
% linkaxes(h(:))
% 
% %% Plot differences 
% figure(3); 
% subplot(2,1,1)
% plot(diff(seq(:,1)))
% disp(unique(diff(seq(:,1))))
% subplot(2,1,2)
% plot(diff(seq(:,2)))
% disp(unique(diff(seq(:,2))))

%% Calculate mean Value 
startMean = settings.sampRate; 
endMean = length(smoothedData)-settings.sampRate; 
xMean = mean(smoothedData(startMean:endMean,1)); 
yMean = mean(smoothedData(startMean:endMean,2)); 

% %% Generate repeatable random sequence 
% rng(1);
% outList = 16:15:4066;
% randIdx = randperm(271);
% randOutList = outList(randIdx);
% 
% C = {randOutList}






% %% Plot processed data
% for i = 1:length(rawData,2)
%     smoothedData(:,i) = smooth(rawData(:,i),5);
%     discData(:,i) = round((smoothedData(:,i) - minVal)./intVal);
%     discDataMm(:,i) = mmPerCount.*(discData(:,i) - (numInts/2));
%     dataOut(:,i) = cumsum(discDataMm(:,i)); 
% end
% 
% figure
% subplot(2,1,1) 
% plot(time,dataOut(:,1))
% title('x')
% subplot(2,1,2)
% plot(time,dataOut(:,2))
% title('y')