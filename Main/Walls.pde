import java.util.Random;
class Walls {
  Random random = new Random();
  int radius = 0;
  boolean[] walls = new boolean[numSides];
  Walls(int radius) {
     this.radius = radius; 
  }
  
  //This is the method for collision detection
  boolean collided() {
    if (radius < innerWidth + dotSize * 2.25) {
      return walls[side];
    }
    return false;
  }

  void drawWalls(float speed) {
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
  void generateWalls(float x, float y, float radius, int npoints, boolean[] sides) {
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
  
  int getRadius() {
    return radius;
  }
  
  boolean[] getWalls() {
    return walls;
  }
}