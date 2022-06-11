public class ParticleSystem
{
  ArrayList<Particle> particles;
  PVector gravity;
  
  ParticleSystem(int particleCount, PVector position, float minVelocity, float maxVelocity, PVector _gravity, float radius) 
  {
    particles = new ArrayList<Particle>();
    gravity = _gravity;
    
    for (int i = 0; i < particleCount; i++)
    {
       particles.add(new Particle(position.copy(), PVector.mult(PVector.random2D(), random(minVelocity, maxVelocity)), gravity, radius));
    }
  }
  
  ParticleSystem(PVector _gravity)
  {
    particles = new ArrayList<Particle>();
    gravity = _gravity;
  }
  
  public void burst(int particleCount, PVector position, float minVelocity, float maxVelocity, float radius)
  {
    for (int i = 0; i < particleCount; i++)
    {
       particles.add(new Particle(position.copy(), PVector.mult(PVector.random2D(), random(minVelocity, maxVelocity)), gravity, radius));
    }
  }
  
  public void update(float deltaT)
  {
    if (particles.size() > 0)
    {
      //ArrayList<Particle> bin = new ArrayList<Particle>();
      
      for (Particle particle : particles)
      {
        particle.simulate(deltaT); //<>//
        particle.paint(200, 100, 100);
        
        //if (particle.position.x < 0 || particle.position.x > width || particle.position.y < 0 || particle.position.y > height)
        //{
        //  bin.add(particle);
        //}
      }
      
      //particles.removeAll(bin);
    }
  }
}
