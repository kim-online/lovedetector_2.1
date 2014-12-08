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


Everything with 1 at the end is the Male sensor (Sensor 1), and everything with 2 is the Female sensor (Sensor 2)

THE PULSE DATA WINDOW IS SCALEABLE WITH SCROLLBAR AT BOTTOM OF SCREEN
PRESS 'S' OR 's' KEY TO SAVE A PICTURE OF THE SCREEN IN SKETCH FOLDER (.jpg)
MADE BY JOEL MURPHY AUGUST, 2012
*/


import processing.serial.*;
PFont font;
Scrollbar scaleBar;

Serial port;     

int Sensor1;      // HOLDS PULSE SENSOR DATA FROM ARDUINO
int Sensor2;      // HOLDS PULSE SENSOR DATA FROM ARDUINO
int IBI1;         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int IBI2;         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int BPM1;         // HOLDS HEART RATE VALUE FROM ARDUINO
int BPM2;         // HOLDS HEART RATE VALUE FROM ARDUINO
int[] RawY1;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING
int[] RawY2;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING
int[] ScaledY1;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM
int[] ScaledY2;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM
int[] rate1;      // USED TO POSITION BPM DATA WAVEFORM
int[] rate2;      // USED TO POSITION BPM DATA WAVEFORM
float zoom;      // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
float offset;    // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
color eggshell = color(255, 253, 248);
int heart1 = 0;   // This variable times the heart image 'pulse' on screen
int heart2 = 0;   // This variable times the heart image 'pulse' on screen
//  THESE VARIABLES DETERMINE THE SIZE OF THE DATA WINDOWS
int PulseWindowWidth = 490;
int PulseWindowHeight = 512;
int BPMWindowWidth = 360;
int BPMWindowHeight = 340;
boolean beat1 = false;    // set when a heart beat is detected, then cleared when the BPM graph is advanced
boolean beat2 = false;    // set when a heart beat is detected, then cleared when the BPM graph is advanced


void setup() {
  size(900, 600);  // Stage size
  frameRate(100);  
  font = loadFont("Arial-BoldMT-24.vlw");
  textFont(font);
  textAlign(CENTER);
  rectMode(CENTER);
  ellipseMode(CENTER);  
// Scrollbar constructor inputs: x,y,width,height,minVal,maxVal
  scaleBar = new Scrollbar (400, 575, 180, 12, 0.5, 1.0);  // set parameters for the scale bar
  RawY1 = new int[PulseWindowWidth];          // initialize raw pulse waveform array
  RawY2 = new int[PulseWindowWidth];          // initialize raw pulse waveform array
  ScaledY1 = new int[PulseWindowWidth];       // initialize scaled pulse waveform array
  ScaledY2 = new int[PulseWindowWidth];       // initialize scaled pulse waveform array
  rate1 = new int [BPMWindowWidth];           // initialize BPM waveform array
  rate2 = new int [BPMWindowWidth];           // initialize BPM waveform array
  zoom = 0.75;                                // initialize scale of heartbeat window
    
// set the visualizer lines to 0
 for (int i=0; i<rate1.length; i++){
    rate1[i] = 555;      // Place BPM graph line at bottom of BPM Window 
   }
 for (int j=0; j<rate2.length; j++){
    rate2[j] = 555;      // Place BPM graph line at bottom of BPM Window 
   }   
 for (int i=0; i<RawY1.length; i++){
    RawY1[i] = height/2; // initialize the pulse window data line to V/2
 }
 for (int j=0; j<RawY2.length; j++){
    RawY2[j] = height/2; // initialize the pulse window data line to V/2
 } 
   
// GO FIND THE ARDUINO
  println(Serial.list());    // print a list of available serial ports
  // choose the number between the [] that is connected to the Arduino
  port = new Serial(this, Serial.list()[], 115200);  // make sure Arduino is talking serial at this baud rate
  port.clear();            // flush buffer
  port.bufferUntil('\n');  // set buffer full flag on receipt of carriage return
}
  
