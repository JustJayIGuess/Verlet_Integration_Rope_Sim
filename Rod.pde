class Rod implements INetworkElement 
{
  public Joint jointA;
  public Joint jointB;
  public float rodLength;
  public PVector center;
  public float strength;
  
  Rod(Joint a, Joint b, float _rodLength, float _strength) 
  {
    jointA = a;
    jointB = b;
    rodLength = _rodLength;
    strength = _strength;
    
    jointA.connectedRods.add(this);
    jointB.connectedRods.add(this);
    
    updateCenter();
  }
  
  Rod(Joint a, Joint b, float _strength) 
  {
    jointA = a;
    jointB = b;
    rodLength = PVector.dist(a.position, b.position);
    strength = _strength;
    
    jointA.connectedRods.add(this);
    jointB.connectedRods.add(this);
    
    updateCenter();
  }
  
  public boolean identicalTo(Rod other)
  {
    return (other.jointA == jointA && other.jointB == jointB) || (other.jointA == jointB && other.jointB == jointA);
  }
  
  public void updateCenter()
  {
    center = PVector.div(PVector.add(jointA.position, jointB.position), 2);
  }
  
  public float getDistanceTo(PVector point) 
  {
    return PVector.dist(PVector.div(PVector.add(jointA.position, jointB.position), 2), point);
  }
  
  public void destroy(Network network, int particleCount) 
  {
    network.rods.remove(this);
    
    for (Joint joint : network.joints)
    {
      joint.connectedRods.remove(this);
    }
    network.particleSystem.burst(particleCount, center, 0, 400, 2);
  }
  
  public void paint(int r, int g, int b) 
  {
    stroke(r - strength * 50, g - strength * 50, b);
    fill(r - strength * 50, g - strength * 50, b);
    line(jointA.position.x, jointA.position.y, jointB.position.x, jointB.position.y);
    
    square(center.x - 1, center.y - 1, 2);
  }

  public boolean isInLineSegment(PVector lineSegA, PVector lineSegB, float lineSegWidth)
  {
    return false;
  }
}
