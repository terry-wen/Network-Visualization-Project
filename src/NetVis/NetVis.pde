/*
Main application which takes input file "data.json" and processes information into individual packets, connections, and nodes.
Generates interface and functionality of entire application.

@author: terrywen
*/

import java.util.Iterator;
import java.util.Map;
import controlP5.*;

JSONArray packetList;                           
Map<String, Node> nodes = new HashMap<String, Node>();
ArrayList dnodes = new ArrayList();
Map<String, Link> links = new HashMap<String, Link>();
ArrayList dlinks = new ArrayList();             //arrays for nodes and links
Node currentNode = null;                        //current active objects
Link currentLink = null;                        //
Packet currentPacket = null;                    //

String infoText = "";                           //info display
String pktInfo = "";                            //

float currentTime = 0;                          //time inits
float startTime = 999999;                       //
float endTime = 0;                              //
float speed = 1;                                //
float fspeed = 1;

color sColor1 = #003882;                        //node coloring (IP1)
color sColor2 = #5100FF;                        //(IP2)
color dColor = #3683FF;                         //(general)

float k;                                        //force-direction constant
  
boolean playing, tempP;                            //playback values
boolean tlChange = false;                       //

ControlP5 cp5;                                  //playback controls
Slider timeline, speedAdjust;                   //
Button playButton;                                   //
Button lockButton, anchorButton;                //layout controls
Button setFlow;                                 //

boolean allAnchored, allLocked;

