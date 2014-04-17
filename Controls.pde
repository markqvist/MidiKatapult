import java.awt.Robot;
import java.awt.event.InputEvent.*;

class Control {
  int x;
  int y;
  int xsize;
  int ysize;
  int type;
  int state;
  int number;
  int value;
  int velocity;
  int softwarevalue;
  boolean persistence;
  boolean sn;
  int timeout;
  int idlecolor;
  int activecolor;
  int controlID;
  int page;
  int channel = customChannel;
  int takeover;
  int updatedelay = 50;
  boolean TLOCK = false;
  boolean TAKEOVER = false;
  long threadsSpawned = 0;
  long threadsFinished = 0;
  Control owner;
  boolean isChained = false;
  int numberOfChains = 0;
  boolean chainSendFlags[] = new boolean[MAXCHAINS];
  Control chains[] = new Control[MAXCHAINS];
  
  void up(){}
  void down(){}
  void on(){}
  void off(){}
  void send(){}
  void setValue(int ivalue){}
  void takeoverSetValue(int ivalue){}
  void nakedSetValue(int ivalue) {}
  void update(){}
  void cancelSchedule(){}
  
  
  void chainTo(Control control, boolean send) {
    chains[numberOfChains] = control;
    //debug("Chaining "+this+" to "+control);
    chainSendFlags[numberOfChains] = send;
    numberOfChains++;
    isChained = true;
  }
  
  void propagateToChainedControls() {
    if(isChained) {
      for (int i = 0; i < numberOfChains; i++) {
        //println("Chained update to c on "+chains[i].page+". now on "+selectedPage);
        chains[i].setValue(value);
        if (chainSendFlags[i]) chains[i].send();
        if (chains[i].page == selectedPage) chains[i].update();
      }
    }
  }
}

class GridSegment extends Control {
  void on() {
    debug(this+"x="+this.x+" y="+this.y+" on()");
    ledOn(x, y, activecolor);
  }
  
  void off() {
    debug(this+"x="+this.x+" y="+this.y+" off()");
    ledOn(x, y, idlecolor);
  }
}

class PageButton extends GridSegment {
  int number;
  
  PageButton(int inumber) {
    page = selectedPage;
    //println(this+" on page "+page);
    number = inumber;
    idlecolor = PAGEBUTTONIDLECOLOR;
    activecolor = PAGEBUTTONACTIVECOLOR;
    grid[number] = this;
    ledOn((number % 8), (int)((float)number / 8), idlecolor);
  }
  
  void down() {
    ledOn((number % 8), (int)((float)number / 8), activecolor);
    loadLayout(number+1);
  }
  
  void update() {
    x = 8;
    y = 7;
    off();
  }
}

class LED extends GridSegment {
  LED(int ix, int iy) {
    controlID = (int)random(1000);
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    value = 0;
    state = OFF;
    timeout = 0;
    grid[y*8+x] = this;
    idlecolor = INDICATOROFFCOLOR;
    activecolor = INDICATORONCOLOR;
    ledOn(x, y, idlecolor);
  }
  
  void send() {
    controlOut(x, y, state);
  }
  
  void down() {
    
  }
  
  void up() {

  }
  
  void update() {
    if (value == 0) {
      off();
    }
    if (value > 0) {
      on();
    }
  }
  
  void nakedSetValue(int ivalue) { setValue(ivalue); }
  void setValue(int ivalue) {
    if (ivalue > 0) { value = ivalue; state = ON; } else { value = OFF; state = OFF; }
    propagateToChainedControls();
  }
}

class Button extends GridSegment {
  Button(int ix, int iy, int itype) {
    controlID = (int)random(1000);
    page = selectedPage;
    persistence = false;
    sn = true;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    type = itype;
    value = 0;
    velocity = -1;
    state = OFF;
    timeout = 0;
    if (x < 8) {
      grid[y*8+x] = this;
    }
    if (x == 8 && y < 7) {
      //debug("Mapping side button:"+this);
      grid[65+y] = this;
    }
    if (type == HOLD) {
      idlecolor = BUTTONIDLECOLOR;
      activecolor = HOLDONCOLOR;
    }
    if (type == TOGGLE) {
      idlecolor = TOGGLEOFFCOLOR;
      activecolor = TOGGLEONCOLOR;
    }
    ledOn(x, y, idlecolor);
  }
  
  void setVelocity(int vel) {
    velocity = vel;
  }
  
  void send() {
    debug("Velocity is "+velocity);
    if (channel != 0) outputChannel = channel-1;
    if (velocity == -1) controlOut(x, y, state);
    if (velocity != -1 && state == ON) controlOut(x, y, velocity);
    if (velocity != -1 && state == OFF) controlOut(x, y, state); 
  }
  
  void down() {
    sn = false;
    if (type == HOLD) {
      state = ON;
      setValue(ON);
      send();
      if (!persistence) on();
    }
    if (type == TOGGLE) {
      if (state == OFF) {
        state = ON;
        send();
        if (!persistence) on();
        setValue(ON);
      } else if (state == ON) {
        state = OFF;
        send();
        if (!persistence) off();
        setValue(OFF);
      }
    }
  }
  
  void up() {
    sn = false;
    if (type == HOLD) {
      //state = OFF;
      setValue(OFF);
      send();
      if (!persistence) off();
    }
  }
  
  void update() {
    debug("sn "+sn);
    if (value == 0) {
      off();
    }
    if (value == 127 || softwarevalue == 127) {
      on();
    }
  }
  
  void nakedSetValue(int ivalue) { setValue(ivalue); }
  void setValue(int ivalue) {
    softwarevalue = ivalue;
    if (ivalue > 0) { value = 127; state = ON; } else { value = 0; state = OFF; }
    propagateToChainedControls();
    sn = true;
  }
}

class Note extends GridSegment {
  int note;
  int vel;
  boolean sendoff = false;
  boolean toggle = false;
  
  Note(int ix, int iy, int octave, String note, int vel) {
    controlID = (int)random(1000);
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    value = 0;
    state = OFF;
    timeout = 0;
    idlecolor = NOTEIDLECOLOR;
    activecolor = NOTEACTIVECOLOR;
    this.note = addOctave(parseNote(note), octave);
    this.vel = vel;
    
    if (x < 8) {
      grid[y*8+x] = this;
    }
    if (x == 8 && y < 7) {
      //debug("Mapping side button:"+this);
      grid[65+y] = this;
    }
    
    ledOn(x, y, idlecolor);
  }
  
  Note(int ix, int iy, int midi, int vel) {
    controlID = (int)random(1000);
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    value = 0;
    state = OFF;
    timeout = 0;
    idlecolor = NOTEIDLECOLOR;
    activecolor = NOTEACTIVECOLOR;
    this.note = midi;
    this.vel = vel;
    
    if (x < 8) {
      grid[y*8+x] = this;
    }
    if (x == 8 && y < 7) {
      //debug("Mapping side button:"+this);
      grid[65+y] = this;
    }
    
    ledOn(x, y, idlecolor);
  }
  
