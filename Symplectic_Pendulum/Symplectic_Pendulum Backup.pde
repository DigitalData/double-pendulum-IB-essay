import java.util.Date;
import java.util.ArrayList;
//import java.util.Timer;
//import java.util.*;
import java.lang.Thread;

int w = 1500;
int h = 1000;
float a1 = PI/3;
float a2 = PI/2;
float len1 = 1;
float len2 = 1;
float lenTotal = len1 + len2;
float lenDispRatio = float(w/9);
float mass1 = 2;
float mass2 = 2;
float massTotal = mass1 + mass2;
float g = 9.8;
float av1 = 0, av2 = 0;
//float aa1 = 0;
//float aa2 = 0;
float pa1 = 0;
float pa2 = 0;
float ke1 = 0, ke2 = 0;
float initialGPE = ((mass1 * g * len1) + (mass2 * g * lenTotal)) + (-1 * (mass1 + mass2) * ( g * len1 * cos(a1))) - (mass2 * len2 * g * cos(a2));
//float te1 = g * mass1 * (len1 - (len1 * cos(a1)));
//float te2 = g * mass2 * (lenTotal - ((len1 * cos(a1)) + (len2 * cos(a2))));
float timeStep = 0.0150;
float timeRate = 1;
float fps = 60;
boolean isPaused = false;
float px1 = len1 * sin(a1);
float py1 = len1 * cos(a1);
float px2 = px1 + len2 * sin(a2);
float py2 = py1 + len2 * cos(a2);

void setup(){
  size(1500, 1000);
  frameRate(10000);
  background(075);
}

void draw(){
  updateAngles(timeStep);
  
  background(075);
  pushMatrix();
  translate(width/4, height/2);
  
  float x1 = lenDispRatio * len1 * sin(a1);
  float y1 = lenDispRatio * len1 * cos(a1);
  float x2 = x1 + lenDispRatio * len2 * sin(a2);
  float y2 = y1 + lenDispRatio * len2 * cos(a2);
  
  
  fill(255);
  stroke(255);
  ellipse(0,0,10,10);
  line(0,0,x1,y1);
  line(x1,y1,x2,y2);
  
  noStroke();
  fill(0,100,255);
  ellipse(x1,y1,50,50);
  fill(255,100,0);
  ellipse(x2,y2,50,50);
  
  popMatrix();
  
  pushMatrix();
  translate(width/2 - 25,0);
  textSize(50);
  text(("Original Energy: " + roundOff(initialGPE) + " Joules"),50,100);
  float currentGPE = ((mass1 * g * len1) + (mass2 * g * lenTotal)) + (-1 * (mass1 + mass2) * ( g * len1 * cos(a1))) - (mass2 * len2 * g * cos(a2));
  text(("Total GPE: " + roundOff(currentGPE) + " Joules"), 50, 200);
  float currentKE = (0.5 * (mass1 + mass2) * av1 * av1 * len1 * len1) + (0.5 * mass2 * av2 * av2 * len2 * len2) + (mass2 * len1 * len2 * av1 * av2 * cos(a2 - a1));
  text(("Total KE: " + roundOff(currentKE) + " Joules"), 50, 300);
  float te = currentKE + currentGPE;
  float de = initialGPE - te;
  text(("Total Energy: " + roundOff(te) + " Joules"), 50, 400);
  text(("Energy Loss: " + roundOff(de) + " Joules"), 50, 500);
  popMatrix();
}

void keyPressed(){
  if(key == 'r'){
  a1 = PI/2;
  a2 = PI/2;
  a1 = random(2,2*PI);
  a2 = random(2,2*PI);
  av1 = 0;
  av2 = 0;
  //aa1 = 0;
  //aa2 = 0;
  pa1 = 0;
  pa2 = 0;
  ke1 = 0;
  ke2 = 0;
  initialGPE = ((mass1 * g * len1) + (mass2 * g * lenTotal)) + (-1 * (mass1 + mass2) * ( g * len1 * cos(a1))) - (mass2 * len2 * g * cos(a2));
  }else{
    if(isPaused){
      isPaused = false;
      frameRate(fps);
    }else{
      isPaused = true;
      frameRate(0);
    }
  }
}

