String[] imgNames = {"1.png", "2.png", "3.png", "4.png", "5.png", "6.png", "7.png", "8.png", "9.png", "0.png"};
//String[] imgNames = {"11.png", "22.png", "33.png", "44.png", "55.png", "66.png", "77.png", "88.png", "99.png", "00.png"};
PImage img;
int imgIndex = 1;

import ddf.minim.*;
import ddf.minim.effects.*;
Minim minim;
AudioPlayer air;

import KinectPV2.KJoint;
import KinectPV2.*;
KinectPV2 kinect;

void setup(){
  size(1980, 1080);
  //fullScreen();
  background(0);
  frameRate(30);
  noCursor();//隐藏光标
  nextImage();
  
  colorMode(HSB);
  
  minim = new Minim(this);
  air = minim.loadFile("music2.mp3", 2048);
  air.loop();
  
  kinect = new KinectPV2(this);

  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);

  kinect.init();
}

void draw(){
  translate(width / 2, height / 2);
  //image(img, 0, 0);
  
  //加载个体的骨骼
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      color col  = skeleton.getIndexColor();
      //fill(col);
      //stroke(col);
     
      //draw different color for each hand state
      drawHandState(joints[KinectPV2.JointType_HandRight]);       
    } 
  }
  
  int index = 0;
  for(int y=0; y<height; y+=1){
    for(int x=0; x<width; x+=1){
      int odds = (int)random(80000);
      if(odds<1){
        color pixelColor = img.pixels[index];
        pixelColor = color(hue(pixelColor), saturation(pixelColor), brightness(pixelColor), 10);
        
        pushMatrix();
        translate(x-img.width/2, y-img.height/2);
        rotate(radians(hue(pixelColor)));
        
        // Paint by layers from rough strokes to finer details
        int sound = (int)(800 * air.left.get((int)random(2048)));
        if(sound < 0){
          sound = -sound;
        }
        
        paintStroke((int)random(sound + 1, sound + 5), pixelColor, (int)random(sound/5, sound/10));
        //还原翻转
        popMatrix();
      }
      
      index += 1;
    }
  }
}

void nextImage() {
  loop();
  frameCount = 0;
  
  img = loadImage(imgNames[imgIndex]);
  img.resize(width, height);
  img.loadPixels();
  
  imgIndex += 1;
  if (imgIndex >= imgNames.length) {
    imgIndex = 0;
  }
}

void mousePressed() {
  nextImage();
}

void drawHandState(KJoint joint) {
  noStroke();
  handState(joint.getState());
  //pushMatrix();
  //translate(joint.getX(), joint.getY(), joint.getZ());
  //ellipse(0, 0, 70, 70);
  //popMatrix();
}

void handState(int handState) {
  if(handState == KinectPV2.HandState_Closed){
    nextImage();
  }
}

void paintStroke(float strokeLength, color strokeColor, int strokeThickness) {
  float stepLength = strokeLength/4.0;
  
  // Determines if the stroke is curved. A straight line is 0.
  float tangent1 = 0;
  float tangent2 = 0;
  
  float odds = random(1.0);
  
  if (odds < 0.9) {
    //tangent1 = random(-hue(strokeColor), hue(strokeColor));
    //tangent2 = random(-hue(strokeColor), hue(strokeColor));
    tangent1 = random(-1, 1);
    tangent2 = random(-1, 1);
  } 
  
  // Draw a big stroke
  noFill();
  stroke(strokeColor);
  strokeWeight(strokeThickness);
  //bezier(tangent1, -stepLength*2, 0, -stepLength, 0, stepLength, tangent2, stepLength*2);
  
  int z = 1;
  
  // Draw stroke's details
  for (int num = strokeThickness; num > 0; num --) {
    float offset = random(-10, 10);
    color newColor = color(hue(strokeColor)+offset, saturation(strokeColor)+offset, brightness(strokeColor)+offset, random(50, 150));
    
    stroke(newColor);
    strokeWeight((int)random(0, 10));
    float curveT=random(-2, 2);
    curveTightness(curveT);
    curve(tangent1, -stepLength*2, z-strokeThickness/2, -stepLength*random(0.9, 1.1), z-strokeThickness/2, stepLength*random(0.9, 1.1), tangent2, stepLength*2);
    //bezier(tangent1, -stepLength*2, z-strokeThickness/2, -stepLength*random(0.9, 1.1), z-strokeThickness/2, stepLength*random(0.9, 1.1), tangent2, stepLength*2);
    z += 1;
  }
}