  int parseNote(String note) {
    note = note.toLowerCase();
    if (note.equals("c")) return 0;
    if (note.equals("c#")) return 1;
    if (note.equals("d")) return 2;
    if (note.equals("d#")) return 3;
    if (note.equals("e")) return 4;
    if (note.equals("f")) return 5;
    if (note.equals("f#")) return 6;
    if (note.equals("g")) return 7;
    if (note.equals("g#")) return 8;
    if (note.equals("a")) return 9;
    if (note.equals("a#")) return 10;
    if (note.equals("b")) return 11;
    return 0;
  }
  
  int addOctave(int note, int octave) {
    octave = octave+1;
    return note+(octave*12);
  }
  
  void send() {
    if (channel != 0) outputChannel = channel-1;
    if (sendoff) {
      noteOut(note, 0);
      sendoff = false;
    } else {
      //debug("sendOn");
      noteOut(note, vel);
    }
  }
  
  void sendOff() {
    if (channel != 0) outputChannel = channel-1;
    //debug("sendOff");
    noteOut(note, 0);
  }
  
  void down() {
    if (!toggle) {
      send();
      on();
    } else {
      if (state == OFF) {
        send();
        on();
        state = ON;
      } else if (state == ON) {
        sendOff();
        off();
        state = OFF;
      }
    }
  }
  
  void up() {
    if (!toggle) {
      sendOff();
      off();
    }
  }
  
  void update() {
    if (value == 0) {
      off();
    }
    if (value == 127) {
      on();
    }
  }
  
  void nakedSetValue(int ivalue) { setValue(ivalue); }
  void setValue(int ivalue) {
    value = ivalue;
    if (ivalue == 0) { 
      sendoff = true;    
    }
    propagateToChainedControls();
  }
}

class CC extends GridSegment {
  int note;
  int vel;
  boolean toggle;
  boolean sendoff = false;
  
  CC(int ix, int iy, int cc, int vel) {
    controlID = (int)random(1000);
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    value = 0;
    state = OFF;
    timeout = 0;
    idlecolor = CCIDLECOLOR;
    activecolor = CCACTIVECOLOR;
    this.note = cc;
    this.vel = vel;
    toggle = false;
    
    if (x < 8) {
      grid[y*8+x] = this;
    }
    if (x == 8 && y < 7) {
      //debug("Mapping side button:"+this);
      grid[65+y] = this;
    }
    
    ledOn(x, y, idlecolor);
  }
  
  void send() {
    if (channel != 0) outputChannel = channel-1;
    if (sendoff) {
      sendOff();
      sendoff = false;
    } else {
      //debug("sendOn");
      controlOut(note, vel);
    }
  }
  
  void sendOff() {
    //debug("sendOff");
    //controlOut(note, 0);
  }
  
  void down() {
      send();
      on();
  }
  
  void up() {
      sendOff();
      off();
  }
  
  void update() {
    if (value == 0) {
      off();
    }
    if (value == 127) {
      on();
    }
  }
  
  void nakedSetValue(int ivalue) { setValue(ivalue); }
  void setValue(int ivalue) {
    value = ivalue;
    if (ivalue == 0) { 
      sendoff = true;    
    }
    propagateToChainedControls();
  }
}

class PC extends GridSegment {
  int note;
  int vel;
  boolean sendoff = false;
  
  PC(int ix, int iy, int program) {
    controlID = (int)random(1000);
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    value = 0;
    state = OFF;
    timeout = 0;
    idlecolor = PCIDLECOLOR;
    activecolor = PCACTIVECOLOR;
    this.note = program;
    
    if (x < 8) {
      grid[y*8+x] = this;
    }
    if (x == 8 && y < 7) {
      //debug("Mapping side button:"+this);
      grid[65+y] = this;
    }
    
    ledOn(x, y, idlecolor);
  }
  
  void send() {
    if (channel != 0) outputChannel = channel-1;
    if (sendoff) {
      sendOff();
      sendoff = false;
    } else {
      //debug("sendOn");
      programOut(note);
    }
  }
  
  void sendOff() {
    //debug("sendOff");
    //controlOut(note, 0);
  }
  
  void down() {
      send();
      on();
  }
  
  void up() {
      sendOff();
      off();

  }
  
  void update() {
    if (value == 0) {
      off();
    }
    if (value == 127) {
      on();
    }
  }
  
  void nakedSetValue(int ivalue) { setValue(ivalue); }
  void setValue(int ivalue) {
    value = ivalue;
    if (ivalue == 0) { 
      sendoff = true;    
    }
    propagateToChainedControls();
  }
}

class Kbd extends GridSegment {
  int note;
  int vel;
  boolean sendoff = false;
  Robot robot;
  int keys[];

  Kbd(int ix, int iy, String keystring) {
    controlID = (int)random(1000);
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    value = 0;
    state = OFF;
    timeout = 0;
    idlecolor = KBDIDLECOLOR;
    activecolor = KBDACTIVECOLOR;
    try {
      robot = new Robot();
    } catch (AWTException e) {
      debug("Exception while creating robot "+e);
    }
    String keysS[] = split(keystring, "+");
    keys = new int[keysS.length];
    for (int i = 0; i < keys.length; i++) {
      keys[i] = parseKey(keysS[i]);
    }
    
    if (x < 8) {
      grid[y*8+x] = this;
    }
    if (x == 8 && y < 7) {
      //debug("Mapping side button:"+this);
      grid[65+y] = this;
    }
    
    ledOn(x, y, idlecolor);
  }
  
