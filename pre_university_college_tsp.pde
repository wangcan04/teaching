// Travelling Salesperson Problem (TSP) solving using Iterative Local Search. 
// Given a list of cities and their pairwise distances, the task is 
// to find the shortest possible tour that visits each city exactly once.
//
// This code was based on code by Ergun Coruh (November 2011),
// largely changed by Maarten Lamers and Lise Stork (2016/2017),
// and then again by Marie Anastacio (2018) for educational purpose


import java.util.*;
import grafica.*;

/****************************************************
*              Variables and constants              *
*****************************************************/

// Presentation configuration
int     xSize        = 550;         // Canvas width
int     ySize        = 550;         // Canvas height
int     backColor    = #000000;     // Canvas color
float   cityDiam     = 5.0;         // City diameter

// Some global variables
City[]  cities                 = null;   // An array of cities
int     numCities              = 0;      // Number of cities
Tour tour                      = null;   // calculated tour
ArrayList<Tour> population     = null;   // An array of tours
boolean redrawAll              = false;  // flags when canvas must be redrawn
int MANUAL                     = 0;      // constant to represent algorithm initialisation mode
int RANDOM                     = 1;      // constant to represent algorithm initialisation mode
int NEARESTNEIGHBOUR           = 2;      // constant to represent algorithm initialisation mode
int RANDNEARESTNEIGHBOUR       = 3;      // constant to represent algorithm initialisation mode
int BESTIMPROV                 = 1;      // constant to represent Iterative Local Search mode
int FIRSTIMPROV                = 2;      // constant to represent Iterative Local Search mode

// Some parameters
String citiesFile = "capitalNL.csv";    // The file containing the list of cities
float randNNProb  = 0.15;        // Probability to take a random direction in the randomized nearest neighbour
int initMode      = RANDOM;      // Method used to inialise the tour
int searchMode    = FIRSTIMPROV; // Method used to search for a better tour
int nbIteration   = 100;         // Number of iteration for Iterative Local Search


/****************************************************
*              Initialisation functions             *
*****************************************************/

// setup() function is called when you launch the program
// it creates the window and load the map from the file
void setup() {
  size(550, 586);
  smooth();
  background(backColor);
  // map
  create_map();
  tour = new Tour(cities, numCities, true);
  redrawAll = true;
}

// create_map() function loads the map from the file specified in parameters and size it to the window
void create_map() {
  load_csv();
  // calculate distances between cities
  for (int i = 0; i < numCities; i++) {
    cities[i].calcDistances(cities, numCities);
  }
}


/****************************************************
*                 Keyboard commands                 *
*****************************************************/

// keyPressed() function determine what happens when a key is pressed
void keyPressed() 
{
  if (key != CODED) {
    switch(key) {
    case 'r': // generate a random tour
      create_randomtours();
      redrawAll = true;
      break;
    case 'n': // generate a tour using nearest neighbour
      create_nearestneighbour();
      redrawAll = true;
      break;
    case 'N': // generate a tour using randomized nearest neighbour
      create_randnearestneighbour();
      redrawAll = true;
      break;
    case 'f': // one step of 2-exchange first improvement
      increment_firstimprovement();
      redrawAll = true;
      break;
    case 'F': // iterative 2-exchange first improvement
      create_iterativefirstimprovement();
      redrawAll = true;
      break;
    case 'b': // one step of 2-exchange first improvement
      increment_bestimprovement();
      redrawAll = true;
      break;
    case 'B': // iterative 2-exchange first improvement
      create_iterativebestimprovement();
      redrawAll = true;
      break;
    case 'i': // iterative local search
      create_itlocalsearch();
      redrawAll = true;
      break;
    case 'w' : // write current tour to csv
      write_tour_csv();
      break;
    default:
      break;
    }
  }
}

// Create random tour
void create_randomtours() {
  tour.makeRandomTourPlan();
}

// Create nearest neighbour tour
void create_nearestneighbour(){
  tour.makeNearestNeighbourTourPlan();
}

// Create nearest neighbour tour
void create_randnearestneighbour(){
  tour.makeRandNearestNeighbourTourPlan(randNNProb);
}

// Create iterative first improvement tour
void create_iterativefirstimprovement(){
  tour.makeItFirstImprovementTourPlan(initMode, randNNProb);
}
// Apply once the first improvement step
void increment_firstimprovement(){
  tour.firstImprovementStep();
}

// Create iterative best improvement tour
void create_iterativebestimprovement(){
  tour.makeItBestImprovementTourPlan(initMode, randNNProb);
}
// Applay once the best improvement step
void increment_bestimprovement(){
  tour.bestImprovementStep();
}

// Create iterative Local Search tour
void create_itlocalsearch(){
  tour.makeItLocalSearch(initMode, randNNProb, searchMode, nbIteration);
}


/****************************************************
*                 Drawing functions                 *
*****************************************************/

// draw() function is called in loop to redraw the map if needed
void draw() {
  if (redrawAll) {
    drawTour();
    drawStatus();
    redrawAll = false;
  }
}

// Draw cities and the best tour from the population
void drawTour()
{
  background(0);
  // draw cities
  for (int i = 0; i < numCities; i++) {
    cities[i].draw();
  }
  // draw the best tour
  tour.draw();
}

// Draw status values
void drawStatus() {
  noStroke();
  fill(#242424);
  rect(0, ySize+2, xSize, 36);
  fill(0, 240, 20);
  text("cities : " + numCities + "; tour length : " + str(int(tour.tourLength()))+"; # distance lookup : "+ str(tour.evalCounter), 10, ySize + 32);
}

/****************************************************
*                   csv functions                   *
*****************************************************/

void write_tour_csv(){
  String fileName = "tour.csv";
  PrintWriter fileWriter = createWriter(fileName);
  fileWriter.println("Name");
  City c;
  for (int i = 0; i<numCities; i++){
    c = cities[tour.tourPlan[i]];
    fileWriter.println(c.name);
  }
  fileWriter.flush();
  fileWriter.close();
}

void load_csv(){
  PVector v;
  String name="";

  // -- load data --
  float maxLat=-180, maxLong=-180, minLat=180, minLong=180, ratio = 1;
  Table data = new Table(); 
  // read file
  data = loadTable(citiesFile, "header");
  for (TableRow row : data.rows()) { //find maximal & minimal latitude & max, min longitude for conversion to pixelspace
    maxLat  = max(maxLat, row.getFloat("Latitude"));
    maxLong = max(maxLong, row.getFloat("Longitude"));
    minLat  = min(minLat, row.getFloat("Latitude"));
    minLong = min(minLong, row.getFloat("Longitude"));
    numCities++;
  }
  ratio = (maxLong - minLong) / (maxLat - minLat);
  // convert file content to our format
  println("Create new map");
  cities = new City[numCities];
  for (int i = 0; i < numCities; i++) {
    float x, y;
    TableRow row = data.getRow(i);
    name = row.getString("Name");
    x = map(row.getFloat("Longitude"), minLong, maxLong, cityDiam/2, xSize - (cityDiam/2));
    y = map(row.getFloat("Latitude"), minLat, maxLat, xSize - (cityDiam/2), cityDiam/2);
    v = new PVector((x / max(ratio, 1)), (y * min(ratio, 1)));
    cities[i] = new City(i, name, v.x, v.y);
  }
}