// Tron 
// 
// Modified and adapted by Evan Raskob 2017
// http://pixelist.info
//
// Licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License:
// http://creativecommons.org/licenses/by-nc-sa/4.0/
//

import java.util.LinkedList;
import java.util.ListIterator;

static int FRAMERATE = 30*2; 
long startTime = 0;  // time sketch was started, for calculating recording times and keypresses
long fakeTime  = 0; //"fake" time when we're rendering, in ms
long lastTime = 0;
float fakeFrameRate=30.0; // for rendering

boolean updateSimulation = true; // update simulation - used in tidal (OSC)
boolean updateAlways = false; // set to true if not using tidal!
String imageMode = MIRROR_IMAGE;

final int [] dxs = {
  1, 0, -1, 0
};
final int [] dys = {
  0, -1, 0, 1
};

int cycleLifetime = Cycle.MAX_CYCLE_LIFETIME;

Grid grid;
LinkedList<Cycle> cycles;
LinkedList<Gesture> gestures;


final int mincycles = 1;
final int maxcycles = 20;
int ncycles;
boolean respawn = false; // respawn cycless automagically after dying

int scaling = 16;
int currentseed = 0;
int nextwait = 0;

static int myW=1280;
static int myH=720;

int minMove = 1;

// handle shutdown properly and save recordings -- needs to be library, really
PEventsHandler disposeHandler;

//PGraphics cycleImageBuffer;

void settings()
{
  //size(srcImg.width,srcImg.height);
  size(myW, myH, P3D);
}

void setup() {
  //fullScreen();
  smooth(2);

  // needed to make sure we stop recording properly
  disposeHandler = new PEventsHandler(this);

  grid = new Grid(width/scaling, height/scaling);
  strokeWeight(1);  

  frameRate(FRAMERATE);
  cycles = new LinkedList<Cycle>();
  gestures = new LinkedList<Gesture>();

  setupGrayScott();

  background(0);
  //image(srcImg, 0,0);
  next();

  // event rendering system
  jtMouseEvents = new LinkedList();
  jtKeyEvents = new LinkedList();

  if (rendering)
  {
    String sString = "cycles_" + year() + month() + day() + "_" + hour() + "-" + minute() + "-" + second()+".mov";
    println("rendering TO DISK: " + sString);

    /*
      mm = new GSMovieMaker(this, width, height, "sString.ogg", GSMovieMaker.THEORA, GSMovieMaker.HIGH, (int)fakeFrameRate);
     mm.start();
     */

    /*mm = new MovieMaker(this, width, height, sString,
     (int)frameRate, MovieMaker.JPEG, MovieMaker.HIGH);
     */
    loadRecording(); // load saved key and mouse presses
    println("...");
  }

  // do this last, otherwise nullpointer errors...
  setupOSC();
} // end setup


void draw() 
{
  background(0);

  if (nextwait > 0) 
  {
    if (--nextwait <= 0) next();
    else return;
  }

  //srcImg.loadPixels();
  if (updateSimulation)
    drawGrayScott();

  int i = 0;

  gsImg.beginDraw();
  gsImg.pushMatrix();
  gsImg.scale(scaling/gsScale);
  for (Cycle c : cycles)
    c.draw();
  gsImg.popMatrix();
  gsImg.endDraw();


  if (imageMode == LEFT_IMAGE || imageMode == MIRROR_IMAGE)
  {
    imageMode(CORNERS);
    blendMode(ADD);
    image(gsImg, 0, 0, width, height);
  }

  if (imageMode == RIGHT_IMAGE || imageMode == MIRROR_IMAGE)
  {
    pushMatrix();
    scale(-1, 1);
    image(gsImg, 0, 0, -width, height);
    popMatrix();
  }

  if (updateSimulation || updateAlways)
  {
    pushMatrix();
    scale(scaling);


    ListIterator<Cycle> li = cycles.listIterator();

    while (li.hasNext()) 
    {
      Cycle c = li.next();

      if (c.alive)
      {
        c.move(grid);
        //c.draw();
      } else 
      {
        li.remove();
        c.freeGrid(grid); // clear up used spaces

        if (respawn)
        {
          addCycle(sketchMouseX()/scaling, sketchMouseY()/scaling);
        }
      }

      //c.draw();
    } //end for all Cycles

    //gsImg.popMatrix();
    //gsImg.endDraw();

    popMatrix();
    updateSimulation = false;
  }

  pushMatrix();
  scale(scaling);
  for (Gesture g : gestures)
  {
    g.update();
    if (g.alive)
    {
      //g.draw();
    }
  }
  popMatrix();

  if (grid.isFullySolid()) 
  {
    nextwait = 2*30;
  }
}


void next() {
  randomSeed(currentseed++);
  float burnone = random(1.0);
  background(0);
  grid.clear();
  grid.setDims(width/scaling, height/scaling);
  cycles.clear();
}


Cycle addCycle(int x, int y)
{
  Cycle w = new Cycle(x, y, cycleLifetime);

  if (cycles.size() >= maxcycles)
  {
    Cycle first = cycles.removeFirst();
    first.freeGrid(grid); // clear up used spaces
  }
  cycles.add(w);
  grid.set(x, y, Grid.SOLID);

  return w;
}

color blendC(color c1, color c2, float t) {

  //int a = (c1 >> 24) & 0xFF;
  int r1 = (c1 >> 16) & 0xFF;  // Faster way of getting red(argb)
  int g1 = (c1 >> 8) & 0xFF;   // Faster way of getting green(argb)
  int b1 = c1 & 0xFF;          // Faster way of getting blue(argb)

  int r2 = (c2 >> 16) & 0xFF;  // Faster way of getting red(argb)
  int g2 = (c2 >> 8) & 0xFF;   // Faster way of getting green(argb)
  int b2 = c2 & 0xFF;          // Faster way of getting blue(argb)

  t = min(max(t, 0), 1.0);

  return color( r1+t*(r2-r1), g1+t*(g2-g1), b1+t*(b2-b1) );
}