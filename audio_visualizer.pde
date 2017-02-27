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

boolean line = false;

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
  
  for(int i = 199; i > 0; i--) {
    for(int j = 99; j > 0; j--) {
      data[i][j] = data[i-1][j];
    }
  }
  
  for(int j = 0; j < 100; j++) data[0][j] = fft.getBand(j);
  
  pushMatrix();
  stroke(255);
  strokeWeight(1.0);
  noFill(); 
  translate(width/2 - 200, height/2 - 100, 0);
  for(int i = 0; i < 200; i++) {
    beginShape();
    for(int j = 0; j < 100; j++) {
      if(beat.isKick() || line){
        vertex(i * 2, j * 2, data[i][j]);
      }else{
        point(i * 2, j * 2, data[i][j]);
      }
    }
    endShape();
  }
  popMatrix();
  
  cam.beginHUD();
  text(cam.getRotations()[0] + " , " + cam.getRotations()[1] + " , " + cam.getRotations()[2], 100, 100);
  text("Dis: " + cam.getDistance(),100, 120);
  cam.endHUD();
}

void keyPressed() {
  switch(key) {
    case ' ':
      line = true;
      break;
    case 'w':
      cam.reset(1000);
      break;
    case 's':
      cam.setState(createCameraState(-1.5, 0, 0, 500),1000);
      break;
    case 'a':
      cam.setState(createCameraState(0.55, -1.5, 2.1, 300),1000);
      break;
    case 'd':
      cam.setState(createCameraState(-1.185, 1.5589, -0.385, 340),1000);
      break;
    case 'e':
      cam.setState(createCameraState(-0.731, 0.6336, -0.6058, 515),1000);
      break;
  }
}

void keyReleased() {
  switch(key) {
    case ' ':
      line = false;
      break;
  }
}

void mousePressed() {
  switch(key) {
  }
}

CameraState createCameraState(float x, float y, float z, double distance) {
  Rotation r = new Rotation(RotationOrder.XYZ, x, y, z);
  float[] look = cam.getLookAt();
  Vector3D v = new Vector3D(look[0], look[1], look[2]);
  CameraState state = new CameraState(r, v, distance);
  return state;
}