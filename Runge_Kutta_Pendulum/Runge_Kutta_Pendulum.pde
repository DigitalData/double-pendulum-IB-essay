import java.util.Date;
import java.util.ArrayList;
//import java.util.Timer;
import java.lang.Thread;

int w = 1920;
int h = 1080;
float a1 = PI;
float a2 = PI;
float len1 = 1;
float len2 = 1;
float lenDispRatio = float(w/9);
float mass1 = 2;
float mass2 = 2;
float massTotal = mass1 + mass2;
float g = 9.8;
float av1 = 0, av2 = 0;
float aa1 = 0;
float aa2 = 0;
float ke1 = 0, ke2 = 0;
float initialGPE = (mass1 * g * (len1 + len2 - len1 * cos(a1)))+(mass2 * g * (len1 + len2 - len1 * cos(a1) - len2 * cos(a2)));
int prevTime = 0;
float timeStep = 0.025;
float timeSpent = 0;
float[] frameTime = {0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100};
float fps = 60;
boolean isPaused = false;

void setup() {
  size(1920, 1080);
  background(255);
}

void draw() {
  if (!isPaused) {
    updateAngles(timeStep);

    timeSpent += timeStep;
  }

  background(255);
  pushMatrix();
  translate(width/4, height/2);
  scale(1, -1);

  float x1 = lenDispRatio * len1 * sin(a1);
  float y1 = -lenDispRatio * len1 * cos(a1);
  float x2 = x1 + lenDispRatio * len2 * sin(a2);
  float y2 = y1 - lenDispRatio * len2 * cos(a2);  

  fill(0);
  stroke(0);
  ellipse(0, 0, 10, 10);
  line(0, 0, x1, y1);
  line(x1, y1, x2, y2);

  noStroke();
  fill(0);
  ellipse(x1, y1, 50, 50);
  fill(0);
  ellipse(x2, y2, 50, 50);

  popMatrix();

   //Energy Calculations
  pushMatrix();
  translate(width/2 - 25, 0);
  textSize(50);
  text(("Original Energy: " + roundOff(initialGPE) + " Joules"), 50, 100);
  float currentGPE = (mass1 * g * (len1 + len2 - len1 * cos(a1)))+(mass2 * g * (len1 + len2 - len1 * cos(a1) - len2 * cos(a2)));
  text(("Total GPE: " + roundOff(currentGPE) + " Joules"), 50, 200);
  float currentKE = (0.5 * (mass1 + mass2) * av1 * av1 * len1 * len1) + (0.5 * mass2 * (av2 * av2 * len2 * len2 + 2 * len1 * len2 * av1 * av2 * cos(a1 - a2)));
  text(("Total KE: " + roundOff(currentKE) + " Joules"), 50, 300);
  float te = currentKE + currentGPE;
  float de = initialGPE - te;
  text(("Total Energy: " + roundOff(te) + " Joules"), 50, 400);
  text(("Energy Loss: " + roundOff(de) + " Joules"), 50, 500);
  text(("Time Spent: " + roundOff(timeSpent) + " Seconds"), 50, 600);
  popMatrix();
  
  if (!isPaused) {
    for (int i = 0; i < frameTime.length; i++) {
      if (frameTime[i] <= timeSpent) {
        saveFrame();
        frameTime[i] = 1000;
        System.out.print("Frame");
        break;
      }
    }
  }
}

void keyPressed() {
  if (key == 'r') {
    a1 = random(0,2*PI);
    a2 = random(0,2*PI);
    aa1 = 0;
    aa2 = 0;
    av1 = 0;
    av2 = 0;
    ke1 = 0;
    ke2 = 0;
    initialGPE = (mass1 * g * (len1 + len2 - len1 * cos(a1)))+(mass2 * g * (len1 + len2 - len1 * cos(a1) - len2 * cos(a2)));
  } else {
    if (isPaused) {
      isPaused = false;
    } else {
      isPaused = true;
    }
  }
}

void updateAngles(float dt) {

  //K Index List
  //     0     1     2     3     [4     5]
  //     a1    av1   a2    av2   [aa1   aa2]

  float[] origins = {a1, a2, av1, av2};
  float[] kVals = new float [4];

  //k1
  float[] k1 = new float[6];
  k1[5] = finda2(origins[0], origins[1], origins[2], origins[3]);
  k1[4] = finda1(origins[0], origins[1], origins[2], origins[3]);
  for (int i = 0; i<origins.length; i++) {
    k1[i] = origins[i];
  }

  //k2
  for (int i = 0; i<kVals.length; i++) {
    kVals[i] = origins[i] + ((dt/2) * k1[i+2]);
  }

  float[] k2 = new float[6];
  k2[5] = finda2(kVals[0], kVals[1], kVals[2], kVals[3]);
  k2[4] = finda1(kVals[0], kVals[1], kVals[2], kVals[3]);  
  for (int i = 0; i<kVals.length; i++) {
    k2[i] = kVals[i];
  }

  //k3
  for (int i = 0; i<kVals.length; i++) {
    kVals[i] = origins[i] + ((dt/2) * k2[i+2]);
  }

  float[] k3 = new float[6];
  k3[5] = finda2(kVals[0], kVals[1], kVals[2], kVals[3]);
  k3[4] = finda1(kVals[0], kVals[1], kVals[2], kVals[3]);  
  for (int i = 0; i<kVals.length; i++) {
    k3[i] = kVals[i];
  }

  //k4
  for (int i = 0; i<kVals.length; i++) {
    kVals[i] = origins[i] + ((dt) * k3[i+2]);
  }

  float[] k4 = new float[6];
  k4[5] = finda2(kVals[0], kVals[1], kVals[2], kVals[3]);
  k4[4] = finda1(kVals[0], kVals[1], kVals[2], kVals[3]);  
  for (int i = 0; i<kVals.length; i++) {
    k4[i] = kVals[i];
  }

  av1 += (dt / 6) * (k1[4] + 2 * k2[4] + 2 * k3[4] + k4[4]);
  av2 += (dt / 6) * (k1[5] + 2 * k2[5] + 2 * k3[5] + k4[5]);
  //a1 += av1 * dt;
  //a2 += av2 * dt;
  a1 += (dt / 6) * (k1[2] + 2 * k2[2] + 2 * k3[2] + k4[2]);
  a2 += (dt / 6) * (k1[3] + 2 * k2[3] + 2 * k3[3] + k4[3]);
}

float finda1(float ka1, float ka2, float w1, float w2) {
  float k = ((-g)*(2 * mass1 + mass2)*(sin(ka1))) - ((mass2 * g) * (sin(ka1 - 2*ka2))) - ((2*sin(ka1 - ka2)*mass2*(w2 * w2 * len2 + w1 * w1 * len1 * cos(ka1-ka2))));
  k /= (len1 * (2 * mass1 + mass2 - mass2 * cos(2*ka1 - 2*ka2)));
  return k;
}

float finda2(float ka1, float ka2, float w1, float w2) {
  float k = 2 * sin(ka1 - ka2) * (w1 * w1 * len1 * (mass1 + mass2) + g * (mass1 + mass2) * cos(ka1) + w2 * w2 * len2 * mass2 * cos(ka1 - ka2));
  k /= (len2 * (2 * mass1 + mass2 - mass2 * cos(2*ka1 - 2*ka2)));
  return k;
}

float roundOff(float a) {
  return Math.round(a * 100.0) / 100.0;
}
