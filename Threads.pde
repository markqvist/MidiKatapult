static long tcount = 0;
static long tcount2d = 0;

class Scheduler implements Runnable {
  Thread thread;
  Fader target;
  
  public Scheduler(Fader target) {
    this.target = target;
    tcount++;
    thread = new Thread(this, "Katapult"+tcount);
    thread.start();
  }
  
  public void run() {
    while (!target.canUpdate()) {
      try {
        thread.sleep(40);
      } catch (Exception e) {
        print(e);
      }
    }
    target.update();
    target.cancelSchedule();
  }
}

class CrsUpdater implements Runnable {
  Thread thread;
  CrsFader target;
  
  public CrsUpdater(CrsFader target) {
    this.target = target;
    tcount++;
    thread = new Thread(this, "Katapult"+tcount);
    thread.start();
  }
  
  public void run() {
    target.running = true;
    try {
      debug("Updater thread spawned: "+this);
      while (target.factor != 0) {
        target.updateValue();
        thread.sleep(25);
      }
    } catch (Exception e) {
      
    }
    target.running = false;
    debug("Updater thread died: "+this);
  } 
}

class TakeOver implements Runnable {
  Thread thread;
  Control target;
  int targetValue;
  int initialTargetValue;
  int mvalue;
  int initialmvalue;
  int takeover;
  long threadnumber;
  boolean exits = false;
  
  public TakeOver(Fader target, int targetValue, int takeover) {
    tcount++;
    thread = new Thread(this, "Katapult"+tcount);
    threadnumber = target.threadsSpawned;
    this.target = target;
    this.targetValue = targetValue;
    this.mvalue = target.value;
    this.initialmvalue = mvalue;
    this.takeover = takeover;
    thread.start();
  }
  
  void cleanUpThreads() {
    //debug("CLEANUP METHOD CALLED______________________________");
    target.threadsFinished++;
    exits = true;   
  }
    
  public void run() {
    boolean wait = false;
    long started = (new Date()).getTime();
    long waitTime = 0;
    int[] probeValues = new int[4];
    int probeCount = 3;
    probeValues[0] = -1;
    
    try {
      //debug("\n\nThread "+target+" running.\ntn="+threadnumber+"\ntf="+target.threadsFinished);
      if (target.threadsFinished >= target.threadsSpawned) target.threadsFinished = threadnumber - 1;
      
      if (!(target.threadsFinished == threadnumber - 1)) wait = true;
      while (wait) {

          thread.sleep((int)(1000/FRAMERATE));
          waitTime = (new Date()).getTime() - started;
          probeValues[probeCount] = target.value;
          probeCount--; if (probeCount == -1) probeCount = 3;
          if (waitTime > 45 && probeValues[0] == probeValues[1] && probeValues[1] == probeValues[2] && probeValues[2] == probeValues[3]) cleanUpThreads();
      
          //debug(target+" sleeping. tn "+threadnumber+" tf "+target.threadsFinished);
          if (!(target.threadsFinished == threadnumber - 1)) { wait = true; } else { wait = false; }
          if (exits) wait = false;
      }
      
      //debug(target+" got past que wait");
      
      thread.sleep(25);
      
      this.mvalue = target.value;
      this.initialmvalue = mvalue;
      target.TLOCK = true;
      target.TAKEOVER = true;
      
      if (!(exits)) {
        //debug(target+" starting takeover. targetValue="+targetValue+" mvalue="+mvalue);
        
        if (initialmvalue < targetValue) {
          for (int i = 0; i < targetValue-initialmvalue; i++) {
          //while (mvalue < targetValue && target.page == selectedPage) {
            //debug(target+" in takeover. mvalue="+mvalue);
            mvalue += 1;
            //debug(target+" waiting for "+takeover+" mills");
            //try {
              thread.sleep(takeover);
            //} catch (Exception e) {
            //  debug("Exception while sleeping "+target+":\n"+e);
            //}
            target.takeoverSetValue(mvalue);
          //}
          }
        }
        
        if (initialmvalue > targetValue && target.page == selectedPage) {
          for (int i = 0; i < initialmvalue-targetValue; i++) {
          //while (mvalue > targetValue) {
            //debug(target+" in takeover. mvalue="+mvalue);
            mvalue -= 1;
            //debug(target+" waiting for "+takeover+" mills");
            //try {
              thread.sleep(takeover);
            //} catch (Exception e) {
            //  debug("Exception while sleeping "+target+":\n"+e);
            //}
            target.takeoverSetValue(mvalue);
          //}
          }
        }
        //debug(target+" takeover finished");
      } else {
        //debug("Closing hanging thread "+thread);
      }
      target.threadsFinished++;
      //debug(target+" sleeping for cleanup");
      //try {
        thread.sleep(1000);
      //} catch (Exception e) {
      //  debug("Exception while sleeping "+target+":\n"+e);
      //}
      if (target.threadsFinished == target.threadsSpawned) target.TAKEOVER = false;
      //debug(target+" terminating");
    } catch (Exception e) {
      target.threadsFinished++;
      if (target.threadsFinished == target.threadsSpawned) target.TAKEOVER = false;
      //debug("Exception in takeover thread "+tcount+"\n"+e);
    }
   }
}

