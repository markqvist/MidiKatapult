import javax.sound.midi.*;
import javax.sound.midi.MidiUnavailableException;

MIDI launchpad;
MIDI software;
MIDIListener receiverA;
MIDIListener receiverB;
MIDIinput launchpadIn;
MIDIinput softwareIn;

int outputChannel;
int customChannel;

///////////////

class MidiMsg extends MidiMessage {
  MidiMsg(byte[] data) {
    super(data); 
  }
  
  MidiMsg clone() {
    return this;
  }
}

class MIDI extends Object {
  MidiDevice device;
  int deviceNumber = 256;
  long midiTS = 0;
  boolean initialised = false;
  Receiver out = null;
  Transmitter in = null;
  public MidiDevice.Info[] infos;
  
  public MIDI(String target) {
    try {
      //debug("1a");
      infos = MidiSystem.getMidiDeviceInfo();
      //debug("1b");
      //debug("Looking for device: "+target);
      for (int i = 0; i < infos.length; i++) {
        //debug(i+": "+infos[i].getName()+", "+infos[i].getDescription()+", "+MidiSystem.getMidiDevice(infos[i]).getMaxReceivers());

        if (target.equals(infos[i].getName()) && (MidiSystem.getMidiDevice(infos[i]).getMaxReceivers() > 0 || MidiSystem.getMidiDevice(infos[i]).getMaxReceivers() == -1)) {
          deviceNumber = i;
        }
      }
      
      //debug("Device is number "+deviceNumber);
      
      if (deviceNumber != 256) {
        MidiDevice device = MidiSystem.getMidiDevice(infos[deviceNumber]);
        device.open();
        out = device.getReceiver();

        this.initialised = true;
      } else {
        this.initialised = false;
      }
    } catch (MidiUnavailableException e) {
      println("Error obtaining device:" + e);
      this.initialised = false;
    }
  }
    
  void sendOff(int note, int vel, int channel) {
    ShortMessage msg = new ShortMessage();
    try {
      msg.setMessage(NOTEOFF, channel, note, vel);
    } catch (InvalidMidiDataException e) {
      println("Error in "+this+": "+e);
    }
    out.send(msg, midiTS);
    midiTS++;
  }
  
  void sendOn(int note, int vel, int channel) {
    //debug("sendOn() note="+note+" vel="+vel+" channel="+channel);
    ShortMessage msg = new ShortMessage();
    try {
      msg.setMessage(NOTEON, channel, note, vel);
    } catch (InvalidMidiDataException e) {
      println("Error in "+this+": "+e);
    }
    if (!NOSEND) out.send(msg, midiTS);
    midiTS++;
  }
  
  void sendCtl(int note, int vel, int channel) { 
    ShortMessage msg = new ShortMessage();
    try {
      msg.setMessage(CTLCHG, channel, note, vel);
    } catch (InvalidMidiDataException e) {
      println("Error in "+this+": "+e);
    }
    if (!NOSEND) out.send(msg, midiTS);
    midiTS++;
  }
  
  void sendPgr(int program, int channel) { 
    ShortMessage msg = new ShortMessage();
    try {
      msg.setMessage(PRGCHG, channel, program, 0);
    } catch (InvalidMidiDataException e) {
      println("Error in "+this+": "+e);
    }
    if (!NOSEND) out.send(msg, midiTS);
    midiTS++;
  }
  
  
  void close() {
    if (device != null) { 
      //debug("Closing "+this+" ("+infos[deviceNumber].getName()+")");
      device.close();
    }
  }
  
  void reset() {
    if (device != null) {
      try {
        device.close();
        device.open();
      } catch (Exception e) {
        //debug("Exception: "+e);
      }
    }
  }
}

class MIDIinput extends Object {
  MidiDevice device;
  int deviceNumber = 256;
  boolean initialised = false;
  Transmitter in = null;
  MidiDevice.Info[] infos;
  
  public MIDIinput(String target, Receiver listener) {
    try {
      infos = MidiSystem.getMidiDeviceInfo();
      //debug("Looking for device: "+target);
      for (int i = 0; i < infos.length; i++) {
        //debug(i+": "+infos[i].getName()+", "+infos[i].getDescription()+", "+MidiSystem.getMidiDevice(infos[i]).getMaxTransmitters());

        if (target.equals(infos[i].getName()) && (MidiSystem.getMidiDevice(infos[i]).getMaxTransmitters() > 0 || MidiSystem.getMidiDevice(infos[i]).getMaxTransmitters() == -1)) {
          deviceNumber = i;
        }
      }
      
      //debug("Device is number "+deviceNumber);
      
      if (deviceNumber != 256) {
        MidiDevice device = MidiSystem.getMidiDevice(infos[deviceNumber]);
        device.open();
        in = device.getTransmitter();
        in.setReceiver(listener);
        this.initialised = true;
      } else {
        this.initialised = false;
      }
    } catch (MidiUnavailableException e) {
      println("Error obtaining device:" + e);
      this.initialised = false;
    }
  }
  
  void close() {
    if (device != null) { 
      //debug("Closing "+this+" ("+infos[deviceNumber].getName()+")");
      device.close();
    }
  }
  
  void reset() {
    if (device != null) {
      try {
        device.close();
        device.open();
      } catch (Exception e) {
        //debug("Exception: "+e);
      }
    }
  }
}

class MIDIListener implements Receiver {
  String context;
  
  public MIDIListener(String context) {
    this.context = context;
//    super.init();
  }
  
  void close() {
    
  }
  
