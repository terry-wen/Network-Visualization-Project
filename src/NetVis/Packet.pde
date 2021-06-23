/*
Packet class to represent individual pieces of data along a flow. 
Exist in arrays on specific flows, portrayed on link animation and flow timeline.

@author: terrywen
*/

class Packet {
  boolean atob;
  float timeStamp, size, pos, len;
  Link link;
  boolean selected = false;
  String srcPort, destPort, protocol;
  
  Packet(Link link, boolean _atob, String _srcPort, String _destPort, float _timeStamp, float _size, String _protocol) {
    atob = _atob;
    timeStamp = _timeStamp;
    size = _size;
    srcPort = _srcPort;
    destPort = _destPort;
    protocol = _protocol;
    pos = max(225, (min(width - 225, 225 + (((timeStamp - link.startTime)/(link.endTime - link.startTime))*(width-450)))));
    len = (atob ? 1 : -1) * min(35, log(size)*5);
  }
  
  //for timeline
  void draw() {
    strokeWeight(1);
    stroke(selected ? #00FF00 : #17386E);
    line(pos, 35 + len, pos, 35);
  }
  
  //for selection
  boolean select(int mx, int my) {
    boolean x = ((mx >= pos - 1) && (mx <= pos + 1));
    boolean y;
    if(atob)
      y = (my >= 35) && (my <= 35 + len);
    else 
      y = (my <= 35) && (my >= 35 - len);
    selected = x && y;
    return selected;
  }
}
