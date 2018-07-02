import java.util.Timer;
float mix = 0.5;
float dotSize = 10;
int side = 0;
float angle = 0;
float innerWidth = 50;
float pathWidth = 60;
float speed = 0.02;
ArrayList<Walls> walls = new ArrayList<Walls>();
ArrayList<Button> mainButtons = new ArrayList<Button>();
ArrayList<Button> instructButtons = new ArrayList<Button>();
ArrayList<Button> highButtons = new ArrayList<Button>();
int numSides = 5;
PShape inner, path;
PVector target, start, pen;
boolean left, right;
boolean rotation = true;
boolean powerUp = true;
HighScore scoreEasy;
HighScore scoreHard;
int section = 0;
State state = State.MENU;
State prevState;
StopWatchTimer timer = new StopWatchTimer();
PImage img;
PFont font;
PFont defau;
String titleText = "SUPER PENTAGON!";
String keyBindings = "Press Enter to retry. Press Esc to go back to the main menu.";
String gameOver = "Game Over";
String goal = "GOAL";
String easyScores = "highScoresEasy.txt";
String hardScores = "highScoresHard.txt";
String highScores = "HIGH SCORES";
String controls = "CONTROLS & ITEMS";
String goalPara = "The goal of the game is to move the white dot around the black pentagon whilst avoiding the lines coming towards you. Try to get the longest time you can. In easy mode, the walls move at a slower speed and the shape is always a pentagon. In hard mode, the walls move at a faster speed and the shape can range from a square to an octogon.";
String controlPara = "Press the left and right arrows keys to move around the pentagon. Press F when the power up is active to destroy the closest set of walls. The power up recharges every time the colour changes. Pressing Esc at anytime will return you to the main menu.";

void setup() {
  size(1200, 675);
  //Loading files for use
  img = loadImage("title.png");
  font = loadFont("superHexagon.vlw");
  defau = loadFont("default.vlw");
  frameRate(60);
  startGame();
  textSize(12.0);
  stroke(0);
  //This makes and adds the buttons to the ArrayLists
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
  highButtons.add(new Button(width/5, height/8-10, 150, 40, "Main Menu") {
    public void click() {
      state = State.MENU;
    }
  }
  );
  highButtons.add(new Button(width-width/4, height-height/8, 150, 40, "Next") {
    public void click() {
      state = State.SCORES2;
    }
  }
  );
  highButtons.add(new Button(width/4, height-height/8, 150, 40, "Prev") {
    public void click() {
      state = State.SCORES1;
    }
  }
  );
  //Sets up the highscores
  scoreEasy = new HighScore(easyScores);
  scoreHard = new HighScore(hardScores);
}

void startGame() {
  //Sets ups variables for the start of the game
  divisor = 1;
  side = 0;
  hue = 274;
  speed = (0.02/5)*numSides;
  stroke(0);
  fill(0);
  //This creates the 2 shapes. The shape in the middle that you can see, and the shape that the dot follows.
  inner = createShape();
  path = createShape();
  //This draws the 2 shapes
  polygon(0, 0, innerWidth, numSides, inner);
  polygon(0, 0, pathWidth, numSides, path);
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
void assignEdge() { 
  start = path.getVertex(side);
  target = path.getVertex((side+1)%numSides);
}

//This scales numbers to work with the frame rate
float scaled(float value) {
  return (350.0/frameRate)*value;
}

void draw() {
  /*This is so that when playing hard, the background at the game over screen
  doesn't give away when num of sides the next try will has*/
  if (state == State.GAME_OVER) {
    numSides = 5;
  }
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
  if (random == 85) {
    rotation = false;
  } else if (random == 65) {
    rotation = true;
  }
  //This rotates the background
  if (rotation) {
    angle+=scaled(0.005);
  } else if (!rotation) {
    angle-=scaled(0.005);
  }
  //These determine what method to run depending on which state
  if (state == State.GOAL) {
    drawGoal();
  }
  if (state == State.CONTROLS) {
    drawControls();
  }
  if (state == State.MENU) {
    drawMenu();
  }
  //This goes back to the main menu when the ESC key is pressed
  if (keyPressed && key == ESC) {
    stroke(0);
    state = State.MENU; 
    return;
  }
  if (state == State.SCORES1) {
    drawHighScoresEasy();
  }
  if (state == State.SCORES2) {
    drawHighScoresHard();
  }
  if (state == State.IN_GAME1) {
    stroke(150, 0, 250);
    noFill();
    textSize(12.0);
    drawGameEasy();
  } else if (state == State.IN_GAME2) {
    stroke(150, 0, 250);
    noFill();
    textSize(12.0);
    drawGameHard();
  } else if (state == State.GAME_OVER) {
    drawGameOver();
    if (keyPressed && key == ENTER) {
      //If the previous state was the Hard mode, make random number of sides for the middle shape if you press enter to retry
      if (prevState == State.IN_GAME2) {
        numSides = (int) random(4, 8);
      }
      state = prevState;
      startGame();
    }
  }
}

void keyPressed() {
  //Disable quit on esc
  if (key == ESC) {
    key = 0;
  }
  //Left and right for movement
  if (key == CODED) {
    if (keyCode == LEFT) {
      left = true;
    } else if (keyCode == RIGHT) {
      right = true;
    }
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
void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      left = false;
    } else if (keyCode == RIGHT) {
      right = false;
    }
  }
}

