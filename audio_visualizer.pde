import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;

PeasyCam cam;
Minim minim;
AudioPlayer player;
AudioInput in;
FFT fft;
BeatDetect beat;
float[][] data = new float[200][100];

float cx = 0, cy = 0, cz = 0, cd = 0;
float dx, dy, dz, dd, count = 0;
float moveStep = 100;

void setup() {
  size(1000, 1000, P3D);
  pixelDensity(2);
  
  cam = new PeasyCam(this, width/2, height/2, 0, 500);
  minim = new Minim(this);
  player = minim.loadFile("story.mp3");
  //in = minim.getLineIn();
  fft = new FFT(player.bufferSize(), player.sampleRate());
  fft.window(FFT.HAMMING);
  beat = new BeatDetect();
  beat.detectMode(BeatDetect.FREQ_ENERGY);
  beat.setSensitivity(400);
  
  player.play();
}

void draw() {
  background(0);
  
  fft.forward(player.mix);
  beat.detect(player.mix);
  
  if(count != 0) moveCameraTarget();
  
  for(int i = 199; i > 0; i--) {
    for(int j = 99; j > 0; j--) {
      data[i][j] = data[i-1][j];
    }
  }
  
  for(int j = 0; j < 100; j++) data[0][j] = fft.getBand(j);
  
  pushMatrix();
  beginShape();
  stroke(255);
  strokeWeight(1.0);
  noFill();
  translate(width/2 - 200, height/2 - 100, 0);
  for(int i = 0; i < 200; i++) {
    for(int j = 0; j < 100; j++) {
      if(beat.isKick()){
        vertex(i * 2, j * 2, data[i][j]);
      }else{
        point(i * 2, j * 2, data[i][j]);
      }
    }
  }
  endShape();
  popMatrix();
  
  cam.beginHUD();
  text(cam.getRotations()[0] + " , " + cam.getRotations()[1] + " , " + cam.getRotations()[2], 100, 100);
  text("Dis: " + cam.getDistance(),100, 150);
  cam.endHUD();
}

void keyPressed() {
  switch(key) {
    case '1':
      float[] target = {0, 0, 0, 500};
      cx = cam.getRotations()[0] - target[0];
      cy = cam.getRotations()[1] - target[1];
      cz = cam.getRotations()[2] - target[2];
      cd = (float)cam.getDistance();
      dx = cx / moveStep;
      dy = cy / moveStep;
      dz = cz / moveStep;
      dd = (cd - target[3]) / moveStep;
      
      count = 100;
      
      break;
  }
}

void moveCameraTarget() {
  cx -= dx;
  cy -= dy;
  cz -= dz;
  cd -= dd;
    
  cam.setRotations(cx, cy, cz);
  cam.setDistance(cd);
  count--;
}