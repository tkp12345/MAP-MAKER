/*----------- 블루투스 모듈 설정 START ---------- */
#include <SoftwareSerial.h>
SoftwareSerial mySerial(7, 8); // 시리얼 통신핀을 설정
/*----------- 블루투스 모듈 설정 END ---------- */
/*----------- 자이로 센서 설정 START ---------- */
#include "I2Cdev.h"
#include "MPU6050_6Axis_MotionApps20.h"
#include "Wire.h"
#define OUTPUT_READABLE_YAWPITCHROLL
#define INTERRUPT_PIN 2  
MPU6050 mpu;
bool dmpReady = false;  
uint8_t mpuIntStatus;   
uint8_t devStatus;   
uint16_t packetSize;  
uint16_t fifoCount;  
uint8_t fifoBuffer[64]; 
Quaternion q;           // [w, x, y, z]        
VectorFloat gravity;    // [x, y, z]          
float ypr[3];           // [yaw, pitch, roll]  
volatile bool mpuInterrupt = false;
void dmpDataReady() {
    mpuInterrupt = true;
}
/*---------------자이로 센서 설정 END---------------*/
/*-------------------- 주행 설정 START-------------*/
#include <Servo.h> 
Servo servoLeft;         
Servo servoRight;
byte wLeftOld;                    
byte wRightOld;
byte counter; 
int moveCount;                     
/*-------------------- 주행 설정 END-------------*/
int start, radius, count;
float dgree1, dgree2;
void setup() {
  /*----------- 자이로 센서 설정 START ---------- */
  #if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
      Wire.begin();
      Wire.setClock(400000); // 400kHz I2C clock. Comment this line if having compilation difficulties
  #elif I2CDEV_IMPLEMENTATION == I2CDEV_BUILTIN_FASTWIRE
      Fastwire::setup(400, true);
  #endif
  mpu.initialize();
  devStatus = mpu.dmpInitialize();
  mpu.setXGyroOffset(220);
  mpu.setYGyroOffset(76);
  mpu.setZGyroOffset(-85);
  mpu.setZAccelOffset(1788); 
  if (devStatus == 0) {
      mpu.setDMPEnabled(true);
      attachInterrupt(digitalPinToInterrupt(INTERRUPT_PIN), dmpDataReady, RISING);
      mpuIntStatus = mpu.getIntStatus();
      dmpReady = true;
      packetSize = mpu.dmpGetFIFOPacketSize();
  }
/*---------------자이로 센서 설정 END---------------*/

  mySerial.begin(57600); // 블루투스의 시리얼 속도를 57600 으로 설정
  Serial.begin(19200);
  start=1, radius=5, count=0;
  dgree1=0, dgree2=0;
  
/*-----------------주행 설정 START------------------------*/
  pinMode(4, INPUT);             
  pinMode(3, INPUT);          
  servoLeft.attach(11);   
  servoRight.attach(10); 
  wLeftOld = 0;                     
  wRightOld = 1;
  counter = 0;         
  moveCount=0;        
/*-----------------주행 설정 END------------------------*/     
} //setup END

void loop() {
/*----------- 자이로 센서 설정 START ---------- */
  mpuInterrupt = false;
  mpuIntStatus = mpu.getIntStatus();
  fifoCount = mpu.getFIFOCount();
  if ((mpuIntStatus & 0x10) || fifoCount == 1024) {
      mpu.resetFIFO();
  } else if (mpuIntStatus & 0x02) {
      mpu.getFIFOBytes(fifoBuffer, packetSize);
      fifoCount -= packetSize;
      mpu.dmpGetQuaternion(&q, fifoBuffer);
      mpu.dmpGetGravity(&gravity, &q);
      mpu.dmpGetYawPitchRoll(ypr, &q, &gravity);
      dgree1=(ypr[0] * 180/M_PI)+180;
      dgree2=(ypr[1] * 180/M_PI)+180;
/*---------------자이로 센서 설정 END---------------*/
/*-----------------------주행 코드 START------------------------------*/
      byte wLeft = digitalRead(3); 
      byte wRight = digitalRead(4);  
      float fv1=volts(A3);
    
      if(fv1>0.80){  //발광석 발견시 멈춤
          start=0;
          count++;
          maneuver(0, 0, 1000);
      }
      if(wLeft != wRight){       
          if ((wLeft != wLeftOld) && (wRight != wRightOld)){
              counter++;                   
              wLeftOld = wLeft;              
              wRightOld = wRight;
              if(counter == 4){
                 wLeft = 0;                   
                 wRight = 0;
                 counter = 0;                
              }
            }
       else {
          counter = 0; // Clear alternate corner count
       }
      }
     if((wLeft == 0) && (wRight == 0)){
         maneuver(-100,-100, 2000);
       // if (millis() - previousTime > 1000)  
         // previousTime = millis();  
      }   
      else if(wLeft==0) {
        maneuver(-100,-100, 500);
        turnLeft(400);
      }   
      else if(wRight==0) {
         maneuver(-100,-100, 500);
         turnLeft(400);
      }
      else {
       start=1;
       if(moveCount==0){
         maneuver(0, 100, 100);
         moveCount++;
        }
       else if(moveCount==1){
         maneuver(0, 100, 100);
         moveCount++;
        }
       else if(moveCount==2){
         maneuver(100, 0, 100);
         moveCount++;
        }
       else{
         maneuver(100, 0, 100);
         moveCount=0;
        }      
      }
    
    Serial.print(F("STR:"));             
    Serial.print(start, DEC);   //움직이면 1, 멈추면 0
    Serial.print(F("#CDN:")); //coordinate 좌표값 
    Serial.print(radius);
    Serial.print(F(","));
    Serial.print(dgree1); //yawing 값 -> z축 방향으로의 회전값
    Serial.print(F(","));
    Serial.print(dgree2); //pitching 값 ->y축 방향으로의 회전값
    Serial.print(F(","));
    Serial.print(count); //발광석을 만난 수     
    Serial.print(F("#END:"));   
    Serial.println(F(""));
    Serial.println(moveCount);  
    Serial.println(fv1);  

    mySerial.print(F("STR:"));             
    mySerial.print(start, DEC);   //움직이면 1, 멈추면 0
    mySerial.print(F("#CDN:")); //coordinate 좌표값 
    mySerial.print(radius);
    mySerial.print(F(","));
    mySerial.print(dgree1); //yawing 값 -> z축 방향으로의 회전값
    mySerial.print(F(","));
    mySerial.print(dgree2); //pitching 값 ->y축 방향으로의 회전값
    mySerial.print(F(","));
    mySerial.print(count); //발광석을 만난 수     
    mySerial.print(F("#END:"));   
    mySerial.println(F(""));
 
  }
/*-----------------------주행 코드 END------------------------------*/
  
} //roop END


void maneuver(int speedLeft, int speedRight, int msTime){
  servoLeft.writeMicroseconds(1500+speedLeft);
  servoRight.writeMicroseconds(1500 - speedRight);
  delay(msTime);                                            
}
void turnLeft(int msTime){
  servoLeft.writeMicroseconds(1500);
  servoRight.writeMicroseconds(1300);
  delay(msTime);                                            
}

float volts(int adPin){
  return float(analogRead(adPin)) * 5.0 / 1023.0;
}
