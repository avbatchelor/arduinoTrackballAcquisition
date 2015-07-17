%% Plot PWM data 
pwmData = rawData(:,1);

% figure
% plot(pwmData)

rate = 2*(1e-4);     
[kb ka] = butter(2,rate);
x_filt = filtfilt(kb, ka, pwmData);

figure
%plot(rawData) 
hold on 
plot(x_filt,'r')
title('pwm')

%% LPF
rate = 2*(1000/40000);     
[kb ka] = butter(2,rate);
smoothedData = filtfilt(kb, ka, rawData);

figure
plot(rawData) 
hold on 
plot(smoothedData,'r')
title('dac')

%% Moving average
smoothedData = smooth(rawData(:,1),15);


%% Sparkfun DAC
minVal = .0548;
maxVal = 4.4182;
numInts = 271;

%% Decode
%offset = numInts/2;
intVal = (maxVal - minVal)/(numInts - 1);

seq = round((smoothedData(:,1) - minVal)./intVal);
figure
plot(seq,'g')

seq(seq>270) = 270; 
seq(seq<0) = 0; 
figure
plot(seq,'b')

% Check discretisation
seqUnrounded = (rawData(:,1) - minVal)./intVal;
seqUnroundedSmoothed = (smoothedData(:,1) - minVal)./intVal;

figure
plot(seq,'g')
hold on
plot(seqUnrounded,'r')
hold on 
plot(seqUnroundedSmoothed,'b')
title('Check discretisation')