void setup() {
  //initialize window
  colorMode(RGB);
  smooth();
  size(1200, 800);
  cp5 = new ControlP5(this);
  
  //initialize lists and generate nodes/links
  generateNodes();
  
  //playback controls
  playButton = cp5.addButton("togglePlay")
     .setPosition(10,height-60)
     .setSize(50,50);   
  playButton.getCaptionLabel().align(CENTER, CENTER);
  
  timeline = cp5.addSlider("timeline")
    .setPosition(150, height-60)
    .setSize(width-300, 30)
    .setRange(startTime, endTime)
    .setValue(currentTime)
    .setSliderMode(Slider.FLEXIBLE)
    .setCaptionLabel("");
    
  speedAdjust = cp5.addSlider("speedAdjust")
    .setPosition(width - 50, height - 400)
    .setSize(20, 300)
    .setRange(-1, 2)
    .setValue(0)
    .setCaptionLabel("")
    .setSliderMode(Slider.FLEXIBLE)
    .setNumberOfTickMarks(4);
    
  //interaction controls
  lockButton = cp5.addButton("lock")
    .setPosition(10, height - 100);
  lockButton.getCaptionLabel().align(CENTER, CENTER);
  anchorButton = cp5.addButton("anchor")
    .setPosition(10, height - 130);
  anchorButton.getCaptionLabel().align(CENTER, CENTER);
  
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
    
    //add node
    Node sNode;
    if(nodes.containsKey(srcIP)) {
      sNode = nodes.get(srcIP);
    } else {
      sNode = new Node();
      sNode.ip = srcIP;
      nodes.put(srcIP, sNode);
    }
    Node dNode;
    if(nodes.containsKey(dstIP)) {
      dNode = nodes.get(dstIP);
    } else {
      dNode = new Node();
      dNode.ip = dstIP;
      nodes.put(dstIP, dNode);
    }
    
    //add link
    String linkKey = srcIP.compareTo(dstIP) < 0 ? srcIP + "-" + dstIP : dstIP + "-" + srcIP;
    Link link;
    if(links.containsKey(linkKey)) {
      link = links.get(linkKey);
    } else {
      link = srcIP.compareTo(dstIP) < 0 ? new Link(sNode, dNode) : new Link(dNode, sNode);
      links.put(linkKey, link);
    }

    //add packet
    String tt = packet.getString("starttime").substring(11);
    float t = Utils.timeStringToFloat(tt);
    int size = packet.getInt("bytes");
    String protocol = packet.getString("proto");
    
    Packet curPacket = new Packet(link, link.a.ip == sNode.ip, srcPort, dstPort, t, size, protocol);
    link.addPacket(curPacket);
    link.setTimes(t);
    
    //set timeline constraints
    startTime = min(startTime, t - 2);
    endTime = max(endTime, t + 2);
  }
  currentTime = startTime;
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
  speedAdjust.setValueLabel(fspeed + "x");
  timeline.setValueLabel(Utils.timeFloatToString(currentTime));

  //updates current nodes
  for(Iterator it = nodes.values().iterator(); it.hasNext();){
    Node n = (Node) it.next();
    if((n.btwnTime(currentTime) || n.locked) && !dnodes.contains(n))
      dnodes.add(n);
  }
  
  k = sqrt(width*height/(max(1,dnodes.size()))*.3);
  
  //updates current links
  for(Iterator it = links.values().iterator(); it.hasNext();){
    Link l = (Link) it.next();
    if(l.btwnTime(currentTime) && !dlinks.contains(l))
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
          b.disp = b.disp.add(dist.unit().mult(fr(dist.norm())));
        }
      }
    }
  }
  
  //pulls nodes together on links
  for(Iterator it = dlinks.iterator(); it.hasNext();){
    Link l = (Link) it.next();
    Vector dist = l.a.pos.sub(l.b.pos);
    if (dist.norm() != 0) {
      l.a.disp = l.a.disp.sub(dist.unit().mult(fa(dist.norm())));
      l.b.disp = l.b.disp.add(dist.unit().mult(fa(dist.norm())));   
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
    boolean selected = currentLink == l;
    l.draw(currentTime, selected);
    l.a.myColor = dColor;
    l.b.myColor = dColor;
    if(!l.drawn)
      it.remove();
  } 
  
  //update colors and show nodes
  if (currentLink != null) {
    currentLink.a.myColor = sColor1;
    currentLink.b.myColor = sColor2;
  }
  for(Iterator it = dnodes.iterator(); it.hasNext();){
    Node n = (Node) it.next();
    n.drag(mouseX, mouseY);
    if(currentLink == null) {
      n.myColor = dColor;
    }
    boolean selected = currentNode == n;
    n.draw(currentTime, selected);
    if(!n.drawn)
      it.remove();
  }
  
  //adjusts selection to visibility
  if(currentNode != null && !currentNode.drawn)
    currentNode = null;
  if(currentLink != null && !currentLink.drawn)
    currentLink = null;
  
  drawUI();
  
  //playback
  if(playing && currentTime < endTime) {
    currentTime += speed/frameRate;
  } else {
    playing = false; // stops at end of duration
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
  playButton.setPosition(20,height-70);
  playButton.setCaptionLabel(playing ? "pause" : "play");
  
  //anchor/lock functions
  anchorButton.setCaptionLabel(allAnchored ? "unanchor all" : "anchor all");
  lockButton.setCaptionLabel(allLocked ? "unlock all" : "lock all");
  
  //adjust button text, info text
  if(currentNode != null) {
    infoText = "IP: " + currentNode.ip;
    anchorButton.setCaptionLabel(currentNode.anchored ? "unanchor" : "anchor");
    lockButton.setCaptionLabel(currentNode.locked ? "unlock" : "lock");
  } else {
    infoText = "";
    anchorButton.setCaptionLabel(allAnchored ? "unanchor all" : "anchor all");
    lockButton.setCaptionLabel(allLocked ? "unlock all" : "lock all");
  }
  
  if(currentPacket != null)
    pktInfo = "Src Port: " + currentPacket.srcPort + "\nDst Port: " + currentPacket.destPort + "\nBytes: " + currentPacket.size + "\nProtocol: " + currentPacket.protocol;
  else
    pktInfo = "";
  
  //draw small timeline, highlight section
  if(currentLink != null) {
    infoText = "IP1: " + currentLink.a.ip + "\nIP2: " + currentLink.b.ip;
    float s = max(155, 155 + (((currentLink.startTime - startTime)/(endTime - startTime))*(width-310))) - 5;
    float e = min(width-155, 155 + (((currentLink.endTime - startTime)/(endTime - startTime))*(width-310))) + 5;
    fill(#48A2CF);
    rect(s, height-70, (e-s), 50);
    currentLink.drawTimeline(currentTime);
  }
  
  //write text, draw sliders
  fill(255);
  text(infoText, 10, 20);
  text(pktInfo, width - 140, 20);
  text("Time: " + Utils.timeFloatToString(currentTime), (width/2)-50, height-75);
  
  timeline.setValue(currentTime)
    .setPosition(150, height-60)
    .setSize(width-300, 30)
    .setValueLabel(Utils.timeFloatToString(currentTime - startTime));
    
  speedAdjust.setPosition(width - 50, height - 400)
    .setSize(20, 300)
    .setValueLabel(fspeed + "x");
} 

void mousePressed() {
  if(mouseButton == LEFT) {
    // node dragging
    for(Iterator it = nodes.values().iterator(); it.hasNext();){
      Node n = (Node) it.next();
      if(n.drawn) {
        if(!n.clicked(mouseX, mouseY) && !((mouseY < height - 90) && (mouseX > 90) && (mouseX < width - 90) && (mouseY > 90)));
      }
    }  
    
    if((mouseY < height - 90) && (mouseX > 90) && (mouseX < width - 90) && (mouseY > 90)){
      //node selection
      currentNode = null;
      for(Iterator it = dnodes.iterator(); it.hasNext();){
        Node n = (Node) it.next();
        if(n.select(mouseX, mouseY)) {
          currentNode = n;
        }
      }
      //link selection
      currentLink = null;
      for(Iterator it = dlinks.iterator(); it.hasNext();){
        Link l = (Link) it.next();
        if(l.select(mouseX, mouseY)) {
          currentLink = l;
        }
      }
    }
    if((mouseY < height - 90) && (mouseX >= 220) && (mouseX <= width-220) && currentLink != null) { 
      //packet selection
      currentPacket = null;
      for(Iterator it = currentLink.packets.iterator(); it.hasNext();) {
        Packet p = (Packet) it.next();
        p.selected = false;
        if(p.select(mouseX, mouseY)) {
          currentPacket = p;
        }
      }
    }
  }
}

void mouseReleased() {
  if (currentNode != null)
    currentNode.stopDragging();
}

//timeline control
void timeline(float t) {
  currentTime = t;
}

//playback speed control
void speedAdjust(float s) {
  speed = pow(10,s);
  fspeed = Math.round(speed * 10) / 10;
}

//layout controls
//lock - make permanantly visible
void lock() {
  if(currentNode != null) {
    currentNode.locked = !currentNode.locked;
    allLocked = allLocked && currentNode.locked;
  } else {
    lockAll();
  }    
}

//anchor - hold position
void anchor() {
  if(currentNode != null) {
    currentNode.anchored = !currentNode.anchored;
    allAnchored = allAnchored && currentNode.anchored;
  } else {
    anchorAll();
  }
}

void lockAll() {
  for(Iterator it = nodes.values().iterator(); it.hasNext();) {
    Node n = (Node) it.next();
    n.locked = !allLocked; 
  } 
  allLocked = !allLocked;
}

void anchorAll() {
  for(Iterator it = nodes.values().iterator(); it.hasNext();) {
    Node n = (Node) it.next();
    n.anchored = !allAnchored;
  }  
  allAnchored = !allAnchored;
}

//play control
void togglePlay() {
  if(currentTime >= endTime) {
    currentTime = startTime;
  }
  playing = !playing;
}

//set to start of current flow
void setflow() {
  if(currentLink != null) {
    currentTime = currentLink.startTime;
  }
}

//keyboard shortcuts
void keyPressed() {
  if (key == 'a')
    anchor();
  if (key == 'l')
    lock();
  if (key == 'A')
    anchorAll();
  if (key == 'L')
    lockAll();
  if (key == ' ')
    togglePlay();
  if (key == 's')
    setflow();
}
