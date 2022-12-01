#include <WiFi.h>
#include "SD.h"
#include <BluetoothSerial.h>
#include <FirebaseESP32.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>
#include "DHT.h"
#define DHTPIN 0
#define DHTTYPE DHT11
#define API_KEY "cNi6jCfhHoCxHJ9yyH7UIlp5UegOApDY5wWvVzic"
#define DATABASE_URL "https://esp32-25b9b-default-rtdb.asia-southeast1.firebasedatabase.app/" 
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
BluetoothSerial BT;
TaskHandle_t Task1;
const char ssid[]="black"; //修改為你家的WiFi網路名稱
const char pwd[]="aa20041201"; //修改為你家的WiFi密碼
char data[6]="",t1='0',r1='0',t2='0',r2='0';
bool sendflag=false;
bool l1=false,l2=false,l3=false,o1=false,o2=false,c1=false,c2=false;
int s=0,living=25,bath=26,bed=33,pin11=4,pin12=5,pin21=15,pin22=16,toilet=17,mo2=19,mc1=22,mc2=23;
int Ax=13,Bx=12,Cx=14,Dx=27,Ay=21,By=32,Cy=18,Dy=2;
int td=0,hd=0;
DHT dht(DHTPIN, DHTTYPE);
void setup() {
  pinMode(mo2,OUTPUT);
  pinMode(mc1,OUTPUT);
  pinMode(mc2,OUTPUT);
  pinMode(living,OUTPUT);
  pinMode(bath,OUTPUT);
  pinMode(bed,OUTPUT);
  pinMode(toilet,OUTPUT);
  pinMode(pin11,OUTPUT);
  pinMode(pin12,OUTPUT);
  pinMode(pin21,OUTPUT);
  pinMode(pin22,OUTPUT);
  pinMode(Ax,OUTPUT);
  pinMode(Bx,OUTPUT);
  pinMode(Cx,OUTPUT);
  pinMode(Dx,OUTPUT);
  pinMode(Ay,OUTPUT);
  pinMode(By,OUTPUT);
  pinMode(Cy,OUTPUT);
  pinMode(Dy,OUTPUT);
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid,pwd);
  while(WiFi.status()!=WL_CONNECTED){
  Serial.print(F("."));
  delay(500);   
  }
  
    Serial.println("");
    Serial.println(WiFi.localIP());
    Serial.println(WiFi.RSSI());
    Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);
    config.api_key = API_KEY;
    config.database_url = DATABASE_URL;
    Firebase.begin(DATABASE_URL, API_KEY);
    Firebase.setDoubleDigits(5);
  dht.begin();
  BT.begin(F("kaven"));
  
}
void loop() {
  show1(t1,r1);
  show2(t2,r2);
  sample();
  if (BT.available()) {
    char ch = BT.read();
    if(ch=='n')
    {
    memset(data, 0, sizeof(data));
    s=0;
    }
    else if(ch=='p')
      check();
    else{
      data[s]=ch;
      s++;
    }
  }
  delay(8);
}
void sample(){
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  if (isnan(h) || isnan(t) ) {
    return;
  }
  td=(int)t;
  hd=(int)h;
  sendflag=true;
  if(sendflag){
      Serial.println("send data"+(String)td);
      Firebase.setInt(fbdo,"data/Temperature",td);
      Firebase.setInt(fbdo,"data/Humidity",hd);
      delay(1500);
      sendflag=false;      
  }
  delay(3000);
}
void testd(){
  Serial.println(data);
}
void check(){
  if(data[0]=='0'){
    if(data[1]=='1'){
      if(l1){
      testd();
      digitalWrite(living,LOW);
      l1=false;
      }
      else{
      testd();
      digitalWrite(living,HIGH);
      l1=true;
      }
    }
    else if(data[1]=='2'){
      if(l2){
      testd();
      digitalWrite(bath,LOW);
      l2=false;
      }
      else{
      testd();
      digitalWrite(bath,HIGH);
      l2=true;
      }
    }
    else if(data[1]=='3'){
      if(l3){
      testd();
      digitalWrite(bed,LOW);
      l3=false;
      }
      else{
      testd();
      digitalWrite(bed,HIGH);
      l3=true;
      }
    }
  }
   else if(data[0]=='1'){
      if(data[1]=='1'){
      testd();
      digitalWrite(toilet,HIGH);
      delay(1000);
      digitalWrite(toilet,LOW);
    }
  }
  else if(data[0]=='2'){
    if(data[1]=='1'){
      if(data[2]=='1'&&o1){
          testd();
          t1=data[3];
          r1=data[4];
      }
       if(data[2]=='2'&&o2){
          testd();
          t2=data[3];
          r2=data[4];
      }
    }
    else if(data[1]=='2'){
      if(data[2]=='1'){
        if(o1)o1=false;
        else if(!o1)o1=true;
      }
      else if(data[2]=='2'){
        if(o2){
        testd();
        digitalWrite(mo2,LOW);
        o2=false;
        }
        else{
        testd();
        digitalWrite(mo2,HIGH);
        o2=true;
        }
      }
    }
    else if(data[1]=='3'){
      if(data[2]=='1'){
        if(o1){
          if(c1){
          testd();
          digitalWrite(mc1,LOW);
          c1=false;
          }
          else{
          testd();
          digitalWrite(mc1,HIGH);
          c1=true;
          }
        }
      }
      else if(data[2]=='2'){
        if(o2){
          if(c2){
          testd();
          digitalWrite(mc2,LOW);
          c2=false;
          }
          else{
          testd();
          digitalWrite(mc2,HIGH);
          c2=true;
          }
        }
      }
    }
  }
  else if(data[0]=='t'){
    testd();
  }
}
void show1(char _t1,char _r1){
  if(o1){
    digitalWrite(pin11,HIGH);
    digitalWrite(pin12,LOW);
    nb(_t1,true);
    delay(5);
    digitalWrite(pin11,LOW);
    digitalWrite(pin12,HIGH);
    nb(_r1,true);
    delay(5);
  }
  else if(!o1){
    digitalWrite(pin12,HIGH);
    digitalWrite(pin11,HIGH);
  }
}
void show2(char _t2,char _r2){
  if(o2){
    digitalWrite(pin21,HIGH);
    digitalWrite(pin22,LOW);
    nb(_t2,false);
    delay(5);
    digitalWrite(pin21,LOW);
    digitalWrite(pin22,HIGH);
    nb(_r2,false);
    delay(5);
  }
  else if(!o2){
    digitalWrite(pin22,HIGH);
    digitalWrite(pin21,HIGH);
  }
}

