import java.awt.*;
import java.awt.geom.*;
abstract class Button {
  Rectangle2D.Float bounds;
  String label;
  Button(float x, float y, float wid, float hei, String lab) {
    bounds = new Rectangle2D.Float(x-wid/2, y-hei/2, wid, hei);
    label = lab;
  }

  //This renders the button
  void render() {
    rect(bounds.x, bounds.y, bounds.width, bounds.height);
    fill(255);
    text(label, bounds.x+(bounds.width-textWidth(label))/2, bounds.y+bounds.height/2+textAscent()*0.375);
  }

  //This allows me to make the buttons do different things when they're clicked on
  abstract void click();
}