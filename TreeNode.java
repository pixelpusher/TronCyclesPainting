//
// simple tree structure where trees are designed to have only one child each (distinct paths) 
// 

public class TreeNode<T> 
{
  private T value;

  TreeNode<T> child;

  TreeNode(T _value) 
  {
    value = _value;
    child = null;
  }

  //
  // return immutable value
  //
  public T getValue()
  {
    return value;
  }

  public boolean hasChild()
  {
    if (child == null) 
      return false;
    else 
    return true;
  }

  public TreeNode<T> addChild(TreeNode<T> node)
  {
    child = node;

    return this;
  }

  public TreeNode<T> getChild()
  {
    return child;
  }

  // end class TreeNode
};