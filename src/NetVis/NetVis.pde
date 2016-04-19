/*
Main application which takes input file "data.json" and processes information into individual packets, connections, and nodes.
Generates interface and functionality of entire application.

@author: terrywen
*/

import java.util.Iterator;
import controlP5.*;

JSONArray packetList;                           
ArrayList nodes, dnodes, links, dlinks;         //arrays for nodes and links
Node cnode = new Node();                        //current active objects
Link clink = new Link(new Node(), new Node());  //
Packet cpacket = new Packet();                  //

String infoText = "";                           //info display
String pktInfo = "";                            //

float time = 99999;                             //time inits
float initTime = 0;                             //
float end = 18;                                 //
int hour, min;                                  //
float sec;                                      //
float speed;                                    //

color sColor1 = #003882;                        //node coloring (IP1)
color sColor2 = #5100FF;                        //(IP2)
color dColor = #3683FF;                         //(general)

float k;                                        //force-direction constant
  
boolean play, tempP;                            //playback values
boolean tlChange = false;                       //

ControlP5 cp5;                                  //playback controls
Slider timeline, speedAdjust;                   //
Button playB;                                   //

Button lock, anchor;                            //layout controls
Button lockall, anchorall;                      //
Button setFlow;                                 //

boolean visanchor, allanchor, vislock, alllock; //

void setup() {
  //initialize window
  colorMode(RGB);
  smooth();
  size(1600, 900);
  cp5 = new ControlP5(this);
  
  //initialize speed
  speed = 1;
  
  //initialize lists and generate nodes/links
  dnodes = new ArrayList();
  nodes = new ArrayList();
  dlinks = new ArrayList();
  links = new ArrayList();
  generateNodes();
  
  //playback controls
  playB = cp5.addButton("play")
     .setPosition(10,height-60)
     .setSize(50,50)
     ;   
  playB.getCaptionLabel().align(CENTER, CENTER);
  
  timeline = cp5.addSlider("timeline")
    .setPosition(150, height-60)
    .setSize(width-300, 30)
    .setRange(initTime, end)
    .setValue(time)
    .setSliderMode(Slider.FLEXIBLE)
    .setCaptionLabel("")
    ;
    
  speedAdjust = cp5.addSlider("speedAdjust")
    .setPosition(width - 50, height - 400)
    .setSize(20, 300)
    .setRange(-1, 2)
    .setValue(0)
    .setCaptionLabel("")
    .setSliderMode(Slider.FLEXIBLE)
    .setNumberOfTickMarks(4)
    ;
    
  //interaction controls
  lock = cp5.addButton("lock")
    .setPosition(width - 100, height - 40);
  lock.getCaptionLabel().align(CENTER, CENTER);
  anchor = cp5.addButton("anchor")
    .setPosition(width - 100, height - 70);;
  anchor.getCaptionLabel().align(CENTER, CENTER);
  
  lockall = cp5.addButton("lockall")
    .setPosition(10, height - 100);
  lockall.getCaptionLabel().align(CENTER, CENTER);
  anchorall = cp5.addButton("anchorall")
    .setPosition(10, height - 130);
  anchorall.getCaptionLabel().align(CENTER, CENTER);
  
  setFlow = cp5.addButton("setflow")
    .setPosition(width - 80, height - 430)
    .setCaptionLabel("start of flow");
  setFlow.getCaptionLabel().align(CENTER,CENTER);
}

