int yline = 1;
int ylinel = yline;
int xline = 1;
int xlinel = xline;
int linedelay = 10;
int tick = 0;
int demo = 0;
int sdemo = 0;
int dtick = 0;
int stick = 0;
int skip = 0;
int dtime = 450;
boolean shuffledemos = true;
boolean scrollerSetup = false;
String letters[] = new String[27];
static int totalrows;
String msg;
boolean msgoverride = false;
int ml = 9999;

int msgindexes[];
static boolean bitmap[][];

void setupDemos() {
  if (DEMOCHOICE != -1) { demo = DEMOCHOICE; shuffledemos = false; }
  msg = DEMOTEXT.toLowerCase();
  msgindexes = new int[msg.length()+1];
  scrollerSetup();
  sdemo = demo;
  demo = 0;
}

void demos() {
  dtick++;
  if (dtick == dtime && shuffledemos == true) {
    dtick = 0;
    demo = (int)random(0, 7);
    clearDisplay();
    //println(demo);
  }
  if (demo == 0) randomOnOff();
  if (demo == 1) ylines();
  if (demo == 2) xlines();
  if (demo == 3) xylines(); 
  if (demo == 4) xlinesn();
  if (demo == 5) ylinesn();
  if (demo == 6) scroller();
}

void overrideBitmap(int line, String data) {
  if (!scrollerSetup) msgindexes = new int[data.length()+1];
  msgoverride = true;
  ml = data.length()+6;
  msg = "";
  for (int i = 0; i < ml; i=i+6) {
    msg = msg+" ";
  }
  scrollerSetup();
  for (int i = 0; i < data.length(); i++) {
    if (i < ml) bitmap[i][line] = data.substring(i, 1+i).equals("#");
  }
  
  /*println("Bitmap:");
    for (int y = 0; y < 6; y++) {
      print("\n");
      for (int x = 0; x < totalrows; x++) {
        if (bitmap[x][y] == true) { print("#"); } else { print(" "); }
      }
    }
    println("");*/
}

void scrollerSetup() {
  if (!scrollerSetup) {
    if (!msgoverride) msg = DEMOTEXT.toLowerCase();
    if (!msgoverride) msg = " "+msg;
    letters[0] = "000000000000000000000000000000000000";
    letters[1] = "00#0000#0#00#000#0#####0#000#0#000#0";
    letters[2] = "####00#000#0####00#000#0#000#0#####0";
    letters[3] = "00##000#00#0#00000#000000#00#000##00";
    letters[4] = "###000#00#00#000#0#000#0#00#00###000";
    letters[5] = "#####0#00000####00#00000#00000#####0";
    letters[6] = "#####0#00000####00#00000#00000#00000";
    letters[7] = "00##000#00#0#00000#00##00#00#000##00";
    letters[8] = "#000#0#000#0#####0#000#0#000#0#000#0";
    letters[9] = "0###0000#00000#00000#00000#0000###00";
    letters[10] = "00###0000#00000#00000#00#00#000##000";
    letters[11] = "#00#00#0#000##0000#0#000#00#00#000#0";
    letters[12] = "#00000#00000#00000#00000#00000#####0";
    letters[13] = "0#0#00#0#0#0#0#0#0#000#0#000#0#000#0";
    letters[14] = "0#00#0#0#0#0#0#0#0#0#0#0#0#0#0#00#00";
    letters[15] = "0###00#000#0#000#0#000#0#000#00###00";
    letters[16] = "####00#000#0####00#00000#00000#00000";
    letters[17] = "0###00#000#0#000#0#0#0#0#00#000##0#0";
    letters[18] = "####00#000#0####00#0#000#00#00#000#0";
    letters[19] = "0####0#000000##000000##00000#0####00";
    letters[20] = "#####000#00000#00000#00000#00000#000";
    letters[21] = "#000#0#000#0#000#0#000#0#000#00###00";
    letters[22] = "#000#0#000#00#0#000#0#0000#00000#000";
    letters[23] = "#000#0#000#0#000#0#0#0#0#0#0#00#0#00";
    letters[24] = "#000#00#0#0000#0000#0#00#000#0#000#0";
    letters[25] = "#000#00#0#0000#00000#00000#00000#000";
    letters[26] = "#####00000#000##000#0000#00000#####0";
    
    totalrows = msg.length()*6;
    bitmap = new boolean[totalrows+8][7];
    for (int i = 0; i < msg.length(); i++) {
      if (msg.charAt(i) == ' ') msgindexes[i] = 0;
      if (msg.charAt(i) == 'a') msgindexes[i] = 1;
      if (msg.charAt(i) == 'b') msgindexes[i] = 2;
      if (msg.charAt(i) == 'c') msgindexes[i] = 3;
      if (msg.charAt(i) == 'd') msgindexes[i] = 4;
      if (msg.charAt(i) == 'e') msgindexes[i] = 5;
      if (msg.charAt(i) == 'f') msgindexes[i] = 6;
      if (msg.charAt(i) == 'g') msgindexes[i] = 7;
      if (msg.charAt(i) == 'h') msgindexes[i] = 8;
      if (msg.charAt(i) == 'i') msgindexes[i] = 9;
      if (msg.charAt(i) == 'j') msgindexes[i] = 10;
      if (msg.charAt(i) == 'k') msgindexes[i] = 11;
      if (msg.charAt(i) == 'l') msgindexes[i] = 12;
      if (msg.charAt(i) == 'm') msgindexes[i] = 13;
      if (msg.charAt(i) == 'n') msgindexes[i] = 14;
      if (msg.charAt(i) == 'o') msgindexes[i] = 15;
      if (msg.charAt(i) == 'p') msgindexes[i] = 16;
      if (msg.charAt(i) == 'q') msgindexes[i] = 17;
      if (msg.charAt(i) == 'r') msgindexes[i] = 18;
      if (msg.charAt(i) == 's') msgindexes[i] = 19;
      if (msg.charAt(i) == 't') msgindexes[i] = 20;
      if (msg.charAt(i) == 'u') msgindexes[i] = 21;
      if (msg.charAt(i) == 'v') msgindexes[i] = 22;
      if (msg.charAt(i) == 'w') msgindexes[i] = 23;
      if (msg.charAt(i) == 'x') msgindexes[i] = 24;
      if (msg.charAt(i) == 'y') msgindexes[i] = 25;
      if (msg.charAt(i) == 'z') msgindexes[i] = 26;
    }
    // Construct the bitmap
    for (int i = 0; i < msg.length(); i++) {
      for (int x = 0; x < 6; x++) {
        for (int y = 0; y < 6; y++) {
          bitmap[x+i*6][y] = letters[msgindexes[i]].substring(x+y*6, 1+x+y*6).equals("#");
        }
      }
    }
    /*println("Bitmap:");
    for (int y = 0; y < 6; y++) {
      print("\n");
      for (int x = 0; x < totalrows; x++) {
        if (bitmap[x][y] == true) { print("#"); } else { print(" "); }
      }
    }*/
    scrollerSetup = true;
    println("");
  }
}

