/*
Basic 2D Vector class for easy position manipulation of nodes.

@author: terrywen
*/

class Vector {
  float x;
  float y;
  
  Vector() {
    this(0,0);
  }
  
  Vector(float _x, float _y) {
    x = _x;
    y = _y;
  }
  
  void set(float _x, float _y) {
    x = _x;
    y = _y;
  }
  
  void clear() {
    x = 0;
    y = 0;
  }
  
  Vector add(Vector v) {
    return new Vector(x += v.x, y += v.y);
  }
  
  Vector add(float x, float y) {
    return new Vector(x += x, y += y);
  }
  
  Vector addSelf(Vector v) {
    x += v.x;
    y += v.y;
    return this;
  }
  
  Vector addSelf(float _x, float _y) {
    x += _x;
    y += _y;
    return this;
  }
  
  Vector sub(float x, float y) {
    return new Vector(x -= x, y -= y);
  }
  
  Vector sub(Vector v) {
    return new Vector(x - v.x, y - v.y);
  }
  
  Vector subSelf(Vector v) {
    x -= v.x;
    y -= v.y;
    return this;
  }
  
  Vector subSelf(float _x, float _y) {
    x -= _x;
    y -= _y;
    return this;
  }
  
  Vector mult(float alpha) {
    return new Vector(x * alpha, y * alpha);
  }
  
  Vector multSelf(float alpha) {
    x *= alpha;
    y *= alpha;
    return this;
  }

  Vector div(float alpha) {
    return new Vector(x/alpha, y/alpha);
  }

  Vector divSelf(float alpha) {
    x /= alpha;
    y /= alpha;
    return this;
  }

  float norm() {
    return sqrt(pow(x, 2) + pow(y, 2));
  }

  Vector unit() {
    return new Vector(x/norm(), y/norm());
  }

  Vector unitSelf() {
    x /= norm();
    y /= norm();
    return this;
  }

  Vector clone() {
    return new Vector(x, y);
  }

  String toString() {
    return "["+x+","+y+"]";   
  }
}