// read json and generate arrays
void generateNodes(){
  packetList = loadJSONArray("data.json");
  
  for  (int i = 0; i < packetList.size(); i++) {
    JSONObject packet = packetList.getJSONObject(i);
    
    String srcIP = packet.getString("sip");
    String srcPort = str(packet.getInt("sport"));
    String dstIP = packet.getString("dip");
    String dstPort = str(packet.getInt("dport"));
    
    Node sNode = new Node();
    Node dNode = new Node();
    
    boolean srcNodeExists = false;
    boolean dstNodeExists = false;
    
    //add node
    for(Iterator it = nodes.iterator(); it.hasNext();) {
      Node n = (Node) it.next();
      if((n.ip.equals(srcIP) /*&& n.port.equals(srcPort)*/)) {
        sNode = n;
        srcNodeExists = true;
      }
      if((n.ip.equals(dstIP) /*&& n.port.equals(srcPort)*/)) {
        dNode = n;
        dstNodeExists = true;
      }
    }
    
    if(!srcNodeExists) {
      sNode.ip = srcIP;
      //sNode.port = srcPort;
      nodes.add(sNode);
      //println(sNode);
    }
    if(!dstNodeExists) {
      dNode.ip = dstIP;
      //dNode.port = dstPort;
      nodes.add(dNode);
      //println(dNode);
    }
    
    //add link
    Link curlink = new Link(sNode, dNode);
    boolean linkCreated = false;
    for(Iterator it = links.iterator(); it.hasNext();) {
      Link l = (Link) it.next();
      if(l.check(sNode, dNode)) {
        linkCreated = true;
        curlink = l;
      }
    }
    if(!linkCreated) {
      links.add(curlink);
    }
    
    //add packet
    String tt = packet.getString("starttime").substring(11);
    float t = (float(tt.substring(0,2)) * 3600) + (float(tt.substring(3,5))*60) + float(tt.substring(6,8)) + (float(tt.substring(9))/1000000);
    int size = packet.getInt("bytes");
    String proto = packet.getString("proto");
    
    Packet curPacket = new Packet(sNode, dNode, srcPort, dstPort, t, size, proto);
    curlink.flow.addPacket(curPacket);
    sNode.startTime = min(sNode.startTime, t - .25);
    sNode.endTime = max(sNode.endTime, t + .25);
    dNode.startTime = min(dNode.startTime, t - .25);
    dNode.endTime = max(dNode.endTime, t + .25);
    curlink.startTime = min(curlink.startTime, t - .25);
    curlink.endTime = max(curlink.endTime, t + .25);
    
    //set timeline constraints
    time = min(time, t - 2);
    end = max(end, t + 2);
  }
  initTime = time;
  /*
  //test data
  nodes.add(new Node(1, 17));
  Node init = (Node) nodes.get(0);
  init.pos.set(width/2, height/2);
  
  nodes.add(new Node(3, 14));
  nodes.add(new Node(3, 13));
  nodes.add(new Node(5, 16));
  nodes.add(new Node(2, 9));
  nodes.add(new Node(6, 13));
  nodes.add(new Node(3, 12));
  nodes.add(new Node(7, 17));
  
  links.add(new Link((Node) nodes.get(0), (Node) nodes.get(1)));
  links.add(new Link((Node) nodes.get(0), (Node) nodes.get(2)));
  //links.add(new Link((Node) nodes.get(2), (Node) nodes.get(4)));
  //links.add(new Link((Node) nodes.get(1), (Node) nodes.get(3)));
  //links.add(new Link((Node) nodes.get(3), (Node) nodes.get(4)));
  links.add(new Link((Node) nodes.get(0), (Node) nodes.get(4)));
  links.add(new Link((Node) nodes.get(0), (Node) nodes.get(3)));
  links.add(new Link((Node) nodes.get(0), (Node) nodes.get(5)));
  links.add(new Link((Node) nodes.get(0), (Node) nodes.get(6)));
  links.add(new Link((Node) nodes.get(0), (Node) nodes.get(7)));
  //links.add(new Link((Node) nodes.get(1), (Node) nodes.get(4)));
  //links.add(new Link((Node) nodes.get(1), (Node) nodes.get(2)));
  
  Link l = (Link) links.get(0);
  l.flow.addPacket(new Packet((Node) nodes.get(0), (Node) nodes.get(1), 3.1, 5, "TCP"));
  l.flow.addPacket(new Packet((Node) nodes.get(0), (Node) nodes.get(1), 3.3, 5, "TCP"));
  l.flow.addPacket(new Packet((Node) nodes.get(0), (Node) nodes.get(1), 9.2, 5, "TCP"));
  l.flow.addPacket(new Packet((Node) nodes.get(0), (Node) nodes.get(1), 6.9, 5, "TCP"));
  l.flow.addPacket(new Packet((Node) nodes.get(0), (Node) nodes.get(1), 11.4, 5, "TCP"));
  l.flow.addPacket(new Packet((Node) nodes.get(0), (Node) nodes.get(1), 12.9, 5, "TCP"));
  l.flow.addPacket(new Packet((Node) nodes.get(1), (Node) nodes.get(0), 3.2, 5, "TCP"));
  l.flow.addPacket(new Packet((Node) nodes.get(1), (Node) nodes.get(0), 4.2, 5, "TCP"));
  l.flow.addPacket(new Packet((Node) nodes.get(1), (Node) nodes.get(0), 5.6, 5, "TCP"));
  l.flow.addPacket(new Packet((Node) nodes.get(1), (Node) nodes.get(0), 5.8, 5, "TCP"));
  l.flow.addPacket(new Packet((Node) nodes.get(1), (Node) nodes.get(0), 5.9, 5, "TCP"));
  l.flow.addPacket(new Packet((Node) nodes.get(1), (Node) nodes.get(0), 6.4, 5, "TCP"));
  l.flow.addPacket(new Packet((Node) nodes.get(1), (Node) nodes.get(0), 9.4, 5, "TCP"));
  l.flow.addPacket(new Packet((Node) nodes.get(1), (Node) nodes.get(0), 12.8, 5, "TCP"));
  */
}

