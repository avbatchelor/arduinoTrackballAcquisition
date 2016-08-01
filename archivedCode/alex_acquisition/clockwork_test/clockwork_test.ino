#include <clockwork.h>

void setup() {
  // put your setup code here, to run once:
Serial.begin(9600);
}

Clockwork cw(10);

void loop() {
  // put your main code here, to run repeatedly:
cw.start();   
Serial.println(micros());
cw.stop();  
}
