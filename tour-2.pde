// class: Tour
// A tour is a circular tour plan connecting cities. A tourLength
// score is calculated by summing up distances between each city in
// the tour.

class Tour {
  City[]      cities;                  // Array of cities
  int         numCities;               // Number of cities
  int         tourPlan[];              // Tour plan
  float       tourLength  = 0.0;       // TourLength score
  final int   drawColor   = #F0F0F0;   // Color to draw lines
  int         evalCounter = 0;         // Counts the number of times the tourLength value was calculated to get the current tour

  /****************************************************
  *              Constructors functions               *
  *****************************************************/

  // Constructors
  Tour(int numCities) {
    this.numCities = numCities;
    this.tourPlan  = new int[numCities];
  }

  Tour(City[] cities, int numCities, boolean init) {
    this.cities    = cities;
    this.numCities = numCities;
    this.tourPlan  = new int[numCities];
    if (init) {
      makeRandomTourPlan();
      calcTourLength();
    }
  }

  /****************************************************
  *                 Drawing function                  *
  *****************************************************/
  void draw() {
    stroke(drawColor);
    for (int i = 0; i < numCities; i++) {
      int j = (i+1) % numCities;
      line(cities[tourPlan[i]].location.x, cities[tourPlan[i]].location.y, 
        cities[tourPlan[j]].location.x, cities[tourPlan[j]].location.y);
    }
  }
  
  /****************************************************
  *        Evaluations an comparison functions        *
  *****************************************************/
  
  // get distance between two cities
  float getDistance(int i, int j){
    evalCounter++;
    return cities[i].distances[j];
  }
  
  // Calculate tour's tourLength score
  float calcTourLength() {
    tourLength = calcTourLength(tourPlan);
    return tourLength;
  }
  
  float calcTourLength(int[] tour) {
    float fit = 0.0;
    for (int i = 0; i < numCities; i++) {
      int j = (i+1) % numCities;
      fit += getDistance(tour[i],tour[j]);
    }
    return fit;
  }

  // Return tour's tourLength score
  float tourLength() {
    return tourLength;
  }

  // get a random tour plan
  int[] getRandomizedCities(){
    int[] tour = new int[numCities];
    ArrayList<Integer> citiesArray = new ArrayList<Integer>(numCities);
    for (int i = 0; i < numCities; i++) {
      citiesArray.add(i);
    }
    for (int i = 0; i < numCities; i++) {
      int r = (int)random(citiesArray.size());
      tour[i] = citiesArray.get(r);
      citiesArray.remove(r);
    }
    return tour;
  }
  
  // get the nearest neighbour of a city inside the given list of cities
  int getNearestNeighbour(int city, ArrayList<Integer> neighbours){
    int nn=-1;
    float nnDist;
    float dist;
    //initialize
    if(neighbours.size()>0){
      nn=neighbours.get(0);
      nnDist = getDistance(city, nn);
      //loop through distances of current location and keep nearest unvisited
      for (int j = 1; j<neighbours.size(); j++){
        // get distance
        dist = getDistance(city, neighbours.get(j));
        // if distance shorter
        if (dist<nnDist){
          nn=neighbours.get(j);
          nnDist=dist;
        }
      }
    }
    return nn; 
  }
  
  /****************************************************
  *            Tour generation functions              *
  *****************************************************/
  
  // Randomize tour's tour plan
  void makeRandomTourPlan() {
    evalCounter=0;
    tourLength = 0;
    // unvisited places list 
    ArrayList<Integer> unvisited = new ArrayList<Integer>(numCities);
    for (int i = 0; i < numCities; i++) {
      unvisited.add(i);
    }
    // as many times as there are cities
    for (int i=0; i< numCities; i++){
      // take a random location
      int ind = (int)random(unvisited.size()); // random index of an unvisited city
      tourPlan[i] = unvisited.get(ind); 
      unvisited.remove(ind);
      
      //eval add path length to our tour length
      if(i>0){
        tourLength = tourLength+getDistance(tourPlan[i-1], tourPlan[i]);
      }
    }
    tourLength = tourLength + getDistance(tourPlan[0], tourPlan[numCities-1]);
  }
  
  // Make nearest neighbour tour tour plan
  void makeNearestNeighbourTourPlan(){
    evalCounter=0;
    tourLength = 0;
    int startLocation = (int)random(numCities);
    tourPlan[0]=startLocation;
    
    // unvisited places list 
    ArrayList<Integer> unvisited = new ArrayList<Integer>(numCities);
    for (int i = 0; i < numCities; i++) {
      unvisited.add(i);
    }
    
    //initialize to start at location
    int currentLocation = startLocation;
    unvisited.remove(unvisited.get(startLocation));
    
    // as many times as there are cities
    for (int i=1; i< numCities; i++){
      tourPlan[i] = getNearestNeighbour(currentLocation, unvisited);
      currentLocation=tourPlan[i];
      unvisited.remove(unvisited.get(unvisited.indexOf(tourPlan[i])));
      
      //eval add path length to our tour length
      if(i>0){
        tourLength = tourLength+getDistance(tourPlan[i-1], tourPlan[i]);
      }
    }
    tourLength = tourLength + getDistance(tourPlan[0], tourPlan[numCities-1]);
  }
  