//force-direction methods
//attraction value
float fa(float z){
  return .0001*pow(k-100-z,2);   
}

//repulsion value
float fr(float z){
  return .25*pow((40+k)/z,2);   
}

void draw() {
  background(180);
  
  //updates current nodes
  for(Iterator it = nodes.iterator(); it.hasNext();){
    Node n = (Node) it.next();
    if((n.btwnTime(time) || n.locked) && !dnodes.contains(n))
      dnodes.add(n);
  }
  
  k = sqrt(width*height/(max(1,dnodes.size()))*.3);
  
  //updates current links
  for(Iterator it = links.iterator(); it.hasNext();){
    Link l = (Link) it.next();
    if(l.btwnTime(time) && !dlinks.contains(l))
      dlinks.add(l);
  }
  
  //repulses nodes from each other
  for(Iterator it = dnodes.iterator(); it.hasNext();){
    Node a = (Node) it.next();
    for(Iterator it2 = dnodes.iterator(); it2.hasNext();){
      Node b = (Node) it2.next();     
      if (a != b){
        Vector dist = b.pos.sub(a.pos);
        if (dist.norm() != 0){
          b.disp.addSelf(dist.unit().mult(fr(dist.norm())));
        }
      }
    }
  }
  
  //pulls nodes together on links
  for(Iterator it = dlinks.iterator(); it.hasNext();){
    Link l = (Link) it.next();
    Vector dist = l.a.pos.sub(l.b.pos);
    if (dist.norm() != 0) {
      l.a.disp.subSelf(dist.unit().mult(fa(dist.norm())));
      l.b.disp.addSelf(dist.unit().mult(fa(dist.norm())));   
    }
  }
  
  //update node positions
  if(dnodes.size() > 1) {
    for(Iterator it = dnodes.iterator(); it.hasNext();){
      Node n = (Node) it.next();
      if(!n.dragging && !n.anchored){
        n.update();
        //println(n.pos);
      } else {
        n.disp.clear();
      }
      n.constrain(90,width-90,100,height - 100);
    }
  }
  
  //show links 
  for(Iterator it = dlinks.iterator(); it.hasNext();){
    Link l = (Link) it.next();
    l.draw(time);
    l.a.myColor = dColor;
    l.b.myColor = dColor;
    if(!l.drawn)
      it.remove();
  } 
  
  //update colors and show nodes
  clink.a.myColor = sColor1;
  clink.b.myColor = sColor2;
  for(Iterator it = dnodes.iterator(); it.hasNext();){
    Node n = (Node) it.next();
    n.drag(mouseX, mouseY);
    if(clink.a.ip == null) {
      n.myColor = dColor;
    }
    n.draw(time);
    if(!n.drawn)
      it.remove();
  }
  
  //adjusts selection to visibility
  if(!cnode.drawn)
    cnode = new Node();
  if(!clink.drawn)
    clink = new Link(new Node(), new Node());
  
  drawUI();
  
  //playback
  if(play && time < end) {
    time +=  speed/frameRate;
  } else {
    play = false; // stops at end of duration
  }
}

