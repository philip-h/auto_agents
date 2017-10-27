class Path {
  PVector start;
  PVector end;
  float r;
  
  Path(PVector start, PVector end, float r) {
    this.start = start;
    this.end = end;
    this.r = r;
  }
  
  PVector getProjection(PVector p) {
    PVector path = PVector.sub(end, start);
    path.normalize();
    PVector startp = PVector.sub(p, start);
   
    path.setMag(path.dot(startp));
    return PVector.add(start, path);
    
    
  }
  
  void display() {
    strokeWeight(r * 2);
    stroke(127);
    line(this.start.x, this.start.y, this.end.x, this.end.y);
    
    strokeWeight(1);
    stroke(0);
    line(this.start.x, this.start.y, this.end.x, this.end.y);
    
  }
}