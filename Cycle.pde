//
// light cycle
//

class Cycle 
{
  int x, y;
  int skip = 1;
  ReadonlyTColor c;
  boolean alive;
  float val;

  private ArrayList<PVector> path;
  private int ox, oy, dir, handedness;
  private int maxLife=0; // max number of ticks this 'lives' for
  private int currentLife=0; // current 'tick'

  private PShape pathShape;

  Cycle(int _x, int _y, int _maxLife, float _val) {
    init(_x, _y, _maxLife, _val);
  }

  //
  // reset or re-init the Cycle
  //
  Cycle init(int _x, int _y, int _maxLife, float _val) {
    val = _val;
    ox = x = _x;
    oy = y = _y;
    alive = true;
    dir = millis()%4;
    c = gsColorMap.getToneFor(val).copy();
    handedness = (random(1.0)>0.5) ? 1 : 3;
    setmaxLife(_maxLife);

    // set all points to original location
    for (PVector point : path)
    {
      point.set(ox, oy);
    }
    //skip = int(random(1,3));

    return this;
  }

  //
  // set how many ticks (or points) this Cycle 'lives' for
  //
  Cycle setmaxLife(int i)
  {
    i = max(i, 1); // less than 1 is dumb
    maxLife = i;
    currentLife = 0; // reset elapsed time count

    path = null; // force garbage collection...
    path = new ArrayList<PVector>(maxLife);

    while (path.size() <maxLife)
    {
      path.add(new PVector(ox, oy));
    }

    // Now make the PShape with those vertices
    pathShape = createShape();
    
    pathShape.beginShape();
    pathShape.noFill();
    pathShape.stroke(c.toARGB());
    pathShape.strokeWeight(scaling/2);

    for (PVector v : path) 
    {
      pathShape.vertex(v.x, v.y);
    }
    pathShape.endShape();

    return this;
  }

  void freeGrid(Grid g)
  {
    for (PVector v : path) 
    {
      grid.set((int)v.x, (int)v.y, Grid.CLEAR);
    }
  }


  void move(Grid g) 
  {
    currentLife++;
    if (currentLife < maxLife) 
    {

      // only reason we check dir+2 is when just-reborn
      //  and thus just assigned a new random direction
      // otherwise we know it's blocked by our own trail
      int [] checkorder = { 
        (dir+handedness)%4, dir, (dir+handedness*3)%4, (dir+2)%4
      };

      int newx=x, newy=y, newd=dir;
      for (int i=0; i<4; i++) {
        newd = checkorder[i];
        newx = x + dxs[newd]/skip;
        newy = y + dys[newd]/skip;
        if (g.get(newx, newy) == Grid.CLEAR)
          break;
      }

      // move or die
      if (g.get(newx, newy) == Grid.CLEAR) //<>//
      {
        //println("move " + millis());
        if ((x!=newx) || (y!=newy))  //<>//
        {
          ox = x;
          oy = y;
          x = newx;
          y = newy;
          dir = newd;
          // update grid
          g.set(newx, newy, this.val);
          // update path
          path.get(currentLife).set(newx, newy);
          float f = currentLife/(float)maxLife;
          
          //pathShape.setStroke(currentLife,color(255, (int)(255f*f*f)));
          pathShape.setStroke(c.getLightened(f*f).toARGB());
          for (int i=currentLife; i>0; i--)
          {
            PVector v = pathShape.getVertex(maxLife-i);
            pathShape.setVertex(maxLife-i-1,v);
            
          }
          pathShape.setVertex(maxLife-1, newx, newy);
          
          
        }       
      } 
      else 
      {
        alive = false;
        //pathShape.setStroke(deadColor);
      }
    }
    else {
      alive = false;
        //pathShape.setStroke(deadColor); // huh? got to rethink this
    }
  }// end move


  void draw() 
  {
    gsImg.shape(pathShape);
  }
}