void drawMenu() {
  numSides = 5;
  textSize(50);
  image(img, width/4-15, height/4);
  textSize(20);
  //This draws the buttons for the menu
  for (Button button : mainButtons) {
    if (button.bounds.contains(mouseX, mouseY)) { 
      fill(150, 0, 250);
      if (mousePressed) {
        button.click();
      }
    } else {
      noFill();
    }
    button.render();
  }
}

void drawGoal() {
  textFont(font);
  textSize(30);
  fill(255);
  text(goal, width/2-textWidth(goal)/2, height/8);
  textFont(defau);
  textSize(20);
  //This draws the buttons for the goal screen
  for (Button button : instructButtons) {
    //This skips the Prev button
    if (button.label.equals("Prev")) {
      continue;
    }
    if (button.bounds.contains(mouseX, mouseY)) { 
      fill(150, 0, 250);
      if (mousePressed) {
        button.click();
      }
    } else {
      noFill();
    }
    button.render();
  }
  textSize(30);
  fill(255);
  text(goalPara, width/4, (height/16)+80, width/2, height-height/4);
}

void drawControls() {
  textFont(font);
  textSize(30);
  fill(255);
  text(controls, width/2-textWidth(controls)/2, height/8);
  textFont(defau);
  textSize(20);
  //This draws the buttons for the control screen
  for (Button button : instructButtons) {
    //This skips the Next button
    if (button.label.equals("Next")) {
      continue;
    }
    if (button.bounds.contains(mouseX, mouseY)) { 
      fill(150, 0, 250);
      if (mousePressed) {
        button.click();
      }
    } else {
      noFill();
    }
    button.render();
  }
  textSize(30);
  fill(255);
  text(controlPara, width/4, (height/16)+80, width/2, height-height/4);
}

void drawGameOver() {
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
  textSize(12.0);
}

void drawHighScoresEasy() {
  textFont(font);
  textSize(30);
  fill(255);
  text(highScores, width/2-textWidth(highScores)/2, height/8);
  textFont(defau);
  textSize(20);
  //This draws the buttons for the easy highscores screen
  for (Button button : highButtons) {
    //This skips the Prev button
    if (button.label.equals("Prev")) {
      continue;
    }
    if (button.bounds.contains(mouseX, mouseY)) { 
      fill(150, 0, 250);
      if (mousePressed) {
        button.click();
      }
    } else {
      noFill();
    }
    button.render();
  }
  textSize(30);
  fill(255);
  int i = 1;
  text("Easy", width/2-80, (height/16)+80, width/2, height-height/4);
  //This displays the scoress from the text file
  for (Float time : scoreEasy.scores) {
    text(i + ". " + fixScore(time), width/2-80, ((i+1)*height/16)+80, width/2, height-height/4);
    i++;
  }
}

