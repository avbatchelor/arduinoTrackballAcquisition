// Import libraries
#include <SPI.h>
#include <avr/pgmspace.h>
#include <clockwork.h>

volatile int xydat[2];
const int xOutPin = DAC0;
const int yOutPin = DAC1; 
const int aWriteRes = 12;

unsigned int testDat;

void setup() {
  Serial.begin(9600);
  
  analogWriteResolution(aWriteRes); 
  
}

void tet_warning(long t) {
  Serial.print(t);
  Serial.println(" TET warning!");
}

Clockwork cw(10, tet_warning);

void loop() 
{
  for (testDat = 16; testDat < 4067; testDat=testDat+15)  
  {
        cw.start();
        analogWrite(xOutPin,testDat); //has to be a number between 0 and 4095 - need to choose an appropriate gain to do this
        analogWrite(yOutPin,testDat); //has to be a number between 0 and 4095 - need to choose an appropriate gain to do this
        Serial.println(testDat);
        cw.stop();
  }   
}
 

