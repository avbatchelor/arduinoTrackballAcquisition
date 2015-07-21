function seq = sparkfunDacDecoding(rawData)

close all

%% Hardcoded parameters 
xMinVal = 0.0490;
xMaxVal = 4.8516;
yMinVal = 0.0500;
yMaxVal = 4.4616;
numInts = 271;
cutoffFreq = 1000; 


%% Decode
seq(:,1) = findSeq(rawData(:,1),xMinVal,xMaxVal,numInts,'X',cutoffFreq); 
seq(:,2) = findSeq(rawData(:,2),yMinVal,yMaxVal,numInts,'Y',cutoffFreq); 

end

function seq = findSeq(rawData,minVal,maxVal,numInts,axis,cutoffFreq) 
    %% LPF
    rate = 2*(cutoffFreq/40000);     
    [kb, ka] = butter(2,rate);
    smoothedData = filtfilt(kb, ka, rawData);

%     figure
%     h(1) = subplot(1,3,1);
%     plot(rawData) 
%     hold on 
%     plot(smoothedData)
%     title(['Data and Smoothed Data, ',axis,' axis'])    

    voltsPerStep = (maxVal - minVal)/(numInts - 1);
    seq = round((smoothedData - minVal)./voltsPerStep);
    maxInt = numInts -1; 
    seq(seq>maxInt) = maxInt; 
    seq(seq<0) = 0;
    zeroVal = -1 + (numInts + 1)/2;
    seq = seq - zeroVal;
    
%     h(2) = subplot(1,3,2);
%     plot(seq,'g')
%     title(['Seq, ',axis,' axis'])
    
%     h(3) = subplot(1,3,3);
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
    title([axis,' axis'])
%     linkaxes(h(2:3))
    
%     figure
%     plot(diff(seq))
%     title(['Diff, ',axis,' axis'])
    
    
% sensorRes  = 8200;
% mmConv = 25.4;
% intVal = (maxVal - minVal)/(numInts-1);
% mmPerCount = 25.4/8200; 
% minVal = 0.5607;
% maxVal = 2.7819;
% numInts = 274;


end
