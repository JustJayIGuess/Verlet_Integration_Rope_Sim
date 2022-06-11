interface INetworkElement 
{
  public float getDistanceTo(PVector point);
  public void destroy(Network network, int particleCount);
  public void paint(int r, int g, int b);
  public boolean isInLineSegment(PVector lineSegA, PVector lineSegB, float lineSegWidth);
}
