//
// simple 2D binary "Grid" 
// 
class Grid 
{
  static final boolean CLEAR = true;
  static final boolean SOLID = false;
  private boolean [][] cells;
  private int width, height;

  private int cellcount, solidcount;

  Grid(int w, int h) 
  {
    setDims(w, h);
  }

  int getWidth() 
  {
    return width;
  }

  int getHeight()
  {
    return height;
  }

  Grid setDims(int w, int h) {
    width = w;
    height = h;
    cells = new boolean[width][height];
    cellcount = width*height;
    clear();
    return this;
  }

  void clear() 
  {
    for (int x=0; x<width; x++)
      for (int y=0; y<height; y++)
        cells[x][y] = CLEAR;
    solidcount = 0;
  }

  boolean isValidCoords(int x, int y) {
    return ((x > -1) && (y > -1) && (x < width) && (y < height));
  }

  boolean isFullySolid() 
  {
    return ( solidcount == cellcount );
  }

  boolean set(int x, int y, boolean state) 
  {
    boolean success = false;

    if (isValidCoords(x, y)) {
      if ((cells[x][y]==SOLID) && (state==CLEAR)) {
        // grayScott
        //gs.clearRect(x, y, 2, 2);
        solidcount--;
      }
      if ((cells[x][y]==CLEAR) && (state==SOLID)) {
        solidcount++;
        // grayScott
        gs.setRect(gsScale*x, gsScale*y, scaling/gsScale, scaling/gsScale);
      } 
      cells[x][y] = state;
      success = true;
    }
    return success;
  }

  boolean setRect(int x, int y, int w, int h, boolean state)
  {
    boolean result = true;
    for (int yy = y; y < y+h; y++)
      for (int xx = x; x < x+w; x++)
        result = result && set(xx, yy, state);

    return result;
  }

  boolean get(int x, int y) 
  {
    if (isValidCoords(x, y))
      return cells[x][y];
    else
      return SOLID;
  }

  //  boolean isClear(int x, int y) 
  //  {
  //    boolean result = SOLID; 
  //    if (isValidCoords(x,y))
  //      result = this.get(x,y);
  //    return result; 
  //  }
}