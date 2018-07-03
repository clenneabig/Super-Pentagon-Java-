import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Timer; 
import java.awt.*; 
import java.awt.geom.*; 
import java.util.Collections; 
import java.util.List; 
import java.util.Random; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Main extends PApplet {



float mix = 0.5f;
float dotSize = 10;
int side = 0;
float angle = 0;
float innerWidth = 50;
float speed = 0.02f;
ArrayList<Walls> walls = new ArrayList<Walls>();
ArrayList<Button> instructButtons = new ArrayList<Button>();
int numSides = 5;
PShape inner, path;
PVector target, start, pen;
boolean left, right;
boolean rotation = true;
boolean powerUp = true;
HighScore scoreEasy;
HighScore scoreHard;
State state = State.MENU;
State prevState;
StopWatchTimer timer = new StopWatchTimer();
PImage img;
PFont font;
PFont defau;
String easyScores = "highScoresEasy.txt";
String hardScores = "highScoresHard.txt";

public void setup() {
  
  //Loading files for use
  img = loadImage("title.png");
  font = loadFont("superHexagon.vlw");
  defau = loadFont("default.vlw");
  frameRate(60);
  startGame();
  textSize(12.0f);
  stroke(0);
  //This makes and adds the buttons to the ArrayLists
  instructButtons.add(new Button(width/5, height/8-10, 150, 40, "Main Menu") {
    public void click() {
      state = State.MENU;
    }
  }
  );
  instructButtons.add(new Button(width-width/4, height-height/8, 150, 40, "Next") {
    public void click() {
      state = State.CONTROLS;
    }
  }
  );
  instructButtons.add(new Button(width/4, height-height/8, 150, 40, "Prev") {
    public void click() {
      state = State.GOAL;
    }
  }
  );
  //Sets up the highscores
  scoreEasy = new HighScore(easyScores);
  scoreHard = new HighScore(hardScores);
}

public void startGame() {
  //Sets ups variables for the start of the game
  divisor = 1;
  side = 0;
  hue = 274;
  speed = (0.02f/5)*numSides;
  stroke(0);
  fill(0);
  //This creates the 2 shapes. The shape in the middle that you can see, and the shape that the dot follows.
  inner = createShape();
  path = createShape();
  //This draws the 2 shapes
  polygon(0, 0, innerWidth, numSides, inner);
  polygon(0, 0, 60, numSides, path);
  assignEdge();
  pen = start.copy();
  //This adds the Walls objects to the ArrayList
  walls.clear();
  walls.add(new Walls(width));
  walls.add(new Walls(width+width/3));
  walls.add(new Walls(width+width/3*2));
  timer.start();
}

//This method is for moving the dot, it lets the dot move around the shape
public void assignEdge() { 
  start = path.getVertex(side);
  target = path.getVertex((side+1)%numSides);
}

//This scales numbers to work with the frame rate
public float scaled(float value) {
  return (350.0f/frameRate)*value;
}

public void draw() {
  /*This is so that when playing hard, the background at the game over screen
  doesn't give away when num of sides the next try will has*/
  if (state == State.GAME_OVER) numSides = 5;
  //This is for the background, it allows the triangle fan to spin while the menu stays still
  pushMatrix();
  {
    translate(width/2, height/2);
    rotate(angle);
    triangleFan(0, 0, width, numSides);
  }
  popMatrix();
  //This lets the background randomly rotate left and right
  int random = (int) (Math.random()*100);
  if (random == 85) rotation = false;
  else if (random == 65) rotation = true;
  //This rotates the background
  if (rotation) angle+=scaled(0.005f);
  else if (!rotation) angle-=scaled(0.005f);
  //These determine what method to run depending on which state
  if (state == State.GOAL) drawGoal();
  if (state == State.CONTROLS) drawControls();
  if (state == State.MENU) drawMenu();
  //This goes back to the main menu when the ESC key is pressed
  if (keyPressed && key == ESC) {
    stroke(0);
    state = State.MENU; 
    return;
  }
  if (state == State.SCORES1) drawHighScores();
  if (state == State.IN_GAME1 || state == State.IN_GAME2) {
    stroke(150, 0, 250);
    noFill();
    textSize(12.0f);
    drawGame();
  } 
  else if (state == State.GAME_OVER) {
    drawGameOver();
    if (keyPressed && key == ENTER) {
      //If the previous state was the Hard mode, make random number of sides for the middle shape if you press enter to retry
      if (prevState == State.IN_GAME2) numSides = (int) random(4, 8);
      state = prevState;
      startGame();
    }
  }
}

public void keyPressed() {
  //Disable quit on esc
  if (key == ESC) key = 0;
  //Left and right for movement
  if (key == CODED) {
    if (keyCode == LEFT) left = true;
    else if (keyCode == RIGHT) right = true;
  }
  //Press F for power up
  if (key == 'f') {
    if (powerUp) {
      int rad = 9999;
      int index = 9999;
      int in = 0;
      //This goes through and finds the wall with the smallest radius
      for (int i = 0; i < walls.size(); i++) {
        if (walls.get(i).radius < rad) {
          index = i;
          rad = walls.get(i).getRadius();
        }
      }
      //This makes all the walls in the closest set to be set to false
      boolean[] waves = walls.get(index).getWalls();
      while (in < numSides) {
        waves[in] = false;
        in++;
      }
      powerUp = false;
    }
  }
}

/*Having a boolean for left and right allows the program to not have a delay between pressing the button and moving around.
 It also allows the program to deal with pressing both left and right at the same time*/
public void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT) left = false;
    else if (keyCode == RIGHT) right = false;
  }
}

