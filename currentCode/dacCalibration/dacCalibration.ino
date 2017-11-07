// Import libraries
#include <SPI.h>
#include <avr/pgmspace.h>
#include <clockwork.h>
#include <Wire.h> //Include the Wire library to talk I2C

#define MCP4725_ADDR_1 0x60    //first dac i2c address
#define MCP4725_ADDR_2 0x61    //second dac i2c address


byte initComplete = 0;
volatile int xydat[2];
int wireOut[2];
volatile byte movementflag = 0;
const int ncs = 51;
const int mot = 53;
byte xH;
byte xL;
byte yH;
byte yL;
byte Motion;
unsigned int testDat;

// Registers
#define REG_Product_ID                           0x00
#define REG_Revision_ID                          0x01
#define REG_Motion                               0x02
#define REG_Delta_X_L                            0x03
#define REG_Delta_X_H                            0x04
#define REG_Delta_Y_L                            0x05
#define REG_Delta_Y_H                            0x06
#define REG_SQUAL                                0x07
#define REG_Pixel_Sum                            0x08
#define REG_Maximum_Pixel                        0x09
#define REG_Minimum_Pixel                        0x0a
#define REG_Shutter_Lower                        0x0b
#define REG_Shutter_Upper                        0x0c
#define REG_Frame_Period_Lower                   0x0d
#define REG_Frame_Period_Upper                   0x0e
#define REG_Configuration_I                      0x0f
#define REG_Configuration_II                     0x10
#define REG_Frame_Capture                        0x12
#define REG_SROM_Enable                          0x13
#define REG_Run_Downshift                        0x14
#define REG_Rest1_Rate                           0x15
#define REG_Rest1_Downshift                      0x16
#define REG_Rest2_Rate                           0x17
#define REG_Rest2_Downshift                      0x18
#define REG_Rest3_Rate                           0x19
#define REG_Frame_Period_Max_Bound_Lower         0x1a
#define REG_Frame_Period_Max_Bound_Upper         0x1b
#define REG_Frame_Period_Min_Bound_Lower         0x1c
#define REG_Frame_Period_Min_Bound_Upper         0x1d
#define REG_Shutter_Max_Bound_Lower              0x1e
#define REG_Shutter_Max_Bound_Upper              0x1f
#define REG_LASER_CTRL0                          0x20
#define REG_Observation                          0x24
#define REG_Data_Out_Lower                       0x25
#define REG_Data_Out_Upper                       0x26
#define REG_SROM_ID                              0x2a
#define REG_Lift_Detection_Thr                   0x2e
#define REG_Configuration_V                      0x2f
#define REG_Configuration_IV                     0x39
#define REG_Power_Up_Reset                       0x3a
#define REG_Shutdown                             0x3b
#define REG_Inverse_Product_ID                   0x3f
#define REG_Motion_Burst                         0x50
#define REG_SROM_Load_Burst                      0x62
#define REG_Pixel_Burst                          0x64

extern const unsigned short firmware_length;
extern prog_uchar firmware_data[];

void setup() {
  Serial.begin(9600);
  Wire.begin(); //prepare for i2c communication with DACs
  
  pinMode (ncs, OUTPUT);
  pinMode (mot, INPUT);

  //attachInterrupt(mot, readXY, FALLING);

  SPI.begin();
  SPI.setDataMode(SPI_MODE3);
  SPI.setBitOrder(MSBFIRST);
  SPI.setClockDivider(42);

  performStartup();
  delay(10);
  Serial.println("ADNS9800testPolling");
  adns_write_reg(REG_Configuration_I, 0x29); // maximum resolution
  dispRegisters();
  delay(5000);
  initComplete = 9;

}

void adns_com_begin() {
  digitalWrite(ncs, LOW);
}

void adns_com_end() {
  digitalWrite(ncs, HIGH);
}

byte adns_read_reg(byte reg_addr) {
  adns_com_begin();

  // send adress of the register, with MSBit = 0 to indicate it's a read
  SPI.transfer(reg_addr & 0x7f );
  delayMicroseconds(100); // tSRAD
  // read data
  byte data = SPI.transfer(0);

  delayMicroseconds(1); // tSCLK-NCS for read operation is 120ns
  adns_com_end();
  delayMicroseconds(19); //  tSRW/tSRR (=20us) minus tSCLK-NCS

  return data;
}

void adns_write_reg(byte reg_addr, byte data) {
  adns_com_begin();

  //send adress of the register, with MSBit = 1 to indicate it's a write
  SPI.transfer(reg_addr | 0x80 );
  //sent data
  SPI.transfer(data);

  delayMicroseconds(20); // tSCLK-NCS for write operation
  adns_com_end();
  delayMicroseconds(100); // tSWW/tSWR (=120us) minus tSCLK-NCS. Could be shortened, but is looks like a safe lower bound
}

void adns_upload_firmware() {
  // send the firmware to the chip, cf p.18 of the datasheet
  Serial.println("Uploading firmware...");
  // set the configuration_IV register in 3k firmware mode
  adns_write_reg(REG_Configuration_IV, 0x02); // bit 1 = 1 for 3k mode, other bits are reserved

  // write 0x1d in SROM_enable reg for initializing
  adns_write_reg(REG_SROM_Enable, 0x1d);

  // wait for more than one frame period
  delay(10); // assume that the frame rate is as low as 100fps... even if it should never be that low

  // write 0x18 to SROM_enable to start SROM download
  adns_write_reg(REG_SROM_Enable, 0x18);

  // write the SROM file (=firmware data)
  adns_com_begin();
  SPI.transfer(REG_SROM_Load_Burst | 0x80); // write burst destination adress
  delayMicroseconds(15);

  // send all bytes of the firmware
  unsigned char c;
  for (int i = 0; i < firmware_length; i++) {
    c = (unsigned char)pgm_read_byte(firmware_data + i);
    SPI.transfer(c);
    delayMicroseconds(15);
  }
  adns_com_end();
}