  int parseKey(String keystr) {
    if (keystr.equals("shift")) return KeyEvent.VK_SHIFT;
    if (keystr.equals("control")) return KeyEvent.VK_CONTROL;
    if (keystr.equals("alt")) return KeyEvent.VK_ALT;
    if (keystr.equals("altgr")) return KeyEvent.VK_ALT_GRAPH;
    if (keystr.equals("command")) return KeyEvent.VK_META;
    if (keystr.equals("1")) return KeyEvent.VK_1;
    if (keystr.equals("2")) return KeyEvent.VK_2;
    if (keystr.equals("3")) return KeyEvent.VK_3;
    if (keystr.equals("4")) return KeyEvent.VK_4;
    if (keystr.equals("5")) return KeyEvent.VK_5;
    if (keystr.equals("6")) return KeyEvent.VK_6;
    if (keystr.equals("7")) return KeyEvent.VK_7;
    if (keystr.equals("8")) return KeyEvent.VK_8;
    if (keystr.equals("9")) return KeyEvent.VK_9;
    if (keystr.equals("0")) return KeyEvent.VK_0;
    if (keystr.equals("a")) return KeyEvent.VK_A;
    if (keystr.equals("b")) return KeyEvent.VK_B;
    if (keystr.equals("c")) return KeyEvent.VK_C;
    if (keystr.equals("d")) return KeyEvent.VK_D;
    if (keystr.equals("e")) return KeyEvent.VK_E;
    if (keystr.equals("f")) return KeyEvent.VK_F;
    if (keystr.equals("g")) return KeyEvent.VK_G;
    if (keystr.equals("h")) return KeyEvent.VK_H;
    if (keystr.equals("i")) return KeyEvent.VK_I;
    if (keystr.equals("j")) return KeyEvent.VK_J;
    if (keystr.equals("k")) return KeyEvent.VK_K;
    if (keystr.equals("l")) return KeyEvent.VK_L;
    if (keystr.equals("m")) return KeyEvent.VK_M;
    if (keystr.equals("n")) return KeyEvent.VK_N;
    if (keystr.equals("o")) return KeyEvent.VK_O;
    if (keystr.equals("p")) return KeyEvent.VK_P;
    if (keystr.equals("q")) return KeyEvent.VK_Q;
    if (keystr.equals("r")) return KeyEvent.VK_R;
    if (keystr.equals("s")) return KeyEvent.VK_S;
    if (keystr.equals("t")) return KeyEvent.VK_T;
    if (keystr.equals("u")) return KeyEvent.VK_U;
    if (keystr.equals("v")) return KeyEvent.VK_V;
    if (keystr.equals("w")) return KeyEvent.VK_W;
    if (keystr.equals("x")) return KeyEvent.VK_X;
    if (keystr.equals("y")) return KeyEvent.VK_Y;
    if (keystr.equals("z")) return KeyEvent.VK_Z;
    if (keystr.equals("f1")) return KeyEvent.VK_F1;
    if (keystr.equals("f2")) return KeyEvent.VK_F2;
    if (keystr.equals("f3")) return KeyEvent.VK_F3;
    if (keystr.equals("f4")) return KeyEvent.VK_F4;
    if (keystr.equals("f5")) return KeyEvent.VK_F5;
    if (keystr.equals("f6")) return KeyEvent.VK_F6;
    if (keystr.equals("f7")) return KeyEvent.VK_F7;
    if (keystr.equals("f8")) return KeyEvent.VK_F8;
    if (keystr.equals("f9")) return KeyEvent.VK_F9;
    if (keystr.equals("f10")) return KeyEvent.VK_F10;
    if (keystr.equals("f11")) return KeyEvent.VK_F11;
    if (keystr.equals("f12")) return KeyEvent.VK_F12;
    if (keystr.equals("f13")) return KeyEvent.VK_F13;
    if (keystr.equals("f14")) return KeyEvent.VK_F14;
    if (keystr.equals("f15")) return KeyEvent.VK_F15;
    if (keystr.equals("f16")) return KeyEvent.VK_F16;
    if (keystr.equals("f17")) return KeyEvent.VK_F17;
    if (keystr.equals("f18")) return KeyEvent.VK_F18;
    if (keystr.equals("f19")) return KeyEvent.VK_F19;
    if (keystr.equals("esc")) return KeyEvent.VK_ESCAPE;
    if (keystr.equals("space")) return KeyEvent.VK_SPACE;
    if (keystr.equals("enter")) return KeyEvent.VK_ENTER;
    if (keystr.equals("tab")) return KeyEvent.VK_TAB;
    if (keystr.equals("backspace")) return KeyEvent.VK_BACK_SPACE;
    if (keystr.equals("delete")) return KeyEvent.VK_DELETE;
    if (keystr.equals("caps")) return KeyEvent.VK_CAPS_LOCK;
    if (keystr.equals("down")) return KeyEvent.VK_DOWN;
    if (keystr.equals("up")) return KeyEvent.VK_UP;
    if (keystr.equals("left")) return KeyEvent.VK_LEFT;
    if (keystr.equals("right")) return KeyEvent.VK_RIGHT;
    if (keystr.equals(",")) return KeyEvent.VK_COMMA;
    if (keystr.equals(".")) return KeyEvent.VK_PERIOD;
    if (keystr.equals("+")) return KeyEvent.VK_PLUS;
    if (keystr.equals("-")) return KeyEvent.VK_MINUS;
    return 0;
  }
  
  void send() {
    for (int i = 0; i < keys.length; i++) {
      if (keys[i] != 0) {
        debug("Sending keyPress "+keys[i]);
        robot.keyPress(keys[i]);
      }
    }
  }

  void sendOff() {
    for (int i = 0; i < keys.length; i++) {
      if (keys[i] != 0) {
        robot.keyRelease(keys[i]);
      }
    }
  }

  void down() {
    send();
    on();
  }
  
  void up() {
    sendOff();
    off();
  }
  
  void update() {
    if (value == 0) {
      off();
    }
    if (value == 127) {
      on();
    }
  }
  
  void nakedSetValue(int ivalue) { setValue(ivalue); }
  void setValue(int ivalue) {
    value = ivalue;
    if (ivalue == 0) { 
      sendoff = true;    
    }
    propagateToChainedControls();
  }
}

class FaderSegment extends GridSegment {
  Fader owner;
  
  FaderSegment(int ix, int iy, Fader iowner) {
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    owner = iowner;
    controlID = (int)random(1000);
    grid[y*8+x] = this;
    idlecolor = FADERIDLECOLOR;
    activecolor = FADERACTIVECOLOR;
    off();
  }
  
  void down() {
    owner.faderAction(this);
  }
  
  void update() {
    if (x == owner.x && y == owner.y) {
      owner.update();
    }
  }
  
  void send() {
    if (x == owner.x && y == owner.y) {
      owner.send();
    }
  }
  
  void nakedSetValue(int ivalue) { setValue(ivalue); }
  void setValue(int ivalue) {
    if (x == owner.x && y == owner.y) {
      owner.nakedSetValue(ivalue);
    }
  }
  
  void chainTo(Control control, boolean send) {
    owner.chainTo(control, send);
  }
  
  void propagateToChainedControls() {
    owner.propagateToChainedControls();
  }
}

class Fader extends Control {
  FaderSegment[] segments;
  long lastupdate;
  boolean schedule;
  
  
  void faderAction(FaderSegment sender){}
  
  boolean canUpdate() {
    long now = (new Date()).getTime();
    debug("l "+lastupdate);
    debug("n "+now);
    debug("d "+(now-lastupdate));
    if (now - lastupdate < 100) {
      lastupdate = now;
      return false;
    } else {
     return true;
    } 
  }
  
  void schedule() {
    schedule = true;
    new Scheduler(this);
  }
  
  void cancelSchedule() {
    schedule = false;
  }
  
  boolean hasSchedule() {
    return schedule;
  }
  
}

class XFader extends Fader {
  int sx;
  int lastsx;

  XFader(int ix, int iy, int ixsize) {
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    xsize = ixsize;
    sx = x;
    lastsx = -1;
    takeover = 0;
    segments = new FaderSegment[xsize];
    for (int i = 0; i < xsize; i++) {
      segments[i] = new FaderSegment(x+i, y, this);
    }
    grid[y*8+x].on();
  }
  
  void faderAction(FaderSegment sender) {
    sx = sender.x;
    float relx = sx - x;
    float quantum = relx * (1 / ((float)xsize - 1));
    float amount = ((relx + quantum) / (float)xsize) * 127;
    setValue((int)amount);
  }
  
