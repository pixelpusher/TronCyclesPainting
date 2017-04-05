boolean theMouseDown = false;
int smouseX  =0, 
  smouseY  =0, 
  spmouseX =0, 
  spmouseY =0, 
  smState  =0;

float startMouseX = 0;
float endMouseX   = 0;
float startMouseY = 0;
float endMouseY   = 0;

LinkedList jtMouseEvents;

int formatRecMouseXPos(String mXp)
{
  return (int)((float)myW *  float(mXp)/(float)recScreenWidth);
}


int formatRecMouseYPos(String mYp)
{
  return (int)((float)myH * float(mYp)/(float)recScreenHeight);
}



int sketchMouseX()
{
  if (!rendering) return mouseX;
  else return smouseX;
}

int sketchMouseY()
{
  if (!rendering) return mouseY;
  else return smouseY;
}

int sketchpMouseX()
{
  if (!rendering) return pmouseX;
  else return spmouseX;
}

int sketchpMouseY()
{
  if (!rendering) return pmouseY;
  else return spmouseY;
}

void mousePressed()
{
  //if (!rendering) jtMouseEvents.add(new jtMouseEvent(mouseX, pmouseX, mouseY, pmouseY, "pressed"));
  // check for key down - if special key, draw circular slider to select gesture

  handleMousePressed();
}

void handleMousePressed()
{
  if (!theMouseDown)
  {
    theMouseDown = true;
    startMouseX=sketchMouseX();
    startMouseY=sketchMouseY();

    // note last point
    _lastP = new PVector(startMouseX/scaling, startMouseY/scaling);
    grid.set((int)_lastP.x, (int)_lastP.y, Grid.CLEAR);

    addCycle((int)_lastP.x, (int)_lastP.y);
    gestures.push(new Gesture((int)_lastP.x, (int)_lastP.y, CYCLE_LIFETIME*4)); // first is always current
  }


  //println("pressed: " + sketchMouseX() + ", " + sketchMouseY());
}



void mouseDragged()
{
  //if (!rendering) jtMouseEvents.add(new jtMouseEvent(mouseX, pmouseX, mouseY, pmouseY, "dragged"));
  handleMouseDragged();
}

//
// add cycle if 
//

PVector _lastP = null;

void handleMouseDragged()
{
  theMouseDown = true;
  int gridX = sketchMouseX()/scaling;
  int gridY = sketchMouseY()/scaling;
 
  if (dist(gridX, gridY, _lastP.x, _lastP.y) > minMove)
  {
    addCycle(gridX, gridY);
    Gesture g = gestures.peek();
    g.addPoint(gridX, gridY);
    _lastP.x = gridX;
    _lastP.y = gridY;
  }
}

void mouseMoved()
{
  //if (!rendering) jtMouseEvents.add(new jtMouseEvent(mouseX, pmouseX, mouseY, pmouseY, "moved"));
  handleMouseMoved();
}

void handleMouseMoved()
{
  theMouseDown = false;
}


void mouseReleased()
{
  //if (!rendering) jtMouseEvents.add(new jtMouseEvent(mouseX, pmouseX, mouseY, pmouseY, "released"));
  handleMouseReleased();
}  

void handleMouseReleased()
{
  theMouseDown = false;
  
  // would need fixing later
  Gesture g = gestures.peek();
  g.finished = true;
}