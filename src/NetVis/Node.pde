/*
Node class that represents specific IP. Connected by links. Appears and disappears based upon activity.

@author: terrywen
*/

class Node {
  Vector pos, disp;
  boolean drawn = false;
  boolean dragging = false;
  boolean anchored = false;
  boolean locked = false;
  float startTime, endTime;
  float d = 20;
  float cd = 0;
  color myColor = #3683FF;
  float offsetX, offsetY;
  String ip;
  
  Node() {
    pos = new Vector(random(width/2-width/8,width/2+width/8),random(height/2-height/8,height/2+height/8));
    disp = new Vector();
    startTime = 9999999;
    endTime = 0;
  }
  
  //updates position on movement
  void update(){
    pos = pos.add(disp);
    disp.clear();
  } 
 
  void draw(float time, boolean selected) {
    if(anchored){
      stroke(0);
      strokeWeight(2);
    } else
      noStroke();
    fill(myColor);
    if(btwnTime(time) || locked) {
      //appear animation
      if(!drawn){
        cd++;
        ellipse(pos.x, pos.y, cd, cd);
        fill(0, 0);
        stroke(myColor, (d-cd)*(255/20));
        ellipse(pos.x, pos.y, cd*4, cd*4);
        if(cd >= d)
          drawn = true;
      } else {
        if (dragging)
          fill(#2865C7);
        else if (selected)
          fill(#17386E);
        else
          fill(myColor);
        ellipse(pos.x, pos.y, d, d);
        if(locked)
          fill(0);
          text("L", pos.x-3, pos.y+4);
      }
    } else {
      //disappear animation
      if(drawn) {
        cd--;
        ellipse(pos.x, pos.y, cd, cd);
        if(cd <= 0)
          drawn = false;
      }
    }
  }
  
  //for dragging
  boolean clicked(int mx, int my) {
    if (select(mx, my)) {
      dragging = true;
      offsetX = pos.x-mx;
      offsetY = pos.y-my;
      return true;
    }
    return false;
  }
  
  //for selection
  boolean select(int mx, int my) {
    return sqrt((pos.x-mx)*(pos.x-mx) + (pos.y-my)*(pos.y-my)) <= d/2;
  }
  
  void stopDragging() {
    dragging = false;
  }
  
  void drag(int mx, int my) {
    if (dragging) {
      pos.x = mx + offsetX;
      pos.y = my + offsetY;
    }
    constrain(90, width-90, 100, height-100);
  }
  
  //checks for display  
  boolean btwnTime(float time) {
    return time >= startTime && time <= endTime;
  }
  
  void setTimes(float time) {
    startTime = min(startTime, time - .25);
    endTime = max(endTime, time + .25);
  }
  
  //limits bounds on mvt
  void constrain(float x0, float x1,float y0, float y1){
    pos.x = min(x1, max(x0,pos.x));
    pos.y = min(y1, max(y0,pos.y));
  }
  
  String toString() {
    return ip;
  }
}
