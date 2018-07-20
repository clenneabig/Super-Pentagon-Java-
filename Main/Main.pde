import java.util.Timer;

float mix = 0.5;
float dotSize = 10;
int side = 0;
float angle = 0;
float innerWidth = 50;
float speed = 0.02;
float wallSpeed;
ArrayList<Walls> walls = new ArrayList<Walls>();
ArrayList<Button> instructButtons = new ArrayList<Button>();
int numSides = 5;
float levelsNumSides;
PShape inner, path;
PVector target, start, pen;
boolean left, right;
boolean rotation = true;
boolean powerUp = true;
float level;
HighScore scoreEasy;
HighScore scoreHard;
State state = State.MENU;
State prevState;
StopWatchTimer timer = new StopWatchTimer();
PImage img, cogwheel, play, highscores;
PFont font;
PFont defau;
String easyScores = "highScoresEasy.txt";
String hardScores = "highScoresHard.txt";

void setup() {
  size(1200, 675);
  //Loading files for use
  img = loadImage("title.png");
  cogwheel = loadImage("Cogwheel.png");
  play = loadImage("play_button.png");
  highscores = loadImage("High_Score.png");
  font = loadFont("superHexagon.vlw");
  defau = loadFont("default.vlw");
  frameRate(60);
  startGame();
  textSize(12);
  //This makes and adds the buttons to the ArrayLists
  instructButtons.add(new Button(width/5, height/8-10, 150, 40, "< Main Menu") {
    public void click() {
      state = State.MENU;
    }
  }
  );
  instructButtons.add(new Button(width-width/4, height-height/8, 150, 40, "Next >") {
    public void click() {
      state = State.CONTROLS;
    }
  }
  );
  instructButtons.add(new Button(width/4, height-height/8, 150, 40, "< Prev") {
    public void click() {
      state = State.GOAL;
    }
  }
  );
  //Sets up the highscores
  scoreEasy = new HighScore(easyScores);
  scoreHard = new HighScore(hardScores);
  String[] variables = loadStrings("save.sav");
  level = Float.parseFloat(variables[0]);
  wallSpeed = Float.parseFloat(variables[1]);
  levelsNumSides = Float.parseFloat(variables[2]);
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
  doesn't give away what num of sides the next try will have*/
  if (state == State.GAME_OVER || state == State.LEVELS_MENU) numSides = 5;
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
  if (rotation) angle+=scaled(0.005);
  else if (!rotation) angle-=scaled(0.005);
  //These determine what method to run depending on which state
  if (state == State.GOAL) drawGoal();
  if (state == State.CONTROLS) drawControls();
  if (state == State.MENU) drawMenu();
  if (state == State.LEVELS_MENU) drawLevelMenu();
  if (state == State.LEVEL_UP) drawLevelUp();
  if (state == State.LEVELS_WIN) drawLevelWin();
  if (state == State.LEVEL_SELECT) drawLevelSelect();
  if (state == State.CREDITS) drawCredits();
  //This goes back to the main menu when the ESC key is pressed
  if (keyPressed && key == ESC) {
    stroke(0);
    state = State.MENU; 
    return;
  }
  if (state == State.SCORES1) drawHighScores();
  if (state == State.IN_GAME1 || state == State.IN_GAME2 || state == State.IN_GAME3) {
    stroke(150, 0, 250);
    noFill();
    textSize(12.0);
    drawGame();
  } 
  else if (state == State.GAME_OVER) {
    drawGameOver();
    if (keyPressed && key == ENTER) {
      //If the previous state was the Hard mode, make random number of sides for the middle shape if you press enter to retry
      if (prevState == State.IN_GAME2) numSides = (int) random(4, 8);
      if (prevState == State.IN_GAME3) numSides = (int) levelsNumSides;
      state = prevState;
      startGame();
    }
  }
}

void keyPressed() {
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
void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT) left = false;
    else if (keyCode == RIGHT) right = false;
  }
}

void drawLevelMenu(){
  List<Button> buttons = new ArrayList<Button>();
  buttons.add(new Button(width/5, height/8-10, 150, 40, "< Main Menu") {
    public void click() {
      state = State.MENU;
    }
  });
  buttons.add(new Button(width/2, height/2-60, 150, 40, "New Game") {
    public void click() {
      level = 1;
      wallSpeed = 1.8;
      numSides = 4;
      state = State.IN_GAME3;
      prevState = State.IN_GAME3;
      startGame();
    }
  });
  if(level != 1){
    buttons.add(new Button(width/2, height/2+60, 150, 40, "Load Game") {
      public void click() {
        numSides = (int) levelsNumSides;
        state = State.IN_GAME3;
        prevState = State.IN_GAME3;
        startGame();
      }
    });
  }
  String levels = "LEVELS";
  textFont(font);
  textSize(30);
  fill(255);
  text(levels, width/2-textWidth(levels)/2, height/8);
  textFont(defau);
  textSize(20);
  for(Button b : buttons){
    if (b.bounds.contains(mouseX, mouseY)) { 
      fill(150, 0, 250);
      if (mousePressed) b.click();
    } 
    else noFill();
    b.render();
  }
  textSize(30);
  fill(255);
}