void updateAngles(float dt){

  //K Index List
  //     0     1     2     3     4     5     6     7
  //     a1    a2    pa1   pa2   av1   av2   pva1  pva2
  
  float[] origins = {a1,a2,pa1,pa2};
  float[] kVals = new float [4];
  
  //k1
  float[] k1 = new float[4];
  k1[3] = findpva2(origins[0],origins[1],origins[2],origins[3]);
  k1[2] = findpva1(origins[0],origins[1],origins[2],origins[3]);
  k1[1] = findav2(origins[0],origins[1],origins[2],origins[3]);
  k1[0] = findav1(origins[0],origins[1],origins[2],origins[3]);


  //k2
  for(int i = 0;i<kVals.length;i++){
    kVals[i] = origins[i] + ((dt/2) * k1[i]);
  }
  
  float[] k2 = new float[4];
  k2[3] = findpva2(kVals[0],kVals[1],kVals[2],kVals[3]);
  k2[2] = findpva1(kVals[0],kVals[1],kVals[2],kVals[3]);
  k2[1] = findav2(kVals[0],kVals[1],kVals[2],kVals[3]);
  k2[0] = findav1(kVals[0],kVals[1],kVals[2],kVals[3]);
 
  //k3
  for(int i = 0;i<kVals.length;i++){
    kVals[i] = origins[i] + ((dt/2) * k2[i]);
  }
  
  float[] k3 = new float[4];
  k3[3] = findpva2(kVals[0],kVals[1],kVals[2],kVals[3]);
  k3[2] = findpva1(kVals[0],kVals[1],kVals[2],kVals[3]);
  k3[1] = findav2(kVals[0],kVals[1],kVals[2],kVals[3]);
  k3[0] = findav1(kVals[0],kVals[1],kVals[2],kVals[3]); 
  
  //k4
    for(int i = 0;i<kVals.length;i++){
    kVals[i] = origins[i] + ((dt) * k3[i]);
  }
  
  float[] k4 = new float[4];
  k4[3] = findpva2(kVals[0],kVals[1],kVals[2],kVals[3]);
  k4[2] = findpva1(kVals[0],kVals[1],kVals[2],kVals[3]);
  k4[1] = findav2(kVals[0],kVals[1],kVals[2],kVals[3]);
  k4[0] = findav1(kVals[0],kVals[1],kVals[2],kVals[3]); 
  
  pa1 += (dt / 6) * (k1[2] + 2 * k2[2] + 2 * k3[2] + k4[2]);
  pa2 += (dt / 6) * (k1[3] + 2 * k2[3] + 2 * k3[3] + k4[3]);
  
  av1 = (k1[0] + 2 * k2[0] + 2 * k3[0] + k4[0])/6;
  av2 = (k1[1] + 2 * k2[1] + 2 * k3[1] + k4[1])/6;
  
  System.out.println(pa1);
  
  a1 += dt * av1;
  a2 += dt * av2;
}

float findav1(float ka1, float ka2, float kpa1, float kpa2){
  float a = len2 * kpa1;
  float b = len1 * kpa2 * cos(ka1 - ka2);
  float c = len1 * len1 * len2;
  float d = mass1 + (mass2 * sin(ka1 - ka2) * sin(ka1 - ka2));
  return (a - b)/(c * d);
}

float findav2(float ka1, float ka2, float kpa1, float kpa2){
  float a = mass2 * len2 * kpa1 * cos(ka1 - ka2);
  float b = (mass1 + mass2) * len1 * kpa2;
  float c = mass2 * len1 * len2 * len2;
  float d = (mass1 + (mass2 * sin(ka1 - ka2) * sin(ka1 - ka2)));
  return (b - a)/(c * d);
}

float findpva1(float ka1, float ka2, float kpa1, float kpa2){
  float h1 = findh1(ka1,ka2,kpa1,kpa2);
  float h2 = findh2(ka1,ka2,kpa1,kpa2);
  
  float a = (mass1 + mass2) * g * len1 * sin(ka1);
  float b = h2 * sin(2 * (ka1 - ka2));
  
  return ((b - h1) - a);
}

float findpva2(float ka1, float ka2, float kpa1, float kpa2){
  float h1 = findh1(ka1,ka2,kpa1,kpa2);
  float h2 = findh2(ka1,ka2,kpa1,kpa2);
  
  float a = mass2 * g * len2 * sin(ka2);
  float b = h2 * sin(2 * (ka1 - ka2));
  return ((h1 - a) - b);
}

float findh1(float ka1, float ka2, float kpa1, float kpa2){
  
  float a = kpa1 * kpa2 * sin(ka1 - ka2);
  float b = len1 * len2;
  float c = mass1 + (mass2 * sin(ka1 - ka2) * sin(ka1 - ka2));
  
  return a/(b*c);
}

float findh2(float ka1, float ka2, float kpa1, float kpa2){
  float a = mass2 * len2 * len2 * kpa1 * kpa1;
  float b = (mass1 + mass2) * len1 * len1 * kpa2 * kpa2;
  float c = 2 * mass2 * len1 * len2 * kpa1 * kpa2 * cos(ka1 - ka2);
  float d = 2 * len1 * len1 * len2 * len2;
  float e = mass1 + (mass2 * sin(ka1 - ka2) * sin(ka1 - ka2));
  
  return ((a+b)-c)/(d*e*e);
}

float roundOff(float a){
  return Math.round(a * 100.0) / 100.0;
}
