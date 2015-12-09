function plotBallCalibration(rawData)

close all
set(0,'DefaultFigureWindowStyle','normal')

Dur = 10;
sampRate = 40e3;
stim.timeVec = 1/sampRate:1/sampRate:Dur;
%% Decode
settings = ballSettings;
[procData.vel(:,1),procData.disp(:,1)] = findSeq(rawData(:,1),settings.xMinVal,settings.xMaxVal,settings,stim);
[procData.vel(:,2),procData.disp(:,2)] = findSeq(rawData(:,2),settings.yMinVal,settings.yMaxVal,settings,stim);

figure(1)
title('Velocity and displacement vs. time')

h(2) = subplot(4,2,1);
mySimplePlot(stim.timeVec,procData.vel(:,1))
set(gca,'XTick',[])
ylabel({'Lateral Vel';'(mm/s)'})
set(get(gca,'YLabel'),'Rotation',0,'HorizontalAlignment','right')

h(3) = subplot(4,2,3);
mySimplePlot(stim.timeVec,procData.vel(:,2))
set(gca,'XTick',[])
ylabel({'Forward Vel';'(mm/s)'})
set(get(gca,'YLabel'),'Rotation',0,'HorizontalAlignment','right')

h(4) = subplot(4,2,5);
mySimplePlot(stim.timeVec,procData.disp(:,1))
set(gca,'XTick',[])
ylabel({'X Disp';'(mm)'})
set(get(gca,'YLabel'),'Rotation',0,'HorizontalAlignment','right') 

h(5) = subplot(4,2,7);
mySimplePlot(stim.timeVec,procData.disp(:,2))
ylabel({'Y Disp';'(mm)'})
set(get(gca,'YLabel'),'Rotation',0,'HorizontalAlignment','right')
line([stim.timeVec(1),stim.timeVec(end)],[0,0],'Color','k')
xlabel('Time (s)')
linkaxes(h(:),'x')



subplot(4,2,2:2:8)
dispSub(:,1) = procData.disp(:,1);
dispSub(:,2) = procData.disp(:,2);
plot(dispSub(:,1),dispSub(:,2))
hold on 
plot(dispSub(1,1),dispSub(1,2),'go')
text(dispSub(1,1),dispSub(1,2),'start','Color','g','FontSize',12);
plot(dispSub(end,1),dispSub(end,2),'ro')
text(dispSub(end,1),dispSub(end,2),'stop','Color','r','FontSize',12);
plot(0,0,'bo')
text(0,0,'stim start','Color','b','Fontsize',12);
axis square
axis equal
xMax = max(abs(dispSub(:,1)));
xlim([-xMax,xMax])
yMax = max(abs(dispSub(:,1)));
ylim([-yMax,yMax])
xlabel('X displacement (mm)')
ylabel('Y displacement (mm)')
title('X-Y displacement')

end

function [velMm,disp] = findSeq(rawData,minVal,maxVal,settings,stim)
%% LPF
rate = 2*(settings.cutoffFreq/settings.sampRate);
[kb, ka] = butter(2,rate);
smoothedData = filtfilt(kb, ka, rawData);

voltsPerStep = (maxVal - minVal)/(settings.numInts - 1);
% seq = round((smoothedData - minVal)./voltsPerStep);
seq = (smoothedData - minVal)./voltsPerStep;
% maxInt = settings.numInts -1;
% seq(seq>maxInt) = maxInt;
% seq(seq<0) = 0;
zeroVal = -1 + (settings.numInts + 1)/2;
seq = seq - zeroVal;

velMm = seq.*settings.mmPerCount.*settings.sensorPollFreq;
disp = cumtrapz(stim.timeVec,velMm);

% Check discretisation
seqUnrounded = (rawData - minVal)./voltsPerStep;
seqUnrounded = seqUnrounded - zeroVal;
seqUnroundedSmoothed = (smoothedData - minVal)./voltsPerStep;
seqUnroundedSmoothed = seqUnroundedSmoothed - zeroVal;
    figure
    plot(seqUnrounded,'r')
    hold on
    plot(seqUnroundedSmoothed,'b')
    hold on
    plot(seq,'g')
    title(['Check discretisation',axis,' axis'])



end
