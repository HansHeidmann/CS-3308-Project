/*
    .  .    .   ___    ___     ____  _____ 
    |  |\   |  |   \  |   |   /      |  
    |  | \  |  |___|  |___|  |       |____
    |  |  \ |  |      |   |  \       |
    |  |   \|  |      |   |   \____  |____
   
    *******    by Hans Heidmann    ********
   
    ---------------------------- 
     
    SD Card Read/Write Pins
 
    CS -> pin D-10
    MOSI -> pin D-11
    MISO -> pin D-12
    CLK -> pin D-13

    -----------------------------
    
    GPS Module Pins
    
    RX --> pin D-3
    TX --> pin D-4
    
    -----------------------------
    
    HM-10 BLE 4.0 Bluetooth Module Pins
    
    RX --> TX
    TX --> RX
    
    -----------------------------
    
    RGB LED pins
    
         __   
        /  \
        |___|
        /| |\
       | | | |
       | | | |
       | | | |
       | | | | 
      1  | | 4
         | 3
         2
  
    (1) red pin
    (2) common ground
    (3) green pin
    (4) blue pin

*/


#include <SoftwareSerial.h>    // to use pins 3 and 4 for RX and TX with GPS module
#include <TinyGPS.h>    // great backend library to support the GY-GPS6MV2
#include <SPI.h>    // for writing/reading data to/from a micro SD card 
#include <SD.h>    // for writing/reading data to/from a micro SD card 


File myFile;    // creates a "File" var that will be a pointer to the .txt file on the micro SD
TinyGPS gps;    // creates a GPS object for the module
SoftwareSerial ss(3, 2);    // initialize pins 3 and 2 to be used for transmitting and receiving GPS data


int redPin = 9;
int greenPin = 8;
int bluePin = 7;

String RGB_LED_COLOR; //  = "off, "red", "green", "blue", "yellow", "purple", "teal"



// define functions for GPS (full functions are below the main loop)
static void smartdelay(unsigned long ms);
static void print_float(float val, float invalid, int len, int prec);
static void print_int(unsigned long val, unsigned long invalid, int len);
static void print_date(TinyGPS &gps);
static void print_str(const char *str, int len);



void setup()
{
  ss.begin(9600); // software serial for communication with GPS module
  
  Serial.begin(9600); // open serial port for HM-10 BLE bluetooth module


  
  pinMode(10, OUTPUT); //prepare pin 10 for CS pin on SD breakout

  if (!SD.begin(10)) { //if SD isnt available, stop doign stuff
    return;
  }
  //Serial.println("card access success"); 

  myFile = SD.open("gpsdata.txt", FILE_WRITE);

  if (myFile) {  // if the file opened okay, write to it:
    Serial.print("Writing to gpsdata.txt...");
    myFile.println("testing 1, 2, 3.");
    myFile.close();// close the file:
    Serial.println("done.");
  } else {
    Serial.println("error opening gpsdata.txt"); // if the file didn't open, print an error
  }

  myFile = SD.open("gpsdata.txt"); // re-open the file for reading
  if (myFile) {
    Serial.println("gpsdata.txt:");
    while (myFile.available()) {  // read from the file until there's nothing else in it
      Serial.write(myFile.read());
    }
    myFile.close(); // close the file
  } else {
    Serial.println("error opening test.txt"); // if the file didn't open, print an error
  }
}



void loop()
{
  float flat, flon;
  unsigned long age, date, time, chars = 0;
  unsigned short sentences = 0, failed = 0;
  static const double LONDON_LAT = 51.508131, LONDON_LON = -0.128002;
  
  print_int(gps.satellites(), TinyGPS::GPS_INVALID_SATELLITES, 5);
  print_int(gps.hdop(), TinyGPS::GPS_INVALID_HDOP, 5);
  gps.f_get_position(&flat, &flon, &age);
  print_float(flat, TinyGPS::GPS_INVALID_F_ANGLE, 10, 6);
  print_float(flon, TinyGPS::GPS_INVALID_F_ANGLE, 11, 6);
  print_int(age, TinyGPS::GPS_INVALID_AGE, 5);
  print_date(gps);
  print_float(gps.f_altitude(), TinyGPS::GPS_INVALID_F_ALTITUDE, 7, 2);
  print_float(gps.f_course(), TinyGPS::GPS_INVALID_F_ANGLE, 7, 2);
  print_float(gps.f_speed_kmph(), TinyGPS::GPS_INVALID_F_SPEED, 6, 2);
  print_str(gps.f_course() == TinyGPS::GPS_INVALID_F_ANGLE ? "*** " : TinyGPS::cardinal(gps.f_course()), 6);
  
  gps.stats(&chars, &sentences, &failed);
  print_int(chars, 0xFFFFFFFF, 6);
  print_int(sentences, 0xFFFFFFFF, 10);
  print_int(failed, 0xFFFFFFFF, 9);
  Serial.println();
  
  smartdelay(1000);
}



static void smartdelay(unsigned long ms)
{
  unsigned long start = millis();
  do 
  {
    while (ss.available())
      gps.encode(ss.read());
  } while (millis() - start < ms);
}

static void print_float(float val, float invalid, int len, int prec)
{
  if (val == invalid)
  {
    while (len-- > 1)
      Serial.print('*');
    Serial.print(' ');
  }
  else
  {
    Serial.print(val, prec);
    int vi = abs((int)val);
    int flen = prec + (val < 0.0 ? 2 : 1); // . and -
    flen += vi >= 1000 ? 4 : vi >= 100 ? 3 : vi >= 10 ? 2 : 1;
    for (int i=flen; i<len; ++i)
      Serial.print(' ');
  }
  smartdelay(0);
}

static void print_int(unsigned long val, unsigned long invalid, int len)
{
  char sz[32];
  if (val == invalid)
    strcpy(sz, "*******");
  else
    sprintf(sz, "%ld", val);
  sz[len] = 0;
  for (int i=strlen(sz); i<len; ++i)
    sz[i] = ' ';
  if (len > 0) 
    sz[len-1] = ' ';
  Serial.print(sz);
  smartdelay(0);
}

static void print_date(TinyGPS &gps)
{
  int year;
  byte month, day, hour, minute, second, hundredths;
  unsigned long age;
  gps.crack_datetime(&year, &month, &day, &hour, &minute, &second, &hundredths, &age);
  if (age == TinyGPS::GPS_INVALID_AGE)
    Serial.print("********** ******** ");
  else
  {
    char sz[32];
    sprintf(sz, "%02d/%02d/%02d %02d:%02d:%02d ",
        month, day, year, hour, minute, second);
    Serial.print(sz);
  }
  print_int(age, TinyGPS::GPS_INVALID_AGE, 5);
  smartdelay(0);
}

static void print_str(const char *str, int len)
{
  int slen = strlen(str);
  for (int i=0; i<len; ++i)
    Serial.print(i<slen ? str[i] : ' ');
  smartdelay(0);
}
