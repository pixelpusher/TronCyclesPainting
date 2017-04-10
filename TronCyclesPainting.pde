// Tron  //<>//
// 
// Modified and adapted by Evan Raskob 2017
// http://pixelist.info
//
// Licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License:
// http://creativecommons.org/licenses/by-nc-sa/4.0/
//

import java.util.LinkedList;
import java.util.ListIterator;

static final int FRAMERATE = 30*2; 
long startTime = 0;  // time sketch was started, for calculating recording times and keypresses
long fakeTime  = 0; //"fake" time when we're rendering, in ms
long lastTime = 0; // last time we added a cycle
final float fakeFrameRate=30.0; // for rendering
final long NextDataPointInterval = 4; // in ms, time between advancing data points
boolean running = true;  // advance data points until false

// directions for cycle movement
final int [] dxs = {
  1, 0, -1, 0
};
final int [] dys = {
  0, -1, 0, 1
};

final int CYCLE_LIFETIME = 10/2;

Grid grid;
LinkedList<Cycle> cycles;
LinkedList<Gesture> gestures;


final int mincycles = 1;
final int maxcycles = 120;
int ncycles;
boolean respawn = false; // respawn cycless automagically after dying

int scaling = 10*2;
int currentseed = 0;
int nextwait = 0;

static final int myW=3508;
static final int myH=2480;

int minMove = 1;


// handle shutdown properly and save recordings -- needs to be library, really
PEventsHandler disposeHandler;

PGraphics ImageBuffer;
/*
void settings()
 {
 //size(srcImg.width,srcImg.height);
 size(myW, myH, P3D);
 }
 */

void setup() 
{
  size(1280, 720, P3D);
  //fullScreen(P3D);
  //ImageBuffer = createGraphics(myW, myH, P3D);
  pixelDensity(displayDensity());
  walkData = loadAllData();
  currentDataRow = 0;
  //println(new int[]{width,height});
  smooth(2);

  // needed to make sure we stop recording properly
  disposeHandler = new PEventsHandler(this);

  grid = new Grid(myW/scaling, myH/scaling);
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

    loadRecording(); // load saved key and mouse presses
    println("...");

    // TODO: 
    // save frame to proper folder!
  }
} // end setup


void draw() 
{
  background(0);
  //println(new int[]{width,height});

  //if (nextwait > 0) 
  //{
  //  if (--nextwait <= 0) next();
  //  else return;
  //}

  //srcImg.loadPixels();

  drawGrayScott();

  int i = 0;

  ListIterator<Cycle> li = cycles.listIterator();
  gsImg.beginDraw();
  gsImg.pushMatrix();
  gsImg.scale(scaling);

  while (li.hasNext()) 
  {
    Cycle c = li.next();

    if (c.alive)
    {
      c.move(grid);
      c.draw();
    } else 
    {
      li.remove();
      c.freeGrid(grid); // clear up used spaces
    }

    //c.draw();
  } //end for all Cycles
  gsImg.popMatrix();

  //if (running)
  //{
  //  for (int ii=0; ii < walkData.length; ii++)
  //  {
  //    float[] dataRow = walkData[ii];
  //    addCycle(int(dataRow[0]/scaling), int(dataRow[1]/scaling));
  //  }
  //  running = false;
  //}
  //ImageBuffer.popMatrix();
  //gsImg.fill(255, 255, 0);
  gsImg.noStroke();
  gsImg.ellipseMode(CENTER);
  for (int ii=0; ii < walkData.length; ii++)
  {
    float[] dataRow = walkData[ii];
    if (dataRow[0] < myW && dataRow[1] < myH)
    {
      //float mq135 = exp(dataRow[2]+1)/exp(2);
      //float mq135 = log(dataRow[2]);
      float mq135 = min(dataRow[2]*dataRow[2], 1f);
      int c = gsColorMap.getARGBToneFor(mq135);

      gsImg.fill(c);
      gsImg.ellipse(int(dataRow[0]), int(dataRow[1]), mq135*scaling*8, mq135*scaling*8);
    }
    //gs.clearRect(int(dataRow[0]), int(dataRow[1]), (int)(mq135*gsScale*2), (int)(mq135*gsScale*2), mq135/5, 0.0);
  }

  gsImg.endDraw();

  imageMode(CORNERS);
  image(gsImg, 0, 0, width, height);

  //if (running && (sketchTime() - lastTime > NextDataPointInterval))
  //if (running && ((frameCount-lastTime) > NextDataPointInterval))
  if (cycles.size() <1)
  {
    lastTime = frameCount;


    float[] dataRow = walkData[currentDataRow];

    if (dataRow[0] > myW || dataRow[1] > myH || dataRow[0] < 0 || dataRow[1] < 0)
    {
    } else
    {
      //addCycle(int(dataRow[0]/scaling), int(dataRow[1]/scaling), sqrt(dataRow[2]));
      addCycle(int(dataRow[0]/scaling), int(dataRow[1]/scaling), dataRow[2]*dataRow[2]);
    }
    int currentDataRow2 = currentDataRow + walkData.length/30;
    currentDataRow2 = currentDataRow2 % walkData.length;

    //iterate a few times
    for (int iii=0; iii<120; iii++) {

      dataRow = walkData[currentDataRow2];
      if (dataRow[0] > myW || dataRow[1] > myH || dataRow[0] < 0 || dataRow[1] < 0)
      {
        currentDataRow2++;
      } else
      {
        addCycle(int(dataRow[0]/scaling), int(dataRow[1]/scaling), dataRow[2]*dataRow[2]);
      }
      currentDataRow2 += walkData.length/30;
      currentDataRow2 = (++currentDataRow + currentDataRow2) % walkData.length;
    }
    // stop if we're out of points
    if (currentDataRow >= walkData.length) 
    {
      currentDataRow %= walkData.length;
      //running = false;
    }
  }


  //  pushMatrix();
  //  scale(scaling);
  for (Gesture g : gestures)
  {
    g.update();
  }
  //  popMatrix();

  //if (grid.isFullySolid()) 
  //{
  //  nextwait = 2*30;
  //}
}


void next() {
  randomSeed(currentseed++);
  float burnone = random(1.0);

  // imgMode = int(random(0,imgModes.length));

  background(0);
  //pushStyle();
  //noStroke();
  //fill(0, 120);
  //rectMode(CORNER);
  //rect(0, 0, width, height);
  //popStyle();

  grid.clear();
  grid.setDims(myW/scaling, myH/scaling);
  cycles.clear();
  /*
  ncycles = (int)random(mincycles, maxcycles);
   for (int i=0; i<ncycles; i++) {
   int x = (int)random(grid.getWidth());
   int y = (int)random(grid.getHeight());
   Cycle w = new Cycle(x, y, CYCLE_LIFETIME);
   cycles.add(w);
   grid.set(x, y, Grid.SOLID);
   }
   */
}


Cycle addCycle(int x, int y, float val)
{
  Cycle w = new Cycle(x, y, CYCLE_LIFETIME, val);

  if (cycles.size() >= maxcycles)
  {
    Cycle first = cycles.removeFirst();
    first.freeGrid(grid); // clear up used spaces
  }
  cycles.add(w);
  grid.set(x, y, w.val);

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