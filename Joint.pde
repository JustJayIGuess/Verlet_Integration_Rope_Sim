class Joint implements INetworkElement 
{
  public PVector position;
  public PVector prevPosition;
  public boolean isFixed;
  public boolean followMouse;
  
  public ArrayList<Rod> connectedRods = new ArrayList<Rod>();
  
  Joint(float x, float y, boolean _isFixed, boolean _followMouse)
  {
    position = new PVector(x, y);
    prevPosition = position.copy();
    isFixed = _isFixed;
    followMouse = _followMouse;
  }
  
  Joint(PVector vect, boolean _isFixed, boolean _followMouse)
  {
    position = vect.copy();
    prevPosition = position.copy();
    isFixed = _isFixed;
    followMouse = _followMouse;
  }
  
  public float getDistanceTo(PVector point) 
  {
    return PVector.dist(position, point);
  }
  
  public void paint(int r, int g, int b) 
  {
    stroke(r, g, b);
    fill(r, g, b);
    square(position.x - 2, position.y - 2, 4);
  }
  
  public void destroy(Network network, int particleCount) 
  {
    if (!followMouse)
    {
      network.joints.remove(network.joints.indexOf(this));
      network.rods.removeAll(connectedRods);
      network.particleSystem.burst(particleCount, position, 0, 400, 2);
    }
  }

  public boolean isInLineSegment(PVector lineSegA, PVector lineSegB, float lineSegWidth)
  {
    PVector xPosLineSeg = lineSegA.x > lineSegB.x ? lineSegA : lineSegB;
    PVector xNegLineSeg = lineSegA.x > lineSegB.x ? lineSegB : lineSegA;
    PVector yPosLineSeg = lineSegA.y > lineSegB.y ? lineSegA : lineSegB;
    PVector yNegLineSeg = lineSegA.y > lineSegB.y ? lineSegB : lineSegA;

    if (position.x < xPosLineSeg.x + lineSegWidth && position.x > xNegLineSeg.x - lineSegWidth && position.y < yPosLineSeg.y + lineSegWidth && position.y > xNegLineSeg.y - lineSegWidth)
    {
      return Utils.distFromPointToLine(lineSegA, lineSegB, position) < lineSegWidth;
    }

    return false;
  }
}
