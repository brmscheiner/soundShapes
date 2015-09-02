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
//   println(xdistortion);
//   println(ydistortion);
//   println(distortion);
   if (angle<=PI) {
     ydistortion *= -1;
   }
   x = x1 + ratio * (x2-x1) + xdistortion;
   y = y1 + ratio * (y2-y1) + ydistortion;
   curveVertex(x,y);
//   vertex(x,y);
 }
}

void soundRect(float x, float y, float w, float h, float jiggle) {
 /* TO DO: CORNER ADJUSTMENTS */
 beginShape();
 soundSide(x,y,x+w,y,PI/2,jiggle); // top
 soundSide(x+w,y,x+w,y+h,0,jiggle); // right
 soundSide(x+w,y+h,x,y+h,3*PI/2,jiggle); // bottom
 soundSide(x,y+h,x,y,PI,jiggle); //left
 endShape();
}

//void soundEllipse(float x, float y, float rx, float ry, float jiggle) {
   //float r = 5+8*power;
   //beginShape();
   //curveVertex(180,0);
   //int ct = max(min(4,t),0);
   //float r_distorted = r+(prevSpec[prevSpec.length-1]*(4-ct)/4 + spec[spec.length-1]*ct/4)*400;
   //float theta = 0;
   //float y = r_distorted*sin(theta); 
   //float x = sqrt(pow(r_distorted,2)-pow(y,2));
   //curveVertex(x,y);
   //for (int i=1;i<spec.length;i++) {
   //  r_distorted = r+(prevSpec[i]*(4-ct)/4 + spec[i]*ct/4)*400;
   //  theta = 2*(i+1)*PI/spec.length;
   //  y = r_distorted*sin(theta); 
   //  x = sqrt(pow(r_distorted,2)-pow(y,2));
   //  if (theta>PI/2 && theta<3*PI/2) {
   //    x = -x; // +- sqrt adjustment
   //  }
   //  curveVertex(x,y);
   //}
   //curveVertex(128,0);
   //endShape();
//}
