Maxim maxim;
AudioPlayer player;
boolean playit;

void setup() {
 size(800, 700);
 maxim = new Maxim(this);
 player = maxim.loadFile("gravity_feels_short.wav");
 player.setLooping(false);
 player.volume(1.0);
 player.setAnalysing(true);
 background(0);
 frameRate(10);
}

void draw() {
    //h = min(15+(spec[5]-0.4)*400,100);
    //if (abs(h-lastH)<10) {
    //  h -= 15; // fabricate hue differences;
    //}
    //lastH = h;
    //s = 100;
    //b = 100;
  if (playit) {
    player.play();
    updateParams();
    
    /* DRAWINGS GO HERE. */
    background(0);
    strokeWeight(1);
    stroke(0);
//    fill(255);
//    soundRect(350,50,100,100,100);
//    fill(200,0,0,30);
//    soundRect(275,150,250,350,300);
//    fill(100,200,200);
//    soundRect(300,500,75,100,100);
//    soundRect(500,500,75,100,100);
    fill(255,255,255,100);
    float[] coordinates = {20,120,50,150,100,120};
//    soundPolygon(coordinates,100);
    float[] squarecoordinates = {width/4,height/4,3*width/4,height/4,3*width/4,3*height/4,width/4,3*height/4};
    soundPolygon(squarecoordinates,100);
    stroke(255);
    strokeWeight(3);
    soundBird(150,200,200);
    soundBird(250,225,180);
    strokeWeight(2);
    soundBird(100,270,100);
    soundBird(170,240,70);
  }
}

void mousePressed() {
  playit = !playit;
  if (playit) {
    //t = 0;
    player.play();
  } 
  else {
    player.stop();
  }
}
