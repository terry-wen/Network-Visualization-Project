/*
Basic 2D Vector class for easy position manipulation of nodes.

@author: terrywen
*/

class Vector {
  float x;
  float y;
  
  public Vector() {
    this(0,0);
  }
  
  public Vector(float _x, float _y) {
    this.x = _x;
    this.y = _y;
  }

  void clear() {
    this.x = 0;
    this.y = 0;
  }
  
  Vector add(Vector v) {
    return new Vector(this.x + v.x, this.y + v.y);
  }
  
  Vector sub(Vector v) {
    return new Vector(this.x - v.x, this.y - v.y);
  }
  
  Vector mult(float alpha) {
    return new Vector(this.x * alpha, this.y * alpha);
  }

  float norm() {
    return sqrt(pow(this.x, 2) + pow(this.y, 2));
  }

  Vector unit() {
    return new Vector(this.x/this.norm(), this.y/this.norm());
  }

  String toString() {
    return "["+this.x+","+this.y+"]";   
  }
}
