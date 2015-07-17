function seq = sparkfunDacDecoding(rawData)

close all

%% Hardcoded parameters 
xMinVal = 0.0441;
xMaxVal = 4.8659;
yMinVal = 0.0452;
yMaxVal = 4.4742;
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

    figure
    h(1) = subplot(1,3,1);
    plot(rawData) 
    hold on 
    plot(smoothedData)
    title(['Data and Smoothed Data, ',axis,' axis'])    

    voltsPerStep = (maxVal - minVal)/(numInts - 1);
    seq = round((smoothedData - minVal)./voltsPerStep);
    maxInt = numInts -1; 
    seq(seq>maxInt) = maxInt; 
    seq(seq<0) = 0;
    zeroVal = -1 + (numInts + 1)/2;
    seq = seq - zeroVal;
    
    h(2) = subplot(1,3,2);
    plot(seq,'g')
    title(['Seq, ',axis,' axis'])
    
    h(3) = subplot(1,3,3) ;
    % Check discretisation
    seqUnrounded = (rawData - minVal)./voltsPerStep;
    seqUnroundedSmoothed = (smoothedData - minVal)./voltsPerStep;

    plot(seq,'g')
    hold on
    plot(seqUnrounded,'r')
    hold on 
    plot(seqUnroundedSmoothed,'b')
    title('Raw, smoothed and discretized data')
    linkaxes(h(2:3))
    
    figure
    plot(diff(seq))
    title(['Diff, ',axis,' axis'])
    
    


end
