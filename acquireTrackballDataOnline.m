function acquireTrackballDataOnline

%% Trackball settings 
%{
resolution  = 8200cpi 
1 inch = 25.4mm
allow for gain 

%}
fprintf('\n*********** Acquiring Trial ***********\n') 

sensorRes  = 8200; 
mmConv = 25.4;



%% Load settings    
inChannelsUsed = 8:9;
     
%% Configure daq
% daqreset;
devID = 'Dev1';

%% Configure input session
sIn = daq.createSession('ni');
sIn.Rate = 10E3;
sIn.DurationInSeconds = 10;

aI = sIn.addAnalogInputChannel(devID,inChannelsUsed,'Voltage');
for i = 1:length(inChannelsUsed)
    aI(i).InputType = 'SingleEnded';
end

%lh = sIn.addlistener('DataAvailable', @(src,event) plot(event.TimeStamps, event.Data));
lh = sIn.addlistener('DataAvailable', @plotData);

    function plotData(~,event) 
        offset = (1/6)*3.3;
        gain = (4/6)* 3.3 * 4095;
        figure(1)
%        plot(event.TimeStamps, cumsum((event.Data-2048).*mmConv./sensorRes))
        subplot(2,1,1)
        plot(event.TimeStamps, (event.Data(:,1) - offset).*gain)
        title('x')
        subplot(2,1,2)
        plot(event.TimeStamps, (event.Data(:,2) - offset).*gain)
        title('y')
    end


%% Run trials
sIn.NotifyWhenDataAvailableExceeds = 10*10e3;
%sIn.IsNotifyWhenDataAvailableExceedsAuto

sIn.startBackground;
sIn.wait()



%% Close daq objects
delete(lh)
sIn.stop;

% %% Plot data
% plotData(stim,settings,data)




end
