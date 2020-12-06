import peasy.*;
import processing.serial.*;
Serial  myPort;
String  inString;
int     calibrating;

int start;
int radius; 
int dgree;
int dgree2;
int count;
int m;
float moveX[]= new float[10000];
float moveY[]= new float[10000];
float moveZ[]= new float[10000];
float zNum;
int moving=1;
boolean check;
int t, time=0;
int shape=0;
float shapeX[]=new float[100];
float shapeY[]=new float[100];
float shapeZ[]=new float[100];
float textX;
float textY;
float textZ;
int startX;
int startY;
int startZ;
int shapeNum=0;
PShape robot;
PeasyCam cam;
 
void setup() {
  size(1000,1000,P3D);
  cam = new PeasyCam(this, 500);
  cam.setMinimumDistance(10);
  cam.setMaximumDistance(3000);
 
  String portName = "COM5"; //Serial.list()[1];
  println(Serial.list());         
  myPort = new Serial(this, portName, 19200);
  myPort.clear();
  myPort.bufferUntil(10);
  
  moveX[0]=10;
  moveY[0]=10;
  moveZ[0]=10;
  
  startX=600;
  startY=300;
  startZ=50;
  
  textX=0;
  textY=0;
  textZ=0;
  
  zNum=30;
  m=1;
  t=0;
  
  robot=loadShape("3D/robot.obj");
}
void draw() { 
  backRectCreate();
  backLineCreate();
  backXYZ();

  lineCreate();
  moveRobot();
  while(check==true){
    if(shape==count){
      break;
    }
    else{
      shapeX[shape]=moveX[m-1];
      shapeY[shape]=moveY[m-1];
      shapeZ[shape]=moveZ[m-1];
      println("shapeX[shape]:"+moveX[m-1]+" shapeY[shape]:"+moveY[m-1]+" shapeZ[shape]:"+moveZ[m-1]+" t:"+t+" m:"+m);
      shape++;
    }
  }
  if(shape>0)
    sphereCreate();
}

void backRectCreate(){
  rotateX(-.001);
  rotateY(-.001);
  background(200);
  translate(0,0,0);
  pushMatrix();
  fill(0);
  noStroke();
  rect(0,0,1000,1000);
  popMatrix();

  pushMatrix();
  rotateY(-HALF_PI);
  fill(0);
  noStroke();
  rect(0,0,200,1000);
  popMatrix();
  
  pushMatrix();
  rotateX(HALF_PI);
  fill(0);
  noStroke();
  rect(0,0,1000,200);
  popMatrix();
  
  String num[] = {"0", "250", "500", "750", "1000"};
  for(int n=0, k=0; n<=1000; n+=225, k++){
      fill(0,0,0);
      textSize(40);
      text(num[k],n,1035,0);
  } 
  
  for(int n=30, k=0; n<=1000; n+=240, k++){
      pushMatrix();
      rotate(-HALF_PI);
      fill(0,0,0);
      textSize(40);
      text(num[k],-n,1035,0);
      popMatrix();
  } 
}
void backXYZ(){
  textX= moveX[m-1]+startX;
  textY= moveY[m-1]+startY;
  textZ= moveZ[m-1]+startZ;
  pushMatrix();
  rotateX(-HALF_PI);
  fill(255,0,0);
  textSize(40);
  text("X:"+textX, 1000, -150, 10);
  popMatrix();
  pushMatrix();
  rotateX(-HALF_PI);
  fill(0,0,255);
  textSize(40);
  text("Y:"+textY, 1000, -110, 10);
  popMatrix();
  pushMatrix();
  rotateX(-HALF_PI);
  fill(0,255,0);
  textSize(40);
  text("Z:"+textZ, 1000, -70, 10);
  popMatrix();
  
  pushMatrix();
  rotateX(-HALF_PI);
  rotateY(HALF_PI);
  fill(255,0,0);
  textSize(40);
  text("X:"+textX, -1150, -150, 10);
  popMatrix();
  pushMatrix();
  rotateX(-HALF_PI);
  rotateY(HALF_PI);
  fill(0,0,255);
  textSize(40);
  text("Y:"+textY, -1150, -110, 10);
  popMatrix();
  pushMatrix();
  rotateX(-HALF_PI);
  rotateY(HALF_PI);
  fill(0,255,0);
  textSize(40);
  text("Z:"+textZ, -1150, -70, 10);
  popMatrix();
}

