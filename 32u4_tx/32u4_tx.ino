// Feather9x_TX
// -*- mode: C++ -*-
// Example sketch showing how to create a simple messaging client (transmitter)
// with the RH_RF95 class. RH_RF95 class does not provide for addressing or
// reliability, so you should only use RH_RF95 if you do not need the higher
// level messaging abilities.
// It is designed to work with the other example Feather9x_RX

#include <SPI.h>
#include <RH_RF95.h>
#include <Adafruit_Si7021.h>


#define RFM95_CS 8
#define RFM95_RST 4
#define RFM95_INT 7


#if defined(ESP8266)
  /* for ESP w/featherwing */ 
  #define RFM95_CS  2    // "E"
  #define RFM95_RST 16   // "D"
  #define RFM95_INT 15   // "B"

#elif defined(ESP32)  
  /* ESP32 feather w/wing */
  #define RFM95_RST     27   // "A"
  #define RFM95_CS      33   // "B"
  #define RFM95_INT     12   //  next to A

#elif defined(NRF52)  
  /* nRF52832 feather w/wing */
  #define RFM95_RST     7   // "A"
  #define RFM95_CS      11   // "B"
  #define RFM95_INT     31   // "C"
  
#elif defined(TEENSYDUINO)
  /* Teensy 3.x w/wing */
  #define RFM95_RST     9   // "A"
  #define RFM95_CS      10   // "B"
  #define RFM95_INT     4    // "C"
#endif

// Change to 434.0 or other frequency, must match RX's freq!
#define RF95_FREQ 915.0

// Singleton instance of the radio driver
RH_RF95 rf95(RFM95_CS, RFM95_INT);

// Instance for Adafruit's Si7021 sensor
Adafruit_Si7021 sensor = Adafruit_Si7021();

unsigned long tf;
unsigned long ti;
float period;
float temp;
float humi;

void setup() 
{
  pinMode(RFM95_RST, OUTPUT);
  digitalWrite(RFM95_RST, HIGH);

  Serial.begin(115200);
//  while (!Serial) {
//    delay(1);
//  }

  delay(100);

  sensor.begin();
  delay(100);

  Serial.println("Feather LoRa TX Test!");

  // manual reset
  digitalWrite(RFM95_RST, LOW);
  delay(10);
  digitalWrite(RFM95_RST, HIGH);
  delay(10);

  while (!rf95.init()) {
    Serial.println("LoRa radio init failed");
    Serial.println("Uncomment '#define SERIAL_DEBUG' in RH_RF95.cpp for detailed debug info");
    while (1);
  }
  Serial.println("LoRa radio init OK!");

  // Defaults after init are 434.0MHz, modulation GFSK_Rb250Fd250, +13dbM
  if (!rf95.setFrequency(RF95_FREQ)) {
    Serial.println("setFrequency failed");
    while (1);
  }
  Serial.print("Set Freq to: "); Serial.println(RF95_FREQ);
  
  // Defaults after init are 434.0MHz, 13dBm, Bw = 125 kHz, Cr = 4/5, Sf = 128chips/symbol, CRC on

  // The default transmitter power is 13dBm, using PA_BOOST.
  // If you are using RFM95/96/97/98 modules which uses the PA_BOOST transmitter pin, then 
  // you can set transmitter powers from 5 to 23 dBm:
  rf95.setTxPower(23, false);

  ti = 0;
}

//int16_t packetnum = 0;  // packet counter, we increment per xmission
char radiopacket[30];

void loop()
{
  delay(30000); // Wait 30 second between sensor readings & transmits, could also 'sleep' here!

  // Reading temperature or humidity takes about 250 milliseconds!
  // Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)
  // Read temperature as Celsius (the default)
  temp = sensor.readTemperature();
  humi = sensor.readHumidity();

  // We compute the period between each measurement
  tf = millis();
  period = (float)(tf - ti) / 1000.;
  Serial.println(period, 10);
  ti = tf;
  
  // Check if any reads failed and exit early (to try again).
  if (isnan(temp) || isnan(humi))
    {
    Serial.println("Failed to read from Si7021 sensor!");
    return;
    }
  else 
    {
    Serial.print("Period: ");
    Serial.print(period);
    Serial.print(" s\t");
    Serial.print("Temperature: ");
    Serial.print(temp);
    Serial.print(" %\t");
    Serial.print("Humidity: ");
    Serial.print(humi);
    Serial.print(" ºC\n");
    Serial.println("Transmitting..."); // Send a message to rf95_server
    }

  // Define the buffer to hold (time) period data
  char time_buff[6]; // in case times get to 100.00 i.e. 6 characters + 1 for NULL
  // Define the buffers to hold sensor data
  char temp_buff[7]; // because -10.00 takes 6 characters + 1 for NULL
  char humi_buff[7]; // because 100.00 takes 6 characters + 1 for NULL

  // Convert float to characters
  dtostrf(period, 5, 2, time_buff);
  dtostrf(temp, 6, 2, temp_buff);
  dtostrf(humi, 6, 2, humi_buff);
  // Concatenate the data into the radiopacket char array
  strcat(radiopacket, time_buff);
  strcat(radiopacket, "\t");
  strcat(radiopacket, temp_buff);
  strcat(radiopacket, "\t");
  strcat(radiopacket, humi_buff);
  //itoa(packetnum++, radiopacket+13, 10);
  //radiopacket[19] = 0;
  Serial.print("Sending packet: "); Serial.println(radiopacket);
  
  
  Serial.println("Sending...");
  delay(10);
  rf95.send((uint8_t *)radiopacket, 30);

  Serial.println("Waiting for packet to complete..."); 
  delay(10);
  rf95.waitPacketSent();

  // Now we clear the char array
  strcpy(radiopacket, "");
  
  // Now wait for a reply
  //uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
  //uint8_t len = sizeof(buf);

  //Serial.println("Waiting for reply...");
  //if (rf95.waitAvailableTimeout(1000))
  //{ 
  //  // Should be a reply message for us now   
  //  if (rf95.recv(buf, &len))
  // {
  //    Serial.print("Got reply: ");
  //    Serial.println((char*)buf);
  //    Serial.print("RSSI: ");
  //    Serial.println(rf95.lastRssi(), DEC);    
  //  }
  //  else
  //  {
  //    Serial.println("Receive failed");
  //  }
  //}
  //else
  //{
  //  Serial.println("No reply, is there a listener around?");
  //}

}
