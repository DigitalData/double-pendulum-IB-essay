import java.util.Date;
import java.util.ArrayList;
//import java.util.Timer;
import java.lang.Thread;

int w = 1500;
int h = 1000;
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
  size(1500, 1000);
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
    a1 = random(0, 2*PI);
    a2 = random(0, 2*PI);
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

  aa1 = ((-g)*(2 * mass1 + mass2)*(sin(a1))) - ((mass2 * g) * (sin(a1 - 2*a2))) - ((2*sin(a1 - a2)*mass2*(av2 * av2 * len2 + av1 * av1 * len1 * cos(a1-a2))));
  aa1 /= (len1 * (2 * mass1 + mass2 - mass2 * cos(2*a1 - 2*a2)));

  aa2 = 2 * sin(a1 - a2) * (av1 * av1 * len1 * (mass1 + mass2) + g * (mass1 + mass2) * cos(a1) + av2 * av2 * len2 * mass2 * cos(a1 - a2));
  aa2 /= (len2 * (2 * mass1 + mass2 - mass2 * cos(2*a1 - 2*a2)));

  av1 += aa1 * dt;
  av2 += aa2 * dt;

  a1 += av1 * dt;
  a2 += av2 * dt;
}

float roundOff(float a) {
  return Math.round(a * 100.0) / 100.0;
}