void backLineCreate(){
  stroke(0,0,255); 
  strokeWeight(4);
  line(0, 0, 0, 1050, 0, 0);
  
  stroke(255,0,0);
  strokeWeight(4);
  line(0, 0, 0, 0, 1050, 0);
  
  stroke(0,255,0);
  strokeWeight(4);
  line(0, 0, 0, 0, 0, 250);
 
  stroke(255);
  strokeWeight(2);
  for (int a=10 ,b=1000; a<=1000; a+=30){
    line(a, 0, 0, a, 0, 200);
    line(a, 0, 0, a, b, 0);
    line(0, a, 0, 0, a, 200);
    line(0, a, 0, b, a, 0);
    for(int c=10; c<200; c+=30){
      line(0, 0, c, b, 0, c);
      line(0, 0, c, 0, b, c);
    }
  }
}
void moveRobot(){
  pushMatrix();
  translate(moveX[m-1]+startX,moveY[m-1]+startY,moveZ[m-1]+startZ);
  rotateZ(dgree*PI/180+1.5);
  shape(robot);
  popMatrix();
}
void lineCreate(){
  pushMatrix();
  strokeWeight(4);
  translate(startX, startY, startZ);
  for(int n=0; n<m; n++){
    stroke(0,255,0);
    line(moveX[n] + 3, moveY[n] + 3, moveZ[n] + 3, moveX[n+1] + 3, moveY[n+1] + 3, moveZ[n+1] + 3);
    stroke(255,0,0);
    line(moveX[n], moveY[n], moveZ[n], moveX[n+1], moveY[n+1], moveZ[n+1]);
    stroke(0,0,255);
    line(moveX[n] - 3, moveY[n] - 3, moveZ[n]-3, moveX[n+1]-3, moveY[n+1] - 3, moveZ[n+1]-3);
  }
  popMatrix();
}

void sphereCreate (){
  for(int n=0; n<shape; n++){
   sphereBase(shapeX[n], shapeY[n], shapeZ[n]);
  }
}
void sphereBase(float x, float y, float z){
    pushMatrix();
    noStroke();
    lights();
    fill(255,255,0);
    translate(x+startX, y+startY, z+startZ);
    sphere(30);
    popMatrix();
}
void serialEvent(Serial p) {

  inString = (myPort.readString());
  
  try {
    String[] dataStrings = split(inString, '#');
    for (int i = 0; i < dataStrings.length; i++) {
      String type = dataStrings[i].substring(0, 4);
      String dataval = dataStrings[i].substring(4);
      if (type.equals("STR:")) {
          start = int(dataval);
          if(start==1){
            check=false;
          }
          else{
            check=true;
          }
        } else if (type.equals("CDN:")) { 
          String data[] = split(dataval, ',');
          
          radius = int(data[0]);
          dgree = int(data[1]);
          dgree2 = int(data[2]);
          count = int(data[3]);
          moveX[m]=moveX[m-1]+cos(dgree*PI/180)*radius;
          moveY[m]=moveY[m-1]+sin(dgree*PI/180)*radius;
          if(dgree2>175 && dgree2<185)
            zNum+=0;
          else if(dgree2>185)
            zNum+=1;
          else
            zNum-=1;
          moveZ[m]=zNum;
 
          println("moveX:"+moveX[m]+" moveY:"+moveY[m]+" moveZ:"+moveZ[m]);
          m++;
        } 
      
    }
     println("start="+start+" radius:"+radius+" dgree:"+dgree+" count:"+count+" shape:"+shape);
  } catch (Exception e) {
      println("Caught Exception");
  }
}
