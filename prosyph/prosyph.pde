import codeanticode.syphon.*;

PGraphics canvas;
PImage img;

SyphonClient client;

import processing.serial.*;

Serial myPort;  // Create object from Serial class

boolean projecting = false;

int PreviousClock = 0;
int FrameClock = 0;
int FrameTime = 100;
int LineCount = 0;

void setup() 
{
  size(200,200, P3D); //make our canvas 200 x 200 pixels big
  
  printArray(Serial.list());
  
  String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 115200 );
  
  println(SyphonClient.listServers());
    
  // Create syhpon client to receive frames 
  // from the first available running server: 
  client = new SyphonClient(this, "Arena", "Composition");
  
  background(0);
}

void keyPressed() {                           //if we clicked in the window
  if ( !projecting ) {
    projecting = true;
    myPort.write('M'); 
    myPort.write('L'); 
    myPort.write('5'); 
  } else {
    projecting = false;
    myPort.write('N'); 
  }
}

void draw() {
  int currentClock = millis();
  int deltaClock = currentClock - PreviousClock;
  PreviousClock = currentClock;
  
  //print( "DT " );
  //println( deltaClock );
   
  while ( myPort.available() > 0 ) {
    char inByte = myPort.readChar();
    print(inByte);
   }  
  
  FrameClock += deltaClock;
  
  if ( LineCount == 0 ) {
    if ( projecting ) {
      if ( client.available() ) {
        // canvas = client.getGraphics(canvas);
        img = client.getImage(img);

        image(img, 0, 0, 8, 8); 
        for ( int y = 0; y < 8; y++ ) {
           myPort.write( 'X' );
           myPort.write( y + '0' );
           for ( int x = 0; x < 8; x++ ) {
             myPort.write( 10 + 10 * x  );
             myPort.write( 10 );
             myPort.write( 10 );
           }
         }
      }
    }
    LineCount++;
  }

/*    
  if ( LineCount < 8 ) {
     int y = LineCount++;
     if ( projecting ) {
       myPort.write( 'X' );
       myPort.write( y + '0' );
       for ( int x = 0; x < 8; x++ ) {
         myPort.write( 10 + 10 * x  );
         myPort.write( 10 );
         myPort.write( 10 );
       }
     }
  }
*/
  
  if ( FrameClock > FrameTime ) {
    FrameClock = 0;
    LineCount = 0;
  }   
}