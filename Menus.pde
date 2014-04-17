PFont f10;
PFont f11;
PFont f14;
PFont f18;
PFont f20;
PFont f40;
MText katapult;
MLine mline;
String state = "nothing";
String mousestate = "nothing";
String menustate = "nothing";
String device = "Launchpad";
int mselection = 0;
int mselout = 0;
int mselmax = 0;
int menuAnswer = 0;

void menus() {
  //if (NETWORK) lpdetect = true;
  if (HEADLESS) { lpdetect = true; NOSEND = true; }
  if (state.equals("splash")) {
    background(#000000);
    if (katapult != null) katapult.draw();
    if (mline != null) mline.draw();
    if (mline.isDone() && katapult.isDone() && katapult.y > 35) {
      katapult.y -= 3;
      mline.y -= 3;
      mline.starty -= 3;
    }
    if (mline.isDone() && katapult.isDone() && katapult.y <= 35) {
      if (delay > 0) {
          delay--;
      } else {
        if (lpdetect && menustate.equals("midiout")) {
          if (mselection != MFINAL && !DEVICECONFIG) {
            fill(#FFFFFF);
            textFont(f18, 18);
            textAlign(CENTER);
            smooth();
            text(device+" connected", WINDOWSIZE/2, 65);
            textFont(f14, 14);
            textAlign(LEFT);
            int ii = 0;
            int[] midilist = new int[256];
            String midiliststr = "What MIDI port should Katapult send MIDI data to?\n\n";
            for (int i = 0; i < launchpad.infos.length; i++) {
              try {
                if ((MidiSystem.getMidiDevice(launchpad.infos[i]).getMaxReceivers() > 0 || MidiSystem.getMidiDevice(launchpad.infos[i]).getMaxReceivers() == -1) && !(launchpad.infos[i].getName().equals("Launchpad"))) {
                  midilist[ii] = i;
                  ii++;
                }
              } catch (MidiUnavailableException e) {
                println("MIDI error while enumerating devices");
              }
            }
            for (int i = 0; i < ii; i++) {
              midiliststr = midiliststr + "     " + (i+1) + ": " + launchpad.infos[midilist[i]].getName() + "\n";
            }
            midiliststr = midiliststr+"\nThis should be set to your software's input port.\nUse the arrow keys and enter to select.";
            mselmax = ii;
            text(midiliststr, 5, 105);
            ellipse(15, 134+(17.5*mselection), 5, 5);
            SOFTWARESEL = launchpad.infos[midilist[mselection]].getName();
          } else {
            SOFTWARE = SOFTWARESEL;
            menustate = "midiin";
            mselection = 0;
          }
        } else if (lpdetect && menustate.equals("midiin")) {
          if (mselection != MFINAL && !DEVICECONFIG) {
            fill(#FFFFFF);
            textFont(f18, 18);
            textAlign(CENTER);
            smooth();
            text("Launchpad connected", WINDOWSIZE/2, 65);
            textFont(f14, 14);
            textAlign(LEFT);
            int ii = 0;
            int[] midilist = new int[256];
            String midiliststr = "What device should Katapult listen for MIDI data on?\n\n";
            for (int i = 0; i < launchpad.infos.length; i++) {
              try {
                if ((MidiSystem.getMidiDevice(launchpad.infos[i]).getMaxTransmitters() > 0 || MidiSystem.getMidiDevice(launchpad.infos[i]).getMaxReceivers() == -1) && !(launchpad.infos[i].getName().equals("Launchpad"))) {
                  midilist[ii] = i;
                  ii++;
                }
              } catch (MidiUnavailableException e) {
                println("MIDI error while enumerating devices");
              }
            }
            for (int i = 0; i < ii; i++) {
              midiliststr = midiliststr + "     " + (i+1) + ": " + launchpad.infos[midilist[i]].getName() + "\n";
            }
            midiliststr = midiliststr+"\nThis should be set to your software's output port.\nUse the arrow keys and enter to select.";
            mselmax = ii;
            text(midiliststr, 5, 105);
            ellipse(15, 134+(17.5*mselection), 5, 5);
            SOFTWAREINSEL = launchpad.infos[midilist[mselection]].getName();
          } else {
            SOFTWAREIN = SOFTWAREINSEL;
            menustate = "saveconfig";
            mselection = 0;
          }
          
          } else if (lpdetect && menustate.equals("saveconfig")) {
          if (mselection != MFINAL && !DEVICECONFIG) {
            fill(#FFFFFF);
            textFont(f18, 18);
            textAlign(CENTER);
            smooth();
            text("Launchpad connected", WINDOWSIZE/2, 65);
            textFont(f14, 14);
            textAlign(LEFT);
            int ii = 0;
            int[] midilist = new int[256];
            String midiliststr = "Save devices choices?\n\n     Yes\n     No\n\n";
            midiliststr += "If you choose 'yes', your choices will be written\nto the configuration file, and this menu\nwill not be displayed at startup.\n\n";
            midiliststr += "If you want to edit your devices at a later point\nyou must remove the in/out lines from the\nconfiguration file.";
            mselmax = 2;
            text(midiliststr, 5, 105);
            ellipse(15, 134+(17.5*mselection), 5, 5);
            menuAnswer = mselection;
          } else {
            if (menuAnswer == 0) { saveConfig(); }
            menustate = "nothing";
            mselection = 0;
            DEMO = false;
            state = "run";
            noStroke();
            noFill();
            background(0);
            initMidiSystem();
          }
          
        } else if (!lpdetect) {
          fill(#FFFFFF);
          textFont(f18, 18);
          textAlign(CENTER);
          smooth();
          text("No Launchpad detected via USB\nWaiting for network connection...", WINDOWSIZE/2, WINDOWSIZE/2);
          if (!online) {
            initServer();
            NETWORK = true;
            NOSEND = true;
          }
          if (slaveConnected) {
            mousestate = "hold";
            menustate = "nothing";
            mselection = 0;
            device = "iPad";
            DEMO = false;
            //HEADLESS = true;
            NOSEND = false;
            state = "run";
            noStroke();
            noFill();
            background(0);
            //initMidiSystem();
            splash(true);
          }
          if (mousestate.equals("hold")) {
            mousestate = "nothing";
          } else {
            mousestate = "quit";
          }
        }
      }
    }
    fill(#FFFFFF);
    textFont(f11, 11);
    textAlign(RIGHT);
    smooth();
    text(UNLICENSED+" v:"+VERSION, WINDOWSIZE-2, WINDOWSIZE-2);
  }
}
