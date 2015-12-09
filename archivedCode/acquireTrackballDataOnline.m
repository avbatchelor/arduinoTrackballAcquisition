function acquireTrackballDataOnline

%% Trackball settings 
%{
resolution  = 8200cpi 
1 inch = 25.4mm
allow for gain 

%}
close all
fprintf('\n*********** Acquiring Trial ***********\n') 

%% Load settings    
inChannelsUsed = 0:1;
     
%% Configure daq
% daqreset;
devID = 'Dev1';
sampRate = 40E3;
accumData = [];
accumTime = [];

%% Configure input session
sIn = daq.createSession('ni');
sIn.Rate = sampRate;
sIn.DurationInSeconds = 60;

aI = sIn.addAnalogInputChannel(devID,inChannelsUsed,'Voltage');
for i = 1:length(inChannelsUsed)
    aI(i).InputType = 'SingleEnded';
end

%lh = sIn.addlistener('DataAvailable', @(src,event) plot(event.TimeStamps, event.Data));
lh = sIn.addlistener('DataAvailable', @plotData);

    function plotData(~,event) 
        settings = ballSettings; 
        accumData = [accumData;event.Data];
        accumTime = [accumTime;event.TimeStamps];
        
        [vel(:,1),disp(:,1)] = getVel(accumData(:,1),settings.xMinVal,settings.xMaxVal,settings,sampRate);
        [vel(:,2),disp(:,2)] = getVel(accumData(:,2),settings.yMinVal,settings.yMaxVal,settings,sampRate);
        figure(1)
%        plot(event.TimeStamps, cumsum((event.Data-2048).*mmConv./sensorRes))
        subplot(4,1,1)
        plot(accumTime, vel(:,1))
%         plot(accumTime, event.Data(:,1))
        title('Vx')
        subplot(4,1,2)
        plot(accumTime, vel(:,2))
%         plot(accumTime, event.Data(:,2))
        title('Vy')
        subplot(4,1,3)
        plot(accumTime, disp(:,1))
        title('X Disp')
        subplot(4,1,4)
        plot(accumTime, disp(:,2))
        title('Y Disp')
        
    end


%% Run trials
sIn.NotifyWhenDataAvailableExceeds = 1*sIn.Rate;
%sIn.IsNotifyWhenDataAvailableExceedsAuto

sIn.startBackground;
sIn.wait()



%% Close daq objects
delete(lh)
sIn.stop;

% %% Plot data
% plotData(stim,settings,data)




end