void scroller() {
  // Run the scroller
  if (skip == 8) {
    clearDisplay();
    for (int x = 0; x < 8; x++) {
      for (int y = 0; y < 7; y++) {
        if (bitmap[x+(stick%totalrows)][y] == true) ledOn(x, y+1, SCROLLERCOLOR);
      }
    }
    stick++;
    skip = 0;
  }
  skip++;
}

void randomOnOff() {
  ledOn((int)random(8), (int)random(8), randomColor());
  //ledOff((int)random(8), (int)random(8));
}

void ylines() {
  tick++;
  if (tick == linedelay) {
    tick = 0;
    int colorl = BLACK;
    while (colorl == BLACK) colorl = randomColor();
    for (int y = 0; y < 8; y++) {
      ledOff(ylinel, y);
    }
    for (int y = 0; y < 8; y++) {
      ledOn(yline, y, colorl);
    }
    ylinel = yline;
    yline++;
    if (yline == 8) yline = 0;
  }
}

void ylinesn() {
  tick++;
  if (tick == linedelay) {
    tick = 0;
    int colorl = BLACK;
    while (colorl == BLACK) colorl = randomColor();
    /*for (int y = 0; y < 8; y++) {
      ledOff(ylinel, y);
    }*/
    for (int y = 0; y < 8; y++) {
      ledOn(yline, y, colorl);
    }
    ylinel = yline;
    yline++;
    if (yline == 8) yline = 0;
  }
}

void xlines() {
  tick++;
  if (tick == linedelay) {
    tick = 0;
    int colorl = BLACK;
    while (colorl == BLACK) colorl = randomColor();
    for (int x = 0; x < 8; x++) {
      ledOff(x, xlinel);
    }
    for (int x = 0; x < 8; x++) {
      ledOn(x, xline, colorl);
    }
    xlinel = xline;
    xline++;
    if (xline == 8) xline = 0;
  }
}

void xlinesn() {
  tick++;
  if (tick == linedelay) {
    tick = 0;
    int colorl = BLACK;
    while (colorl == BLACK) colorl = randomColor();
    /*for (int x = 0; x < 8; x++) {
      ledOff(x, xlinel);
    }*/
    for (int x = 0; x < 8; x++) {
      ledOn(x, xline, colorl);
    }
    xlinel = xline;
    xline++;
    if (xline == 8) xline = 0;
  }
}

void xylines() {
  tick++;
  if (tick == linedelay) {
    tick = 0;
    int colorl = BLACK;
    while (colorl == BLACK) colorl = randomColor();
    for (int x = 0; x < 8; x++) {
      ledOff(x, xlinel);
      ledOff(xlinel, x);
    }
    for (int x = 0; x < 8; x++) {
      ledOn(x, xline, colorl);
      ledOn(xline, x, colorl);
    }
    xlinel = xline;
    xline++;
    if (xline == 8) xline = 0;
  }
}