  void update() {
    //if (lastsx == sx && !hasSchedule()) schedule();
    if (lastsx != sx || canUpdate()) {
      if (page == selectedPage) {    
        for(int i = 0; i < xsize; i++) {
          if (i <= sx) { grid[y*8+x+i].on(); } else { grid[y*8+x+i].off(); }
        }
        lastsx = sx;
        lastupdate = (new Date()).getTime();
      }
    }
  }
  
  void send() {
    if (channel != 0) outputChannel = channel-1;
    controlOut(x, y, value);
  }
  
  void setTakeover(int itakeover) {
    //debug("setTakeover()");
    takeover = itakeover;
  }
  
  void nakedSetValue(int ivalue) {
    if (TAKEOVER == false) {
      float step = 127 / (xsize-1);
      sx = (int)(ivalue / step);
      value = ivalue;
      propagateToChainedControls();
    } else {
      //debug("nakedSetValueX() blocked because takeover is in progress.");
    }
  }
  
  void takeoverSetValue(int ivalue) {
    float step = 127 / (xsize-1);
    sx = (int)(ivalue / step);
    value = ivalue;
    send();
    if (lastsx != sx) update();
    propagateToChainedControls();
  }
  
  void setValue(int ivalue) {
    if (takeover == 0) {
      float step = 127 / (xsize-1);
      sx = (int)(ivalue / step);
      value = ivalue;
      send();
      if (lastsx != sx) update();
      propagateToChainedControls();
    } else {
      //debug("Delegating control to takeover routine");
      takeover(ivalue);
    }    
  }
  
  void takeover(int ivalue) {
    threadsSpawned++;
    TakeOver takeover = new TakeOver(this, ivalue, this.takeover);
  }
  
}

class IXFader extends Fader {
  int sx;
  int lastsx;

  IXFader(int ix, int iy, int ixsize) {
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    xsize = ixsize;
    sx = 0;
    lastsx = -1;
    takeover = 0;
    segments = new FaderSegment[xsize];
    for (int i = 0; i < xsize; i++) {
      segments[i] = new FaderSegment(x+i, y, this);
    }
    grid[y*8+x].on();
  }
  
  void faderAction(FaderSegment sender) {
    sx = sender.x;
    float relx = sx - x;
    float quantum = relx * (1 / ((float)xsize - 1));
    float amount = ((relx + quantum) / (float)xsize) * 127;
    setValue(127-(int)amount);
  }
  
  void update() {
    //if (lastsx == sx && !hasSchedule()) schedule();
    if (lastsx != sx || canUpdate()) {
      if (page == selectedPage) {    
        for(int i = xsize-1; i >= 0; i--) {
          debug("sx="+((xsize-1)-sx)+" i="+i);
          if (i >= (xsize-1)-sx) { grid[y*8+x+i].on(); } else { grid[y*8+x+i].off(); }
          //if (i <= sx) { grid[y*8+x+i].on(); } else { grid[y*8+x+i].off(); }
        }
        lastsx = sx;
        lastupdate = (new Date()).getTime();
      }
    }
  }
  
  void send() {
    if (channel != 0) outputChannel = channel-1;
    controlOut(x, y, value);
  }
  
  void setTakeover(int itakeover) {
    //debug("setTakeover()");
    takeover = itakeover;
  }
  
  void nakedSetValue(int ivalue) {
    if (TAKEOVER == false) {
      float step = 127 / (xsize-1);
      sx = (int)(ivalue / step);
      value = ivalue;
      propagateToChainedControls();
    } else {
      //debug("nakedSetValueX() blocked because takeover is in progress.");
    }
  }
  
  void takeoverSetValue(int ivalue) {
    float step = 127 / (xsize-1);
    sx = (int)(ivalue / step);
    value = ivalue;
    send();
    if (lastsx != sx) update();
    propagateToChainedControls();
  }
  
  void setValue(int ivalue) {
    if (takeover == 0) {
      float step = 127 / (xsize-1);
      sx = (int)(ivalue / step);
      value = ivalue;
      send();
      if (lastsx != sx) update();
      propagateToChainedControls();
    } else {
      //debug("Delegating control to takeover routine");
      takeover(ivalue);
    }    
  }
  
  void takeover(int ivalue) {
    threadsSpawned++;
    TakeOver takeover = new TakeOver(this, ivalue, this.takeover);
  }
        
}

class YFader extends Fader {
  int sy;
  int lastsy;
  
  YFader(int ix, int iy, int iysize) {
    controlID = (int)random(1000);
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    ysize = iysize;
    sy = y;
    lastsy = -1;
    value = 0;
    segments = new FaderSegment[ysize];
    for (int i = 0; i < ysize; i++) {
      segments[i] = new FaderSegment(x, y - i, this);
    }
    grid[y*8+x].on();
  }
  
  void faderAction(FaderSegment sender) {
    sy = sender.y;
    float rely = sy - y;
    float quantum = rely * (1 / ((float)ysize - 1));
    float amount = ((rely + quantum) / (float)ysize) * 127;
    setValue(0 - ((int)amount));
  }
  
  void update() {
    //if (lastsy == sy && !hasSchedule()) schedule();
    if (lastsy != sy || canUpdate()) {

    if (page == selectedPage) {
      for(int i = y; i > y - ysize; i--) {
        if (i >= sy) { grid[i*8+x].on(); } else { grid[i*8+x].off(); }
      }
      lastsy = sy;
      lastupdate = (new Date()).getTime();
    }
    }
  }
  
  void send() {
    if (channel != 0) outputChannel = channel-1;
    controlOut(x, y, value);
  }
  
  void setTakeover(int itakeover) {
    //debug("setTakeover()");
    takeover = itakeover;
  }
  
  void nakedSetValue(int ivalue) {
    if (TAKEOVER == false) {
      float step = 127 / (ysize-1);
      int rely = ((int)(ivalue / step));
      sy = y - rely;
      value = ivalue;
      propagateToChainedControls();
    } else {
      //debug("nakedSetValue() blocked because takeover is in progress.");
    }
  }

  void takeoverSetValue(int ivalue) {
    float step = 127 / (ysize-1);
    int rely = ((int)(ivalue / step));
    sy = y - rely;
    value = ivalue;
    send();
    //debug("sy "+sy+" lastsy "+lastsy);
    if (lastsy != sy) update();
    propagateToChainedControls();
  }
  
  void setValue(int ivalue) {
    if (takeover == 0) {
      float step = 127 / (ysize-1);
      int rely = ((int)(ivalue / step));
      sy = y - rely;
      value = ivalue;
      send();
      if (lastsy != sy) update();
      propagateToChainedControls();
    } else {
      //debug("Delegating control to takeover routine");
      takeover(ivalue);
    }
  }
  
  void takeover(int ivalue) {
    threadsSpawned++;
    TakeOver takeover = new TakeOver(this, ivalue, this.takeover);
  }
}

class IYFader extends Fader {
  int sy;
  int lastsy;
  
  IYFader(int ix, int iy, int iysize) {
    controlID = (int)random(1000);
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    ysize = iysize;
    sy = y;
    lastsy = -1;
    value = 0;
    segments = new FaderSegment[ysize];
    for (int i = 0; i < ysize; i++) {
      segments[i] = new FaderSegment(x, y - i, this);
    }
    grid[y*8+x].on();
  }
  