public void drawMenu() {
  ArrayList<Button> mainButtons = new ArrayList<Button>();
  mainButtons.add(new Button(width/4, height/2, 150, 40, "Easy") { 
    //This tells the program what to do when the button is pressed
    public void click() {
      state = State.IN_GAME1;
      prevState = State.IN_GAME1;
      startGame();
    }
  }
  );
  mainButtons.add(new Button(width/4, height/2+60, 150, 40, "Hard") {
    public void click() {
      state = State.IN_GAME2;
      prevState = State.IN_GAME2;
      startGame();
    }
  }
  );
  mainButtons.add(new Button(width/2, height/2, 150, 40, "How To Play") { 
    public void click() {
      state = State.GOAL;
    }
  }
  );
  mainButtons.add(new Button(width-width/4, height/2, 150, 40, "Highscores") {
    public void click() {
      state = State.SCORES1;
    }
  }
  );
  numSides = 5;
  textSize(50);
  image(img, width/4-15, height/4);
  textSize(20);
  //This draws the buttons for the menu
  for (Button button : mainButtons) {
    if (button.bounds.contains(mouseX, mouseY)) { 
      fill(150, 0, 250);
      if (mousePressed) button.click();
    } 
    else noFill();
    button.render();
  }
}

public void drawGoal() {
  String goalPara = "The goal of the game is to move the white dot around the black pentagon whilst" + 
                    " avoiding the lines coming towards you. Try to get the longest time you can. In" + 
                    " easy mode, the walls move at a slower speed and the shape is always a pentagon." + 
                    " In hard mode, the walls move at a faster speed and the shape can range from a square to an octogon.";
  String goal = "GOAL";
  textFont(font);
  textSize(30);
  fill(255);
  text(goal, width/2-textWidth(goal)/2, height/8);
  textFont(defau);
  textSize(20);
  //This draws the buttons for the goal screen
  for (Button button : instructButtons) {
    //This skips the Prev button
    if (button.label.equals("Prev")) continue;
    if (button.bounds.contains(mouseX, mouseY)) { 
      fill(150, 0, 250);
      if (mousePressed) button.click();
    } 
    else noFill();
    button.render();
  }
  textSize(30);
  fill(255);
  text(goalPara, width/4, (height/16)+80, width/2, height-height/4);
}

