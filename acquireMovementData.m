function acquireMovementData

%% Configure daq
% daqreset;
devID = 'Dev1';

%% Configure ouput session
sOut = daq.createSession('ni');
sOut.Rate = settings.sampRate.out;

% Analog Channels / names for documentation
sOut.addAnalogOutputChannel(devID,0:1,'Voltage');
sOut.Rate = settings.sampRate.out;

% Add trigger
sOut.addTriggerConnection('External','Dev1/PFI3','StartTrigger');

%% Configure input session
sIn = daq.createSession('ni');
sIn.Rate = 5e3;
sIn.DurationInSeconds = 30;

aI = sIn.addAnalogInputChannel(devID,8:9,'Voltage');
for i = 1+inChannelsUsed
    aI(i).InputType = 'SingleEnded';
end

%% Run trials
rawData = sIn.startForeground;

%% Process and plot non-scaled data
% Process
data.xVel = rawData(:,1);
data.yVel = rawData(:,2);

%% Close daq objects
sOut.stop;
sIn.stop;

%% Plot data
figure(1)
subplot(2,1,1)
plot(xVel)
subplot(2,1,2)
plot(yVel)

end
