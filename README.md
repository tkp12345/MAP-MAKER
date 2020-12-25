# MAP-MAKER

## __Introduction__
 
MAP MAKER (for arduino) - 아두이노 주행키트를 활용한 x,y,z  지도생성(프로세싱) 및 광물질 탐사로봇 프로젝트

------------

*사진을 클릭하면 영상이 실행됩니다.

[![MAP MAKER](https://img.youtube.com/vi/YVovNnWpEo0/0.jpg )](https://www.youtube.com/watch?v=YVovNnWpEo0)

url : "https://www.youtube.com/watch?v=YVovNnWpEo0"

------------

아두이노는 데이터를 전송하는 클라이언트 역할을 하고 
컴퓨터 연결 아두이노는 데이터를 전송받는 서버역할을 합니다 \
___블루트스모듈 HC-06 사용___
<img src="https://user-images.githubusercontent.com/46067837/102974223-80bd1c00-4541-11eb-8449-00f15c69635b.JPG" width="50%" height="60%">

먼저 arduino 주행키트 에서 이코드(___arduinoProject_transmitter.ino___)를 실행합니다 

```c++
/*----------- 블루투스 모듈 을통한 아두이노 데이터송신 ---------- */
#include <SoftwareSerial.h>
SoftwareSerial mySerial(7, 8); // 시리얼 통신핀을 설정
...
//블루투스 통신으로 보내 주는 값들.
int start, radius, count; 
float dgree1, dgree2;     
...

void loop() {
...

 //블루투스를 통해 데이터 전달, 문자열로 전달되는 것을 프로세싱에서  ‘,’ ‘#’을 기준으로 문자열을 분리하기 때문에 같이 보내줌. 
    mySerial.print(F("STR:"));   
    mySerial.print(start, DEC);   //움직이면 1, 멈추면 0
    mySerial.print(F("#CDN:")); //coordinate 좌표값 
    mySerial.print(radius);
    mySerial.print(F(","));
    mySerial.print(dgree1); //yawing 값 -> z축 방향으로의 회전값
    mySerial.print(F(","));
    mySerial.print(dgree2); //pitching 값 ->y축 방향으로의 회전값
    mySerial.print(F(","));
    mySerial.print(count); //발광석을 관측한  수     
    mySerial.print(F("#END:"));   
    mySerial.println(F(""));
...

}

```

그런 다음 컴퓨터 연결 arduino에서 이코드(___arduinoProject_receiver.ino___)를 실행합니다
```c++
/*----------- 블루투스 모듈 을통한 컴퓨터 데이터수신 ---------- */
#include <SoftwareSerial.h> 
SoftwareSerial mySerial(7, 8);  // 시리얼 통신핀을 설정

void setup() {
  Serial.begin(57600);                               
  mySerial.begin(9600); 
}
void loop(){
   if (mySerial.available()) { // 넘어온 데이터가 존재하면
    Serial.write(mySerial.read()); // 시리얼에 출력
  }
}
```

수신 받은 데이터를 시리얼 통신으로 프로세싱 과 공유합니다 .\
컴퓨터에서 프로세싱 코드를 (__Processing_final.pde__) 실행합니다.
<img src="https://user-images.githubusercontent.com/46067837/102790986-ab945c80-43e9-11eb-808f-54fa050bc617.png" width="80%">
그래픽 기반 언어 "프로세싱"을 통해 처리합니다
```java

Serial  myPort;
String  inString; //시리얼통신을 통해 받아오는 문자열을 저장하는 변수.
int start, radius, dgree, dgree2, count;  //블루투스 통신을 통해 보내주는 값들을 받는 변수

//processing 에서 "setup()" : 시작될 때 딱 한번만 실행
void setup() { 
   String portName = "COM3";  //시리얼통신할 포트 설정 (컴퓨터와 연결된 포트이름을 넣습니다)
   println(Serial.list());  //시리얼 포트 출력
   myPort = new Serial(this, portName, 19200);
   myPort.clear();
   myPort.bufferUntil(10);
}
...

//processing 에서 "draw()" : setup이 실행되고 나서 프로그램이 끝날 때까지 계속 반복 실행
void draw() {


}
...

void serialEvent(Serial p) {   //시리얼 통신을 하여 받은 문자열을 필요한 값만으로 분리
		inString = (myPort.readString());  //설정한 포트로 문자열을 받음
		try {
		String[] dataStrings = split(inString, '#');  // ‘#’을 기준으로 분리하여 저장 ex) #STR:  #CDN
		for (int i = 0; i < dataStrings.length; i++) {
		 String type = dataStrings[i].substring(0, 4); //STR: <- 이와 같은 4글자 분리
		 String dataval = dataStrings[i].substring(4); //STR: <- 이와 같은 4글자 이후의 값들
		 if (type.equals("STR:")) {
		     start = int(dataval);  //start는 MAPMAKER가 이동 중이면 1, 멈추면 0을 뜻함.
		     if(start==1){
		       check=false;
		     }
		     else{  //MAPMAKER가 발광석을 발견하면 멈추는데 멈추면 check에 true를 대입
		       check=true;
		     }
		   } else if (type.equals("CDN:")) { 
		     String data[] = split(dataval, ',');  // ‘,’을 기준으로 분리하여 저장
		
		  	  //문자열에서 추출한 값들을 형변환하여 변수에 저장
		     radius = int(data[0]);  //반지름을 MAPMAKER의  일정한 속도로 설정
		     dgree = int(data[1]);  //yaw 각도(0~360)
		     dgree2 = int(data[2]); //pitch 각도(0~360)
		     count = int(data[3]);  //발광석의 개수
		     //자이로 센서로 추출한 각도 값(0~360)을 이용하여 X, Y좌표를 구하고 이 값들을 배열의 이전 값과 더하여 배열에 저장함. 
		     moveX[m]=moveX[m-1]+cos(dgree*PI/180)*radius; //이동경로를 그리기 위한 좌표
		     moveY[m]=moveY[m-1]+sin(dgree*PI/180)*radius;
		
		 //평지에 있을 때의 dgree2(pitch)의 값이 약 180도임. 이를 이용하여 값이 변하면 Z축의 값을 변화시킴
		     if(dgree2>175 && dgree2<185) 
		       zNum+=0;
		     else if(dgree2>185)
		       zNum+=1;
		     else
		       zNum-=1;
		     moveZ[m]=zNum;
		
		     m++;
		   } 
		}
		} catch (Exception e) {  //에러발생 시 프로세싱에 에러라고 출력해줌.
		 println("Error");
		}
}
 
```