  void faderAction(FaderSegment sender) {
    sy = sender.y;
    debug("!! sy="+sy);
    float rely = sy - y;
    float quantum = rely * (1 / ((float)ysize - 1));
    float amount = ((rely + quantum) / (float)ysize) * 127;
    setValue(127 + ((int)amount));
    debug("!! value="+(127 + ((int)amount)));
  }
  
  void update() {
    if (lastsy != sy || canUpdate()) {

    if (page == selectedPage) {
      for(int i = 0; i < ysize; i++) {
        int pos = y - sy;
        pos = (ysize-1)-pos;
        debug("i="+i+" sy="+sy+" pos="+pos);
        if (i >= pos ) { grid[(y-i)*8+x].on(); } else { grid[(y-i)*8+x].off(); }
      }
      
      lastsy = sy;
      lastupdate = (new Date()).getTime();
    }
    }
  }
  
  void send() {
    if (channel != 0) outputChannel = channel-1;
    controlOut(x, y, value);
  }
  
  void setTakeover(int itakeover) {
    //debug("setTakeover()");
    takeover = itakeover;
  }
  
  void nakedSetValue(int ivalue) {
    if (TAKEOVER == false) {
      float step = 127 / (ysize-1);
      int rely = ((int)(ivalue / step));
      sy = y - rely;
      value = ivalue;
      propagateToChainedControls();
    } else {
      //debug("nakedSetValue() blocked because takeover is in progress.");
    }
  }

  void takeoverSetValue(int ivalue) {
    float step = 127 / (ysize-1);
    int rely = ((int)(ivalue / step));
    sy = y - rely;
    value = ivalue;
    send();
    //debug("sy "+sy+" lastsy "+lastsy);
    if (lastsy != sy) update();
    propagateToChainedControls();
  }
  
  void setValue(int ivalue) {
    if (takeover == 0) {
      float step = 127 / (ysize-1);
      int rely = ((int)(ivalue / step));
      sy = y - rely;
      value = ivalue;
      send();
      if (lastsy != sy) update();
      propagateToChainedControls();
    } else {
      //debug("Delegating control to takeover routine");
      takeover(ivalue);
    }
  }
  
  void takeover(int ivalue) {
    threadsSpawned++;
    TakeOver takeover = new TakeOver(this, ivalue, this.takeover);
  }
}

class SliderSegment extends GridSegment {
  Slider owner;
  
  SliderSegment(int ix, int iy, Slider iowner) {
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    owner = iowner;
    grid[y*8+x] = this;
    idlecolor = SLIDERIDLECOLOR;
    activecolor = SLIDERACTIVECOLOR;
    off();
  }
  
  void down() {
    owner.sliderAction(this);
  }
  
  void up() {
    owner.liftFinger(this);
  }
  
  void update() {
    off();
  }
  
  void send() {
    if (x == owner.x && y == owner.y) {
      owner.send();
    }
  }
  
  void nakedSetValue(int ivalue) { setValue(ivalue); }
  void setValue(int ivalue) {
    if (x == owner.x && y == owner.y) {
      owner.setValue(ivalue);
    }
  }
  
  void chainTo(Control control, boolean send) {
    owner.chainTo(control, send);
  }
  
  void propagateToChainedControls() {
    owner.propagateToChainedControls();
  }
}

class Slider extends Control {
  SliderSegment[] segments;
  
  void sliderAction(SliderSegment sender){}
  void liftFinger(SliderSegment sender){};
  
  void send() {
    if (channel != 0) outputChannel = channel-1;
    controlOut(x, y, value);
  }
  
  void nakedSetValue(int ivalue) { setValue(ivalue); }
  void setValue(int ivalue) {
    value = ivalue;
    propagateToChainedControls();
  }
}

class XSlider extends Slider {
  int lastSegment;
  int segment;
  int granularity;
  
  XSlider(int ix, int iy, int ixsize, int igranularity) {
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    xsize = ixsize;
    value = SLIDERDEFAULTVALUE;
    granularity = igranularity;
    segments = new SliderSegment[xsize];
    for (int i = 0; i < xsize; i++) {
      segments[i] = new SliderSegment(x+i, y, this);
    }
  }
  
  void sliderAction(SliderSegment sender) {
    segment = sender.x;
    if (lastSegment - 1 == segment) {
      decrease();
      //debug("Decreasing "+this+" to "+value);
    }
    if (lastSegment + 1 == segment) {
      increase();
      //debug("Increasing "+this+" to "+value);
    }
    sender.on();
    lastSegment = segment;
  }
  
  void liftFinger(SliderSegment sender) {
    sender.off();
  }
  
  void increase() {
    if (value < 127) {
      value += granularity;
    }
    if (value > 127) {
      value = 127;
    }
    send();
    propagateToChainedControls();
  }
  
  void decrease() {
    if (value > 0) {
      value -= granularity;
    }
    if (value < 0) {
      value = 0;
    }
    send();
    propagateToChainedControls();
  }
}

class YSlider extends Slider {
  int lastSegment;
  int segment;
  int granularity;
  
  YSlider(int ix, int iy, int iysize, int igranularity) {
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    ysize = iysize;
    value = SLIDERDEFAULTVALUE;
    granularity = igranularity;
    segments = new SliderSegment[ysize];
    for (int i = 0; i < ysize; i++) {
      segments[i] = new SliderSegment(x, y - i, this);
    }
  }
  
  void sliderAction(SliderSegment sender) {
    segment = sender.y;
    if (lastSegment - 1 == segment) {
      increase();
    }
    if (lastSegment + 1 == segment) {
      decrease();
    }
    sender.on();
    lastSegment = segment;
  }
  
  void liftFinger(SliderSegment sender) {
    sender.off();
  }
  
  void increase() {
    if (value < 127) {
      value += granularity;
    }
    if (value > 127) {
      value = 127;
    }
    send();
    propagateToChainedControls();
  }
  
  void decrease() {
    if (value > 0) {
      value -= granularity;
    }
    if (value < 0) {
      value = 0;
    }
    send();
    propagateToChainedControls();
  }
}

class PadSegment extends GridSegment {
  Pad owner;
  
  PadSegment(int ix, int iy, Pad iowner) {
    x = ix;
    y = iy;
    owner = iowner;
    grid[y*8+x] = this;
    idlecolor = PADOFFCOLOR;
    activecolor = PADONCOLOR;
    off();
  }
  
  void down() {
    owner.padAction(this);
  }
  
  void update() {
    owner.update(this);
  }
  
  void send() {
    if (x == owner.x && y == owner.y) {
      owner.sendX();
    }
    if (x == owner.x+1 && y == owner.y) {
      owner.sendY();
    }
  }
  
  void nakedSetValue(int ivalue) { setValue(ivalue); }
  void setValue(int ivalue) {
    if (x == owner.x && y == owner.y) {
      owner.nakedSetValueX(ivalue);
    }
    if (x == owner.x+1 && y == owner.y) {
      owner.nakedSetValueY(ivalue);
    }
  }
  
