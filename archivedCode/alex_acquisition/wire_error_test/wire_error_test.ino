// Import libraries
#include <SPI.h>
#include <avr/pgmspace.h>
#include <Wire.h> //Include the Wire library to talk I2C
#include <clockwork.h>

#define MCP4725_ADDR_1 0x60    //first dac i2c address
#define MCP4725_ADDR_2 0x61    //second dac i2c address

unsigned int testDat;

void setup() {
  Serial.begin(9600); //prepare for usb communication with computer
  Wire.begin(); //prepare for i2c communication with DACs
}

void tet_warning(long t) {
  Serial.print(t);
  Serial.println(" TET warning!");
}

Clockwork cw(5000, tet_warning);

void loop() {
  cw.start();
  int JUMP_VAL=1;
  for (testDat = 0; testDat < 4096; testDat=testDat+JUMP_VAL)  
  {
    Wire.beginTransmission(MCP4725_ADDR_1);
    Wire.write(64);                     // cmd to update the DAC
    Wire.write(testDat >> 4);        // the 8 most significant bits...
    Wire.write((testDat & 15) << 4); // the 4 least significant bits...
    int rc = Wire.endTransmission();
    if (rc != 0)
    {
      Serial.print("ERROR:: Wire.endTransmission returned: ");
      Serial.println(rc);
    }
  }

  Serial.println("All good");
  cw.stop();
}


