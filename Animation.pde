class MText extends Object {
  float x;
  float y;
  int endx;
  int endy;
  int startx;
  int starty;
  int duration;
  int step;
  boolean animate = false;
  boolean done = false;
  String text;
  
  MText(String text, int x, int y) {
    this.x = (float)x;
    this.y = (float)y;
    this.startx = x;
    this.starty = y;
    this.text = text;
  }
  
  void animate() {
    animate = true;
  }
  
  void setDuration(int duration) {
    this.duration = duration;
  }
  
  void setDestination(int x, int y) {
    endx = x;
    endy = y;
  }
  
  boolean isDone() {
    return done;
  }
  
  void draw() {
    if (step < duration) {
      x = (x + ((float)(endx-startx)/(float)duration));
      y = (y + ((float)(endy-starty)/(float)duration));
      step++;
      if (step == duration) done = true;
    }
    if (animate) {
      fill(#FFFFFF);
      textFont(f40, 40);
      textAlign(CENTER);
      smooth();
      text(text, (int)x, (int)y);
    }
  }
  
}

class MLine extends Object {
  float x;
  float y;
  int endx;
  int endy;
  int startx;
  int starty;
  int duration;
  int step;
  boolean animate = false;
  boolean done = false;
  
  MLine(int x, int y) {
    this.x = (float)x;
    this.y = (float)y;
    this.startx = x;
    this.starty = y;
  }
  
  void animate() {
    animate = true;
  }
  
  void setDuration(int duration) {
    this.duration = duration;
  }
  
  void setDestination(int x, int y) {
    endx = x;
    endy = y;
  }
  
  boolean isDone() {
    return done;
  }
  
  void draw() {
    if (step < duration) {
      x = (x + ((float)(endx-startx)/(float)duration));
      y = (y + ((float)(endy-starty)/(float)duration));
      step++;
      if (step == duration) done = true;
    }
    if (animate) {
      stroke(#FFFFFF);
      smooth();
      line(startx, starty, x, y);
    }
  }
  
}

void sleep(int m) {
  float now = millis();
  while(millis() < now + (float)m) {
    
  }
}
