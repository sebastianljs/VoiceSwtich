#include <IRremote.h>

bool lumLow = false;
bool LightsOn = true;
int photoLevel = 0;
String command = "";
const int relay = 3;
const int photo = 0; 
void setup() {
  // put your setup code here, to run once:
  delay(1000)
  Serial.begin(9600);
  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);
  pinMode(relay, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  photoLevel = analogRead(photo);
  if (photoLevel>250){
    lumLow = true;
  }
  
  delay(100);
  
  command = Serial.readStringUntil('X');
  if (command.equals("LightsON") && ((lumLow == true)||(LightsOn == true))){
      digitalWrite(relay, HIGH);
      LightsOn = true;
   }else if (command.equals("LightsOFF")) {
      digitalWrite(relay, LOW);
      LightsOn = false;
   }

  if (command.equals("ACON")){
      digitalWrite(13, HIGH);
   }else if (command.equals("ACOFF")) {
      digitalWrite(13, LOW);
   }
   if (command.equals("TVON")){
    irsend.sendSony(0x490, 20);
    Serial.print("1");
    irsend.sendSony(0x490, 20);
    Serial.print("2");
    irsend.sendSony(0x490, 20);
    Serial.print("3");
   }else if (command.equals("TVOFF")) {
      
   }
   command = "";    
}
