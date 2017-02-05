//
// drawn Gesture
//

class Gesture 
{
  int x, y;
  color c, deadColor;
  boolean alive, finished;
  static final int MAXPOINTS = 20;

  private LinkedList<PVector> path;
  private int maxLife=0; // max number of ticks this 'lives' for
  private int currentLife=0; // current 'tick'

  private PShape pathShape;

  Gesture(int _x, int _y, int _maxLife) {
    init(_x, _y, _maxLife);
  }

  //
  // reset or re-init the Gesture
  //
  Gesture init(int _x, int _y, int _maxLife) {
    x = _x;
    y = _y;
    finished = false;
    setmaxLife(_maxLife);

    c = color(255);
    deadColor = color(180, 100, 180);
    alive = true;

    path = new LinkedList<PVector>();

    addPoint(x, y);

    return this;
  }

  //
  // set how many ticks (or points) this Gesture 'lives' for
  //
  Gesture setmaxLife(int i)
  {
    i = max(i, 1); // less than 1 is dumb
    maxLife = i;
    currentLife = 0; // reset elapsed time count

    return this;
  }

  void freeGrid(Grid g)
  {
    for (PVector v : path) 
    {
      grid.set((int)v.x, (int)v.y, Grid.CLEAR);
    }
  }

  void addPoint(int _x, int _y)
  {
    path.add(new PVector(_x, _y));
    if (path.size() > MAXPOINTS)
    {
      path.remove(0);
    }

    // Now make the PShape with those vertices
    pathShape = null;

    pathShape = createShape();
    pathShape.beginShape();
    pathShape.noFill();
    pathShape.stroke(c);
    pathShape.strokeWeight(4);

    for (PVector v : path) 
    {
      pathShape.vertex(v.x, v.y);
    }
    pathShape.endShape();
  }

  void update() 
  {
    if (finished) {

      if (currentLife < maxLife) 
      {
        currentLife++;


        // TODO: update color alpha based on life
        //c = ( ((int(map(currentLife,0,maxLife,0,255)) >> 6) | 0x00FFFFFF) & c); // ???
        int alpha = (int)map(currentLife, 0, maxLife, 255, 0);

        c = color(255,0,0, alpha);
        pathShape.setStroke(c);
      } else
      {
        alive = false;

        //pathShape.setStroke(deadColor); // huh? got to rethink this
      }
    }
  }// end move


  void draw() 
  {
    if (pathShape != null) 
      shape(pathShape);

    //noStroke();
    //fill(c);
    //rectMode(CENTER);
    
    for (PVector p : path)
    {
      //gs.clearRect((int)p.x, (int)p.y, 2, 2);
    }
    
    /*
    for (PVector p : path)
    {
      rect(p.x, p.y, 1, 1);
    }
    */
  }

  // end class Gesture
}