class Network 
{
  private float airFriction = 0.001;
  private float wallFriction = 0.02;
  private float wallRadius = 1;
  private float bounciness = 0.4;
  private float tearingThreshold = 2;
  
  public ArrayList<Joint> joints;
  public ArrayList<Rod> rods;
  
  private ParticleSystem particleSystem;
  
  private PVector gravity;
  private int physicsIters = 50;
  
  private float editingSelectionRadius = 7;
  private float deletionRadius = 20;
  private boolean networkEditingMode = false;
  private Joint ghostJoint = null;
  
  private int wasClickSinceLastUpdate = 0;
  
  private PVector mousePos;
  
  Network(PVector[] stringPoints, PVector grav, ParticleSystem _particleSystem) 
  {
    init(grav, _particleSystem);
    
    for (int i = 0; i < stringPoints.length; i++) 
    {
      joints.add(new Joint(stringPoints[i], i == 0, i == 0));
    }
        
    for (int i = 0; i < stringPoints.length - 1; i++) 
    {
      rods.add(new Rod(joints.get(i), joints.get(i + 1), tearingThreshold));
    }
  }
  
  Network(PVector[][] stringPoints, PVector grav, ParticleSystem _particleSystem) 
  {
    init(grav, _particleSystem);
    
    for (int i = 0; i < stringPoints.length; i++) 
    {
      for (int j = 0; j < stringPoints[i].length; j++)
      {
        joints.add(new Joint(stringPoints[i][j], (i % 8 == 0 || i == stringPoints.length - 1) && j == 0, false));
      }
    }
        
    for (int i = 0; i < stringPoints.length; i++) 
    {
      for (int j = 0; j < stringPoints[i].length - 1; j++)
      {
        rods.add(new Rod(joints.get(i * stringPoints[i].length + j), joints.get(i * stringPoints[i].length + j + 1), tearingThreshold * (0.01 * (stringPoints[i].length - j) + 1)));
      }
    }
        
    for (int i = 0; i < stringPoints.length - 1; i++) 
    {
      for (int j = 0; j < stringPoints[i].length; j++)
      {
        rods.add(new Rod(joints.get(i * stringPoints[i].length + j), joints.get(stringPoints[i].length * (i + 1) + j), tearingThreshold * (0.01 * (stringPoints[i].length - j) + 1)));
      }
    }
  }
  
  private void init(PVector grav, ParticleSystem _particleSystem)
  {
    mousePos = new PVector(mouseX, mouseY);
    joints = new ArrayList<Joint>();
    rods = new ArrayList<Rod>();
    
    particleSystem = _particleSystem;
    gravity = grav;
  }
  
  public void setNetworkEditingMode(boolean doEdit) 
  {
    networkEditingMode = doEdit;
  }
  
  public void setNetworkEditingMode() 
  {
    networkEditingMode = !networkEditingMode;
  }

  public void update(float deltaT) 
  {
    simulateFrame(deltaT);
    paint();
    updateNetworkEditing();
  }

  private void updateNetworkEditing()
  {
    PVector prevMousePos = mousePos.copy();

    mousePos.x = mouseX;
    mousePos.y = mouseY;

    if (!networkEditingMode)
    {
      ArrayList<Joint> jointBin = new ArrayList<Joint>();

      if (wasClickSinceLastUpdate == 3)
      {
        fill(100, 100, 255);
        stroke(255, 100, 100);
        ellipse(mouseX, mouseY, deletionRadius * 2, deletionRadius * 2);
      }

      for (Joint joint : joints)
      {
        if (wasClickSinceLastUpdate == 3 && joint.isInLineSegment(prevMousePos, mousePos, deletionRadius))
        {
          jointBin.add(joint);
        }
      }
      
      for (Joint joint : jointBin) {
        joint.destroy(this, 5);
      }
    }
    else
    {
      INetworkElement nearestElement = null;

      // Draw editing cursor
      fill(100, 100, 255);
      stroke(255, 100, 100);
      ellipse(mouseX, mouseY, editingSelectionRadius * 2, editingSelectionRadius * 2);
      
      // Find closest element      
      ArrayList<INetworkElement> networkElements = new ArrayList<INetworkElement>();
      networkElements.addAll(joints);
      networkElements.addAll(rods);
      
      for (INetworkElement element : networkElements) 
      {
        if (element.getDistanceTo(mousePos) < (nearestElement == null ? editingSelectionRadius : nearestElement.getDistanceTo(mousePos))) 
        {
          nearestElement = element;
        }
      }
      
      if (nearestElement != null) 
      { 
        nearestElement.paint(100, 255, 50);
      }
      
      if (ghostJoint != null) 
      {
        stroke(255);
        line(ghostJoint.position.x, ghostJoint.position.y, mouseX, mouseY);
      }
      
      if (wasClickSinceLastUpdate != 0) 
      {
        
        // If nearest element is point...
        if (nearestElement instanceof Joint) 
        {
          if (ghostJoint == null) {
            if (wasClickSinceLastUpdate == 1) 
            {
              ghostJoint = (Joint)nearestElement;
            }
            else if (wasClickSinceLastUpdate == 2) 
            {
              ((Joint)nearestElement).isFixed = !((Joint)nearestElement).isFixed;
            }
            else 
            {
              nearestElement.destroy(this, 20);
            }
          }
          else 
          {
            if (nearestElement != ghostJoint)
            {
              addRodIfDoesntExist(new Rod(ghostJoint, (Joint)nearestElement, tearingThreshold));
            }
            ghostJoint = null;
          }
          wasClickSinceLastUpdate = 0;
        }
        // If nearest element is rod...
        else if (nearestElement instanceof Rod)
        {
          if (ghostJoint == null) 
          {
            if (wasClickSinceLastUpdate == 3) 
            {
              nearestElement.destroy(this, 20);
            }
          }
          wasClickSinceLastUpdate = 0;
        }
        // If click was in empty space...
        else 
        {
          if (wasClickSinceLastUpdate == 1 && ghostJoint != null)
          {
            joints.add(new Joint(mouseX, mouseY, wasClickSinceLastUpdate == 2, false));
            rods.add(new Rod(ghostJoint, joints.get(joints.size() - 1), tearingThreshold));
            ghostJoint = null;
          }
        }
      }
    }
  }
  