void drawHighScoresHard() {
  textFont(font);
  textSize(30);
  fill(255);
  text(highScores, width/2-textWidth(highScores)/2, height/8);
  textFont(defau);
  textSize(20);
  //This draws the buttons for the hard highscores screen
  for (Button button : highButtons) {
    //This skips the Next button
    if (button.label.equals("Next")) {
      continue;
    }
    if (button.bounds.contains(mouseX, mouseY)) { 
      fill(150, 0, 250);
      if (mousePressed) {
        button.click();
      }
    } else {
      noFill();
    }
    button.render();
  }
  textSize(30);
  fill(255);
  int i = 1;
  text("Hard", width/2-80, (height/16)+80, width/2, height-height/4);
  //This displays the highscores from the text file
  for (Float time : scoreHard.scores) {
    text(i + ". " + fixScore(time), width/2-80, ((i+1)*height/16)+80, width/2, height-height/4);
    i++;
  }
}

void drawGameEasy() {
  pushMatrix(); 
  {
    //This allows the dot to move left and right around the shape
    if (left) {
      mix-=scaled(speed);
    } 
    if (right) {
      mix+=scaled(speed);
    }
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
        scoreEasy.addTime(timer.second(), easyScores);
        state = State.GAME_OVER;
        return;
      }
      wall.drawWalls(1.5);
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
    } else if (mix < 0) {
      mix = 1;
      side--;
      if (side < 0) {
        side = numSides-1;
      }
      assignEdge();
    } else {
      pen = PVector.lerp(start, target, mix);
    }
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
  if (scoreEasy.scores.size() != 0) {
    text("High Score", 100, 80);
  }
  textFont(font);
  textSize(30);
  if (scoreEasy.scores.size() != 0) {
    text(fixScore(scoreEasy.scores.get(0)), 100, 125);
  }
  textFont(defau);
  textSize(25);
  text("Power Up", (width/2)-50, 80);
  textFont(font);
  textSize(30);
  if (powerUp) {
    text("Active", (width/2)-50, 125);
  } else if (!powerUp) {
    text("Inactive", (width/2)-50, 125);
  }
  textFont(defau);
}

void drawGameHard() {
  pushMatrix(); 
  {
    //This allows the dot to move left and right around the shape
    if (left) {
      mix-=scaled(speed);
    } 
    if (right) {
      mix+=scaled(speed);
    }
    translate(width/2, height/2);
    rotate(angle);
    noStroke();
    noFill();

    //visible pentagon
    stroke(150, 0, 250);
    shape(inner);
    //Collision detection
    for (Walls wall : walls) {
      if (wall.collided()) {
        timer.stop();
        //This adds the score to the text file
        scoreHard.addTime(timer.second(), hardScores);
        state = State.GAME_OVER;
        return;
      }
      wall.drawWalls(2);
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
    } else if (mix < 0) {
      mix = 1;
      side--;
      if (side < 0) {
        side = numSides-1;
      }
      assignEdge();
    } else {
      pen = PVector.lerp(start, target, mix);
    }
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
  if (scoreHard.scores.size() != 0) {
    text("High Score", 100, 80);
  }
  textFont(font);
  textSize(30);
  if (scoreHard.scores.size() != 0) {
    text(fixScore(scoreHard.scores.get(0)), 100, 125);
  }
  textFont(defau);
  textSize(25);
  text("Power Up", width/2, 80);
  textFont(font);
  textSize(30);
  if (powerUp) {
    text("Active", width/2, 125);
  } else if (!powerUp) {
    text("Inactive", width/2, 125);
  }
  textFont(defau);
}

//https://processing.org/examples/regularpolygon.html
void polygon(float x, float y, float radius, int npoints, PShape to) {
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
void triangleFan(float x, float y, float radius, int npoints) {
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
    } else {
      fill(274, 100, stroke+(angle/a*25));
    }
    float sx = cos(a) * radius;
    float sy = sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
  //This makes the screen seem to pulsate
  if (stroke > 54) {
    offset = -(abs(offset));
  }
  if (stroke < 40) {
    offset = abs(offset);
  }
  if (random(0, 100) > 60) {
    stroke+=offset;
  }
  colorMode(RGB, 255, 255, 255);
}

//This formats the time to 2 decimal points
String fixScore(float f) {
  return String.format("%.2f", f);
}