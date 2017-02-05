// 
// Inner class representing cell state for unitary TreeNodes
//

import java.util.HashMap;


class GridCell
{
  int x, y;
  HashMap properties = null; // shapes, etc.

  // direction is based on polar function at pi/2 intervals: 0, pi/2, pi, 3*pi/2
  // or top, right, bottom, left 
  //float direction = 0f; // r*sin(0) + r*cos(0)

  GridCell() {
    reset();
  };

  GridCell(int _x, int _y) 
  {
    x = _x;
    y = _y;
    reset();
  }

  boolean equals(GridCell other)
  {
    boolean result = false;
    if ( other.x == x && other.y == y)
      result = true;

    return result;
  }

  GridShape reset()
  {
    if (properties != null) properties.clear();
    else properties = new HashMap();
    state = Grid.CLEAR;
  }
} //end GridCell