public void drawControls() {
  String controlPara = "Press the left and right arrows keys to move around the pentagon. Press F when the" + 
                       " power up is active to destroy the closest set of walls. The power up recharges every" + 
                       " time the colour changes. Pressing Esc at anytime will return you to the main menu.";
  String controls = "CONTROLS & ITEMS";
  textFont(font);
  textSize(30);
  fill(255);
  text(controls, width/2-textWidth(controls)/2, height/8);
  textFont(defau);
  textSize(20);
  //This draws the buttons for the control screen
  for (Button button : instructButtons) {
    //This skips the Next button
    if (button.label.equals("Next")) continue;
    if (button.bounds.contains(mouseX, mouseY)) { 
      fill(150, 0, 250);
      if (mousePressed) button.click();
    } 
    else noFill();
    button.render();
  }
  textSize(30);
  fill(255);
  text(controlPara, width/4, (height/16)+80, width/2, height-height/4);
}

public void drawGameOver() {
  String keyBindings = "Press Enter to retry. Press Esc to go back to the main menu.";
  String gameOver = "Game Over";
  powerUp = true;
  String time = "Your time: " + fixScore(timer.second()) + " seconds";
  textSize(50);
  fill(255);
  text(time, width/2-textWidth(time)/2, height/4);
  textSize(20);
  textFont(font);
  colorMode(HSB, 360, 100, 100);
  fill(283, 100, 100);
  text(gameOver, width/2-textWidth(gameOver)/2, height/2); 
  colorMode(RGB, 255, 255, 255);
  textFont(defau);
  textSize(30);
  fill(255);
  text(keyBindings, width/2 - textWidth(keyBindings)/2, height-height/4);
  textSize(12.0f);
}

public void drawHighScores() {
  String highScores = "HIGH SCORES";
  textFont(font);
  textSize(30);
  fill(255);
  text(highScores, width/2-textWidth(highScores)/2, height/8);
  textFont(defau);
  textSize(20);
  //This draws the button for the highscores screen
  Button mainMenu = new Button(width/5, height/8-10, 150, 40, "Main Menu") {
    public void click() {
      state = State.MENU;
    }
  };
  if (mainMenu.bounds.contains(mouseX, mouseY)) { 
    fill(150, 0, 250);
    if (mousePressed) mainMenu.click();
  } 
  else noFill();
  mainMenu.render();
  textSize(30);
  fill(255);
  int i = 1;
  text("Easy", width/4-80, (height/16)+80, width/4, height-height/4);
  //This displays the scoress from the text file
  for (Float time : scoreEasy.scores) {
    text(i + ". " + fixScore(time), width/4-80, ((i+1)*height/16)+80, width/4, height-height/4);
    i++;
  }
  i = 1;
  text("Hard", 3*width/4-80, (height/16)+80, 3*width/4, height-height/4);
  //This displays the highscores from the text file
  for (Float time : scoreHard.scores) {
    text(i + ". " + fixScore(time), 3*width/4-80, ((i+1)*height/16)+80, 3*width/4, height-height/4);
    i++;
  }
}

