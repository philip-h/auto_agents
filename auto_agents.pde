ArrayList<Vehicle> vehicles;
void setup() {
  size(700,500);
  vehicles = new ArrayList<Vehicle>();
  for (int i = 0; i < 10; i++) {
    vehicles.add(new Vehicle(width/2, height/2, 1));
  }
  

}

void draw() {
  background(255);
  
  
  
  for (Vehicle v : vehicles) {
    
    v.applyFlock(vehicles);
    v.update();
    v.edgesTele();
    v.displayTriangle();
  }
}

void mouseDragged() {
  vehicles.add(new Vehicle(mouseX, mouseY, 1));
}