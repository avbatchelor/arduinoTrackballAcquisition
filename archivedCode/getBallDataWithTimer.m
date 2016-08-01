function [data, w] = getBallDataWithTimer

%% Load settings
stim = PipStimulus; 
settings = ballSettings(stim);

%% Close serial connection if already open 
newobjs = instrfind;
fclose(newobjs);

%% Setup serial acquisition
s1 = serial(settings.serialPort);            % define serial port
s1.BaudRate=settings.baudRate;               % define baud rate
set(s1, 'terminator', 'LF');    % define the terminator for println

%% Setup timer
ballData = []; 
myTimer = timer('Period', 0.01, 'ExecutionMode', 'fixedRate','TasksToExecute',10);
myTimer.timerFcn =  @myTimerCallbackFcn;
myTimer.startFcn = @initTimer; 

%% Acquire ball data
fopen(s1);
disp('** Opened serial connection')

start(myTimer)
disp('** Started timer')

    function initTimer(src, event)
        w=fscanf(s1,'%s');
        disp('** Acquired first serial sample');
    end
 
    function myTimerCallbackFcn(src,event)
        ballData(end+1,:)=fscanf(s1,'%d%*[|]%d%*[|]%d');
        disp('** Acquiring subsequent samples');
    end

while myTimer.TasksExecuted < 10
end
        
delete(myTimer)
fclose(s1);

%% Process data
data.xPos = ballData(:,1);
data.yPos = ballData(:,2);
data.time = ballData(:,3);



end


