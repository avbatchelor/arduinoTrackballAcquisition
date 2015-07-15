% Process trackball data to measure discretisation

clear all
close all
load('C:\Users\Alex\Dropbox\PhD\Year2\DataTemp\ballCalibrationData');

sensorRes  = 8200;
mmConv = 25.4;
minVal = 0.5607;
maxVal = 2.7819;
numInts = 274;

acquisitionRate = 10e3;
minVal = 0.5607;
maxVal = 2.7819;
offset = numInts/2;
intVal = (maxVal - minVal)/(numInts - 1);
mmPerCount = 25.4/8200; 

lowTransIndThresh = 20; 
highTransIndThresh = 60; 


%% Process data 
% Discretise
smoothedData = smooth(rawData(:,1),5);
seq = round((smoothedData(:,1) - minVal)./intVal);

% Find transitions 
dataDiff = diff(seq);
dataDiffBin = dataDiff~=0;
transInd = findstr(dataDiffBin',[1,0]) + 1;
indSep = diff(transInd);

% Remove transitions that are too close together (these are artefacts) 
transInd(indSep<lowTransIndThresh) = [];

% Add an extra transition when the transition is too long 
indSep2 = diff(transInd);
medSep = round(median(indSep2)); 
highInd = transInd(60<indSep2);
while ~isempty(highInd)
    newInd = highInd+medSep;
    transInd = sort([transInd,newInd]);
    indSep2 = diff(transInd);
    highInd = transInd(60<indSep2);
end

% Read out values at transitions 
transVals = seq(transInd);  
figure
plot(seq)
hold on 
plot(transInd,transVals,'go')

%%
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

% %% Check discretisation
% seqUnrounded = (rawData(:,1) - minVal)./intVal;
% 
% figure
% plot(seq,'g')
% hold on
% plot(seqUnrounded,'r')
% 
% %% Check mm conversion 
% 
% 
% %% See where steps of only 1 occur 
% oneStepInd = find(diff(seq) == -1);
% figure
% plot(seq,'g')
% hold on
% plot(seqUnrounded,'b')
% hold on 
% plot(oneStepInd,seq(oneStepInd),'ro')
% 
% %% Check what differences between steps look like 
% figure
% plot(rawData(:,1),'g')
% hold on
% plot(diff(seq))
% unique(diff(seq))
% 
% %% Check removal of too short transitions 
% figure
% hist(indSep,100)
% title('indSep1')
% 
% figure 
% plot(seq,'g')
% hold on
% plot(transInd,seq(transInd),'ro')
% 
% %% Add extra transitions when transitions are too long
% 
% 
% figure
% hist(indSep2,100)
% title('indSep2')
% 
% figure 
% plot(seq,'g')
% hold on
% plot(transInd,seq(transInd),'ro')
% 
% %%
% 
% 
% figure 
% plot(seq,'g')
% hold on
% plot(transInd,seq(transInd),'bo')
% hold on
% plot(highInd,seq(highInd)+0.1,'ro');
% hold on 
% plot(newInd,seq(newInd),'mo');
% 
% %%
% figure
% plot(dataDiff)
% hold on 
% plot(seq - 137,'g')
