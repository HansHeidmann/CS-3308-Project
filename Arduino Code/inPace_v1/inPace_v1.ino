/*  ______________________________________________
   |     .  .    .   ___    ___     ____  _____  |
   |     |  |\   |  |   \  |   |   /      |      |
   |     |  | \  |  |___|  |___|  |       |____  |
   |     |  |  \ |  |      |   |  \       |      |
   |     |  |   \|  |      |   |   \____  |____  |
   |                                             |
   |*******       by Hans Heidmann        ********
   |                                             |
   |.......         Spring 2015           .......|
   |                                             |
   |_____________________________________________|
    
           ***   Parts List  ***
           ---------------------
                
    1. Arduino Pro Mini
    
    2. Adafruit Ultimate GPS Breakout Board
    
    3. Four-Pin Addressable G-R-B LED
    
    4. Adafruit microSD Card 
    
    5. Sparkfun LiPo Powercell Charger/Booster (*Fried Booster,  Replacement #: 8750  should arrive by 4/17/2015)
    
    6. 2 Momentary Tactile Push Buttons (4 pin)
    
    7. Red Bear Labs Bluetooth Module
            
    
    ---------------------------------------
     
    Adafruit microSD Card Read/Write Pins
 
    CS -> pin D-10
    MOSI -> pin D-11
    MISO -> pin D-12
    CLK -> pin D-13

    -----------------------------
    
    Adafruit Ultimate GPS_Module Module Pins
    
    RX --> pin D-2
    TX --> pin D-3
    
    -----------------------------
    
    Red Bear Labs BLE 4.0 Bluetooth Module Pins
    
    RX --> TX
    TX --> RX
    
    -----------------------------
    
    Bluetooth push button --> pin 8
    GPS push button --> pin 9
    
    -----------------------------
    
    Four-Pin Addressable G-R-B LED
    
         __   
        /  \
        |___|  <-- flat side
        /| |\
       | | | |
       | | | |
       | | | |
       | | | | 
       1 2 | |
           | |
           3 4            
  
    (1) logic input  -->  6
    (2) 4.5-6V VIN  -->  VCC
    (3) ground  -->  GND
    (4) locic output  -->  (Nothing, but could be used to chain more G-R-B LEDs together.)
    
    
    -----------------------------
    
  
    ////// systemState ////
    
    systemState = 0: initializing 
                     - LED should be RED
                     - attemping to get a GPS_Module Satellite fix
    
    
    systemState = 1: Logging GPS_Module data
                     - LED should be GREEN
                     - open dataFile (GPS_Moduledata.txt) for writing to
                     - read in GPS_Module data from software serial pins 2 and 3
                     - write GPS_Module data to the microSD
             
    
    systemState = 2: Sending Data Over Bluetooth
                     - LED should be BLUE
                     - open dataFile (GPS_Moduledata.txt) for reading from
                     - iterate through all the lines of the text file
                     - send each line of the text file through bluetooth as a string
                     - *GPS_Moduledata.txt will be "rebuilt" string by string on the iOS receiving end

*/


#include <Wire.h>
#include <SPI.h>
#include <SD.h>

#include <SoftwareSerial.h>
#include <TinyGPS.h>
#include "RTClib.h"

#include <Adafruit_NeoPixel.h>
#include <avr/power.h>

/// NEO PIXEL ///
#define PIN            6
#define NUMPIXELS      1
Adafruit_NeoPixel pixels = Adafruit_NeoPixel(NUMPIXELS, PIN, NEO_RGB + NEO_KHZ800);


/// Push Buttons ///
const int GPS_Button_Pin = 9;
int GPS_Button_State = 0;

const int BLE_Button_Pin = 8;
int BLE_Button_State = 0; 


/// SD vars ///
const int chipSelect = 10; // CS (chip select pin on microSD breakout board)
File dataFile;  // creates a File called dataFile which will point to GPS_Moduledata.txt


/// GPS_Module vars ///
RTC_Millis RTC;  // create a Real-Time-Clocking time system
TinyGPS GPS_Module;
SoftwareSerial ss(3, 2); // pin 2 -> GPS_Module RX   and   pin 3 -> GPS_Module TX


/// live comparison variables //
/*
int oldStartTime;
int newerStartTime;  //keep initial time and location stamp
*/

//////////////////////////////
/// **** SYSTEM STATE **** ///  See top of this file for description of what my different system states are used for. 
//////////////////////////////
                            //
int systemState = 0;        //   
                            //
//////////////////////////////



/// function delcarations ///
static void smartdelay(unsigned long ms);
static void sendBluetooth();


////////  MAIN SETUP FUNCTION ////////
void setup()  {
  
  pixels.begin();
  
  pinMode(BLE_Button_Pin, INPUT);  // prepare pin 8 (bluetooth button) for detecting button press
  pinMode(GPS_Button_Pin, INPUT);  // prepare pin 9 (gps mode button) for detecting button press
  //pinMode(6, OUTPUT);
  
  Serial.begin(57600); // for debugging, *** remember to change to 9600 for bluetooth ***
  Serial.print("Initializing SD card...");   // for debugging, *** remember to comment this out when using RX & TX for bluetooth! ***
  
  ss.begin(9600); // set the baud rate to 9600 for software serial pins 2 and 3 (GPS_Module)
  
  pinMode(chipSelect, OUTPUT); // set pin 10 as OUTPUT to ensure correct functionality of microSD sniffer
  
  RTC.adjust(DateTime(__DATE__, __TIME__));
 
  // see if the card is present and can be initialized:
  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present");  // for debugging, *** remember to comment this out when using RX & TX for bluetooth! ***
    // don't do anything more:
    while (1) ;
  }
  Serial.println("card initialized.");  // for debugging, *** remember to comment this out when using RX & TX for bluetooth! ***
 
  dataFile = SD.open("gpsdata.txt", FILE_WRITE);  //opens my gpsdata.text file for reading/writing
  if (! dataFile) {
    Serial.println("error opening gpsdata.txt");
    // Wait forever since we cant write data
    while (1) ;
  }
  
}