void nb(char nb,bool ch){
  if(ch)
  {
    if(nb=='0'){
    digitalWrite(Ax,LOW);
    digitalWrite(Bx,LOW);
    digitalWrite(Cx,LOW);
    digitalWrite(Dx,LOW);
  }
  if(nb=='1'){
    digitalWrite(Ax,LOW);
    digitalWrite(Bx,LOW);
    digitalWrite(Cx,LOW);
    digitalWrite(Dx,HIGH);
  }
  if(nb=='2'){
    digitalWrite(Ax,LOW);
    digitalWrite(Bx,LOW);
    digitalWrite(Cx,HIGH);
    digitalWrite(Dx,LOW);
  }
  if(nb=='3'){
    digitalWrite(Ax,LOW);
    digitalWrite(Bx,LOW);
    digitalWrite(Cx,HIGH);
    digitalWrite(Dx,HIGH);
  }
  if(nb=='4'){
    digitalWrite(Ax,LOW);
    digitalWrite(Bx,HIGH);
    digitalWrite(Cx,LOW);
    digitalWrite(Dx,LOW);
  }
  if(nb=='5'){
    digitalWrite(Ax,LOW);
    digitalWrite(Bx,HIGH);
    digitalWrite(Cx,LOW);
    digitalWrite(Dx,HIGH);
  }
  if(nb=='6'){
    digitalWrite(Ax,LOW);
    digitalWrite(Bx,HIGH);
    digitalWrite(Cx,HIGH);
    digitalWrite(Dx,LOW);
  }
  if(nb=='7'){
    digitalWrite(Ax,LOW);
    digitalWrite(Bx,HIGH);
    digitalWrite(Cx,HIGH);
    digitalWrite(Dx,HIGH);
  }
  if(nb=='8'){
    digitalWrite(Ax,HIGH);
    digitalWrite(Bx,LOW);
    digitalWrite(Cx,LOW);
    digitalWrite(Dx,LOW);
  }
  if(nb=='9'){
    digitalWrite(Ax,HIGH);
    digitalWrite(Bx,LOW);
    digitalWrite(Cx,LOW);
    digitalWrite(Dx,HIGH);
  }
  }
  else if(!ch){
     if(nb=='0'){
    digitalWrite(Ay,LOW);
    digitalWrite(By,LOW);
    digitalWrite(Cy,LOW);
    digitalWrite(Dy,LOW);
  }
  if(nb=='1'){
    digitalWrite(Ay,LOW);
    digitalWrite(By,LOW);
    digitalWrite(Cy,LOW);
    digitalWrite(Dy,HIGH);
  }
  if(nb=='2'){
    digitalWrite(Ay,LOW);
    digitalWrite(By,LOW);
    digitalWrite(Cy,HIGH);
    digitalWrite(Dy,LOW);
  }
  if(nb=='3'){
    digitalWrite(Ay,LOW);
    digitalWrite(By,LOW);
    digitalWrite(Cy,HIGH);
    digitalWrite(Dy,HIGH);
  }
  if(nb=='4'){
    digitalWrite(Ay,LOW);
    digitalWrite(By,HIGH);
    digitalWrite(Cy,LOW);
    digitalWrite(Dy,LOW);
  }
  if(nb=='5'){
    digitalWrite(Ay,LOW);
    digitalWrite(By,HIGH);
    digitalWrite(Cy,LOW);
    digitalWrite(Dy,HIGH);
  }
  if(nb=='6'){
    digitalWrite(Ay,LOW);
    digitalWrite(By,HIGH);
    digitalWrite(Cy,HIGH);
    digitalWrite(Dy,LOW);
  }
  if(nb=='7'){
    digitalWrite(Ay,LOW);
    digitalWrite(By,HIGH);
    digitalWrite(Cy,HIGH);
    digitalWrite(Dy,HIGH);
  }
  if(nb=='8'){
    digitalWrite(Ay,HIGH);
    digitalWrite(By,LOW);
    digitalWrite(Cy,LOW);
    digitalWrite(Dy,LOW);
  }
  if(nb=='9'){
    digitalWrite(Ay,HIGH);
    digitalWrite(By,LOW);
    digitalWrite(Cy,LOW);
    digitalWrite(Dy,HIGH);
  }    
  }
 
}