void drawCredits(){
  Button mainMenu = new Button(width/5, height/8-10, 150, 40, "< Main Menu") {
    public void click() {
      state = State.MENU;
    }
  };
  String creditsPara = "Developer: Daniel Clennell\n" + 
                       "UI Designer: Dylan Wansbrough";
  String credits = "CREDITS";
  textFont(font);
  textSize(30);
  fill(255);
  text(credits, width/2-textWidth(credits)/2, height/8);
  textFont(defau);
  textSize(20);
  if (mainMenu.bounds.contains(mouseX, mouseY)) { 
    fill(150, 0, 250);
    if (mousePressed) mainMenu.click();
  } 
  else noFill();
  mainMenu.render();
  textSize(30);
  fill(255);
  text(creditsPara, width/4, (height/16)+80, width/2, height-height/4);
}

void drawMenu() {
  ArrayList<Button> mainButtons = new ArrayList<Button>();
  mainButtons.add(new Button(width/4, height/2, 150, 40, "Easy") { 
    //This tells the program what to do when the button is pressed
    public void click() {
      numSides = 5;
      state = State.IN_GAME1;
      prevState = State.IN_GAME1;
      startGame();
    }
  }
  );
  mainButtons.add(new Button(width/4, height/2+60, 150, 40, "Hard") {
    public void click() {
      numSides = 5;
      state = State.IN_GAME2;
      prevState = State.IN_GAME2;
      startGame();
    }
  }
  );
  mainButtons.add(new Button(width/4, height/2+120, 150, 40, "Levels"){
    public void click(){
      numSides = (int) levelsNumSides;
      state = State.LEVELS_MENU;
    }
  });
  mainButtons.add(new Button(width/2, height/2, 150, 40, "How To Play") { 
    public void click() {
      state = State.GOAL;
    }
  }
  );
  mainButtons.add(new Button(width/2, height/2+60, 150, 40, "Credits") { 
    public void click() {
      state = State.CREDITS;
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
  image(img, width/4-15, height/4);
  cogwheel.resize(0, 40);
  image(cogwheel, width/2-20, height/2-75);
  play.resize(0,40);
  image(play, width/4-14, height/2-75);
  highscores.resize(0,40);
  image(highscores, width-width/4-37, height/2-75);
  strokeWeight(2);
  stroke(255);
  line(width/2-75, height/2-25, width/2+75, height/2-25);
  line(width/4-75, height/2-25, width/4+75, height/2-25);
  line(width-width/4-75, height/2-25, width-width/4+75, height/2-25);
  strokeWeight(0);
  noStroke();
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

void drawGoal() {
  String goalPara = "The goal of the game is to move the white dot around the black pentagon whilst" + 
                    " avoiding the lines coming towards you. Try to get the longest time you can. In" + 
                    " easy mode, the walls move at a slower speed and the shape is always a pentagon." + 
                    " In hard mode, the walls move at a faster speed and the shape can range from a " + 
                    "square to an octogon. In levels mode, you will proceed through a series of levels " + 
                    "with increasing difficulty. It will save your progress each time you successfully " +
                    "complete a level";
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
    if (button.label.equals("< Prev")) continue;
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

void drawControls() {
  String controlPara = "Press the left and right arrows keys to move around the pentagon. Press F when the" + 
                       " power up is active to destroy the closest set of walls. The power up recharges every" + 
                       " time the colour changes. Pressing Esc at anytime will return you to the main menu." +
                       " Pressing Enter at the game over screen will restart the game in the current difficulty.";
  String controls = "CONTROLS";
  textFont(font);
  textSize(30);
  fill(255);
  text(controls, width/2-textWidth(controls)/2, height/8);
  textFont(defau);
  textSize(20);
  //This draws the buttons for the control screen
  for (Button button : instructButtons) {
    //This skips the Next button
    if (button.label.equals("Next >")) continue;
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

void drawGameOver() {
  ArrayList<Button> gameOverButtons = new ArrayList<Button>();
  gameOverButtons.add(new Button(width/2, height/2+60, 200, 50, "Retry"){
    public void click(){
      //If the previous state was the Hard mode, make random number of sides for the middle shape if you press click retry
      if (prevState == State.IN_GAME2) numSides = (int) random(4, 8);
      if (prevState == State.IN_GAME3) numSides = (int) levelsNumSides;
      state = prevState;
      startGame();
    }
  });
  gameOverButtons.add(new Button(width/2, height/2+140, 200, 50, "Main Menu"){
    public void click(){
      state = State.MENU;
    }
  });
  String gameOver = "Game Over";
  String mode = "";
  powerUp = true;
  String plural = " second";
  String pluralHigh = " second";
  if(timer.second() != 1) plural = " seconds";
  String time = "Your time: " + fixScore(timer.second()) + plural;
  String high = "";
  if(prevState == State.IN_GAME1 && scoreEasy.scores.size() != 0){
    if(scoreEasy.scores.get(0) != 1) pluralHigh = " seconds";
    high = "Your highscore: " + fixScore(scoreEasy.scores.get(0)) + pluralHigh;
    mode = "Easy";
  }
  else if(prevState == State.IN_GAME2 && scoreHard.scores.size() != 0){
    if(scoreHard.scores.get(0) != 1) pluralHigh = " seconds";
    high = "Your highscore: " + fixScore(scoreHard.scores.get(0)) + pluralHigh;
    mode = "Hard";
  }
  else if(prevState == State.IN_GAME3){
    high =  "Your level: " + int(level);
    mode = "Levels";
  }
  textSize(50);
  fill(255);
  text(mode, width/2-textWidth(mode)/2, height/8);
  if(prevState != State.IN_GAME3) text(time, width/2-textWidth(time)/2, height/4);
  text(high, width/2-textWidth(high)/2, height/4+50);
  textSize(20);
  textFont(font);
  colorMode(HSB, 360, 100, 100);
  fill(283, 100, 100);
  text(gameOver, width/2-textWidth(gameOver)/2, height/2); 
  colorMode(RGB, 255, 255, 255);
  textFont(defau);
  textSize(30);
  fill(255);
  for (Button button : gameOverButtons) {
    if (button.bounds.contains(mouseX, mouseY)) { 
      fill(150, 0, 250);
      if (mousePressed) button.click();
    } 
    else noFill();
    button.render();
  }
  textSize(12.0);
}

void drawHighScores() {
  String highScores = "HIGH SCORES";
  textFont(font);
  textSize(30);
  fill(255);
  text(highScores, width/2-textWidth(highScores)/2, height/8);
  textFont(defau);
  textSize(20);
  //This draws the button for the highscores screen
  Button mainMenu = new Button(width/5, height/8-10, 150, 40, "< Main Menu") {
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
  text("Hard", width-width/4-80, (height/16)+80, 3*width/4, height-height/4);
  //This displays the highscores from the text file
  for (Float time : scoreHard.scores) {
    text(i + ". " + fixScore(time), 3*width/4-80, ((i+1)*height/16)+80, 3*width/4, height-height/4);
    i++;
  }
}

void drawLevelUp(){}

void drawLevelWin(){}

void drawLevelSelect(){}

void drawGame() {
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
        wall.drawWalls(1.5);
      }
      else if(state == State.IN_GAME2){
        wall.drawWalls(2);
      }
      else if(state == State.IN_GAME3){
        wall.drawWalls(wallSpeed);
      }
    }
    if (state == State.IN_GAME3 && (int) (timer.second()) / 30 == 1) {
        powerUp = true;
        timer.stop();
        if(level < 15){ 
          level++;
          if(wallSpeed < 2.0) wallSpeed += 0.1;
          else if (numSides < 8){
            wallSpeed = 1.8;
            levelsNumSides++;
          }
          state = State.LEVEL_UP;
        }
        else state = State.LEVELS_WIN;
        saveLevel();
        return;  
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
  else if(state == State.IN_GAME3){
    text("Level", 100, 80);
    textFont(font);
    textSize(30);
    text(int(level), 100, 125);
  }
  textFont(defau);
  textSize(25);
  text("Power Up (F)", (width/2)-50, 80);
  textFont(font);
  textSize(30);
  if (powerUp) text("Active", (width/2)-50, 125); 
  else if (!powerUp) text("Inactive", (width/2)-50, 125);
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
String fixScore(float f) {
  return String.format("%.2f", f);
}

void saveLevel(){
  String[] variables = new String[3];
  variables[0] = level + "";
  variables[1] = wallSpeed + "";
  variables[2] = levelsNumSides + "";
  saveStrings("data/save.sav", variables);
}
