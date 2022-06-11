class Particle
{
  PVector position;
  PVector velocity;
  PVector acceleration;
  
  float radius;
  
  Particle(PVector _position, PVector _velocity, PVector _acceleration, float _radius) 
  {
    position = _position;
    velocity = _velocity;
    acceleration = _acceleration;
    radius = _radius;
  }
  
  public void simulate(float deltaT)
  {
    velocity.add(PVector.mult(acceleration, deltaT));
    position.add(PVector.mult(velocity, deltaT));
  }
  
  public void paint(float r, float g, float b)
  {
    stroke(r, g, b);
    fill(r, g, b);
    square(position.x, position.y, radius);
  }
}
