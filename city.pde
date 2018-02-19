class City {
  int       id;
  String    name;
  PVector   location;
  float[]   distances;
  final int drawColor = #00F014;

  // Constructor method City(i,n,x,y)
  City(int id, String name, float xpos, float ypos) {
    this.id   = id;
    this.name = name;
    location  = new PVector(xpos, ypos);
  }

  // Draw the city
  void draw() {
    fill(drawColor);
    ellipse(location.x, location.y, cityDiam, cityDiam);
    text(name, location.x, location.y);
  }

  // Calculate distances to other cities and fill distances vector
  void calcDistances(City[] cities, int numCities) {
    distances = new float[numCities];
    for (int i = 0; i < numCities; i++) {
      float d = PVector.dist(this.location, cities[i].location);
      distances[i] = d;
    }
  }
}