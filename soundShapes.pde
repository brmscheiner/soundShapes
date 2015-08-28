//The MIT License (MIT) - See Licence.txt for details

//Copyright (c) 2013 Mick Grierson, Matthew Yee-King, Marco Gillies


Maxim maxim;
AudioPlayer player;
boolean playit;
float[] spec = new float[95];
float[] flatSpec = new float[95];
float[] prevSpec = new float[95];
float[] colorBand = {0,0,0,0,0};
//float[] bass;
//float[] mids;
//float[] high;
float h;
float s;
float b;
float lastH = 70;
float power;
float threshold = 0.23;// try increasing this if it jumps around too much
int wait=0;
float treblePower;
float trebleThresh = 0.35;
float trebleWait = 0;
int t=0;

float arrayAverage(float[] input) {
  float sum = 0;
  for (int i=0; i<input.length; i++) {
    sum+=input[i];
  }
  return sum/input.length;
}

float[] flattenSpec(float[] spec) {
  for (int i=0;i<15;i++) {
    spec[i] = spec[i]/(1+(0.035*(15-i)));
  }
  return spec;
}

void makeColorBand() {
  for (int i=0; i<colorBand.length; i++) {
    fill(colorBand[i],100,100);
    ellipse(0,0,150+200*(4-i),150+200*(4-i));
  }
}

void setup() {
  size(600, 600);
  maxim = new Maxim(this);
  player = maxim.loadFile("fluorescent_adolescent.wav");
  player.setLooping(false);
  player.volume(1.0);
  player.setAnalysing(true);
  background(0);
  frameRate(10);
  colorMode(HSB,100);
  for (int i=0; i<95; i++) {
    spec[i]=0;
  }
}

void draw() {

  float power = 0;
  noStroke();
  if (playit) {
    background(0);
    player.play();

    // BEAT DETECTION 
    power = player.getAveragePower();
    if (power > threshold && wait<0) {
      //rotate(random(0,2*PI));
      prevSpec = spec;
      spec = subset(player.getPowerSpectrum(),0,95);
      h = min(15+(spec[5]-0.4)*400,100);
      if (abs(h-lastH)<10) {
        h -= 15; // fabricate hue differences;
      }
      lastH = h;
      s = 100;
      b = 100;
      colorBand[4]=colorBand[3];
      colorBand[3]=colorBand[2];
      colorBand[2]=colorBand[1];
      colorBand[1]=colorBand[0];
      colorBand[0]=h;
      fill(h,s,b);
      
      flattenSpec(spec);
      wait+=4; 
      t=0;
      
    }
    wait--;
    
    translate(width/2,height/2);
    fill(h,s,b);
    makeColorBand();
    
    // TREBLE BEAT DETECTION 
    treblePower = arrayAverage(subset(player.getPowerSpectrum(),60,30));
    if (treblePower > trebleThresh && trebleWait<0) {
      for (int i=0;i<8;i++) {
        pushMatrix();
        translate(450,0);
        rotate(i*PI/4);
        fill(0);
        strokeWeight(3);
        stroke(0);
        triangle(0,0,-25,30,25,30);
        popMatrix();
        trebleWait+= 5;
      }
    }
    trebleWait--;

    float r = 5+8*power;
//    noStroke();
    stroke(0);
    strokeWeight(4);
    beginShape();
    curveVertex(180,0);
    int ct = max(min(4,t),0);
    float r_distorted = r+(prevSpec[prevSpec.length-1]*(4-ct)/4 + spec[spec.length-1]*ct/4)*400;
    float theta = 0;
    float y = r_distorted*sin(theta); 
    float x = sqrt(pow(r_distorted,2)-pow(y,2));
    curveVertex(x,y);
    for (int i=1;i<spec.length;i++) {
      r_distorted = r+(prevSpec[i]*(4-ct)/4 + spec[i]*ct/4)*400;
      theta = 2*(i+1)*PI/spec.length;
      y = r_distorted*sin(theta); 
      x = sqrt(pow(r_distorted,2)-pow(y,2));
      if (theta>PI/2 && theta<3*PI/2) {
        x = -x; // +- sqrt adjustment
      }
      curveVertex(x,y);
    }
    curveVertex(128,0);
    endShape();
  }
  t++;
}



void mousePressed() {

  playit = !playit;

  if (playit) {
    t = 0;
    player.play();
  } 
  else {

    player.stop();
  }
}