  private void simulateFrame(float deltaT)
  {
    if (!networkEditingMode)
    {
      ArrayList<Joint> jointBin = new ArrayList<Joint>();
      for (Joint joint : joints)
      {
        if (joint.followMouse)
        {
          joint.position = new PVector(mouseX, mouseY);
        }
        else if (!joint.isFixed)
        {
          boolean onWall = joint.position.x < wallRadius || joint.position.x > width - wallRadius || joint.position.y < wallRadius || joint.position.y > height - wallRadius;
          
          PVector positionTemp = joint.position.copy();
          
          PVector velocity = PVector.mult(PVector.sub(joint.position, joint.prevPosition), 1.0 - (onWall ? wallFriction : airFriction));
          
          joint.position.add(velocity);
          joint.position.add(PVector.mult(gravity, deltaT * deltaT));
          
          joint.prevPosition = positionTemp;
          if (joint.position.x < 0)
          {
            joint.position.x = 0;
            joint.prevPosition.x = velocity.x * bounciness;
          }
          if (joint.position.y < 0)
          {
            joint.position.y = 0;
            joint.prevPosition.y = velocity.y * bounciness;
          }
          if (joint.position.x > width)
          {
            joint.position.x = width;
            joint.prevPosition.x = width + (velocity.x * bounciness);
          }
          if (joint.position.y > height)
          {
            joint.position.y = height;
            joint.prevPosition.y = height + (velocity.y * bounciness);
          }
        }
      }

      // Code slightly different here to maximise performance
      for (int i = 0; i < physicsIters; i++) 
      {
        for (int j = 0; j < rods.size(); j++) 
        {
          Rod rod = rods.get(j);
                    
          //PVector rodCentre = new PVector();  //PVector.mult(PVector.add(rod.jointA.position, rod.jointB.position), 0.5);
          //rodCentre.x = (rod.jointA.position.x + rod.jointB.position.x) * 0.5;
          //rodCentre.y = (rod.jointA.position.y + rod.jointB.position.y) * 0.5;
          PVector rodDir = new PVector();  //PVector.sub(rod.jointA.position, rod.jointB.position);
          rodDir.x = rod.jointA.position.x - rod.jointB.position.x;
          rodDir.y = rod.jointA.position.y - rod.jointB.position.y;
          rodDir.normalize();
          
          rod.updateCenter();
          if (!rod.jointA.isFixed) 
          {
            rod.jointA.position.x = rod.center.x + rodDir.x * rod.rodLength * 0.5;
            rod.jointA.position.y = rod.center.y + rodDir.y * rod.rodLength * 0.5;
          }
          
          if (!rod.jointB.isFixed) 
          {
            rod.jointB.position.x = rod.center.x - rodDir.x * rod.rodLength * 0.5;
            rod.jointB.position.y = rod.center.y - rodDir.y * rod.rodLength * 0.5;
          }
        }
      }
      
      ArrayList<Rod> rodBin = new ArrayList<Rod>();
      for (Rod rod : rods)
      {
        if (!(rod.jointA.followMouse || rod.jointB.followMouse))
        {
          if (PVector.dist(rod.jointA.position, rod.jointB.position) > rod.rodLength * (rod.strength + 1.0))
          {
            rodBin.add(rod);
          }
        }
      }
      
      for (Rod rod : rodBin)
      {
        rod.destroy(this, 5);
      }
    }
  }
  
  private int findDuplicates(Rod other)
  {
    for (Rod rod : rods)
    {
      if (rod.identicalTo(other))
      {
        return rods.indexOf(rod);
      }
    }
    
    return -1;
  }
  
    
  public void addRodIfDoesntExist(Rod rod) 
  {    
    if (findDuplicates(rod) < 0)
    {
      rods.add(rod);
    }
  }
  
  public void setClick(int clickType) 
  {
    wasClickSinceLastUpdate = clickType;
  }
  
  private void paint() 
  {    
    stroke(255);
    strokeWeight(2);
    
    for (int i = 0; i < rods.size(); i++) 
    {
      Rod rod = rods.get(i);
      rod.updateCenter();
      rod.paint(255, 255, 255);
    }
        
    for (int i = 0; i < joints.size(); i++) 
    {
      Joint joint = joints.get(i);
      joint.paint(255, 255 * int(!joint.isFixed), 255 * int(!joint.isFixed));
    }
  }
}
