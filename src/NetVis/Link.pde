/*
Connection between nodes representing connection between IPs. 
Contains flow and is manipulated by node positions.

@author: terrywen
*/

class Link {
  float offset = 0;
  Node a, b;
  color proto = 0;
  float x1, y1, x2, y2, dashCount, lineAngle; //animation vars
  boolean drawn = false;
  boolean flowDrawn = false;
  float alpha = 0;                            //opacity
  float startTime, endTime;
  ArrayList packets;
  boolean sending = false;
  float weight = 0;
  
  Link(Node _a, Node _b) {
    a = _a;
    b = _b;
    startTime = 99999;
    endTime = 0;
    packets = new ArrayList();
  }
  
  void addPacket(Packet p) {
    packets.add(p);
    p.link = this;
  }
  
  void setTimes(float time) {
    startTime = min(startTime, time - .25);
    endTime = max(endTime, time + .25);
    a.setTimes(time);
    b.setTimes(time);
  }
  
  void draw(float time, boolean selected) {
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
    
    drawFlow(time);
    
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
  
  void drawFlow(float time) {
    sending = false;
    weight = 0;
    stroke(proto);
    strokeWeight(0);
    //highlight if active
    for(Iterator it = packets.iterator(); it.hasNext();) {
      Packet p = (Packet) it.next();
      if(time >= p.timeStamp - .1 && time <= p.timeStamp + .1)
        sending = true;
    }
    if(sending) {
      //appear animation
      if(!flowDrawn){
        weight++;
        strokeWeight(weight);
        //stroke(proto, weight*(255/4));
        if(weight >= 2)
          drawn = true;
      }
      else
        strokeWeight(2);
    }
    else {
      //disappear animation
      if(flowDrawn) {
        weight--;
        strokeWeight(weight);
        //stroke(proto, weight*(255/4));
        if(weight <= 0)
          drawn = false;
      }
    }
    line(a.pos.x, a.pos.y, b.pos.x, b.pos.y);
  }
  
  //checks for display
  boolean btwnTime(float time) {
    return time >= startTime && time <= endTime;
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
    return (node1 == a && node2 == b) || (node2 == a && node1 == b);
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
    return btx && (online || (bty && ((a.pos.x - b.pos.x) <= 25)));
  }

  //upper timeline
  void drawTimeline(float time) {
    //draw packets
    for(Iterator it = packets.iterator(); it.hasNext();) {
      Packet p = (Packet) it.next();
      p.draw();
    }
    stroke(0);
    fill(0);
    strokeWeight(2);
    line(220, 35, width-220, 35);
    //labels
    textSize(9);
    text("To", 220, 10);
    text("To", 220, 65);
    fill(a.myColor);
    text(a.ip, 235, 10);
    fill(b.myColor);
    text(b.ip, 235, 65);
    fill(0);
    //timestamps
    text(Utils.timeFloatToString(startTime), 220, 45);
    text(Utils.timeFloatToString(endTime), width-273, 45);
    textSize(12);
    strokeWeight(1);
    stroke(#FF0000);
    float pos = max(225, (min(width - 225, 225 + (((time - startTime)/(endTime - startTime))*(width-450)))));
    line(pos, 0, pos, 70);
  }
}