void performStartup(void) {
  adns_com_end(); // ensure that the serial port is reset
  adns_com_begin(); // ensure that the serial port is reset
  adns_com_end(); // ensure that the serial port is reset
  adns_write_reg(REG_Power_Up_Reset, 0x5a); // force reset
  delay(50); // wait for it to reboot
  // read registers 0x02 to 0x06 (and discard the data)
  adns_read_reg(REG_Motion);
  adns_read_reg(REG_Delta_X_L);
  adns_read_reg(REG_Delta_X_H);
  adns_read_reg(REG_Delta_Y_L);
  adns_read_reg(REG_Delta_Y_H);
  // upload the firmware
  adns_upload_firmware();
  delay(10);
  //enable laser(bit 0 = 0b), in normal mode (bits 3,2,1 = 000b)
  // reading the actual value of the register is important because the real
  // default value is different from what is said in the datasheet, and if you
  // change the reserved bytes (like by writing 0x00...) it would not work.
  byte laser_ctrl0 = adns_read_reg(REG_LASER_CTRL0);
  adns_write_reg(REG_LASER_CTRL0, laser_ctrl0 & 0xf0 );

  delay(1);

  Serial.println("Optical Chip Initialized");
}

void readXY(void) {
  if (initComplete == 9) {

    digitalWrite(ncs, LOW);
    Motion = (adns_read_reg(REG_Motion) & (1 << 8 - 1)) != 0;
    xL = (int)adns_read_reg(REG_Delta_X_L);
    xH = (int)adns_read_reg(REG_Delta_X_H);
    yL = (int)adns_read_reg(REG_Delta_Y_L);
    yH = (int)adns_read_reg(REG_Delta_Y_H);
    xydat[0] = (xH << 8) + xL;
    xydat[1] = (yH << 8) + yL;
    digitalWrite(ncs, HIGH);

    //movementflag=1;
  }
}

void dispRegisters(void) {
  int oreg[7] = {
    0x00, 0x3F, 0x2A, 0x02
  };
  char* oregname[] = {
    "Product_ID", "Inverse_Product_ID", "SROM_Version", "Motion"
  };
  byte regres;

  digitalWrite(ncs, LOW);

  int rctr = 0;
  for (rctr = 0; rctr < 4; rctr++) {
    SPI.transfer(oreg[rctr]);
    delay(1);
    Serial.println("---");
    Serial.println(oregname[rctr]);
    Serial.println(oreg[rctr],HEX);
    regres = SPI.transfer(0);
    Serial.println(regres,BIN);
    Serial.println(regres,HEX);
    delay(1);
  }
  digitalWrite(ncs, HIGH);
}


int convTwosComp(int b) {
  //Convert from 2's complement
  if (b & 0x8000) {
    b = -1 * ((b ^ 0xffff) + 1);
  }
  return b;
}

void tet_warning(long t) {
  Serial.print(t);
  Serial.println(" TET warning!");
}

Clockwork cw(10, tet_warning);

void loop()
{


  /*
  readXY();
  xydat[0] = convTwosComp(xydat[0]);
  xydat[1] = convTwosComp(xydat[1]);

  
  wireOut[0] = 2041+(xydat[0]*15);
  wireOut[1] = 2041+(xydat[1]*15);
  if (wireOut[0] > 4066) {
    wireOut[0] = 4066; 
  }
  if (wireOut[0] < 16) {
    wireOut[0] = 16; 
  }
  if (wireOut[1] > 4066) {
    wireOut[1] = 4066; 
  }
  if (wireOut[1] < 16) {
    wireOut[1] = 16; 
  } 

   */

 /*
  Serial.print("X Dat: "); 
  Serial.print(xydat[0]); 
  Serial.print("Y Dat: "); 
  Serial.print(xydat[1]);
  Serial.print("X Wire: "); 
  Serial.print(wireOut[0]); 
  Serial.print("Y Wire: "); 
  Serial.println(wireOut[1]);
  */

  



  for (testDat = 16; testDat < 4067; testDat=testDat+15)  
  {
        cw.start();
        wireOut[0] = 2041; 
        wireOut[1] = testDat; 
        Serial.println(testDat);
        cw.stop();

        Wire.beginTransmission(MCP4725_ADDR_1);
        Wire.write(64);                     // cmd to update the DAC
        Wire.write(wireOut[0] >> 4);        // the 8 most significant bits...
        Wire.write((wireOut[0] & 15) << 4); // the 4 least significant bits...
        int wire1err = Wire.endTransmission();
        if (wire1err != 0)
        {
          Serial.print("ERROR:: Wire1.endTransmission returned: ");
          Serial.println(wire1err);
        }
      
        Wire.beginTransmission(MCP4725_ADDR_2);
        Wire.write(64);                     // cmd to update the DAC
        Wire.write(wireOut[1] >> 4);        // the 8 most significant bits...
        Wire.write((wireOut[1] & 15) << 4); // the 4 least significant bits...
        int wire2err = Wire.endTransmission();
        if (wire2err != 0)
        {
          Serial.print("ERROR:: Wire2.endTransmission returned: ");
          Serial.println(wire2err);
        }  
  }   

}


