License license = new License();
boolean lpdetect = false;
boolean allgood = false;
int delay;

void setup(){
  loadConfig();
  setupDemos();
  f10 = loadFont("10.vlw");
  f11 = loadFont("11.vlw");
  f14 = loadFont("14.vlw");
  f18 = loadFont("18.vlw");
  f20 = loadFont("20.vlw");
  f40 = loadFont("40.vlw");
  size(WINDOWSIZE, WINDOWSIZE);
  background(0);
  frameRate(FRAMERATE);
  launchpad = new MIDI("Launchpad");
  if (launchpad.initialised) launchpad.sendCtl(0, 0, 0);
  sleep(500);
  if (launchpad.initialised) launchpad.sendCtl(0, 0, 0);
  
  if (launchpad.initialised) {
    //debug("Launchpad detected, huzzah!");
    launchpad.reset();
    splash(true);
  } else {
    //debug("Oh sorrow... No Launchpad was detected...");
    splash(false);
  }
}

void splash(boolean success) {
  if (SILENTMODE) {
    if (!SOFTWARE.equals("") && !SOFTWAREIN.equals("")) {
      fill(#FFFFFF);
      textFont(f10, 10);
      textAlign(LEFT);
      smooth();
      text("Out: "+SOFTWARE+"\nIn: "+SOFTWAREIN, 2, 12);
      initMidiSystem();
    } else {
      SILENTMODE = false;
    }
  }
  if (!SILENTMODE) {
    if (success) { launchpad.reset(); DEMO = true; displaystate = true; }
    lpdetect = success;
    delay = 15;
    state = "splash";
    menustate = "midiout";
    katapult = new MText("Katapult", 0, WINDOWSIZE/2);
    mline = new MLine(WINDOWSIZE, WINDOWSIZE/2+3);
    katapult.setDestination(WINDOWSIZE/2, WINDOWSIZE/2);
    katapult.setDuration(16);
    mline.setDestination(0, WINDOWSIZE/2+3);
    mline.setDuration(20);
    mline.animate();
    katapult.animate();
  }
}

void initMidiSystem() {
  //debug("Initiaing MIDI system...");
  //debug("SOFTWARE: " + SOFTWARE);
  //debug("SOFTWAREIN: " + SOFTWAREIN);
  receiverA = new MIDIListener("Launchpad");
  receiverB = new MIDIListener("Software");
  software = new MIDI(SOFTWARE);
  softwareIn = new MIDIinput(SOFTWAREIN, receiverB);
  launchpadIn = new MIDIinput("Launchpad", receiverA);
  software.reset();
  softwareIn.reset();
  launchpadIn.reset();
  
  displaystate = true;
  clearDisplay();
  displaystate = false;
  loadLayouts();
  for (int i = 0; i < numberOfPages; i++) {
    loadLayout(pageNumbers[i]);
    loadLayout(PAGESELECTOR);
  }
  displaystate = true;
  loadLayout(1);
  demo = sdemo;
  allgood = true;
}

void draw() {
  if (online) readServer();
  if (DEMO) demos();
  menus();
}

void cleanup() {
  clearDisplay();
  if (launchpad != null) launchpad.close();
  if (software != null) software.close();
  if (launchpadIn != null) launchpadIn.close();
  if (softwareIn != null) softwareIn.close();
}

public void stop() {
  //debug("Cleaning up...");
  cleanup();
  //debug("Cleanup done");
  println("Coding monkey and sewing monkey are the supreme rulers of the world");
  clearDisplay();
  super.stop();
} 

void mousePressed() {
  if (mousestate.equals("quit")) {
    displaystate = false;
    clearDisplay();
    exit();
  }
}

void keyPressed() {
  if ((int)keyCode == 40 && mselection < mselmax - 1) mselection = (mselection + 1)%mselmax;
  if ((int)keyCode == 38 && mselection > 0) mselection = (mselection - 1)%mselmax;
  if ((int)keyCode == 10) { mselout = mselection; mselection = MFINAL; }
  if ((int)keyCode == 37 && (HEADLESS == true || NETWORK == true) && currentPage > 1) {  selectedPage = pageNumbers[indexForKey(pageNumbers, selectedPage)-1]; loadLayout(selectedPage); }
  if ((int)keyCode == 39 && (HEADLESS == true || NETWORK == true) && currentPage < pageNumbers[numberOfPages-1]) { selectedPage = pageNumbers[indexForKey(pageNumbers, selectedPage)+1]; loadLayout(selectedPage); }
  if ((int)keyCode == 80 && (HEADLESS == true || NETWORK == true || LIVEENABLED == true)) { reloadLayouts(); }
  //if ((int)keyCode == 80 && (HEADLESS == true || NETWORK == true)) { DEMO = !(DEMO); }
//  if ((int)keyCode == 27) cleanup();
}

// Testing functions

void debug(String msg) {
  if (DEBUG) println(msg);
}

int indexForKey(int[] a, int target) {
  for (int i = 0; i < a.length; i++) {
    if (a[i] == target) return i;
  }
  return 0;
}
