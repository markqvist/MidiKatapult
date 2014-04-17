// LED color definitions
static final int BLACK = 12;
static final int REDL = 13;
static final int RED = 15;
static final int AMBERL = 29;
static final int AMBER = 63;
static final int YELLOW = 62;
static final int GREEN = 60;
static final int GREENL = 28;
static final int REDF = 11;
static final int AMBERF = 59;
static final int YELLOWF = 58;
static final int GREENF = 56;

static final int BLUE = 90;
static final int BLUEL = 91;
static final int CYAN = 92;
static final int CYANL = 93;
static final int MAGENTA = 94;
static final int MAGENTAL = 95;
static final int WHITE = 96;
static final int WHITEL = 97;

int colors[] = new int[12];

static int SCROLLERCOLOR = RED;

// Button color definitions
static int BUTTONIDLECOLOR = AMBER;
static int HOLDONCOLOR = GREEN;
static int TOGGLEONCOLOR = GREEN;
static int TOGGLEOFFCOLOR = AMBER;
static int FADERIDLECOLOR = RED;
static int FADERACTIVECOLOR = GREEN;
static int SLIDERIDLECOLOR = GREENL;
static int SLIDERACTIVECOLOR = GREEN;
static int PAGEBUTTONIDLECOLOR = AMBER;
static int PAGEBUTTONACTIVECOLOR = GREEN;
static int INDICATOROFFCOLOR = RED;
static int INDICATORONCOLOR = GREEN;
static int PADOFFCOLOR = AMBER;
static int PADONCOLOR = YELLOW;
static int METERIDLECOLOR = AMBER;
static int METERACTIVECOLOR = GREEN;
static int PROGRESSIDLECOLOR = RED;
static int PROGRESSACTIVECOLOR = GREEN;
static int NOTEIDLECOLOR = YELLOW;
static int NOTEACTIVECOLOR = GREEN;
static int CCIDLECOLOR = YELLOW;
static int CCACTIVECOLOR = GREEN;
static int KBDIDLECOLOR = GREENL;
static int KBDACTIVECOLOR = GREEN;
static int PCIDLECOLOR = YELLOW;
static int PCACTIVECOLOR = GREEN;
int[] cdef = new int[26];

void storeDefaultColors() {
  cdef[0] = BUTTONIDLECOLOR;
  cdef[1] = HOLDONCOLOR;
  cdef[2] = TOGGLEONCOLOR;
  cdef[3] = TOGGLEOFFCOLOR;
  cdef[4] = FADERIDLECOLOR;
  cdef[5] = FADERACTIVECOLOR;
  cdef[6] = SLIDERIDLECOLOR;
  cdef[7] = SLIDERACTIVECOLOR;
  cdef[8] = PAGEBUTTONIDLECOLOR;
  cdef[9] = PAGEBUTTONACTIVECOLOR;
  cdef[10] = INDICATOROFFCOLOR;
  cdef[11] = INDICATORONCOLOR;
  cdef[12] = PADOFFCOLOR;
  cdef[13] = PADONCOLOR;
  cdef[14] = METERIDLECOLOR;
  cdef[15] = METERACTIVECOLOR;
  cdef[16] = PROGRESSIDLECOLOR;
  cdef[17] = PROGRESSACTIVECOLOR;
  cdef[18] = NOTEIDLECOLOR;
  cdef[19] = NOTEACTIVECOLOR;
  cdef[20] = CCIDLECOLOR;
  cdef[21] = CCACTIVECOLOR;
  cdef[22] = KBDIDLECOLOR;
  cdef[23] = KBDACTIVECOLOR;
  cdef[24] = PCIDLECOLOR;
  cdef[25] = PCACTIVECOLOR;
}

void defaultColors() {
  BUTTONIDLECOLOR = cdef[0];
  HOLDONCOLOR = cdef[1];
  TOGGLEONCOLOR = cdef[2];
  TOGGLEOFFCOLOR = cdef[3];
  FADERIDLECOLOR = cdef[4];
  FADERACTIVECOLOR = cdef[5];
  SLIDERIDLECOLOR = cdef[6];
  SLIDERACTIVECOLOR = cdef[7];
  PAGEBUTTONIDLECOLOR = cdef[8];
  PAGEBUTTONACTIVECOLOR = cdef[9];
  INDICATOROFFCOLOR = cdef[10];
  INDICATORONCOLOR = cdef[11];
  PADOFFCOLOR = cdef[12];
  PADONCOLOR = cdef[13];
  METERIDLECOLOR = cdef[14];
  METERACTIVECOLOR = cdef[15];
  PROGRESSIDLECOLOR = cdef[16];
  PROGRESSACTIVECOLOR = cdef[17];
  NOTEIDLECOLOR = cdef[18];
  NOTEACTIVECOLOR = cdef[19];
  CCIDLECOLOR = cdef[20];
  CCACTIVECOLOR = cdef[21];
  KBDIDLECOLOR = cdef[22];
  KBDACTIVECOLOR = cdef[23];
  PCIDLECOLOR = cdef[24];
  PCACTIVECOLOR = cdef[25];
}

int parseColor(String input) {
  int scolor = BLACK;
  if (input.equals("black")) { scolor = BLACK; }
  if (input.equals("redlow")) { scolor = REDL; }
  if (input.equals("red")) { scolor = RED; }
  if (input.equals("amberlow")) { scolor = AMBERL; }
  if (input.equals("amber")) { scolor = AMBER; }
  if (input.equals("yellow")) { scolor = YELLOW; }
  if (input.equals("greenlow")) { scolor = GREENL; }
  if (input.equals("green")) { scolor = GREEN; }
  
  if (input.equals("blue")) { scolor = BLUE; }
  if (input.equals("bluelow")) { scolor = BLUEL ; }
  if (input.equals("cyan")) { scolor = CYAN; }
  if (input.equals("cyanlow")) { scolor = CYANL; }
  if (input.equals("magenta")) { scolor = MAGENTA; }
  if (input.equals("magentalow")) { scolor = MAGENTAL; }
  if (input.equals("white")) { scolor = WHITE; }
  if (input.equals("whitelow")) { scolor = WHITEL ; }
  
  if (input.equals("redflash")) { scolor = REDF; }
  if (input.equals("amberflash")) { scolor = AMBERF; }
  if (input.equals("yellowflash")) { scolor = YELLOWF; }
  if (input.equals("greenflash")) { scolor = GREENF; }
  return scolor;
}

void setOffColors(int scolor) {
  BUTTONIDLECOLOR = scolor;
  TOGGLEOFFCOLOR = scolor;
  FADERIDLECOLOR = scolor;
  SLIDERIDLECOLOR = scolor;
  INDICATOROFFCOLOR = scolor;
  PADOFFCOLOR = scolor;
  METERIDLECOLOR = scolor;
  PROGRESSIDLECOLOR = scolor;
  NOTEIDLECOLOR = scolor;
  CCIDLECOLOR = scolor;
  KBDIDLECOLOR = scolor;
  PCIDLECOLOR = scolor;
}

void setOnColors(int scolor) {
  HOLDONCOLOR = scolor;
  TOGGLEONCOLOR = scolor;
  FADERACTIVECOLOR = scolor;
  SLIDERACTIVECOLOR = scolor;
  INDICATORONCOLOR = scolor;
  PADONCOLOR = scolor;
  METERACTIVECOLOR = scolor;
  PROGRESSACTIVECOLOR = scolor;
  NOTEACTIVECOLOR = scolor;
  CCACTIVECOLOR = scolor;
  KBDACTIVECOLOR = scolor;
  PCACTIVECOLOR = scolor;
}
