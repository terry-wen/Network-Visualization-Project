/*
Connection between nodes representing connection between IPs. 
Contains flow and is manipulated by node positions.

@author: terrywen
*/

class Link{
  float offset = 0;
  Node a, b;
  color proto = 0;
  float x1, y1, x2, y2, dashCount, lineAngle; //animation vars
  boolean drawn = false;
  boolean selected = false;
  float alpha = 0;                            //opacity
  float startTime, endTime;
  Flow flow;
  
  Link(Node _a, Node _b) {
    a = _a;
    b = _b;
    startTime = 99999;
    endTime = 0;
    flow = new Flow(a, b);
    flow.parent = this;
  }
  
  void draw(float time) {
    strokeWeight(1);
    if(btwnTime(time)) {
      //appear animation
      if(!drawn){
        stroke(proto, alpha);
        alpha += 51;
        if(alpha == 255)
          drawn = true;
      }
      else
        stroke(proto);
    }
    else{
      //disappear animation
      if(drawn) {
        stroke(proto, alpha);
        alpha -= 51;
        if(alpha == 0)
          drawn = false;
      }
    }
    stroke(0);
    drawConnection(a, b);
    drawConnection(b, a);
    if(selected) {
      stroke(255, 150);
      strokeWeight(4);
      line(a.pos.x, a.pos.y, b.pos.x, b.pos.y);
    }
    
    flow.draw(time);
    
    if(!drawn) {
      selected = false;
    }
    //animation control
    if(offset >= 10) {
      offset = 0;
    } else {
      offset += .05;  
    }
  }
  
  //checks for display
  boolean btwnTime(float time) {
    if(time >= startTime && time <= endTime)
      return true;
    else
      return false;
  }
  
  //connection animation
  void drawConnection(Node from, Node to) {
    if(sqrt((from.pos.x - to.pos.x)*(from.pos.x - to.pos.x) + (from.pos.y - to.pos.y)*(from.pos.y-to.pos.y)) >= (from.d + to.d)/2) {
      x1 = from.pos.x;
      y1 = from.pos.y;
      x2 = to.pos.x;
      y2 = to.pos.y;
      dashCount = sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))/5;
      lineAngle = atan((y2-y1)/(x2-x1));
      for(int i = 0; i < dashCount; i += 2)
      {
        if(x1 <= x2) {
          if(x1 + (((i + offset)+.5)*cos(lineAngle)*5) <= x2 && ((y1 + (((i + offset)+.5)*sin(lineAngle))*5 <= y2 && y1 <= y2) || (y1 + (((i + offset)+.5)*sin(lineAngle))*5 >= y2 && y1 >= y2)))
            line(x1 + ((i + offset)*cos(lineAngle)*5), y1 + ((i + offset)*sin(lineAngle)*5), x1 + (((i + offset)+.5)*cos(lineAngle)*5), y1 + (((i + offset)+.5)*sin(lineAngle))*5);
          else
            line(x1 + (((i - dashCount) + offset)*cos(lineAngle)*5), y1 + (((i - dashCount) + offset)*sin(lineAngle)*5), x1 + ((((i - dashCount) + offset)+.5)*cos(lineAngle)*5), y1 + ((((i - dashCount) + offset)+.5)*sin(lineAngle))*5);
        }
        else {
          if(x2 + (((i - offset)+.5)*cos(lineAngle)*5) >= x2 && ((y2 + (((i - offset)+.5)*sin(lineAngle))*5 >= y2 && y2 <= y1) || (y2 + (((i - offset)+.5)*sin(lineAngle))*5 <= y2 && y2 >= y1)))
            line(x2 + ((i - offset)*cos(lineAngle)*5), y2 + ((i - offset)*sin(lineAngle)*5), x2 + (((i - offset)-.5)*cos(lineAngle)*5), y2 + (((i - offset)-.5)*sin(lineAngle))*5);
          else
            line(x2 + ((dashCount + i - offset)*cos(lineAngle)*5), y2 + ((dashCount + i - offset)*sin(lineAngle)*5), x2 + (((dashCount + i - offset)-.5)*cos(lineAngle)*5), y2 + (((dashCount + i - offset)-.5)*sin(lineAngle))*5);
        }
      }
    }
  }
  
  //checks for existence
  boolean check(Node node1, Node node2) {
    if((node1 == a && node2 == b) || (node2 == a && node1 == b)) {
      return true;
    } else {
      return false;
    }
  }
  
  //link selection
  boolean select(int mx, int my) {
    float u = .2;
    float slope = (b.pos.y-a.pos.y)/(b.pos.x-a.pos.x);
    boolean btx = ((mx >= a.pos.x - 10) && (mx <= b.pos.x + 10)) || ((mx >= b.pos.x - 10) && (mx <= a.pos.x + 10));
    boolean bty = ((my >= a.pos.y - 10) && (my <= b.pos.y + 10)) || ((my >= b.pos.y - 10) && (my <= a.pos.y + 10));
    float slopea = (a.pos.y - my)/(a.pos.x - mx);
    float slopeb = (b.pos.y - my)/(b.pos.x - mx);
    boolean online = ((slopeb <= slope + u) && (slopeb >= slope - u)) || ((slopea <= slope + u) && (slopea >= slope - u));
    if (btx && (online || (bty && ((a.pos.x - b.pos.x) <= 25)))) {
      return true;
    } else {
      selected = false;
      return false;
    }
  }
}