public void drawGame() {
  pushMatrix(); 
  {
    //This allows the dot to move left and right around the shape
    if (left) mix-=scaled(speed);
    if (right) mix+=scaled(speed);
    translate(width/2, height/2);
    rotate(angle);
    noStroke();
    noFill();

    //visible pentagon
    shape(inner);
    //Collision detection
    for (Walls wall : walls) {
      if (wall.collided()) {
        timer.stop();
        //This adds the time to the text file
        if(state == State.IN_GAME1){
          scoreEasy.addTime(timer.second(), easyScores); 
        }
        else if(state == State.IN_GAME2){
          scoreHard.addTime(timer.second(), hardScores);
        }
        state = State.GAME_OVER;
        return;
      }
      if(state == State.IN_GAME1){
        wall.drawWalls(1.5f);
      }
      else if(state == State.IN_GAME2){
        wall.drawWalls(2);
      }
    }
    stroke(255);
    fill(255);

    //Pentagon dot
    ellipse(pen.x, pen.y, dotSize, dotSize);

    //If statements for dot movement
    if (mix > 1) {
      mix = 0;
      side=(++side)%numSides;
      assignEdge();
    } 
    else if (mix < 0) {
      mix = 1;
      side--;
      if (side < 0) side = numSides-1;
      assignEdge();
    } 
    else pen = PVector.lerp(start, target, mix);
  }
  popMatrix();
  //This draws the text on the screen
  textSize(25);
  text("Your time", width-200, 80);
  textFont(font);
  textSize(30);
  text(fixScore(timer.second()), width-200, 125);
  textFont(defau);
  textSize(25);
  if(state == State.IN_GAME1){
    if (scoreEasy.scores.size() != 0) text("High Score", 100, 80);
    textFont(font);
    textSize(30);
    if (scoreEasy.scores.size() != 0) text(fixScore(scoreEasy.scores.get(0)), 100, 125);
  }
  else if(state == State.IN_GAME2){
    if (scoreHard.scores.size() != 0) text("High Score", 100, 80);
    textFont(font);
    textSize(30);
    if (scoreHard.scores.size() != 0) text(fixScore(scoreHard.scores.get(0)), 100, 125);
  }
  textFont(defau);
  textSize(25);
  text("Power Up", (width/2)-50, 80);
  textFont(font);
  textSize(30);
  if (powerUp) text("Active", (width/2)-50, 125); 
  else if (!powerUp) text("Inactive", (width/2)-50, 125);
  textFont(defau);
}

//https://processing.org/examples/regularpolygon.html
public void polygon(float x, float y, float radius, int npoints, PShape to) {
  float angle = TWO_PI / npoints;
  to.beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    to.vertex(sx, sy);
  }
  to.endShape(CLOSE);
}