////////  MAIN LOOP ////////
void loop()  {
  
      
      DateTime now = RTC.now();  // set DateTime to current
      bool newData = false;  // initializes newData as false, will become true once the GPS_Module module gets a satellite fix
    
      for (unsigned long start = millis(); millis() - start < 1000;)
      {
        while (ss.available()) // while data is coming from the GPS_Module module
        {
          char c = ss.read(); // read the GPS_Module data one character at a time
          if (GPS_Module.encode(c)) // check to see if valid NMEA GPS_Module data is coming through yet (satellite fix yet?)
            newData = true; // set to true if we have a satellite fix giving GPS_Module data
        }
      }
      
      
      
      if (newData)  {
        
          float flat, flon;
          unsigned long age;
          int year;
          byte month, day, hour, minute, second, hundredths;
          GPS_Module.f_get_position(&flat, &flon, &age);
          GPS_Module.crack_datetime(&year, &month, &day, &hour, &minute, &second, &hundredths, &age);
          char sz[32];
          sprintf(sz, "%02d/%02d/%02d, %02d:%02d:%02d",
          month, day, year, hour, minute, second);
          
    
          Serial.print("");
          Serial.print(flon == TinyGPS::GPS_INVALID_F_ANGLE ? 0.0 : flon, 6);
          Serial.print(", ");
          Serial.print(flat == TinyGPS::GPS_INVALID_F_ANGLE ? 0.0 : flat, 6);
          Serial.print(", ");
          Serial.println(sz);  
          smartdelay(0);
      
          dataFile.print("");
          dataFile.print(flon == TinyGPS::GPS_INVALID_F_ANGLE ? 0.0 : flon, 6);
          dataFile.print(", ");
          dataFile.print(flat == TinyGPS::GPS_INVALID_F_ANGLE ? 0.0 : flat, 6);
          dataFile.print(", ");
          dataFile.println(sz);  
          smartdelay(0);
      }
      
      
      // if recording is not true:
      // blah blah blah
    
      dataFile.flush();  // flush() ensures that the bytes were (or will be) written to the microSD like they should be
      delay(500); // quick delay to give the processor some time to do the flush()
      
      
      BLE_Button_State = digitalRead(BLE_Button_Pin);
      GPS_Button_State = digitalRead(GPS_Button_Pin);
      Serial.println(BLE_Button_State);
      Serial.println(GPS_Button_State);
      
      systemState = 0;
      
      if (BLE_Button_State == HIGH) { 
          Serial.println("BLE button pressed"); 
          systemState = 2;   // **** Change system state to GPS_Module Mode (G-R-B LED will be Green)
          sendBluetoothData();
      }
      
      
      if (GPS_Button_State == HIGH) { 
          Serial.println("gps button pressed"); 
          systemState = 1;   // **** Change system state to GPS_Module Mode (G-R-B LED will be Green)
      } 
      
      
      
      
      
      ////////////////////////////////////
      /// systemState G-R-B indication ///
      ////////////////////////////////////
      if (systemState == 0) {  
        pixels.setPixelColor(0, pixels.Color(0,200,0)); // Moderately bright red color.
        pixels.show(); // This sends the updated pixels color to the hardware.
        delay(500); // this delay needs to happen in order to make the color change take effect 
      } else if (systemState == 1) {
        pixels.setPixelColor(0, pixels.Color(200,0,0)); // Moderately bright green color.
        pixels.show(); // This sends the updated pixels color to the hardware.
        delay(500); // this delay needs to happen in order to make the color change take effect
      } else if (systemState == 2) {
        pixels.setPixelColor(0, pixels.Color(0,0,200)); // Moderately bright blue color.
        pixels.show(); // This sends the updated pixels color to the hardware.
        delay(500); // this delay needs to happen in order to make the color change take effect
      } else if (systemState == 3) {
        pixels.setPixelColor(0, pixels.Color(0,200,200)); // Moderately bright blue color.
        pixels.show(); // This sends the updated pixels color to the hardware.
        delay(500); // this delay needs to happen in order to make the color change take effect
      }
      

  
  
}


////////  SMART DELAY FOR ERROR-FREE GPS_Module DATA ENCODING ////////
static void smartdelay(unsigned long ms)
{
  unsigned long start = millis();
  do 
  {
    while (ss.available())
      GPS_Module.encode(ss.read());
  } while (millis() - start < ms);
}


static void sendBluetoothData() {
//
//  when tactile push button is pressed for bluetooth:
//
// - pair with iphone 
// - grab GPS_Module data from microSD
// - send through arduino TX to BLE module RX
// - send through BLE module TX to iphone
//
//
//
/*
  if (bluetooth button was pressed) {
    
    myFile = SD.open("test.txt");
    
    if (myFile) {
      Serial.println("test.txt:");
    
      while (myFile.available()) {
        
        Serial.write(myFile.read()); // read from the file until there's nothing else in it
      }
    
      myFile.close(); // close the file:
      
  } else {
    Serial.println("error opening test.txt");  // if the file didn't open, print an error
  }
    
  
  }
*/


}

