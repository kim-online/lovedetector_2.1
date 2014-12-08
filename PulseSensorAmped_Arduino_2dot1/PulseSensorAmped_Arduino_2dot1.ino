
/*
LOVE DETECTOR 2.1

Code made by Kim Köhler for final project in Code and Core Studio/Lab fall 2014. (BFA Design & Technology, Parsons/The New School)

Credits to Joel Murphy and Yury Gitman (www.pulsesensor.com) for producing the pulse sensors and creating base
code for both Arduino and Processing.

Thanks to Anthony Marefatk and Lucy Morcos for help in coding.
    
Pulse Sensor sample aquisition and processing happens in the background via Timer 2 interrupt. 2mS sample rate.
PWM on pins 3 and 11 will not work when using this code, because we are using Timer 2!
The following variables are automatically updated:
Signal :    int that holds the analog signal data straight from the sensor. updated every 2mS.
IBI  :      int that holds the time interval between beats. 2mS resolution.
BPM  :      int that holds the heart rate value, derived every beat, from averaging previous 10 IBI values.
QS  :       boolean that is made true whenever Pulse is found and BPM is updated. User must reset.
Pulse :     boolean that is true when a heartbeat is sensed then false in time with pin13 LED going out.

*/

// Everything with 1 at the end is the Male sensor (Sensor 1), and everything with 2 is the Female sensor (Sensor 2)


//  VARIABLES
int lovePin = 2;                   // Love Pin 
int pulsePin1 = 0;                 // Pulse Sensor purple wire connected to analog pin 0
int pulsePin2 = 1;
int blinkPin1 = 12;                // pin to blink led at each beat
int blinkPin2 = 10;
int fadePin1 = 5;                  // pin to do fancy classy fading blink at each beat
int fadePin2 = 6;  
int fadeRate1 = 0;                 // used to fade LED on with PWM on fadePin
int fadeRate2 = 0;


// these variables are volatile because they are used during the interrupt service routine!
volatile int BPM1;                   // used to hold the pulse rate
volatile int BPM2;
volatile int Signal1;                // holds the incoming raw data
volatile int Signal2;  
volatile int IBI1 = 600;             // holds the time between beats, must be seeded! 
volatile int IBI2 = 600;
volatile int time;                   
volatile int timeDelay;
volatile boolean Pulse1 = false;     // true when pulse wave is high, false when it's low
volatile boolean Pulse2 = false;
volatile boolean QS1 = false;        // becomes true when Arduoino finds a beat.
volatile boolean QS2 = false;
volatile boolean CoRaise = false;    // Rule 1
volatile boolean FemChange = false;  // Rule 2
volatile boolean ManChange = false;  // Rule 3



void setup(){
  time = millis();                   
  timeDelay = 5000;                   //setting the timedelay to 5 seconds
  pinMode(lovePin,OUTPUT);            //pin that signals love
  pinMode(blinkPin1,OUTPUT);          // pin that will blink to your heartbeat!
  pinMode(blinkPin2,OUTPUT);
  pinMode(fadePin1,OUTPUT);           // pin that will fade to your heartbeat!
  pinMode(fadePin2,OUTPUT);
  Serial.begin(115200);               // we agree to talk fast!
  interrupt1Setup();                  // sets up to read Pulse Sensor signal every 2mS 
  //interrupt2Setup(); 
   // UN-COMMENT THE NEXT LINE IF YOU ARE POWERING The Pulse Sensor AT LOW VOLTAGE, 
   // AND APPLY THAT VOLTAGE TO THE A-REF PIN
   //analogReference(EXTERNAL);   
}



void loop(){
  sendDataToProcessing('S', Signal1);     // send Processing the raw Pulse Sensor data
  sendDataToProcessing('D', Signal2);
  if (QS1 == true){                       // Quantified Self flag is true when arduino finds a heartbeat
        fadeRate1 = 255;                  // Set 'fadeRate' Variable to 255 to fade LED with pulse
        sendDataToProcessing('B',BPM1);   // send heart rate with a 'B' prefix
        sendDataToProcessing('Q',IBI1);   // send time between beats with a 'Q' prefix
        QS1 = false;                      // reset the Quantified Self flag for next time    
     }
     
     if (QS2 == true){                    // Quantified Self flag is true when arduino finds a heartbeat
        fadeRate2 = 255;                  // Set 'fadeRate' Variable to 255 to fade LED with pulse
        sendDataToProcessing('N',BPM2);   // send heart rate with a 'N' prefix
        sendDataToProcessing('W',IBI2);   // send time between beats with a 'W' prefix
        QS2 = false;                      // reset the Quantified Self flag for next time    
     }
  
  ledFadeToBeat1();
  ledFadeToBeat2();
  
  delay(20);                               //  take a break
}


void ledFadeToBeat1(){
    fadeRate1 -= 15;                          //  set LED fade value
    fadeRate1 = constrain(fadeRate1,0,255);   //  keep LED fade value from going into negative numbers!
    analogWrite(fadePin1,fadeRate1);          //  fade LED
  }
  
  void ledFadeToBeat2(){
    fadeRate2 -= 15;                          //  set LED fade value
    fadeRate2 = constrain(fadeRate2,0,255);   //  keep LED fade value from going into negative numbers!
    analogWrite(fadePin2,fadeRate2);          //  fade LED
  }


void sendDataToProcessing(char symbol, int data ){
    Serial.print(symbol);                // symbol prefix tells Processing what type of data is coming
    Serial.println(data);                // the data to send culminating in a carriage return
  }







