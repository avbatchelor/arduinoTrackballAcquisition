// Import libraries
#include <SPI.h>
#include <avr/pgmspace.h>
#include <Wire.h> //Include the Wire library to talk I2C
#include <clockwork.h>

#define MCP4725_ADDR_1 0x60    //first dac i2c address
#define MCP4725_ADDR_2 0x61    //second dac i2c address

unsigned int testDat1;
unsigned int testDat2;

void setup() {
  Serial.begin(9600); //prepare for usb communication with computer
  Wire.begin(); //prepare for i2c communication with DACs
}

void tet_warning(long t) {
  Serial.print(t);
  Serial.println(" TET warning!");
}

Clockwork cw(10,tet_warning);

void loop() {
  //for (testDat1 = 16; testDat1 < 4067; testDat1=testDat1+15)  {
  
    cw.start();  
    testDat1 = random(1,271);
    testDat1 = 1 + (testDat1*15);
    Wire.beginTransmission(MCP4725_ADDR_1);
    Wire.write(64);                     // cmd to update the DAC
    Wire.write(testDat1 >> 4);        // the 8 most significant bits...
    Wire.write((testDat1 & 15) << 4); // the 4 least significant bits...
    int wire1err = Wire.endTransmission();
    if (wire1err != 0)
      {
        Serial.print("ERROR:: Wire1.endTransmission returned: ");
        Serial.println(wire1err);
      }

    //testDat2 = random(1,271);
    //testDat2 = 1 + (testDat1*15);
    Wire.beginTransmission(MCP4725_ADDR_2);
    Wire.write(64);                     // cmd to update the DAC
    Wire.write(testDat1 >> 4);        // the 8 most significant bits...
    Wire.write((testDat1 & 15) << 4); // the 4 least significant bits...
    int wire2err = Wire.endTransmission();
    if (wire2err != 0)
      {
        Serial.print("ERROR:: Wire2.endTransmission returned: ");
        Serial.println(wire2err);
      }
     
    cw.stop(); 
  //}
}


