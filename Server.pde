import processing.net.*;
Server slaveServer;
boolean online;
boolean slaveConnected;
boolean wasConnected;
long lastping;
int serverPort = 6969;

void initServer() {
  locatePort();
  debug("Starting server on port " + serverPort);
  slaveServer = new Server(this, serverPort);
  //Server tsrv = new Server(this, serverPort);
  
  if (slaveServer != null) {
    online = true;
    debug("Server started");
  } else {
    debug("Could not initialize server");
  }
}

void locatePort() {
  debug("Locating available port...");
  boolean foundPort = false;
  while (!foundPort) {
    Client probe = new Client(this, "127.0.0.1", serverPort);
    try {
      String s = probe.ip();
      serverPort++;
    } catch (Exception e) {
      foundPort = true;
      
    }
  }
}

void sendToSlave(String message) {
  if (online) {
    slaveServer.write(message);
  }
}

void readServer() {
  Client slave;
  boolean run = true;
  while (run) {
    slave = getSlave();
    if (slave != null) {
      String message = slave.readString();

      if (message != null && message.equals("CONNECT")) {
        if (slaveConnected) {
          debug("Other client tried connection, redirecting");
          slave.write("meta+trynextTT");
          message = null;
        }
      } 
      
      if (message != null) interpretMessage(message);
    } else {
      long now = (new Date()).getTime();
      if (now - lastping >= 2500) {
        //debug("Last ping: "+(now - lastping));
        slaveConnected = false;
      }
      run = false;
    }
  }
}

void interpretMessage(String message) {
  debug("---"+message+"---");
  if (message.equals("CONNECT") && !slaveConnected) {
      slaveConnected = true;
      wasConnected = true;
      lastping = (new Date()).getTime();
      if (displaystate) loadLayout(selectedPage);
  }
  //if (message.equals("DISCONNECT")) slaveConnected = false;
  String[] messages = split(message, "+T");

  for (int i = 0; i < messages.length-1; i++) {
    //debug("MSG:"+messages[i]);
    String[] components = split(messages[i], "+");
    if (components.length == 2) {
      if (!components[0].equals("") && !components[1].equals("")) {
        if (components[0].equals("meta")) {
          if (allgood) {
          if (components[1].equals("prev") && currentPage > 1) {
            selectedPage = pageNumbers[indexForKey(pageNumbers, selectedPage)-1]; loadLayout(selectedPage);
          }
          if (components[1].equals("next") && currentPage < pageNumbers[numberOfPages-1]) {
            selectedPage = pageNumbers[indexForKey(pageNumbers, selectedPage)+1]; loadLayout(selectedPage);
          }
          }
          if (components[1].equals("ping")) {
            lastping = (new Date()).getTime();
            if (wasConnected) slaveConnected = true;
          }
        }
      }
    }
    
    if (components.length == 3) {
      if (!components[0].equals("") && !components[1].equals("") && !components[2].equals("")) {
        int x = Integer.parseInt(components[0]);
        int y = Integer.parseInt(components[1]);
        int v = Integer.parseInt(components[2]);
        launchpadAction(16*y+x,v);
      }
    }
  }
}

Client getSlave() {
  Client slave = slaveServer.available();
  if (slave == null) {
    return null;
  } else {
    return slave;
  }
}

void slaveOn(int x, int y, int lcolor) {
  String message = ""+x+"+"+y+"+"+lcolor+"TT";
  //debug(message);
  slaveServer.write(message);
}

void slaveClear() {
  slaveServer.write("meta+wipeTT");
}