  void chainTo(Control control, boolean send) {
    owner.chainTo(control, send);
  }
  
  void propagateToChainedControls() {
    owner.propagateToChainedControls();
  }
}

class Pad extends Control {
  PadSegment[] padSegments;
  int sx;
  int sy;
  int lastsx;
  int lastsy;
  int xvalue;
  int yvalue;
  boolean invertx = false;
  boolean inverty = false;
  boolean TAKEOVER;
  long threadsSpawned = 0;
  long threadsFinished = 0;
  
  Pad(int ix, int iy, int ixsize, int iysize) {
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    xsize = ixsize;
    ysize = iysize;
    sx = x;
    sy = y+ysize-1;
    takeover = 0;
    yvalue = 0;
    xvalue = 0;
    lastsx = x;
    lastsy = y+ysize-1;
    padSegments = new PadSegment[xsize*ysize];
    
    for (int yi = 0; yi < ysize; yi++) {
      for (int xi = 0; xi < xsize; xi++) {
        padSegments[yi*ysize+xi] = new PadSegment(xi+x, yi+y, this);
      }
    }
  }
  
  void padAction(PadSegment sender) {
    //debug("padAction()");
    sy = sender.y;
    float rely = sy - y;
    float quantum = rely * (1 / ((float)ysize - 1));
    float amounty = 127-((rely + quantum) / (float)ysize) * 127;
    sx = sender.x;
    float relx = sx - x;
    quantum = relx * (1 / ((float)xsize - 1));
    float amountx = ((relx + quantum) / (float)xsize) * 127;
    setValue((int)amountx, (int)amounty);
  }
  
  void send() {
    sendX();
    sendY();
  }
  
  void sendX() {
    if (channel != 0) outputChannel = channel-1;
    if (!invertx) controlOut(x, y, xvalue);
    if (invertx) controlOut(x, y, 127-xvalue);
  }
  
  void sendY() {
    if (channel != 0) outputChannel = channel-1;
    if (!inverty) controlOut(x+1, y, yvalue);
    if (inverty) controlOut(x+1, y, 127-yvalue);

  }
  
  void setTakeover(int takeover) {
    this.takeover = takeover;
  }
  
  void invertx() {
    invertx = true;
  }
  
  void inverty() {
    inverty = true;
  }
  
  void nakedSetValueX(int ivalue) {
    if (invertx) ivalue = 127-ivalue;
    if (TAKEOVER == false) {
      float step = 127 / (xsize-1);
      sx = x+(int)(ivalue / step);
      xvalue = ivalue;
      propagateToChainedControls();
      //debug("nakedSetValueX() succeeded.");
    } else {
      //debug("nakedSetValueX() blocked because takeover is in progress.");
    }
  }
  
  void nakedSetValueY(int ivalue) {
    if (inverty) ivalue = 127-ivalue;
    if (TAKEOVER == false) {
      float step = 127 / (ysize-1);
      int rely = ((int)(ivalue / step));
      sy = (ysize-1)+(y - rely);
      yvalue = ivalue;
      propagateToChainedControls();
      //debug("nakedSetValueY() succeeded.");
    } else {
      //debug("nakedSetValueY() blocked because takeover is in progress.");
    }
  }
  
  void takeoverSetValue(int ixvalue, int iyvalue) {
    float step = 127 / (ysize-1);
      int rely = ((int)(iyvalue / step));
      sy = (ysize-1)+(y - rely);
      yvalue = iyvalue;
      
      step = 127 / (xsize-1);
      sx = x+(int)(ixvalue / step);
      xvalue = ixvalue;
      //debug("xvalue = "+xvalue+". sx = "+sx);
      //debug("yvalue = "+yvalue+". sy = "+sy);
      send();
      if (lastsy != sy || lastsx != sx) update();
      propagateToChainedControls();
  }
  
  void setValue(int ixvalue, int iyvalue) {
    if (takeover == 0) {
      float step = 127 / (ysize-1);
      int rely = ((int)(iyvalue / step));
      sy = (ysize-1)+(y - rely);
      yvalue = iyvalue;
      
      step = 127 / (xsize-1);
      sx = x+(int)(ixvalue / step);
      xvalue = ixvalue;
      //debug("xvalue = "+xvalue+". sx = "+sx);
      //debug("yvalue = "+yvalue+". sy = "+sy);
      send();
      if (lastsy != sy || lastsx != sx) update();
      propagateToChainedControls();
    } else {
      //debug("Delegating control to takeover routine");
      takeover(ixvalue, iyvalue);
    }
  }
  
  void takeover(int ixvalue, int iyvalue) {
      threadsSpawned++;
      TakeOver2d takeover = new TakeOver2d(this, ixvalue, iyvalue, this.takeover);
  }
  
  void update() {
    if (page == selectedPage) {
      //debug("update() sx="+sx+" sy="+sy);
      grid[lastsx+lastsy*8].off();
      grid[sx+sy*8].on();
      lastsx = sx;
      lastsy = sy;
    }
  }
  
  void update(PadSegment sender) {
    //debug("update("+sender+") sx="+sx+" sy="+sy);
    if ((sender.x == x && sender.y == y) || (sender.x-1 == x && sender.y == y)) {
      //debug("is the case");
      if (sender.x == sx && sender.y == sy) { sender.on(); } else { sender.off(); }
      grid[sx+sy*8].on();
      if (lastsx != sx || lastsy != sy) {
        grid[lastsx+lastsy*8].off();
        lastsx = sx;
        lastsy = sy;
      }
      
    } else {
      //debug("not the case");
      if (sender.x == sx && sender.y == sy) sender.on();
      if (sender.x != sx || sender.y != sy) sender.off();
    }
    /*lastsx = sx;
    lastsy = sy;*/
    
  }
}

class Drumrack extends Control {
  
  Drumrack(int ix, int iy, int ixsize, int iysize, int startOctave, String startNote, int vel, boolean invert) {
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    xsize = ixsize;
    ysize = iysize;
    Note note;
    
    int snote = addOctave(parseNote(startNote), startOctave);
    
    if (invert) {
      for (int yi = 0; yi < ysize; yi++) {
        for (int xi = 0; xi < xsize; xi++) {
          new Note(xi+x, ((ysize-1)-yi)+y, snote, vel);
          snote++;
        }
      }
    } else {
      for (int yi = 0; yi < ysize; yi++) {
        for (int xi = 0; xi < xsize; xi++) {
          new Note(xi+x, yi+y, snote, vel);
          snote++;
        }
      }
    }
  }
  
  int parseNote(String note) {
    note = note.toLowerCase();
    if (note.equals("c")) return 0;
    if (note.equals("c#")) return 1;
    if (note.equals("d")) return 2;
    if (note.equals("d#")) return 3;
    if (note.equals("e")) return 4;
    if (note.equals("f")) return 5;
    if (note.equals("f#")) return 6;
    if (note.equals("g")) return 7;
    if (note.equals("g#")) return 8;
    if (note.equals("a")) return 9;
    if (note.equals("a#")) return 10;
    if (note.equals("b")) return 11;
    return 0;
  }
  
