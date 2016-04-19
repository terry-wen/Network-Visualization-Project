/*
Flow class attached to a specific link with data of all packets along said link.
Animates link using solid line.

@author: terrywen
*/

import java.util.Iterator;

class Flow{
  Node a, b;
  ArrayList packets;
  boolean drawn;
  boolean sending = false;
  float weight = 0;
  color proto;
  Link parent;
  
  Flow(Node _a, Node _b) {
    a = _a;
    b = _b;
    packets = new ArrayList();
  }
  
  void addPacket(Packet p) {
    packets.add(p);
    p.parent = this;
  }
  
  void draw(float time) {
    sending = false;
    stroke(proto);
    strokeWeight(0);
    //highlight if active
    for(Iterator it = packets.iterator(); it.hasNext();) {
      Packet p = (Packet) it.next();
      if(time >= p.tstamp - .1 && time <= p.tstamp + .1)
        sending = true;
        proto = p.proto;
    }
    if(sending) {
      //appear animation
      if(!drawn){
        weight++;
        strokeWeight(weight);
        //stroke(proto, weight*(255/4));
        if(weight >= 2)
          drawn = true;
      }
      else
        strokeWeight(2);
    }
    else{
      //disappear animation
      if(drawn) {
        weight--;
        strokeWeight(weight);
        //stroke(proto, weight*(255/4));
        if(weight <= 0)
          drawn = false;
      }
    }
    line(a.pos.x, a.pos.y, b.pos.x, b.pos.y);
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
    textSize(9);
    strokeWeight(2);
    line(220, 35, width-220, 35);
    //labels
    text("To", 220, 10);
    text("To", 220, 65);
    fill(a.myColor);
    text(a.ip, 235, 10);
    fill(b.myColor);
    text(b.ip, 235, 65);
    fill(0);
    //timestamps
    float ssec = parent.startTime % 60;
    int smin = floor(parent.startTime/60) % 60;
    int shour = floor(parent.startTime/3600);
    text(nf(shour, 2) + ":" + nf(smin, 2) + ":" + nf(ssec, 2, 2), 220, 45);
    float esec = parent.endTime % 60;
    int emin = floor(parent.endTime/60) % 60;
    int ehour = floor(parent.endTime/3600);
    text(nf(ehour, 2) + ":" + nf(emin, 2) + ":" + nf(esec, 2, 2), width-273, 45);
    strokeWeight(1);
    stroke(#FF0000);
    float pos = max(225, (min(width - 225, 225 + (((time - parent.startTime)/(parent.endTime - parent.startTime))*(width-450)))));
    line(pos, 0, pos, 70);
    textSize(12);
  }
}
