// Configuration
static String VERSION = "1.2";
static int FRAMERATE = 60;
static int WINDOWSIZE = 400;
static int FRAMEBORDER = 10;
static String SOFTWARE = "";
static String SOFTWAREIN = "";
static String SOFTWARESEL = "";
static String SOFTWAREINSEL = "";
static boolean DEBUG = false;
static boolean NOSEND = false;
static boolean NETWORK = false;
static boolean HEADLESS = false;
static boolean LIVECONTROL = false;
static boolean LIVEENABLED = false;
static int USERMODE = 1;
static int MAXCHAINS = 64;
static boolean DEMO = false;
static String DEMOTEXT = "katapult";
static int DEMOCHOICE = -1;
static boolean SILENTMODE = false;

// Internal variables
static String config[];
static int CLINESIN = -1;
static int CLINESOUT = -1;
static boolean DEVICECONFIG = false;

void loadConfig() {
  config = loadStrings("config.txt");
  for (int i = 0; i < config.length; i++) {
    String configLine[] = split(config[i], "=");
    if (configLine[0].equals("in")) {
      SOFTWAREIN = configLine[1];
      SOFTWAREINSEL = configLine[1];
      CLINESIN = i;
    }
    if (configLine[0].equals("out")) {
      SOFTWARE = configLine[1];
      SOFTWARESEL = configLine[1];
      CLINESOUT = i;
    }
    if (configLine[0].equals("abletonlive")) {
      if (configLine[1].equals("yes")) { LIVEENABLED = true; }
    }
    if (configLine[0].equals("liveusermode")) {
      if (configLine[1].equals("2")) { USERMODE = 2; }
    }
    if (configLine[0].equals("silent")) {
      if (configLine[1].equals("yes")) { SILENTMODE = true; WINDOWSIZE = 150; }
    }
    if (configLine[0].equals("headless")) {
      if (configLine[1].equals("yes")) { HEADLESS = true; VERSION = VERSION + " headless"; }
    }
    if (configLine[0].equals("holdoffcolor")) {
       BUTTONIDLECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("holdoncolor")) {
       HOLDONCOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("toggleoffcolor")) {
       TOGGLEOFFCOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("toggleoncolor")) {
       TOGGLEONCOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("faderoffcolor")) {
       FADERIDLECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("faderoncolor")) {
       FADERACTIVECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("slideroffcolor")) {
      SLIDERIDLECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("slideroncolor")) {
      SLIDERACTIVECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("pagebuttononcolor")) {
      PAGEBUTTONACTIVECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("pagebuttonoffcolor")) {
      PAGEBUTTONIDLECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("meteroffcolor")) {
      METERIDLECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("meteroncolor")) {
      METERACTIVECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("progressoffcolor")) {
      PROGRESSIDLECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("progressoncolor")) {
      PROGRESSACTIVECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("noteoffcolor")) {
      NOTEIDLECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("noteoncolor")) {
      NOTEACTIVECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("cconcolor")) {
      CCACTIVECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("ccoffcolor")) {
      CCIDLECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("pconcolor")) {
      PCACTIVECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("pcoffcolor")) {
      PCIDLECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("kbdoncolor")) {
      KBDACTIVECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("kbdoffcolor")) {
      KBDIDLECOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("demotextcolor")) {
      SCROLLERCOLOR = parseColor(configLine[1]);
    }
    if (configLine[0].equals("demotext")) {
      DEMOTEXT = configLine[1];
    }
    if (configLine[0].equals("demochoice")) {
      DEMOCHOICE = Integer.parseInt(configLine[1]);
    }
    if (configLine[0].equals("b1")) {
      overrideBitmap(0, configLine[1]);
    }
    if (configLine[0].equals("b2")) {
      overrideBitmap(1, configLine[1]);
    }
    if (configLine[0].equals("b3")) {
      overrideBitmap(2, configLine[1]); 
    }
    if (configLine[0].equals("b4")) {
      overrideBitmap(3, configLine[1]);
    }
    if (configLine[0].equals("b5")) {
      overrideBitmap(4, configLine[1]);
    }
    if (configLine[0].equals("b6")) {
      overrideBitmap(5, configLine[1]);
    }
    
  }
  if (!SOFTWAREIN.equals("") && !SOFTWARE.equals("")) DEVICECONFIG = true;
  storeDefaultColors();
}

void saveConfig() {
  //debug("saveConfig()");
  int configlength = config.length;
  //debug("Configlength "+configlength);
  if (CLINESIN == -1) { CLINESIN = configlength; configlength++; }
  if (CLINESOUT == -1) { CLINESOUT = configlength; configlength++; }
  //debug("Configlength "+configlength);
  String[] newconfig = new String[configlength];
  for (int i = 0; i < config.length; i++) {
    newconfig[i] = config[i];
  }
  //debug("linein"+CLINESIN);
  //debug("lineout"+CLINESOUT);
  //debug("Configlength "+newconfig.length);
  newconfig[CLINESIN] = "in="+SOFTWAREIN;
  newconfig[CLINESOUT] = "out="+SOFTWARE;
  saveStrings("config.txt", newconfig);
}
