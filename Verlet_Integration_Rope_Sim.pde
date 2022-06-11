Network rope;

PVector universalGravity = new PVector(0, 5000, 0);
ParticleSystem particleSystem = new ParticleSystem(PVector.mult(universalGravity, 0.3));

void setup() 
{
  fullScreen();
  frame.requestFocus();
  textSize(20);
  
  frameRate(60);
  
  //PVector[] ropePoints = new PVector[75];
  //for (int i = 0; i < ropePoints.length; i++) 
  //{
  //  ropePoints[i] = new PVector(300, 10 + i * 10);
  //}
  
  PVector[][] clothPoints = new PVector[80][35];
  for (int i = 0; i < clothPoints.length; i++)
  {
    for (int j = 0; j < clothPoints[i].length; j++)
    {
      clothPoints[i][j] = new PVector(200 + 20 * i, 50 + 20 * j);
    }
  }
  
  rope = new Network(clothPoints, universalGravity, particleSystem);
  
  rope.joints.add(new Joint(0, 0, true, true));
}

void draw() 
{
  background(51, 51, 51);

  rope.update(1 / frameRate);
  particleSystem.update(1 / frameRate);
    
  fill(200);
  text((float)round(frameRate * 10) / 10 + "FPS\nPress ESC to exit.", 0, 20);
  
  //noLoop();
}

void keyPressed() 
{
  if (key == 'e') 
  {
    rope.setNetworkEditingMode();
  }
}

void mousePressed() 
{
  rope.setClick(mouseButton == LEFT ? 1 : (mouseButton == RIGHT ? 2 : 3));
}

void mouseReleased() {
  rope.setClick(0);
}