class TakeOver2d implements Runnable {
  Thread thread;
  Pad target;
  float targetXValue;
  float targetYValue;
  float initialTargetXValue;
  float initialTargetYValue;
  float mxvalue;
  float myvalue;
  float initialmxvalue;
  float initialmyvalue;
  float xstep;
  float ystep;
  float xdiff;
  float ydiff;
  float xdir;
  float ydir;
  float steps;
  int takeover;
  long threadnumber;
  
  public TakeOver2d(Pad target, int targetXValue, int targetYValue, int takeover) {
    tcount2d++;
    thread = new Thread(this, "Katapult2d"+tcount2d);
    threadnumber = target.threadsSpawned;
    this.target = target;
    this.targetXValue = targetXValue;
    this.targetYValue = targetYValue;
    this.takeover = takeover;
    thread.start();
  }
    
  public void run() {
    
    while (!(target.threadsFinished == threadnumber - 1)) {
      try {
        thread.sleep((int)(1000/FRAMERATE));
      } catch (Exception e) {
        //debug("Exception while sleeping "+this+":\n"+e);
      }
    }
    
    target.TAKEOVER = true;
    
    mxvalue = target.xvalue;
    myvalue = target.yvalue;
    initialmxvalue = mxvalue;
    initialmyvalue = myvalue;
    xdiff = targetXValue - mxvalue;
    ydiff = targetYValue - myvalue;
    
    if (xdiff < 0) xdir = -1;
    if (xdiff > 0) xdir = 1;
    if (ydiff < 0) ydir = -1;
    if (ydiff > 0) ydir = 1;
    
    if (abs(xdiff) > abs(ydiff)) {
      steps = abs(xdiff);
      xstep = 1;
      ystep = abs(ydiff) / abs(xdiff);
    }
    
    if (abs(ydiff) > abs(xdiff)) {
      steps = abs(ydiff);
      ystep = 1;
      xstep = abs(xdiff) / abs(ydiff);
    }
    
    if (abs(xdiff) == abs(ydiff)) {
      xstep = 1;
      ystep = 1;
      steps = abs(xdiff);
    }
    
    //debug("Starting takeover");
    //debug("Target x value="+targetXValue);
    //debug("Target y value="+targetYValue);
    //debug("xdiff="+xdiff);
    //debug("ydiff="+ydiff);
    //debug("initialmxvalue="+mxvalue);
    //debug("initialmyvalue="+myvalue);
    //debug("xdir="+xdir);
    //debug("ydir="+ydir);
    //debug("xstep="+xstep);
    //debug("ystep="+ystep);
    //debug("steps="+steps);
    
    for (int i = 0; i < steps; i++) {
      mxvalue += xstep*xdir;
      myvalue += ystep*ydir;
      //debug(target+" in takeover. mxvalue="+mxvalue+" myvalue="+myvalue);
      target.takeoverSetValue((int)round(mxvalue), (int)round(myvalue));
      //debug("Waiting for "+takeover+" mills");
      sleep(takeover);
    }
    
    target.threadsFinished++;
    try {
      thread.sleep(1000);
    } catch (Exception e) {
      //debug("Exception while sleeping "+this+":\n"+e);
    }
    if (target.threadsFinished == target.threadsSpawned) target.TAKEOVER = false;
  }
}

