float[] spec = new float[95];
float[] prevSpec = new float[95];
int wait=0;
int t=0;
int bt=0;

float arrayAverage(float[] input) {
 float sum = 0;
 for (int i=0; i<input.length; i++) {
   sum+=input[i];
 }
 return sum/input.length;
}

float[] arrayEvens(float[] input) {
  float[] output = new float[input.length/2];
  int j = 0;
  for (int i=0; i<input.length; i++) {
    if (i%2==0) {
      output[j] = input[i];
      j++;
    }
  }
  return output;
}


float[] arrayOdds(float[] input) {
  float[] output = new float[input.length/2];
  int j = 0;
  for (int i=0; i<input.length; i++) {
    if (i%2==1) {
      output[j] = input[i];
      j++;
    }
  }
  return output;
}


void flattenSpec() {
 for (int i=0;i<15;i++) {
   spec[i] = spec[i]/(1+(0.035*(15-i)));
 }
}

boolean beatDetector() {
  /* TO DO: MOVING AVERAGE FUNCTION */
 float power;
 power = player.getAveragePower();
 float threshold = 0.1;
 if (power > threshold && wait<0) {
     wait+=4; 
     return true;
 }
 wait--;
 return false;
}

void updateParams() {
 t++;
 if (beatDetector()) {
   prevSpec = spec;
   spec = subset(player.getPowerSpectrum(),0,95);
   flattenSpec();
   bt = 0;
 }
 else {
   bt++;
   bt = min(max(bt,0),4);
 }
}

void soundSide(float x1, float y1, float x2, float y2, float angle, float jiggle) {
 /* Constructs a sound-distorted side from (x1,y1) to (x2,y2).
    Distortion will be based on the magnitude of jiggle and in
    the direction given by angle (in radians).
 */
 float ratio;
 float distortion;
 float xdistortion;
 float ydistortion;
 float x;
 float y;
 
 for (int i=0;i<spec.length;i++) {
   ratio = float(i)/spec.length;
   distortion = jiggle * ((float(bt)/4)*spec[i] + (float(4-bt)/4)*prevSpec[i]);
   xdistortion = cos(angle)*distortion;
   ydistortion = sqrt(sq(distortion)-sq(xdistortion));
   if (angle<=PI) {
     ydistortion *= -1;
   }
   x = x1 + ratio * (x2-x1) + xdistortion;
   y = y1 + ratio * (y2-y1) + ydistortion;
//   curveVertex(x,y); // not noticing much of a difference from vertex(), visually.
   vertex(x,y);
 }
}

void soundRect(float x, float y, float w, float h, float jiggle) {
 /* TO DO: CORNER DISTORTIONS */
// beginShape(TRIANGLE_FAN);
 beginShape();
 soundSide(x,y,x+w,y,PI/2,jiggle); // top
 soundSide(x+w,y,x+w,y+h,0,jiggle); // right
 soundSide(x+w,y+h,x,y+h,3*PI/2,jiggle); // bottom
 soundSide(x,y+h,x,y,PI,jiggle); //left
 endShape(CLOSE);
}

float calculateDistortionAngle(float[] center, float x1, float y1, float x2, float y2) {
  float angle;
  float theta;
  float midx;
  float midy;
  theta = atan(abs(x1-x2)/abs(y1-y2));
  midx = (x1+x2)/2;
  midy = (y1+y2)/2;
  if ((midx>center[0]) && (midy>center[1])) {
    stroke(100,0,0);
    println("1");
    angle = theta;
  } else if ((midx<=center[0]) && (midy>center[1])) {
    stroke(0,100,0);
    println("2");
    angle = theta + PI/2;
  } else if ((midx<=center[0]) && (midy<=center[1])) {
    stroke(0,0,100);
    println("3");
    angle = theta + PI;
  } else {
    stroke(0,100,100);
    println("4");
    angle = theta + 3*PI/2; // if ((midx>center[0]) && (midy<=center[1]))
  }
  return angle;
}

void soundPolygon(float[] coordinates, float jiggle) {
  float angle;
  float center[] = new float[2];
  if (coordinates.length % 2 == 1) {
    println("Error: unmatched x coordinates (input array contains an odd number of elements)");
    println("Usage: soundPolygon([x1,y1,x2,y2,x3,y3,...],jiggle)");
  }
  else if (coordinates.length < 6) {
    println("Error: not enough coordinates to construct polygon (need at least 3)");
    println("Usage: soundPolygon([x1,y1,x2,y2,x3,y3,...],jiggle)");
  }
  else {
    center[0] = arrayAverage(arrayEvens(coordinates));
    center[1] = arrayAverage(arrayOdds(coordinates));
    beginShape();
    for (int i=0;i<coordinates.length-2;i+=2) {
      angle = calculateDistortionAngle(center,coordinates[i],coordinates[i+1],coordinates[i+2],coordinates[i+3]);
      soundSide(coordinates[i],coordinates[i+1],coordinates[i+2],coordinates[i+3],angle,jiggle);
    }
    angle = calculateDistortionAngle(center,coordinates[coordinates.length-2],coordinates[coordinates.length-1],coordinates[0],coordinates[1]);
    soundSide(coordinates[coordinates.length-2],coordinates[coordinates.length-1],coordinates[0],coordinates[1],angle,jiggle);
    endShape();
  }
}

void soundBird(float x, float y, float w) {
  float h = w/10 - (4-bt)*w/60;
  noFill();
  bezier(x-w/2,y,x-w*9/24,y-h,x-w*3/24,y-h,x,y);
  bezier(x,y,x+w*3/24,y-h,x+w*9/24,y-h,x+w/2,y);
}
//
//void soundEllipse(float x, float y, float w, float h, float jiggle) {
//  float distortion;
//  float r;
//  float theta = 0;
//  beginShape();
//  float y = r_distorted*sin(theta); 
//  float x = sqrt(sq(r_distorted)-sq(y));
//  vertex(180,0);
//  vertex(x,y);
//  for (int i=1;i<spec.length;i++) {
//    theta = 2*(i+1)*PI/spec.length;
//    r = 
//    distortion = jiggle * ((float(bt)/4)*spec[i] + (float(4-bt)/4)*prevSpec[i]);
//    xdistortion = cos(angle)*distortion;
//    ydistortion = sqrt(sq(distortion)-sq(xdistortion));
//    if (angle<=PI) {
//      ydistortion *= -1;
//    }
//    
//    y = r_distorted*sin(theta); 
//    x = sqrt(sq(r_distorted)-sq(y));
//    if (theta>PI/2 && theta<3*PI/2) {
//      x = -x; // +- sqrt adjustment
//    }
//    curveVertex(x,y);
//  }
//  curveVertex(128,0);
//  endShape();
//}
