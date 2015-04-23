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
       | | | 4
       1 | 3 
         |  
         2             
  
    (1) RED ground
    (2) 4.5-6V VIN  -->  VCC
    (3) ground  -->  GND
    (4) locic output  -->  (Nothing, but could be used to chain more G-R-B LEDs together.)
    
    
    -----------------------------
    
  
    ////// systemState ////
    
    systemState = 1: initializing 
                     - LED should be RED
                     - attemping to get a GPS_Module Satellite fix
    
    
    systemState = 2: Logging GPS_Module data
                     - LED should be GREEN
                     - open dataFile (GPS_Moduledata.txt) for writing to
                     - read in GPS_Module data from software serial pins 2 and 3
                     - write GPS_Module data to the microSD
             
    
    systemState = 3: Sending Data Over Bluetooth
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


#define BLE_BUTTON_PIN   8
#define GPS_BUTTON_PIN   9

#define RGB_RED_PIN  14
#define RGB_GREEN_PIN  15
#define RGB_BLUE_PIN  16


/// Push Button States ///
int BLE_Button_State = LOW; 
int GPS_Button_State = LOW;



/// SD vars ///
const int chipSelect = 10; // CS (chip select pin on microSD breakout board)
File dataFile;  // creates a File called dataFile which will point to GPS_Moduledata.txt


/// GPS_Module vars ///
RTC_Millis RTC;  // create a Real-Time-Clocking time system
TinyGPS GPS_Module;
SoftwareSerial ss(3, 2); // pin 2 -> GPS_Module RX   and   pin 3 -> GPS_Module TX



//////////////////////////////
/// **** SYSTEM STATE **** ///  See top of this file for description of what my different system states are used for. 
//////////////////////////////
                            
int systemState = 1;
                
//////////////////////////////



////////  MAIN SETUP FUNCTION ////////
void setup()  {
  
  pinMode(BLE_BUTTON_PIN, INPUT);
  pinMode(GPS_BUTTON_PIN, INPUT);
  
  pinMode(RGB_RED_PIN, OUTPUT);
  pinMode(RGB_GREEN_PIN, OUTPUT);
  pinMode(RGB_BLUE_PIN, OUTPUT);
  

  Serial.begin(57600); // for debugging, *** remember to change to 57600 for bluetooth ***
  //Serial.print("Initializing SD card...");   // for debugging, *** remember to comment this out when using RX & TX for bluetooth! ***
  
  ss.begin(9600); // set the baud rate to 9600 for software serial pins 2 and 3 (GPS_Module)
  
  pinMode(chipSelect, OUTPUT); // set pin 10 as OUTPUT to ensure correct functionality of microSD sniffer
  
  RTC.adjust(DateTime(__DATE__, __TIME__));
  
  if (!SD.begin(chipSelect)) {// see if the card is present and can be initialized
    Serial.println("Card failed, or not present");  // for debugging, *** remember to comment this out when using RX & TX for bluetooth! ***
    while (1) ; // don't do anything more if the card does't initialize
  }
  //Serial.println("card initialized.");  // for debugging, *** remember to comment this out when using RX & TX for bluetooth! ***
  
  dataFile = SD.open("gpsdata.txt", FILE_WRITE);  //opens my gpsdata.text file for reading/writing
  if (! dataFile) {
    Serial.println("error opening gpsdata.txt");  // for debugging, *** remember to comment this out when using RX & TX for bluetooth! ***
    // Wait forever since we cant write data
    while (1) ;
  }
  
  
}


////////  MAIN LOOP ////////
void loop()  {
      
    
     BLE_Button_State = digitalRead(BLE_BUTTON_PIN);
     GPS_Button_State = digitalRead(GPS_BUTTON_PIN);

        
     if (systemState == 1) {
       
            Serial.println("System State:");
            Serial.println(systemState);
            
            digitalWrite(RGB_RED_PIN, LOW);
            digitalWrite(RGB_GREEN_PIN, HIGH);
            digitalWrite(RGB_BLUE_PIN, HIGH);

            if (BLE_Button_State == HIGH) {  
                systemState = 3;
                
            } else if (GPS_Button_State == HIGH) {                
                 systemState = 2;
            }
            delay(500);
           
    
     } else if (systemState == 2) {
       
        Serial.println("System State:");
        Serial.println(systemState);
        
        digitalWrite(RGB_RED_PIN, HIGH);
        digitalWrite(RGB_GREEN_PIN, LOW);
        digitalWrite(RGB_BLUE_PIN, HIGH);;

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
            char sa[32];
            sprintf(sa, "%02d/%02d/%02d", month, day, year);
            char sb[32];
            sprintf(sb, "%02d:%02d:%02d", hour, minute, second);
            
            Serial.println(flon == TinyGPS::GPS_INVALID_F_ANGLE ? 0.0 : flon, 6);
            Serial.println(flat == TinyGPS::GPS_INVALID_F_ANGLE ? 0.0 : flat, 6);
            Serial.println(sa);
            Serial.println(sb); 
            
            dataFile.println(flon == TinyGPS::GPS_INVALID_F_ANGLE ? 0.0 : flon, 6);
            dataFile.println(flat == TinyGPS::GPS_INVALID_F_ANGLE ? 0.0 : flat, 6);
            dataFile.println(sa); 
            dataFile.println(sb); 
            
            smartdelay(0);

            
            dataFile.flush();  // flush() ensures that the bytes were (or will be) written to the microSD like they should be
            delay(100);
          
        }
        
        if (GPS_Button_State == HIGH) { 
              systemState = 1;
              dataFile.println("end");
              dataFile.flush();
        }
        delay(500);
     
   
     } else if (systemState == 3)  {
           Serial.println("System State:");
           Serial.println(systemState);
           
           digitalWrite(RGB_RED_PIN, HIGH);
           digitalWrite(RGB_GREEN_PIN, HIGH);
           digitalWrite(RGB_BLUE_PIN, LOW);
           
           sendBluetoothData(); 
     
     }
}


////////  SMART DELAY FOR ERROR-FREE GPS_Module DATA ENCODING ////////
void smartdelay(unsigned long ms)
{
  unsigned long start = millis();
  do 
  {
    while (ss.available())
      GPS_Module.encode(ss.read());
  } while (millis() - start < ms);
}


void sendBluetoothData() {
    
   if (SD.exists("gpsdata.txt")) {
       
       dataFile = SD.open("gpsdata.txt");
    
       while (dataFile.available()) {
          Serial.write(dataFile.read()); // read from the file until there's nothing else in it
          Serial.flush();
       }
       
       SD.remove("gpsdata.txt");   // REMOVE gpsdata.txt after sending it over Bluetooth
       delay(2000);

    } else {
        
          Serial.println("making gpsdata.txt");  // if the file didn't open, print an error
          SD.begin(chipSelect);    
          dataFile = SD.open("gpsdata.txt", FILE_WRITE);  //create a new gpsdata.txt file
          dataFile.flush();
    }

    systemState = 1;
    Serial.println("System State:");
    Serial.println(systemState);
  

}