  int addOctave(int note, int octave) {
    octave = octave+1;
    return note+(octave*12);
  }
  
}

class MeterSegment extends GridSegment {
  Meter owner;
  
  MeterSegment(int ix, int iy, Meter iowner) {
    page = selectedPage;
    x = ix;
    y = iy;
    owner = iowner;
    controlID = (int)random(1000);
    grid[y*8+x] = this;
    idlecolor = METERIDLECOLOR;
    activecolor = METERACTIVECOLOR;
    off();
  }
  
  void update() {
    if (x == owner.x && y == owner.y) {
      owner.update();
    }
  }
  
  void nakedSetValue(int ivalue) { setValue(ivalue); }
  void setValue(int ivalue) {
    if (x == owner.x && y == owner.y) {
      owner.nakedSetValue(ivalue);
    }
  }
  
  void chainTo(Control control, boolean send) {
    owner.chainTo(control, send);
  }
  
  void propagateToChainedControls() {
    owner.propagateToChainedControls();
  }
}

class Meter extends Control {
  MeterSegment[] segments;
  long lastupdate;
  
  boolean canUpdate() {
    long now = (new Date()).getTime();
    if (now - lastupdate > updatedelay) {
      lastupdate = now;
     return true;
    } else {
     return false;
    } 
  }
}

class XMeter extends Meter {
  int sx;
  float sxf;
  int lastsx;
  float lastsxf;

  XMeter(int ix, int iy, int ixsize) {
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    xsize = ixsize;
    sx = x;
    lastsx = -1;
    takeover = 0;
    segments = new MeterSegment[xsize];
    for (int i = 0; i < xsize; i++) {
      segments[i] = new MeterSegment(x+i, y, this);
    }
    grid[y*8+x].on();
  }
    
  void update() {
    
    if (canUpdate()) {
      //debug("go");
    if (page == selectedPage) { 
      for(int i = 0; i < xsize; i++) {
        
        if (i != sx && i != sx+1) {
          grid[y*8+x+i].off();
        }
        
        if (i == sx+1 && !(sxf - sx >= 0.56) && !(((sxf - sx) > 0.43 && (sxf - sx) < 0.56) && sx != xsize-1)) {
          grid[y*8+x+i].off();
        }
        
        if (i == sx) { 
          if (sxf - sx <= 0.43) {
            grid[y*8+x+i].on();
          }
          
          if (sxf - sx >= 0.56) {
            grid[y*8+x+(i+1)].on();
          }
          
          if (((sxf - sx) > 0.43 && (sxf - sx) < 0.56) && sx != xsize-1) {
            grid[y*8+x+i].on();
            grid[y*8+x+i+1].on();
          }
        }
        
      }
      lastsx = sx;
      lastsxf = sxf;
    }
    } else { /*debug("filtered");*/ }
  }
  
  
  void nakedSetValue(int ivalue) {
      float step = 127 / (xsize-1);
      sxf = (ivalue / step);
      //println(sxf);
      sx = (int)sxf;
      value = ivalue;
      propagateToChainedControls();
  }
  
  
  void setValue(int ivalue) {
      float step = 127 / (xsize-1);
      sxf = (ivalue / step);
      //println(sxf);
      sx = (int)sxf;
      value = ivalue;
      send();
      if (lastsxf != sxf) update();
      propagateToChainedControls();
   
  }
        
}

class YMeter extends Meter {
  int sy;
  int lastsy;
  float syf;
  float lastsyf;
  
  YMeter(int ix, int iy, int iysize) {
    controlID = (int)random(1000);
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    ysize = iysize;
    sy = y;
    lastsy = -1;
    value = 0;
    segments = new MeterSegment[ysize];
    for (int i = 0; i < ysize; i++) {
      segments[i] = new MeterSegment(x, y - i, this);
    }
    grid[y*8+x].on();
  }
  
  void update() {
    //debug("diff: "+abs((lastsy-lastsyf) - (sy-syf)));

    if (page == selectedPage && canUpdate()) { 
      for(int i = y; i >= y-(ysize-1); i--) {
        if (i != sy && i != sy-1) {
          grid[i*8+x].off();
          //debug("turning off 0");
        }
        
        if (i == sy-1 && !(sy - syf >= 0.56) && !(((sy - syf) > 0.43 && (syf - sy) < 0.56))) {
          grid[(i)*8+x].off();
        }
        
        
        if (i == sy) { 
          if (sy - syf <= 0.43) {
            grid[i*8+x].on();
            //debug("turning on 0");
          }
          
          if (sy - syf >= 0.56) {
            grid[(i-1)*8+x].on();
            //debug("turning on -1");
          }
          
          if (((sy - syf) > 0.43 && (syf - sy) < 0.56) && sy != y-ysize-1) {
            grid[i*8+x].on();
            grid[(i-1)*8+x].on();
            //debug("turning on both");
          }
        }
        
      }
      
      lastsy = sy;
      lastsyf = syf;
    }

  }
  
  
  
  void nakedSetValue(int ivalue) {
      float step = 127 / (ysize-1);
      int rely = ((int)(ivalue / step));
      syf = y - abs((ivalue / step));
      sy = y - rely;
      //debug("syf: "+syf);
      value = ivalue;
      propagateToChainedControls();
  }
  
  void setValue(int ivalue) {
      float step = 127 / (ysize-1);
      int rely = ((int)(ivalue / step));
      sy = y - rely;
      syf = y - abs((ivalue / step));
      //debug("syf: "+syf);
      value = ivalue;
      send();
      if (lastsyf != syf) update();
      propagateToChainedControls();
  }
}

class ProgressSegment extends GridSegment {
  Progress owner;
  
  ProgressSegment(int ix, int iy, Progress iowner) {
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    owner = iowner;
    controlID = (int)random(1000);
    grid[y*8+x] = this;
    idlecolor = PROGRESSIDLECOLOR;
    activecolor = PROGRESSACTIVECOLOR;
    off();
  }
  
  
  void update() {
    if (x == owner.x && y == owner.y) {
      owner.update();
    }
  }
  

  
  void nakedSetValue(int ivalue) { setValue(ivalue); }
  void setValue(int ivalue) {
    if (x == owner.x && y == owner.y) {
      owner.nakedSetValue(ivalue);
    }
  }
  
  void chainTo(Control control, boolean send) {
    owner.chainTo(control, send);
  }
  
  void propagateToChainedControls() {
    owner.propagateToChainedControls();
  }
}

class Progress extends Control {
  ProgressSegment[] segments;
  long lastupdate;
  
  boolean canUpdate() {
    long now = (new Date()).getTime();
    if (now - lastupdate > updatedelay) {
      lastupdate = now;
     return true;
    } else {
     return false;
    } 
  }
}

class XProgress extends Progress {
  int sx;
  int lastsx;

  XProgress(int ix, int iy, int ixsize) {
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    xsize = ixsize;
    sx = x;
    lastsx = -1;
    takeover = 0;
    segments = new ProgressSegment[xsize];
    for (int i = 0; i < xsize; i++) {
      segments[i] = new ProgressSegment(x+i, y, this);
    }
    grid[y*8+x].on();
  }

