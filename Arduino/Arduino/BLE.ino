#include <CurieBLE.h>

BLEPeripheral blePeripheral;  
BLEService hub("19B10000-E8F2-537E-4F6C-D104768A1214"); // BLE hub Service (Used to link the smartphone and the Arduino)
BLEIntCharacteristic temperature("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify); // if the value changed the central device (phone) will be notified. 
BLEIntCharacteristic switchAC("19B10003-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite);
BLEIntCharacteristic switchTV("19B10005-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite);
BLEIntCharacteristic switchLights("19B10007-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite);

const int ledPin = 13; // pin to use for the LED
int previousMillis = 0;

void setup() {
  Serial.begin(9600);

  // set LED pin to output mode
  pinMode(ledPin, OUTPUT);

  // set advertised local name and service UUID:
  blePeripheral.setLocalName("AH");
  blePeripheral.addAttribute(hub);
  blePeripheral.setAdvertisedServiceUuid(hub.uuid());
  blePeripheral.addAttribute(temperature);
  blePeripheral.addAttribute(switchAC);
  blePeripheral.addAttribute(switchTV);
  blePeripheral.addAttribute(switchLights);
  
  // set the initial value for the characeristic:
  temperature.setValue(70);
  switchAC.setValue(0);
  switchTV.setValue(0);
  switchLights.setValue(0);

  // begin advertising BLE service:
  blePeripheral.begin();
}

void loop() {
  // listen for BLE peripherals to connect:
  BLECentral central = blePeripheral.central();

  // if a central is connected to peripheral:
  if (central) {  
    // while the central is still connected to peripheral:
    while (central.connected()) {

      long currentMillis = millis();
      if (currentMillis - previousMillis >= 1000) {
        previousMillis = currentMillis;
        updateData();
      }

      if (switchAC.written()) {
        if (switchAC.value()) {   
          Serial.println("ACONX");        
        } else {                              
          Serial.println("ACOFFX");        
        }
      }
      
      if (switchTV.written()) {
        if (switchTV.value()) {   
          Serial.println("TVONX");        
        } else {                              
          Serial.println("TVOFFX");        
        }
      }
      
      if (switchLights.written()) {
        if (switchLights.value()) {   
          Serial.println("LightsONX");        
        } else {                              
          Serial.println("LightsOFFX");        
        }
      }     
    }
  }
}

void updateData(){
  String roomTemperature = Serial.readStringUntil('T');
  temperature.setValue(roomTemperature.toInt());
}