void drawUI() {
  //interface base
  noStroke();
  fill(0xff011D33);
  rect(0, height - 90, width, 90);
  rect(0, 0, 90, height);
  rect(width-90, 0, 90, height);
  rect(0, 0, width, 70);
  fill(0xff02344d);
  rect(0, 0, 150, 90, 0, 0, 10, 0);
  rect(width - 150, 0, 150, 90, 0, 0, 0, 10);
  rect(200, 0, width-400, 90, 0, 0, 10, 10);
  rect(140, height-70, width-280, 50);
  
  fill(180);
  rect(220, 0 , width - 440, 70, 0, 0, 5, 5);
  
  //play button
  playB.setPosition(20,height-70);
  if(play) {
    playB.setCaptionLabel("pause");
  } else {
    playB.setCaptionLabel("play");
  }
  
  //anchor/lock functions
  allanchor = true;
  for(Iterator it = nodes.iterator(); it.hasNext();) {
    Node n = (Node) it.next();
    allanchor = allanchor && n.anchored;
  }
  if(allanchor)
    anchorall.setCaptionLabel("unanchor all");
  else
    anchorall.setCaptionLabel("anchor all");
    
  alllock = true;
  for(Iterator it = nodes.iterator(); it.hasNext();) {
    Node n = (Node) it.next();
    alllock = alllock && n.locked;
  }
  if(alllock)
    lockall.setCaptionLabel("unlock all");
  else
    lockall.setCaptionLabel("lock all");
  
  visanchor = true;
  for(Iterator it = dnodes.iterator(); it.hasNext();) {
    Node n = (Node) it.next();
    visanchor = visanchor && n.anchored;
  }
  
  vislock = true;
  for(Iterator it = dnodes.iterator(); it.hasNext();) {
    Node n = (Node) it.next();
    vislock = vislock && n.locked;
  }
  
  //adjust button text, info text
  if(cnode.ip != null) {
    infoText = "IP: " + cnode.ip;
    if(cnode.anchored)
    anchor.setCaptionLabel("unanchor");
    else
      anchor.setCaptionLabel("anchor");
    if(cnode.locked)
      lock.setCaptionLabel("unlock");
    else
      lock.setCaptionLabel("lock");
  } else {
    if(vislock && !(dnodes.isEmpty()))
      lock.setCaptionLabel("unlock visible");
    else
      lock.setCaptionLabel("lock visible");
    if(visanchor && !(dnodes.isEmpty()))
      anchor.setCaptionLabel("unanchor visible");
    else
      anchor.setCaptionLabel("anchor visible");
    infoText = "";
  }
  
  if(cpacket.sp != null)
    pktInfo = "Src Port: " + cpacket.sp + "\nDst Port: " + cpacket.dp + "\nBytes: " + cpacket.size + "\nProtocol: " + cpacket.protoText;
  else
    pktInfo = "";
  
  //draw small timeline, highlight section
  if(clink.a.ip != null) {
    infoText = "IP1: " + clink.a.ip + "\nIP2: " + clink.b.ip;
    float s = max(155, 155 + (((clink.startTime - initTime)/(end - initTime))*(width-310))) - 5;
    float e = min(width-155, 155 + (((clink.endTime - initTime)/(end - initTime))*(width-310))) + 5;
    fill(#48A2CF);
    rect(s, height-70, (e-s), 50);
    clink.flow.drawTimeline(time);
  }
  
  //write text, draw sliders
  fill(255);
  text(infoText, 10, 20);
  text(pktInfo, width - 140, 20);
  
  sec = time % 60;
  min = floor(time/60) % 60;
  hour = floor(time/3600);
  text("Time: " + nf(hour, 2) + ":" + nf(min, 2) + ":" + nf(sec, 2, 2), (width/2)-50, height-75);
  
  float pSec = (time-initTime) % 60;
  int pMin = floor((time-initTime)/60) % 60;
  int pHour = floor((time-initTime)/3600);
  timeline.setValue(time)
    .setPosition(150, height-60)
    .setSize(width-300, 30)
    .setValueLabel(nf(pHour, 2) + ":" + nf(pMin, 2) + ":" + nf(pSec, 2, 2));
  
  float fspeed = speed * 10;
  int rspeed = (int) fspeed;
  fspeed = (float) rspeed / 10;
  speedAdjust.setPosition(width - 50, height - 400)
    .setSize(20, 300)
    .setValueLabel(speed + "x");
} 

void mousePressed() {
  if(mouseButton == LEFT) {
    // node dragging
    for(Iterator it = nodes.iterator(); it.hasNext();){
      Node n = (Node) it.next();
      if(n.drawn) {
        if(!n.clicked(mouseX, mouseY) && !((mouseY < height - 90) && (mouseX > 90) && (mouseX < width - 90) && (mouseY > 90)));
      }
    }  
    
    if((mouseY < height - 90) && (mouseX > 90) && (mouseX < width - 90) && (mouseY > 90)){
      //node selection
      cnode = new Node();
      for(Iterator it = dnodes.iterator(); it.hasNext();){
        Node n = (Node) it.next();
        n.selected = false;
        if(n.select(mouseX, mouseY)) {
          cnode = n;
        }
      }
      //link selection
      clink = new Link(new Node(), new Node());
      for(Iterator it = dlinks.iterator(); it.hasNext();){
        Link l = (Link) it.next();
        l.selected = false;
        if(l.select(mouseX, mouseY)) {
          clink = l;
        }
      }
      for(Iterator it = dlinks.iterator(); it.hasNext();){
        Link l = (Link) it.next();
        if(clink == l)
          l.selected = true;
        else
          l.selected = false;
      }
      if(cnode.ip != null) {
        clink.selected = false;
        clink = new Link(new Node(), new Node());
      }
    }
    if((mouseY < height - 90) && (mouseX >= 220) && (mouseX <= width-220)) { 
      //packet selection
      cpacket = new Packet();
      for(Iterator it = clink.flow.packets.iterator(); it.hasNext();) {
        Packet p = (Packet) it.next();
        p.selected = false;
        if(p.select(mouseX, mouseY)) {
          cpacket = p;
        }
      }
      for(Iterator it = clink.flow.packets.iterator(); it.hasNext();) {
        Packet p = (Packet) it.next();
        if(cpacket == p)
          p.selected = true;
        else
          p.selected = false;
      }
      if(clink != cpacket.parent.parent)
        cpacket = new Packet();
    }
  }
}

void mouseReleased() {
  for(Iterator it = nodes.iterator(); it.hasNext();){
    Node n = (Node) it.next();
    n.stopDragging();
  }
}

//play control
void play() {
  play = !play;
  if(time >= end) {
      time = initTime;
  }
}

//timeline control
void timeline(float t) {
  time = t;
  float pSec = (time-initTime) % 60;
  int pMin = floor((time-initTime)/60) % 60;
  int pHour = floor((time-initTime)/3600);
  timeline.setValueLabel(nf(pHour, 2) + ":" + nf(pMin, 2) + ":" + nf(pSec, 2, 2));
}

//playback speed control
void speedAdjust(float s) {
  speed = pow(10,s);
  float fspeed = speed * 10;
  int rspeed = (int) fspeed;
  fspeed = (float) rspeed / 10;
  speedAdjust.setValueLabel(fspeed + "x");
}

//layout controls
//lock - make permanantly visible
void lock() {
  if(cnode.ip != null)
    cnode.locked = !cnode.locked;
  else {
    if(vislock) { 
      for(Iterator it = dnodes.iterator(); it.hasNext();) {
        Node n = (Node) it.next();
        n.locked = false; 
      } 
    } else {
      for(Iterator it = dnodes.iterator(); it.hasNext();) {
        Node n = (Node) it.next();
        n.locked = true;
      } 
    }
  }    
}

//anchor - hold position
void anchor() {
  if(cnode.ip != null)
    cnode.anchored = !cnode.anchored;
  else {
    if(visanchor) {
      for(Iterator it = dnodes.iterator(); it.hasNext();) {
        Node n = (Node) it.next();
        n.anchored = false;
      }  
    } else { 
      for(Iterator it = dnodes.iterator(); it.hasNext();) {
        Node n = (Node) it.next();
        n.anchored = true;
      } 
    }
  }
}

void lockall() {
  if(alllock) { 
    for(Iterator it = nodes.iterator(); it.hasNext();) {
      Node n = (Node) it.next();
      n.locked = false; 
    } 
  } else {
    for(Iterator it = nodes.iterator(); it.hasNext();) {
      Node n = (Node) it.next();
      n.locked = true;
    } 
  }
}

void anchorall() {
  if(allanchor) {
    for(Iterator it = nodes.iterator(); it.hasNext();) {
      Node n = (Node) it.next();
      n.anchored = false;
    }  
  } else { 
    for(Iterator it = nodes.iterator(); it.hasNext();) {
      Node n = (Node) it.next();
      n.anchored = true;
    } 
  }
}

//set to start of current flow
void setflow() {
  if(clink.a.ip != null) {
    time = clink.startTime;
  }
}

//keyboard shortcuts
void keyPressed() {
  if (key == 'a')
    anchor();
  if (key == 'l')
    lock();
  if (key == 'A')
    anchorall();
  if (key == 'L')
    lockall();
  if (key == ' ')
    play();
  if (key == 's')
    setflow();
}
