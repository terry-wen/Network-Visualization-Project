/*
Packet class to represent individual pieces of data along a flow. 
Exist in arrays on specific flows, portrayed on link animation and flow timeline.

@author: terrywen
*/

class Packet {
  Node src, dst;
  float tstamp, size, pos, len;
  color proto = 0;
  color TCP = #8000FF;
  color UDP = #00C9CC;
  Flow parent;
  boolean selected = false;
  String sp, dp, protoText;
  
  Packet() {
    parent = new Flow(new Node(), new Node());
    parent.parent = new Link(new Node(), new Node());
  }
  
  Packet(Node _src, Node _dst, String _sp, String _dp, float _tstamp, float _size, String _proto) {
    src = _src;
    dst = _dst;
    tstamp = _tstamp;
    size = _size;
    sp = _sp;
    dp = _dp;
    protoText = _proto;
    if(_proto.equals("TCP"))
      proto = TCP;
    else if (_proto.equals("UDP"))
      proto = UDP;
  }
  
  //for timeline
  void draw() {
    strokeWeight(1);
    if(selected)
      stroke(#00FF00);
    else {
      if(src == parent.a)
        stroke(parent.a.myColor);
      else
        stroke(parent.b.myColor);
    }
    pos = max(225, (min(width - 225, 225 + (((tstamp - parent.parent.startTime)/(parent.parent.endTime - parent.parent.startTime))*(width-450)))));
    len = min(35, log(size)*5);
    if(src == parent.b)
      line(pos, 35 - len, pos, 35);
    else
      line(pos, 35, pos, 35 + len);
  }
  
  //for selection
  boolean select(int mx, int my) {
    boolean x = ((mx >= pos - 1) && (mx <= pos + 1));
    boolean y;
    if(src == parent.b)
      y = (my <= 35) && (my >= 35 - len);
    else 
      y = (my >= 35) && (my <= 35 + len);
    if (x && y) {
      selected = true;
      return true;
    } else {
      selected = false;
      return false;
    }
  }
}
