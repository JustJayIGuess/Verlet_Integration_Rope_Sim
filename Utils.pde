public static class Utils
{
  public static float distFromPointToLine(PVector a, PVector b, PVector p)
  {
    return abs((b.x - a.x) * (a.y - p.y) - (b.y - a.y) * (a.x - p.x)) / PVector.dist(a, b);
  }
}