  //Make randomized nearest neighbour tour tour plan
  void makeRandNearestNeighbourTourPlan(float randProbability){
    evalCounter=0;
    tourLength = 0;
    int startLocation = (int)random(numCities);
    
    //variables 
    ArrayList<Integer> unvisited = new ArrayList<Integer>(numCities);
    for (int i = 0; i < numCities; i++) {
      unvisited.add(i);
    }
    
    //initialize to start at location
    int currentLocation = startLocation;
    unvisited.remove(unvisited.get(startLocation));
    tourPlan[0] = startLocation; 
    
    // as many times as there are cities
    for (int i=1; i< numCities; i++){
      // probability of taking random location
      if (random(1)<randProbability){
        tourPlan[i] = unvisited.get((int)random(unvisited.size()));
      }
      else{
        tourPlan[i] = getNearestNeighbour(currentLocation, unvisited);
      }
      
      currentLocation=tourPlan[i];
      unvisited.remove(unvisited.get(unvisited.indexOf(tourPlan[i])));
    
      //eval add path length to our tour length
      if(i>0){
        tourLength = tourLength+getDistance(tourPlan[i-1], tourPlan[i]);
      }
    }
    tourLength = tourLength + getDistance(tourPlan[0], tourPlan[numCities-1]);
  }
  
  
  /****************************************************
  *           Tour improvement functions              *
  *****************************************************/

  // initialize the tour following the defined init mode
  // 1 : random tour
  // 2 : nearest neighbour
  // 3 : randomized nearest neighbour
  void initTourPlan(int initMode){
    if (initMode == 1){
      /** missing line here **/
    }
    else if (initMode == 2){
      /** missing line here **/
    }
    else if(initMode == 3){
      /** missing line here **/
    }
  }
    
  // Make tour tour plan with iterative first improvement
  void makeItFirstImprovementTourPlan(int initMode, float randProbability){
    evalCounter=0;
    // initialize
    initTourPlan(initMode);
    
    float prevTourLength = tourLength+1; // +1 to enter into while loop
    while(prevTourLength>tourLength){
      prevTourLength = tourLength;
      firstImprovementStep();
    }
  }
  
  // apply one step of iterative first improvement strategy
  void firstImprovementStep(){
      // try double exchange move until getting a better tour
    int newTour[];
    float newTourLength;
    int[] bestImpTour = Arrays.copyOf(tourPlan,numCities);
    float bestImpTourLength = tourLength;
    for (int i = 0; i<numCities; i++){
      for (int j =0; j<numCities; j++){
        newTour = Arrays.copyOf(tourPlan,numCities);
        newTourLength = twoExchange(newTour,tourLength,i,j);
        if (newTourLength<bestImpTourLength){
          bestImpTour=Arrays.copyOf(newTour,numCities);
          bestImpTourLength=newTourLength;
        }
      }
    }
    tourPlan = bestImpTour;
    tourLength = bestImpTourLength;
  }
  
  // Make tour plan with iterative best improvement
  void makeItBestImprovementTourPlan(int initMode, float randProbability){
    evalCounter=0;
    // initialize
    initTourPlan(initMode);

    float prevTourLength = tourLength+1; // +1 tp enter into while loop
    while(prevTourLength>tourLength){
      prevTourLength = tourLength;
      bestImprovementStep();
    }
  }
  
  // apply one step of iterative best improvement strategy
  void bestImprovementStep(){
    // try double exchange move until getting a better tour
    int newTour[];
    float newTourLength;
    int[] bestImpTour = Arrays.copyOf(tourPlan,numCities);
    float bestImpTourLength = tourLength;
    for (int i = 0; i<numCities; i++){
      for (int j =0; j<numCities; j++){
        newTour = Arrays.copyOf(tourPlan,numCities);
        newTourLength = twoExchange(newTour,tourLength,i,j);
        if (newTourLength<bestImpTourLength){
          bestImpTour=Arrays.copyOf(newTour,numCities);
          bestImpTourLength=newTourLength;
        }
      }
    }
    tourPlan = bestImpTour;
    tourLength = bestImpTourLength;
  }
  
  // apply two exchange move to the tour, between position start and end
  // returns length of the new tour
  float twoExchange(int[] tour, float tourL, int start, int end){
    // make sure that start is before end in our tour
    if(start==end){
      return tourL;
    }
    if (start>end){
      int temp = start;
      start = end;
      end = temp;
    }
    if(start==(end+1)%numCities){
      return tourL;
    }
    
    // get positions of predecessor of start and successor of end
    int precStart = (start-1+numCities)%numCities;
    int succEnd = (end+1)%numCities;
    
    // calculate length of new tour
    float newTourLength = tourL
                        - getDistance(tour[precStart],tour[start]) - getDistance(tour[end], tour[succEnd])
                        + getDistance(tour[succEnd], tour[start]) + getDistance(tour[end], tour[precStart]);
    
    // modify the tour
    int[] segment = new int[end-start+1];
    for (int i = 0; i < end-start+1; i++){
      segment[i]=tour[end-i];
    }
    for (int i = 0; i < end-start+1; i++){
      tour[start+i]=segment[i];
    }
    
    return newTourLength;
  }
  
  /****************************************************
  *         Iterative local search functions          *
  *****************************************************/
 // make a tour with Iterative Local Search strategy
  void makeItLocalSearch(int initMode, float randProbability, int searchMode, int nbSearch){}
  
  // double bridge move on the tour given in entry.
  // returns the length of the new tour
  float doubleBridge(int[] tour){
    return 0.0;
  }
}