void draw() {
  background(0);
  noStroke();
// DRAW OUT THE PULSE WINDOW AND BPM WINDOW RECTANGLES  
  fill(eggshell);  // color for the window background
  rect(255,height/2,PulseWindowWidth,PulseWindowHeight);
  rect(700,385,BPMWindowWidth,BPMWindowHeight);
  
// DRAW THE PULSE WAVEFORM
  // prepare pulse data points    
  RawY1[RawY1.length-1] = (1023 - Sensor1) - 212;   // place the new raw datapoint at the end of the array
  RawY2[RawY2.length-1] = (1023 - Sensor2) - 212;   // place the new raw datapoint at the end of the array
  zoom = scaleBar.getPos();                         // get current waveform scale value
  offset = map(zoom,0.5,1,150,0);                   // calculate the offset needed at this scale
  for (int i = 0; i < RawY1.length-1; i++) {        // move the pulse waveform by
    RawY1[i] = RawY1[i+1];                          // shifting all raw datapoints one pixel left
    float dummy1 = RawY1[i] * zoom + offset;        // adjust the raw data to the selected scale
    ScaledY1[i] = constrain(int(dummy1),44,556);    // transfer the raw data array to the scaled array
  }
  for (int j = 0; j < RawY2.length-1; j++) {        // move the pulse waveform by
    RawY2[j] = RawY2[j+1];                          // shifting all raw datapoints one pixel left
    float dummy2 = RawY2[j] * zoom + offset;        // adjust the raw data to the selected scale
    ScaledY2[j] = constrain(int(dummy2),44,556);    // transfer the raw data array to the scaled array
  }  
  stroke(250,0,0);                                // red is a good color for the pulse waveform
  noFill();
  beginShape();                                   // using beginShape() renders fast
  for (int x = 1; x < ScaledY1.length-1; x++) {    
    vertex(x+10, ScaledY1[x]);                    //draw a line connecting the data points
  }
  endShape();
  
  stroke(0,250,0);                               // green is a good color for the pulse waveform
  beginShape();                                  // using beginShape() renders fast
  for (int q = 1; q < ScaledY2.length-1; q++) {    
    vertex(q+10, ScaledY2[q]);                   //draw a line connecting the data points
  }
  endShape();
  
// DRAW THE BPM WAVE FORM
// first, shift the BPM waveform over to fit then next data point only when a beat is found
 if (beat1 == true){   // move the heart rate line over one pixel every time the heart beats 
   beat1 = false;      // clear beat flag (beat flag waset in serialEvent tab)
   for (int i=0; i<rate1.length-1; i++){
     rate1[i] = rate1[i+1];                  // shift the bpm Y coordinates over one pixel to the left
   }
   
// then limit and scale the BPM value
   BPM1 = min(BPM1,200);                      // limit the highest BPM value to 200
   float dummy1 = map(BPM1,0,200,555,215);    // map it to the heart rate window Y
   rate1[rate1.length-1] = int(dummy1);       // set the rightmost pixel to the new data point value
 }

if (beat2 == true){    // move the heart rate line over one pixel every time the heart beats 
   beat2 = false;      // clear beat flag (beat flag waset in serialEvent tab)
   for (int j=0; j<rate2.length-1; j++){
     rate2[j] = rate2[j+1];                  // shift the bpm Y coordinates over one pixel to the left
   }
   
  BPM2 = min(BPM2,200);                      // limit the highest BPM value to 200
  float dummy2 = map(BPM2,0,200,555,215);    // map it to the heart rate window Y
  rate2[rate2.length-1] = int(dummy2);       // set the rightmost pixel to the new data point value 
} 
 // GRAPH THE HEART RATE WAVEFORM
 stroke(250,0,0);                          // color of heart rate graph
 strokeWeight(2);                          // thicker line is easier to read
 noFill();
 beginShape();
 for (int i=0; i < rate1.length-1; i++){    // variable 'i' will take the place of pixel x position   
   vertex(i+520, rate1[i]);                 // display history of heart rate datapoints
 }
 endShape();
 
  stroke(0,250,0);                          // color of heart rate graph
 strokeWeight(2);                           // thicker line is easier to read
 noFill();
 beginShape();
 for (int j=0; j < rate2.length-1; j++){    // variable 'j' will take the place of pixel x position   
   vertex(j+520, rate2[j]);                 // display history of heart rate datapoints
 }
 endShape();
 
// DRAW THE HEART AND MAYBE MAKE IT BEAT
  fill(250,0,0);
  stroke(250,0,0);
  // the 'heart' variable is set in serialEvent when arduino sees a beat happen
  heart1--;                     // heart is used to time how long the heart graphic swells when your heart beats
  heart1 = max(heart1,0);       // don't let the heart variable go into negative numbers
  if (heart1 > 0){              // if a beat happened recently, 
    strokeWeight(8);            // make the heart big
  }
  smooth();                 // draw the heart with two bezier curves
  bezier(width-300,50, width-220,-20, width-200,140, width-300,150);
  bezier(width-300,50, width-390,-20, width-400,140, width-300,150);
  strokeWeight(1);          // reset the strokeWeight for next time
  
  fill(250,0,0);
  stroke(250,0,0);
  // the 'heart' variable is set in serialEvent when arduino sees a beat happen
  heart2--;                     // heart is used to time how long the heart graphic swells when your heart beats
  heart2 = max(heart2,0);       // don't let the heart variable go into negative numbers
  if (heart2 > 0){              // if a beat happened recently, 
    strokeWeight(8);            // make the heart big
  }
  smooth();                 // draw the heart with two bezier curves
  bezier(width-100,50, width-20,-20, width,140, width-100,150);
  bezier(width-100,50, width-190,-20, width-200,140, width-100,150);
  strokeWeight(1);          // reset the strokeWeight for next time


// PRINT THE DATA AND VARIABLE VALUES
  fill(eggshell);                      // get ready to print text
  text("Lovedetector 2.1",245,30);     // Title
  text("IBI/mS" ,700,585);
  fill(250,0,0);
  text(IBI1 ,600,585);                 // print the time between heartbeats in mS
  fill(0,250,0);
  text(IBI2 ,800,585);                 // print the time between heartbeats in mS
  fill(eggshell);
  text("BPM" ,700,200);
  fill(250,0,0);
  text(BPM1 ,600,200);    // print the Beats Per Minute of Heart 1
  fill(0,250,0);
  text(BPM2 ,800,200);    // print the Beats Per Minute of Heart 2
  fill(eggshell);
  text("Pulse Window Scale " + nf(zoom,1,2), 150, 585); // show the current scale of Pulse Window
  
//  DO THE SCROLLBAR THINGS
  scaleBar.update (mouseX, mouseY);
  scaleBar.display();
  
//   
}  //end of draw loop



