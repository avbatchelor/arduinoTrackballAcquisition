#include <clockwork.h>

int pwmPin = 2;   
unsigned int testDat = 0; 
int JUMP_VAL = 1;


void setup() {
    pinMode(pwmPin, OUTPUT);   // sets the pin as output
    analogWriteResolution(8);
    Serial.begin(9600);
}

void tet_warning(long t) {
  Serial.print(t);
  Serial.println(" TET warning!");
}

Clockwork cw(10, tet_warning);

void loop() {
      
  for (testDat = 1; testDat < 255; testDat=testDat+JUMP_VAL) 
  {
    cw.start();
    // analogWrite(pwmPin, testDat);
    //int rand_num = random(1, 254);
    analogWrite(pwmPin, testDat);
    cw.stop();
  }
}



