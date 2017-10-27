class Vehicle {

  PVector pos;
  PVector vel;
  PVector acc;
  float mass;
  float r;
  float maxSpeed;
  float maxForce;

  Vehicle(float x, float y, float m) {
    pos = new PVector(x, y);
    vel = new PVector(random(-3,3), random(-3,3));
    acc = new PVector(0, 0);
    mass = m;
    maxSpeed = 10;
    maxForce = 0.05;
    r = 6 * m;
  }

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, this.pos);
    desired.setMag(this.maxSpeed);

    PVector steer = PVector.sub(desired, this.vel);
    steer.limit(this.maxForce);
    return steer;
  }

  PVector arrive(PVector target) {    
    PVector desired = PVector.sub(target, this.pos);
    float d = desired.mag();
    if (d > 100) {
      desired.setMag(this.maxSpeed);
    } else {
      float speed = map(d, 0, 100, 0, this.maxSpeed);
      desired.setMag(speed);
    }
    PVector steer = PVector.sub(desired, this.vel);
    steer.limit(this.maxForce);
    return steer;
  }

  PVector follow(Path p) {
    // Get future location
    PVector futureVel = this.vel.copy().setMag(50);
    PVector futurePos = PVector.add(this.pos, futureVel);

    PVector pointOnPath = p.getProjection(futurePos);

    float dist = PVector.dist(pointOnPath, futurePos);

    if (dist > p.r) {
      PVector dir = PVector.sub(p.end, p.start);
      dir.setMag(10);
      PVector target = PVector.add(pointOnPath, dir);
      return seek(target);
    }
    return new PVector(0, 0);
  }

  PVector align(ArrayList<Vehicle> vehicles) {
    PVector desired = new PVector(0, 0);
    float sightDist = 50;
    int count = 0;
    for (Vehicle v : vehicles) {
      float dist = PVector.dist(this.pos, v.pos);
      if (dist > 0 && dist < sightDist) {
        desired.add(v.vel);
        count ++;
      }
    }

    PVector steer = new PVector(0, 0);
    if (count > 0) {
      desired.div((float)count);
      desired.setMag(maxSpeed);
      steer = PVector.sub(desired, this.vel);
      steer.limit(this.maxForce);
    }

    return steer;
  }

  PVector separate(ArrayList<Vehicle> vehicles) {
    PVector desired = new PVector(0, 0);
    float sightDist = 25;
    int count = 0;
    for (Vehicle v : vehicles) {
      float dist = PVector.dist(this.pos, v.pos);
      if (dist > 0 && dist < sightDist) {
        PVector flee = PVector.sub(this.pos, v.pos);
        flee.normalize();
        flee.div(dist);
        desired.add(flee);
        count ++;
      }
    }

    PVector steer = new PVector(0, 0);
    if (count > 0) {
      desired.div(count);
      desired.setMag(maxSpeed);
      steer = PVector.sub(desired, this.vel);
      steer.limit(this.maxForce);
    }

    return steer;
  }

  PVector cohesion(ArrayList<Vehicle> vehicles) {
    PVector avgPos = new PVector(0, 0);

    float sightDist = 50;
    int count = 0;
    for (Vehicle v : vehicles) {
      float dist = PVector.dist(this.pos, v.pos);
      if (dist > 0 && dist < sightDist) {
        avgPos.add(v.pos);
        count ++;
      }
    }


    if (count > 0) {
      avgPos.div(count);
      return seek(avgPos);
    }

    return new PVector(0, 0);
  }

  void applyFlock(ArrayList<Vehicle> vehicles) {
    PVector separateForce = separate(vehicles);
    PVector alignForce = align(vehicles);
    PVector cohesionForce = cohesion(vehicles);

    separateForce.mult(25);
    alignForce.mult(4);
    cohesionForce.mult(5);

    applyForce(separateForce);
    applyForce(alignForce);
    applyForce(cohesionForce);
  }

  void applyQueue(ArrayList<Vehicle> vehicles) {
    PVector separateForce = separate(vehicles);
    PVector seekForce = seek(new PVector(width/2, 0));

    separateForce.mult(2);
    seekForce.mult(1);

    applyForce(separateForce);
    applyForce(seekForce);
  }


  void applyForce(PVector force) {
    //PVector f = PVector.div(force, mass);
    acc.add(force);
  }

  void update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    pos.add(vel);
    acc.mult(0);
  }

  void edgesTele() {
    if (this.pos.x < -r) this.pos.x = width+r;
    if (this.pos.y < -r) this.pos.y = height+r;
    if (this.pos.x > width+r) this.pos.x = -r;
    if (this.pos.y > height+r) this.pos.y = -r;
  }

  void edgesBounce() {
    if (pos.x < 0) {
      pos.x = 0;
      vel.x *= -1;
    } else if (pos.x > width) {
      pos.x = width;
      vel.x *= -1;
    }

    if (pos.y < 0) {
      pos.y = 0;
      vel.y *= -1;
    } else if (pos.y > height) {
      pos.y = height;
      vel.y *= -1;
    }
  }

  void displayTriangle() {
    float theta = this.vel.heading() + PI/2;
    fill(127);
    stroke(0);
    strokeWeight(1);
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    rotate(theta);
    beginShape();
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape(CLOSE);
    popMatrix();
  }

  void displayCircle() {
    fill(127);
    stroke(0);
    ellipse(this.pos.x, this.pos.y, r*2, r*2);
  }

  void displayPoint() {
    stroke(0);
    strokeWeight(3);
    point(this.pos.x, this.pos.y);
  }
}