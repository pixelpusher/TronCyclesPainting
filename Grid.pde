// //<>// //<>//
// simple 2D binary "Grid" 
// 
class Grid 
{
  static final float CLEAR = 2f;
  private float [][] cells;
  private int width, height;

  private int cellcount, solidcount;

  Grid(int w, int h) 
  {
    setDims(w, h);
  }

  int getWidth() 
  {
    return this.width;
  }

  int getHeight()
  {
    return this.height;
  }

  Grid setDims(int w, int h) {
    this.width = w;
    this.height = h;
    cells = new float[this.width][this.height];
    cellcount = this.width*this.height;
    clear();
    return this;
  }

  void clear() 
  {
    for (int x=0; x<this.width; x++)
      for (int y=0; y<this.height; y++)
        cells[x][y] = CLEAR;

    if (gs != null) gs.reset();
    solidcount = 0;
  }

  boolean isValidCoords(int x, int y) {
    return ((x > -1) && (y > -1) && (x < this.width) && (y < this.height));
  }

  boolean isFullySolid() 
  {
    return ( solidcount == cellcount );
  }

  boolean set(int x, int y, float val) 
  {
    boolean success = false;

    if (isValidCoords(x, y)) {
      if ((cells[x][y] != Grid.CLEAR) && (val == Grid.CLEAR)) {
        // grayScott - don't clear!
        // gs.clearRect(scaling*x, scaling*y, gsScale, gsScale);
        solidcount--;
      } else if ((cells[x][y]== Grid.CLEAR) && (val != Grid.CLEAR)) 
      {
        solidcount++;
        // grayScott
        //println("set " + millis());
        gs.clearRect(scaling*x, scaling*y, gsScale, gsScale, 0.25f, val);
      }
      cells[x][y] = val;
      success = true;
    }
    return success;
  }

  boolean setRect(int x, int y, int w, int h, float val)
  {
    boolean result = true;
    for (int yy = y; y < y+h; y++)
      for (int xx = x; x < x+w; x++)
        result = result && set(xx, yy, val);

    return result;
  }

  float get(int x, int y) 
  {
    if (isValidCoords(x, y))
      return cells[x][y];
    else
      return -1f;
  }

  //  float isClear(int x, int y) 
  //  {
  //    float result = SOLID; 
  //    if (isValidCoords(x,y))
  //      result = this.get(x,y);
  //    return result; 
  //  }
}