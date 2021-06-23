/*
Basic 2D Vector class for easy position manipulation of nodes.

@author: terrywen
*/

class Vector {
  private float x;
  private float y;
  
  public Vector() {
    this(0,0);
  }
  
  public Vector(float _x, float _y) {
    this.x = _x;
    this.y = _y;
  }
  
  public float getX() {
    return this.x;
  }
  
  public float getY() {
    return this.y;
  }

  void clear() {
    this.x = 0;
    this.y = 0;
  }
  
  Vector add(Vector v) {
    return new Vector(this.x + v.getX(), this.y + v.getY());
  }
  
  Vector sub(Vector v) {
    return new Vector(this.x - v.getX(), this.y - v.getY());
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
