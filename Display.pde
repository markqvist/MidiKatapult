int frameSize = WINDOWSIZE - FRAMEBORDER*2;
int buttonSize = frameSize / 8;
int offset = 1;
boolean displaystate = false;
boolean dlock = false;

void display(int x, int y, int lcolor) {
  if (!SILENTMODE) {
    while (dlock);
    dlock = true;
    fill(64, 64, 64);
    noStroke();
    smooth();
    int o = 150;
    if (x >= 0 && x < 8 && y >= 0 && y < 8 && displaystate) rect((x*buttonSize)+FRAMEBORDER+offset, (y*buttonSize)+FRAMEBORDER+offset, buttonSize-offset, buttonSize-offset);
    if (lcolor == RED) fill(255, 0, 0, o);
    if (lcolor == REDL) fill(127, 0, 0, o);
    if (lcolor == GREEN) fill(0, 255, 0, o);
    if (lcolor == GREENL) fill(0, 127, 0, o);
    if (lcolor == AMBER) fill(255, 127, 0, o);
    if (lcolor == AMBERL) fill(127, 63, 0, o);
    if (lcolor == YELLOW) fill(255, 255, 0, o);
    
    if (lcolor == BLUE) fill(0, 0, 255, o);
    if (lcolor == BLUEL) fill(0, 0, 127, o);
    if (lcolor == CYAN) fill(0, 255, 255, o);
    if (lcolor == CYANL) fill(0, 127, 127, o);
    if (lcolor == MAGENTA) fill(255, 0, 255, o);
    if (lcolor == MAGENTAL) fill(127, 0, 127, o);
    if (lcolor == WHITE) fill(230, 230, 230, o);
    if (lcolor == WHITEL) fill(180, 180, 200, o);
    
    
    if (x >= 0 && x < 8 && y >= 0 && y < 8 && displaystate) {
      rect((x*buttonSize)+FRAMEBORDER+offset, (y*buttonSize)+FRAMEBORDER+offset, buttonSize-offset, buttonSize-offset);
      o = 16;
      if (lcolor == RED) fill(255, 0, 0, o);
      if (lcolor == REDL) fill(127, 0, 0, o);
      if (lcolor == GREEN) fill(0, 255, 0, o);
      if (lcolor == GREENL) fill(0, 127, 0, o);
      if (lcolor == AMBER) fill(255, 127, 0, o);
      if (lcolor == AMBERL) fill(127, 63, 0, o);
      if (lcolor == YELLOW) fill(255, 255, 0, o);
      if (lcolor == BLUE) fill(0, 0, 255, o);
      if (lcolor == BLUEL) fill(0, 0, 127, o);
      if (lcolor == CYAN) fill(0, 255, 255, o);
      if (lcolor == CYANL) fill(0, 127, 127, o);
      if (lcolor == MAGENTA) fill(255, 0, 255, o);
      if (lcolor == MAGENTAL) fill(127, 0, 127, o);
      if (lcolor == WHITE) fill(230, 230, 230, o);
      if (lcolor == WHITEL) fill(200, 200, 200, o);
      
      noStroke();
      for(int i = 30; i > 0; i--) {
        ellipse((x*buttonSize+(buttonSize/2))+FRAMEBORDER+offset, (y*buttonSize+(buttonSize/2))+FRAMEBORDER+offset, (buttonSize-i*2)-4, (buttonSize-i*2)-4);
      }
    }
    dlock = false;
  }
}

void ledOn(int x, int y, int lcolor) {
  if (displaystate) {
    int address = (y*16) + x;
    if (!NETWORK) launchpad.sendOn(address, lcolor, 0);
    if (online) slaveOn(x, y, lcolor);
    display(x, y, lcolor);
  }
}

void ledOff(int x, int y) {
  if (displaystate) {
    int address = (y*16) + x;
    if (!NETWORK) launchpad.sendOn(address, 0, 0);
  }
}

void clearDisplay() {
  if (displaystate) {
    if (!NETWORK) launchpad.sendCtl(0, 0, 0);
    if (online) slaveClear();
    fill(64, 64, 64);
    for (int i = 0; i < 64; i++) {
      if (!SILENTMODE) rect(((i%8)*buttonSize)+FRAMEBORDER+offset, ((int)((float)i/8)*buttonSize)+FRAMEBORDER+offset, buttonSize-offset, buttonSize-offset);
    }
  }
}

void pageName() {
  pagename = pagenames[selectedPage-1];
  //debug("pageName()"+pagename);
  fill(#000000);
  noStroke();
  rect(0, WINDOWSIZE-12, 250, 12);
  fill(#FFFFFF);
  textFont(f11, 11);
  smooth();
  textAlign(LEFT);
  if (pagename != null) text(pagename, 2, WINDOWSIZE-2);
}

int randomColor() {
  colors[0] = BLACK;
  colors[1] = BLUE;
  colors[2] = RED;
  colors[3] = CYAN;
  colors[4] = AMBER;
  colors[5] = YELLOW;
  colors[6] = GREEN;
  colors[7] = MAGENTA;
  colors[8] = BLACK;
  colors[9] = BLACK;
  colors[10] = BLACK;
  
  int select = (int)random(11);
  
  return colors[select];
}
