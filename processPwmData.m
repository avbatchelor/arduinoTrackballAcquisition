% Process raw PWM data 

pwmData = rawData(:,1);

% Find transitions
upTrans = strfind(pwmData',[0,1]);
downTrans = strfind(pwmData',[1,0]);

% Remove first down tranisition if it comes before an up tranisition 
if downTrans(1) < upTrans(1)
    downTrans(1) = [];
end 

% Remove last up transition if there is no down transition after 
if upTrans(end) > downTrans(end) 
    upTrans(end) = []; 
end 
    
stepLengths = downTrans - upTrans; 

figure
plot(stepLengths,'.') 

offset = 4;%min(stepLengths); 
stepSize = 4;%(996-4)/254;%(max(stepLengths) - min(stepLengths))/64; 

seq = stepLengths-501.5; 

figure 
plot(seq)

%% Other analysis
figure
plot(diff(stepLengths))

figure
plot(smooth(stepLengths,5))

