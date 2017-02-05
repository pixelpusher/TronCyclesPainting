//
// simple 2D binary "Grid" 
// 
class Grid 
{
  static final boolean CLEAR = true;
  static final boolean SOLID = false;
  private GridCell [][] cells; // for fast lookup of values
  private int _width, _height;
  private ArrayList<TreeNode<GridCell>> trees; // all the paths in this grid.  Initially, all will be clear and on same leve

  private int cellcount, solidcount;


  Grid(int w, int h) 
  {
    setDims(w, h);
  }

  int getWidth() 
  {
    return _width;
  }

  int getHeight()
  {
    return _height;
  }

  Grid setDims(int w, int h) {
    _width = w;
    _height = h;
    cells = new GridCell[_width][_height];
    trees = new ArrayList<TreeNode<GridCell>>();
    for (int i=0; i < _width*_height; i++)
    {
      GridCell cell = new GridCell(i%w, int(i/h));
      cell.properties.add("color", color(255));
      cell.properties.add("state", Grid.CLEAR);
      cells[x][y] = cell;
    }

    cellcount = _width*_height;
    clear();
    return this;
  }



  void clear() 
  {
    ArrayList<TreeNode<GridCell>> rootNodes = new ArrayList<TreeNode<GridCell>>(trees);

    // only one node to delete for each
    for (TreeNode<GridCell> t : rootNodes)
    {
      t.state = CLEAR;

      TreeNode<GridCell> _t = t;

      while (_t.hasChild())
      {
        _t = _t.getChild();
        _t.properties.get("state") == Grid.CLEAR;
      }
    }

    trees.clear();

    /*
    for (int x=0; x<_width; x++)
     for (int y=0; y<_height; y++)
     cells[x][y] = CLEAR;
     */
    solidcount = 0;
  }

  boolean isValidCoords(int x, int y) {
    return ((x > -1) && (y > -1) && (x < _width) && (y < _height));
  }

  boolean isFullySolid() 
  {
    // TODO: fixme
    return ( solidcount == cellcount );
  }

  boolean set(int x, int y, boolean state) 
  {
    boolean success = false;

    if (isValidCoords(x, y)) {
      if ((cells[x][y]==SOLID) && (state==CLEAR)) solidcount--;
      if ((cells[x][y]==CLEAR) && (state==SOLID)) solidcount++;
      cells[x][y] = state;
      success = true;
    }
    return success;
  }

  boolean get(int x, int y) 
  {
    if (isValidCoords(x, y))
      return cells[x][y];
    else
      return SOLID;
  }


  //
  // returns null if it is full - exceptions would be cleaner
  //
  TreeNode<GridCell> startPath(int x, int y)
  {
    return startPath(x, y, false);
  }

  //
  // returns null if it is full - exceptions would be cleaner
  //
  TreeNode<GridCell> startPath(int x, int y, boolean force)
  {
    TreeNode<GridCell> newPath = null;
    GridCell targetCell = cells[x][y];

    if (get(x, y))
    {
      newPath = new TreeNode<GridCell>(targetCell);
      trees.add(newPath);
    } else if (force)
    {
      TreeNode<GridCell> _t;

      // look through each root tree
      for (TreeNode<GridCell> t : trees)
      {
        _t = t;  
        // check for this node
        if (t.value.equals(targetCell))
        {
          // set clear
          _t.value.reset();

          // clear the path after it
          while (_t.hasChildren())
          {
            // set clear
            _t = _t.getChild();
            _t.value.reset();
          }
        }

        //clear this grid cell
        // start new path
        newPath = new TreeNode<GridCell>(targetCell);
        trees.add(newPath);
      }
    }

    return newPath;
  }


  //
  // add to a path and return next node
  //

  TreeNode<GridCell> addToPath(TreeNode<GridCell> path, int x, int y)
  {
    return addToPath(path, x, y, false);
  }

  TreeNode<GridCell> addToPath(TreeNode<GridCell> path, int x, int y, boolean force)
  {
    TreeNode<GridCell> nextPath = null;
    GridCell targetCell = cells[x][y];

    // check if we are adding ourselves...
    if (!path.value.equals(targetCell) && get(x, y))
    {
      nextPath = new TreeNode<GridCell>(targetCell);
      path.addChild(nextPath);
    } else if (force)
    {
      TreeNode<GridCell> _t = path;

      // check for this node
      if (t.value.equals(targetCell))
      {
        // set clear
        _t.value.reset();

        // clear the path after it
        while (_t.hasChildren())
        {
          // set clear
          _t = _t.getChild();
          _t.value.reset();
        }
      }

      //clear this grid cell
      // start new path
      nextPath = new TreeNode<GridCell>(targetCell);
      path.add(newPath);
    }

    return newPath;
  }


  //  boolean isClear(int x, int y) 
  //  {
  //    boolean result = SOLID; 
  //    if (isValidCoords(x,y))
  //      result = this.get(x,y);
  //    return result; 
  //  }



  //not used
  /*
      // TODO: fixme
   for (TreeNode<GridCell> t : rootNodes)
   {
   TreeNode<GridCell> _t = t;
   
   if (t.x == x && t.y == y)
   return t.state; 
   
   while (_t.hasChild())
   {
   // do something
   _t = t.getChild();
   
   if (t.x == x && t.y == y)
   return t.state; 
   }
   }
   */


  void rebuildShapes()
  {
    // TODO
  }


  void draw()
  {
    // make new PShape? 
    // to do 
    // loop through all paths
    // draw lines or whatever between them
    // use gridcell color
  }
}