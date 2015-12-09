numSec=1;


s1 = serial('COM4');    % define serial port
s1.BaudRate=9600;               % define baud rate
set(s1, 'terminator', 'LF');    % define the terminator for println
fopen(s1);


w=fscanf(s1,'%s');              % must define the input % d or %s, etc.

i=0;
t0=tic;
while (toc(t0)<=numSec)
    i=i+1;
    ballData(i,:)=fscanf(s1,'%d%*[|]%d%*[|]%d');
end
fclose(s1);


xPos = ballData(:,1);
yPos = ballData(:,2);
time = ballData(:,3);