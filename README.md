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

아두이노에서 컴퓨터로 전송받은데이터를 그래픽 기반 언어 "프로세싱"을 통해 처리합니다.\
컴퓨터에서 프로세싱 코드를 (__Processing_final.pde__) 실행합니다.
<img src="https://user-images.githubusercontent.com/46067837/102790986-ab945c80-43e9-11eb-808f-54fa050bc617.png" width="80%">