  void send(MidiMessage msg, long ts) {
    ShortMessage smsg = (ShortMessage) msg;
    int channel = smsg.getChannel();
    byte[] data = msg.getMessage();
    debug("Control MIDI: "+data[1]);
    debug("USERMODE: "+USERMODE);
    
    if ((data[0] & 0xFF) == NOTEON) {
      if (context.equals("Launchpad")) {
        launchpadAction(data[1], data[2]);
      }
      if (context.equals("Software")) {
        softwareNoteAction(data[1], data[2], channel);
      }
    }
    
    if ((data[0] & 0xFF) == CTLCHG+channel ) {
      if (context.equals("Software")) {
        softwareCtlAction(data[1], data[2], channel);
      }
      
      if (context.equals("Launchpad")) {
        if (LIVECONTROL == false) {
          if (data[1] == 107 && data[2] == 127 && currentPage < pageNumbers[numberOfPages-1]) { 
            selectedPage = pageNumbers[indexForKey(pageNumbers, selectedPage)+1]; loadLayout(selectedPage);
          }
          
          if (data[1] == 106 && data[2] == 127 && currentPage > 1) {
            selectedPage = pageNumbers[indexForKey(pageNumbers, selectedPage)-1]; loadLayout(selectedPage);
          }
        }
        
        if (data[1] == 111 && data[2] == 127) {
          if (LIVECONTROL == false) {
            DEMO = !(DEMO);
            //debug("Demo " + DEMO);
            if (DEMO == false) {
              clearDisplay();
              loadLayout(currentPage);
            }
          }
        }
        
        if (data[1] == 108 && data[2] == 127) {
          if (LIVEENABLED) {
            clearDisplay();
            LIVECONTROL = true;
            NOSEND = true;
          } else {
            reloadLayouts();
          }
        }
        
        if (data[1] == 109 && data[2] == 127 && USERMODE == 1) {
          if (USERMODE == 1) {
            LIVECONTROL = false;
            NOSEND = false;
            sleep(500);
            loadLayout(selectedPage);
          } else {
            clearDisplay();
            LIVECONTROL = true;
            NOSEND = true;
          }
        }
        
        if (data[1] == 110 && data[2] == 127 && USERMODE == 2) {
          if (USERMODE == 2) {
            LIVECONTROL = false;
            NOSEND = false;
            sleep(500);
            loadLayout(selectedPage);
          } else {
            clearDisplay();
            LIVECONTROL = true;
            NOSEND = true;
          }
        }
      }
    }
    
    //debug(context+" "+(data[0] & 0xFF)+" "+data[1]+" "+data[2]);
  }
}

int lpacount = 0;
int lpacountmax = 400;

void controlOut(int x, int y, int value) {
  if (x == 8) {
    software.sendCtl(65+y, value, outputChannel);
  } else {
    software.sendCtl(y*8 + x, value, outputChannel);
  }
  outputChannel = currentPage - 1;
}

void controlOut(int cc, int value) {
  software.sendCtl(cc, value, outputChannel);
  outputChannel = currentPage - 1;
}

void programOut(int program) {
  software.sendPgr(program, outputChannel);
  outputChannel = currentPage - 1;
}

void noteOut(int note, int vel) {
  software.sendOn(note, vel, outputChannel);
  outputChannel = currentPage - 1;
}

void launchpadAction(int segment, int value){
  if (LIVECONTROL == false) {
  if (license.isValid() || demoIsValid()) {
    debug("MIDI from X" + segment + " " + value);
    if (segment == 8 || segment == 24 || segment == 40 || segment == 56 || segment == 72 || segment == 88 || segment == 104 ) {
      if (segment == 8) segment = 65;
      if (segment == 24) segment = 66;
      if (segment == 40) segment = 67;
      if (segment == 56) segment = 68;
      if (segment == 72) segment = 69;
      if (segment == 88) segment = 70;
      if (segment == 104) segment = 71;
    } else {
      if (segment >= 112) { segment -= 8; }
      if (segment >= 96) { segment -= 8; }
      if (segment >= 80) { segment -= 8; }
      if (segment >= 64) { segment -= 8; }
      if (segment >= 48) { segment -= 8; }
      if (segment >= 32) { segment -= 8; }
      if (segment >= 16) { segment -= 8; }
    }
    
    debug("Translated segment: "+segment);
    
    if (segment >= 0 && segment <= 71 && segment != 64) {
      if (grid[segment] != null) {
        if (value == 127) { grid[segment].down(); }
        if (value == 0) { grid[segment].up(); }
      }
    } else {
      if (segment == PAGESELECTOR && value == 127 && !LIVECONTROL) {
        loadLayout(PAGESELECTOR);
      }
    }
    lpacount++;
  } else {
    clearDisplay();
    background(0);
    fill(#FFFFFF);
    textFont(f20, 20);
    textAlign(CENTER);
    smooth();
    text("Demo period expired\nRelaunch or get a license :)", WINDOWSIZE/2, WINDOWSIZE/2);
    mousestate = "quit";
  }
  }
}

void softwareNoteAction(int segment, int value, int channel) {
  debug("softwareAction(): " + channel + " " + segment + " " + value);
  if (channel+1 == currentPage) {
    if (grid[segment] != null) {
      grid[segment].nakedSetValue(value);
      grid[segment].update();
    }
  } else {
    if (grids[channel+1][segment] != null) grids[channel+1][segment].nakedSetValue(value);
  }
}

void softwareCtlAction(int segment, int value, int channel) {
  debug("softwareAction(): " + channel + " " + segment + " " + value);
    if (channel+1 == currentPage) {
      if (grid[segment] != null) {
        grid[segment].nakedSetValue(value);
        grid[segment].update();
      }
    } else {
      if (grids[channel+1][segment] != null) grids[channel+1][segment].nakedSetValue(value);
    }
}