  void update() {
    //if (lastsx != sx) {
    if (page == selectedPage && canUpdate()) {    
      for(int i = 0; i < xsize; i++) {
        if (i <= sx) { grid[y*8+x+i].on(); } else { grid[y*8+x+i].off(); }
      }
      lastsx = sx;
    }
    //}
  }
  
  void nakedSetValue(int ivalue) {
      float step = 127 / (xsize-1);
      sx = (int)(ivalue / step);
      value = ivalue;
      propagateToChainedControls();
  }
  
  
  void setValue(int ivalue) {
      float step = 127 / (xsize-1);
      sx = (int)(ivalue / step);
      value = ivalue;
      send();
      if (lastsx != sx) update();
      propagateToChainedControls();    
  }   
}

class YProgress extends Progress {
  int sy;
  int lastsy;
  
  YProgress(int ix, int iy, int iysize) {
    controlID = (int)random(1000);
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    ysize = iysize;
    sy = y;
    lastsy = -1;
    value = 0;
    segments = new ProgressSegment[ysize];
    for (int i = 0; i < ysize; i++) {
      segments[i] = new ProgressSegment(x, y - i, this);
    }
    grid[y*8+x].on();
  }
  
  void update() {
    //if (lastsy != sy) {
    if (page == selectedPage && canUpdate()) {
      for(int i = y; i > y - ysize; i--) {
        if (i >= sy) { grid[i*8+x].on(); } else { grid[i*8+x].off(); }
      }
      lastsy = sy;
    }
    //}
  }
  
  void nakedSetValue(int ivalue) {
      float step = 127 / (ysize-1);
      int rely = ((int)(ivalue / step));
      sy = y - rely;
      value = ivalue;
      propagateToChainedControls();
  }
  
  void setValue(int ivalue) {
      float step = 127 / (ysize-1);
      int rely = ((int)(ivalue / step));
      sy = y - rely;
      value = ivalue;
      send();
      if (lastsy != sy) update();
      propagateToChainedControls();

  }
}

class CrsFaderSegment extends GridSegment {
  CrsFader owner;
  
  CrsFaderSegment(int ix, int iy, CrsFader iowner) {
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    owner = iowner;
    controlID = (int)random(1000);
    grid[y*8+x] = this;
    idlecolor = FADERIDLECOLOR;
    activecolor = FADERACTIVECOLOR;
    off();
  }
  
  void down() {
    owner.faderAction(this);
  }
  
  void up() {
    owner.stopAction();
  }
  
  void update() {
    if (x == owner.x && y == owner.y) {
      owner.update();
    }
  }
  
  void send() {
    if (x == owner.x && y == owner.y) {
      owner.send();
    }
  }
  
  void nakedSetValue(int ivalue) { setValue(ivalue); }
  void setValue(int ivalue) {
    if (x == owner.x && y == owner.y) {
      owner.nakedSetValue(ivalue);
    }
  }
  
  void chainTo(Control control, boolean send) {
    owner.chainTo(control, send);
  }
  
  void propagateToChainedControls() {
    owner.propagateToChainedControls();
  }
}

class CrsFader extends Control {
  int sx;
  float sxf;
  int lastsx;
  float lastsxf;
  float factor;
  boolean running;
  CrsFaderSegment[] segments;
  long lastupdate;
  
  CrsFader(int ix, int iy, int ixsize) {
    page = selectedPage;
    //println(this+" on page "+page);
    x = ix;
    y = iy;
    xsize = ixsize;
    sx = x;
    lastsx = -1;
    takeover = 0;
    factor = 0;
    running = false;
    segments = new CrsFaderSegment[xsize];
    for (int i = 0; i < xsize; i++) {
      segments[i] = new CrsFaderSegment(x+i, y, this);
    }
    grid[y*8+x].on();
  }
  
  void stopAction() {
    running = false;
    factor = 0;
  }
  
  void faderAction(CrsFaderSegment sender) {
    if (xsize % 2 != 0) {
      int relx = sender.x - x + 1;
      int center = abs(round(((float)xsize/2)));
      float relpos = ((relx - center)/((float)xsize-1))*2;
      
      debug("CrsFader update. Sender x = "+sender.x+", relx="+relx);
      debug("Relative position: "+relpos+", center="+center);
    } else {
      int relx = sender.x - x + 1;
      int center = xsize/2;
      float relpos = 0;
      
      if (relx <= center) {
        relpos = (center - (relx-1))/(float)center * -1;
      } else {
        relpos = (relx - center)/(float)center;
      }
      
      debug("CrsFader update. Sender x = "+sender.x+", relx="+relx);
      debug("Relative position: "+relpos+", center="+center);
      
      factor = relpos;
      if (factor != 0 && !running) {
        running = true;
        spawnThread();
      }
    }
  }
  
  void spawnThread() {
    CrsUpdater updater = new CrsUpdater(this);
  }
  
  void updateValue() {
    int nvalue = (int)(value+(factor*6));
    if (nvalue < 0) nvalue = 0;
    if (nvalue > 127) nvalue = 127;
    setValue(nvalue);
  }
  
  boolean canUpdate() {
    long now = (new Date()).getTime();
    if (now - lastupdate > updatedelay) {
      lastupdate = now;
     return true;
    } else {
     return false;
    } 
  }
    
  void update() {
    
    if (canUpdate()) {
      //debug("go");
    if (page == selectedPage) { 
      for(int i = 0; i < xsize; i++) {
        
        if (i != sx && i != sx+1) {
          grid[y*8+x+i].off();
        }
        
        if (i == sx+1 && !(sxf - sx >= 0.56) && !(((sxf - sx) > 0.43 && (sxf - sx) < 0.56) && sx != xsize-1)) {
          grid[y*8+x+i].off();
        }
        
        if (i == sx) { 
          if (sxf - sx <= 0.43) {
            grid[y*8+x+i].on();
          }
          
          if (sxf - sx >= 0.56) {
            grid[y*8+x+(i+1)].on();
          }
          
          if (((sxf - sx) > 0.43 && (sxf - sx) < 0.56) && sx != xsize-1) {
            grid[y*8+x+i].on();
            grid[y*8+x+i+1].on();
          }
        }
        
      }
      lastsx = sx;
      lastsxf = sxf;
    }
    } else { /*debug("filtered");*/ }
  }
  
  
  void nakedSetValue(int ivalue) {
    if (!running) {
      float step = 127 / (xsize-1);
      sxf = (ivalue / step);
      //println(sxf);
      sx = (int)sxf;
      value = ivalue;
      propagateToChainedControls();
    } else {
      debug("Blocked because thread is running");
    }
  }
  
  
  void setValue(int ivalue) {
      float step = 127 / (xsize-1);
      sxf = (ivalue / step);
      //println(sxf);
      sx = (int)sxf;
      value = ivalue;
      send();
      if (lastsxf != sxf) update();
      propagateToChainedControls();
  }
  
  void send() {
    controlOut(x, y, value);
  }
        
}

