% Process trackball data to measure discretisation

clear all
close all
load('C:\Users\Alex\Dropbox\PhD\Year2\DataTemp\ballCalibrationData3');

%% Hard-coded parameters
% Sensor settings 
sensorRes  = 8200;
mmConv = 25.4;

% DAC settings 
minVal = .5857;%0.0037;%0.0284;%0.5607 - due dac value ;
maxVal = 2.7823;%3.3253;%4.8951;%2.7819 - due dac value;
numInts = 136;

% Set min and max step length 
lowTransIndThresh = 350;%80; 
highTransIndThresh = 450; 

% Acq settings
acquisitionRate = 40e3;

%% Calculated parameters 
offset = numInts/2;
intVal = (maxVal - minVal)/(numInts - 1);
mmPerCount = mmConv/sensorRes; 

%% Process data 
% Discretise
smoothedData = smooth(rawData(:,1),15);
seq = round((smoothedData(:,1) - minVal)./intVal);

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

% Find transitions 
dataDiff = diff(seq);
dataDiffBin = dataDiff~=0;
transInd = findstr(dataDiffBin',[1,0]) + 1;
indSep = diff(transInd);

% Check transitions
transVals = seq(transInd);  
figure
plot(seq)
hold on 
plot(transInd,transVals,'go')
title('Raw transitions')
clear transVals

% Check frequency of transitions
figure
hist(indSep,400)
title('transition separation histogram')

% Remove transitions that are too close together (these are artefacts) 
transInd(indSep<lowTransIndThresh) = [];

% Add an extra transition when the transition is too long 
indSep2 = diff(transInd);
medSep = round(median(indSep2)); 
highInd = transInd(highTransIndThresh<indSep2);
while ~isempty(highInd)
    newInd = highInd+medSep;
    transInd = sort([transInd,newInd]);
    indSep2 = diff(transInd);
    highInd = transInd(highTransIndThresh<indSep2);
end

% Read out values at transitions 
transVals = seq(transInd);  
figure
plot(seq)
hold on 
plot(transInd,transVals,'go')

%% Convert to form wanted 
% Subtract offset 
transVals = transVals - offset;
figure
plot(transVals)

% Convert counts to mm 
transVals = mmPerCount.*transVals;
figure
plot(transVals,'.')

% Calculate cumulative changes 
cumVals = cumsum(transVals);

figure
plot(transVals,'.')
hold on 
plot(cumVals,'g.')




%% See where steps of only 1 occur 
oneStepInd = find(diff(seq) == -1);
figure
plot(seq,'g')
hold on
plot(seqUnrounded,'b')
hold on 
plot(oneStepInd,seq(oneStepInd),'ro')

%% Check what differences between steps look like 
figure
plot(rawData(:,1),'g')
hold on
plot(diff(seq))
unique(diff(seq))

%% Check removal of too short transitions 
figure
hist(indSep,100)
title('indSep1')

figure 
plot(seq,'g')
hold on
plot(transInd,seq(transInd),'ro')

%% Add extra transitions when transitions are too long


figure
hist(indSep2,100)
title('indSep2')

figure 
plot(seq,'g')
hold on
plot(transInd,seq(transInd),'ro')

%%


figure 
plot(seq,'g')
hold on
plot(transInd,seq(transInd),'bo')
hold on
plot(highInd,seq(highInd)+0.1,'ro');
hold on 
plot(newInd,seq(newInd),'mo');

%%
figure
plot(dataDiff)
hold on 
plot(seq - 137,'g')