/*This method is for drawing the background. It uses beingShape(TRIANGLE_FAN) to draw a triangle fan.
It changes colours every 30 seconds and also activates the power up everytime the colour changes.*/
float stroke = 54;
float offset = -2;
int divisor = 1;
int hue = 274;
public void triangleFan(float x, float y, float radius, int npoints) {
  colorMode(HSB, 360, 100, 100);
  float angle = TWO_PI / npoints;
  beginShape(TRIANGLE_FAN);
  noStroke();
  vertex(x, y);
  //This for loop draws the different vertexes for the fan. It also has the code to change colour every 30 secs
  for (float a = 0; a <= TWO_PI; a += angle) {
    if (state == State.IN_GAME1 || state == State.IN_GAME2) {
      //This changes the colour and acitvates the power up every 30 secs
      if ((int) (timer.second()) / 30 == divisor) {
        hue = (int) random(0, 360);
        divisor++;
        powerUp = true;
      }
      fill(hue, 100, stroke+(angle/a*25));
    } 
    else fill(274, 100, stroke+(angle/a*25));
    float sx = cos(a) * radius;
    float sy = sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
  //This makes the screen seem to pulsate
  if (stroke > 54) offset = -(abs(offset));
  if (stroke < 40) offset = abs(offset);
  if (random(0, 100) > 60) stroke+=offset;
  colorMode(RGB, 255, 255, 255);
}

//This formats the time to 2 decimal points
public String fixScore(float f) {
  return String.format("%.2f", f);
}


abstract class Button {
  Rectangle2D.Float bounds;
  String label;
  Button(float x, float y, float wid, float hei, String lab) {
    bounds = new Rectangle2D.Float(x-wid/2, y-hei/2, wid, hei);
    label = lab;
  }

  //This renders the button
  public void render() {
    rect(bounds.x, bounds.y, bounds.width, bounds.height);
    fill(255);
    text(label, bounds.x+(bounds.width-textWidth(label))/2, bounds.y+bounds.height/2+textAscent()*0.375f);
  }

  //This allows me to make the buttons do different things when they're clicked on
  public abstract void click();
}


//This loads the highscores from a file
class HighScore {
  List<Float> scores = new ArrayList<Float>();
  HighScore(String file) {
    String[] scoresLoaded = loadStrings(file);
    for (String score : scoresLoaded) {
      scores.add(Float.parseFloat(score));
    }
    sortTimes();
  }
  
  //This sorts the scores from highest to lowest
  public void sortTimes() {
    Collections.sort(scores, Collections.reverseOrder());
  }
  
  //This only adds a time to the file if it is at least greater than the smallest time in the file
  public void addTime(float time, String file) {
    scores.add(time);
    sortTimes();
    scores = scores.subList(0,Math.min(10,scores.size()));
    saveTimes(file);
  }
  
  //This saves the times to a file
  public void saveTimes(String file) {
    String[] times = new String[scores.size()];
    for(int i = 0; i < scores.size(); i++) {
      times[i] = scores.get(i) + "";
    }
    saveStrings("data/"+file, times);
  }
}
enum State {
  IN_GAME1, IN_GAME2, MENU, GAME_OVER, GOAL, CONTROLS, SCORES1
}
class StopWatchTimer {
  int startTime = 0;
  int stopTime = 0;
  boolean running = false; 

  public void start() {
    startTime = millis();
    running = true;
  }

  public void stop() {
    stopTime = millis();
    running = false;
  }

  public int getElapsedTime() {
    int elapsed;
    if (running) {
      elapsed = (millis() - startTime);
    } else {
      elapsed = (stopTime - startTime);
    }
    return elapsed;
  }
  
  //This gets the elapsed time in seconds
  public float second() {
    return (getElapsedTime() / 1000.0f);
  }
}

class Walls {
  Random random = new Random();
  int radius = 0;
  boolean[] walls = new boolean[numSides];
  Walls(int radius) {
     this.radius = radius; 
  }
  
  //This is the method for collision detection
  public boolean collided() {
    if (radius < innerWidth + dotSize * 2.25f) {
      return walls[side];
    }
    return false;
  }

  public void drawWalls(float speed) {
    generateWalls(0, 0, radius, numSides, walls);
    radius -= scaled(speed);
    //This makes the line move back out to the outside of the screen if it makes it to the middle
    if (radius < innerWidth-10) {
      radius = width;
      int downSides = 0;
      //This randomly sets up the walls
      for (int i = 0; i < numSides; i++) {
        walls[i] = random.nextBoolean();
        if (walls[i]) {
          downSides++;
        }
      }
      //If there are no walls, make the first a wall
      if (downSides == 0) {
        walls[0] = true;
      }
      //If all are walls, make the first not a wall
      if (downSides == numSides) {
        walls[0] = false;
      }
    }
  }

  //Polygon generator : with boolean array for different walls
  public void generateWalls(float x, float y, float radius, int npoints, boolean[] sides) {
    float angle = TWO_PI / npoints;
    int i = 0;
    colorMode(HSB, 360, 100, 100);
    fill(hue+13,100,100);
    stroke(hue+13,100,100);
    for (float a = 0; a < TWO_PI; a += angle, i++) {
      if (sides[i%numSides]) {
        //These floats are all to make the walls look thicker than just lines
        float sx = x + cos(a) * radius;
        float sy = y + sin(a) * radius;
        float sx2 = x + cos(a+angle) * radius;
        float sy2 = y + sin(a+angle) * radius;
        float lx = x + cos(a) * (radius+30);
        float ly = y + sin(a) * (radius+30);
        float lx2 = x + cos(a+angle) * (radius+30);
        float ly2 = y + sin(a+angle) * (radius+30);
        beginShape();
        vertex(sx, sy);
        vertex(sx2, sy2);
        vertex(lx2, ly2);
        vertex(lx, ly);
        endShape();
      }
    }
    colorMode(RGB, 255, 255, 255);
  }
  
  public int getRadius() {
    return radius;
  }
  
  public boolean[] getWalls() {
    return walls;
  }
}
  public void settings() {  size(1200, 675); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Main" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
