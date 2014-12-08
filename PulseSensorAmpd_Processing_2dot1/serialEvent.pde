



void serialEvent(Serial port){ 
   String inData = port.readStringUntil('\n');
   inData = trim(inData);                 // cut off white space (carriage return)
   
   if (inData.charAt(0) == 'S'){          // leading 'S' for sensor data
     inData = inData.substring(1);        // cut off the leading 'S'
     Sensor1 = int(inData);               // convert the string to usable int
   }
    if (inData.charAt(0) == 'D'){          // leading 'D' for sensor data
     inData = inData.substring(1);         // cut off the leading 'D'
     Sensor2 = int(inData);                // convert the string to usable int
   }
   if (inData.charAt(0) == 'B'){           // leading 'B' for BPM data
     inData = inData.substring(1);         // cut off the leading 'B'
     BPM1 = int(inData);                   // convert the string to usable int
     beat1 = true;                         // set beat flag to advance heart rate graph
     heart1 = 20;                          // begin heart image 'swell' timer
   }
   if (inData.charAt(0) == 'N'){           // leading 'N' for BPM data
     inData = inData.substring(1);         // cut off the leading 'N'
     BPM2 = int(inData);                   // convert the string to usable int
     beat2 = true;                         // set beat flag to advance heart rate graph
     heart2 = 20;                          // begin heart image 'swell' timer
   }
 if (inData.charAt(0) == 'Q'){            // leading 'Q' means IBI data 
     inData = inData.substring(1);        // cut off the leading 'Q'
     IBI1 = int(inData);                  // convert the string to usable int
   }
    if (inData.charAt(0) == 'W'){         // leading 'W' means IBI data 
     inData = inData.substring(1);        // cut off the leading 'W'
     IBI2 = int(inData);                  // convert the string to usable int
   }
}
