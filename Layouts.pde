static String layout[];
String pagenames[] = new String[16];
String pagename = "";
Control[] grid = new Control[72];
Control[] shortcuts = new Control[7];
Control[][] grids = new Control[64][72];
Control[] takeoverPool = new Control[512];
int selectedPage = 1;
int currentPage = selectedPage;
int numberOfPages = 0;
int[] pageNumbers = new int[16];
int customInit = 0;

void loadLayouts() {
  layout = loadStrings("layout.txt");
  for (int i = 0; i < layout.length; i++) {
    String[] entry = split(layout[i], " ");
    String type = entry[0];
    if (type.equals("page")) {
      //if (Integer.parseInt(entry[1]) > numberOfPages) {
        pageNumbers[numberOfPages] = Integer.parseInt(entry[1]);
        //println("number "+numberOfPages+" is "+pageNumbers[numberOfPages]);
        numberOfPages++;
      //}
    }
  }
}

void reloadLayouts() {
  for (int igrid = 0; igrid < 64; igrid++) {
    if (grid[igrid] != null) grid[igrid] = null;
    for (int icontrol = 0; icontrol < grid.length; icontrol++) {
      if (grids[igrid][icontrol] != null) grids[igrid][icontrol] = null;
    }
  }
  
  defaultColors();
      
  grid = new Control[72];
  grids = new Control[64][72];
  numberOfPages = 0;
  pageNumbers = new int[16];
  pagenames = new String[16];
  pagename = "";
  takeoverPool = new Control[512];
  
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
}

void loadLayout(int targetPage) {
  selectedPage = targetPage;
  //debug("Current page is " + currentPage);
  //debug("Selected page is " + selectedPage);
  if (targetPage == PAGESELECTOR) {
    // Push active grid to buffer
    //debug("Pushing to buffer ");
    for (int i = 0; i < grid.length; i++) {
      grids[currentPage][i] = grid[i];
    }
    
    // Destroy active grid
    //debug("Destroying active grid ");
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] != null) {
        grid[i] = null;
      }
    }
    clearDisplay();
    
    for (int i = 0; i < numberOfPages; i++) {
      new PageButton(pageNumbers[i]-1);
    }
  } else {
    // Destroy active grid
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] != null) {
        grid[i] = null;
      }
    }
    clearDisplay();
    
    if (grids[selectedPage][64] != null) {
      // If chosen grid is in buffer, restore it
      //debug("Restoring from buffer ");
      for (int i = 0; i < grid.length; i++) {
        grid[i] = grids[selectedPage][i];
      }
      for (int i = 0; i < grid.length; i++) {
        if (grid[i] != null) {
          grid[i].update();
        }
      }
      pagename = pagenames[selectedPage-1];
      pageName();
    } else {
      // If not, build it from layout data
      //debug("Building from data");
      int page;
      boolean loadPage = false;
      for (int i = 0; i < layout.length; i++) {
        try {
        String[] entry = split(layout[i], " ");
        String type = entry[0];
        
/*        if (type.equals("global")) {
          int global = Integer.parseInt(entry[1]);
          i++;
          entry = split(layout[i], " ");
          
        }*/
        
        if (type.equals("page")) { 
          page = Integer.parseInt(entry[1]);
          if (page == 1) customChannel = 0;
          if (page == 16) customChannel = 16;
          if (entry.length > 2 && page == targetPage) {
            String pname = "";
            for (int ii = 2; ii < entry.length; ii++) {
              pname += entry[ii] + " ";
            }
            pagenames[page-1] = pname;
            pagename = pname;
            //debug("Building page "+page+", named "+pagename);
            //debug("Entry was: "+layout[i]);
          }
          if (page == targetPage) { loadPage = true; } else { loadPage = false; }
        }
        
        if (loadPage == true) {
          Control lastControl = null;
          
          if (type.equals("oncolor")) {
            int scolor = parseColor(entry[1]);
            setOnColors(scolor);
          }
          if (type.equals("offcolor")) {
            int scolor = parseColor(entry[1]);
            setOffColors(scolor);
          }
          if (type.equals("defaultcolors")) {
            defaultColors();
          }
          if (type.equals("button")) {
            int btype = HOLD;
            if (entry[3].equals("hold")) { btype = HOLD; }
            if (entry[3].equals("toggle")) { btype = TOGGLE; }
            Button button = new Button(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), btype);
            if (entry.length >= 5) {
              if (entry[4].equals("persistent")) { button.persistence = true; }
              
              String[] velArg = split(entry[4], "=");
              debug("Entry: "+entry[4]);
              if (velArg[0].equals("velocity")) {
                debug("Setting velocity to "+Integer.parseInt(velArg[1])+" on "+button);
                button.setVelocity(Integer.parseInt(velArg[1]));
              }
            }
            if (entry.length >= 6) {
              String[] velArg = split(entry[5], "=");
              debug("Entry: "+entry[5]);
              if (velArg[0].equals("velocity")) {
                debug("Setting velocity to "+Integer.parseInt(velArg[1])+" on "+button);
                button.setVelocity(Integer.parseInt(velArg[1]));
              }
            }
            lastControl = button;
          }
          if (type.equals("note")) {
            Note note = new Note(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]), entry[4], Integer.parseInt(entry[5]));
            if (entry.length > 6) {
              if (entry[6].equals("toggle")) note.toggle = true;
            }
            //lastControl = note;
          }
          if (type.equals("rawnote")) {
            Note note = new Note(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]), Integer.parseInt(entry[4]));
            if (entry.length > 5) {
              if (entry[6].equals("toggle")) note.toggle = true;
            }
            //lastControl = note;
          }
          if (type.equals("cc")) {
            CC cc = new CC(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]), Integer.parseInt(entry[4]));
          }
          if (type.equals("pc")) {
            PC pc = new PC(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]));
          }
          if (type.equals("kbd")) {
            Kbd kbd = new Kbd(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), entry[3]);
          }
          if (type.equals("xfader")) {
            XFader xfader = new XFader(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]));
            //debug("L"+entry.length);
            for (int ii = 0; ii < entry.length-4; ii++) {
              //debug(entry[ii+4]);
              if (split(entry[ii+4], "=")[0].equals("takeover")) xfader.setTakeover(Integer.parseInt(split(entry[ii+4], "=")[1]));
            }
            lastControl = xfader;
          }
          if (type.equals("ixfader")) {
            IXFader ixfader = new IXFader(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]));
            //debug("L"+entry.length);
            for (int ii = 0; ii < entry.length-4; ii++) {
              //debug(entry[ii+4]);
              if (split(entry[ii+4], "=")[0].equals("takeover")) ixfader.setTakeover(Integer.parseInt(split(entry[ii+4], "=")[1]));
            }
            lastControl = ixfader;
          }
          if (type.equals("yfader")) {
            YFader yfader = new YFader(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]));
            for (int ii = 0; ii < entry.length-4; ii++) {
              //debug(entry[ii+4]);
              if (split(entry[ii+4], "=")[0].equals("takeover")) yfader.setTakeover(Integer.parseInt(split(entry[ii+4], "=")[1]));
            }
            lastControl = yfader;
          }
          if (type.equals("iyfader")) {
            IYFader iyfader = new IYFader(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]));
            for (int ii = 0; ii < entry.length-4; ii++) {
              //debug(entry[ii+4]);
              if (split(entry[ii+4], "=")[0].equals("takeover")) iyfader.setTakeover(Integer.parseInt(split(entry[ii+4], "=")[1]));
            }
            lastControl = iyfader;
          }
          if (type.equals("xslider")) {
            XSlider xslider = new XSlider(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]), Integer.parseInt(entry[4]));
            lastControl = xslider;
          }
          if (type.equals("yslider")) {
            YSlider yslider = new YSlider(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]), Integer.parseInt(entry[4]));
            lastControl = yslider;
          }
          if (type.equals("xmeter")) {
            XMeter xmeter = new XMeter(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]));
            lastControl = xmeter;
          }
          if (type.equals("ymeter")) {
            YMeter ymeter = new YMeter(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]));
            lastControl = ymeter;
          }
          if (type.equals("crsfader")) {
            CrsFader crsfader = new CrsFader(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]));
            lastControl = crsfader;
          }
          if (type.equals("xprogress")) {
            XProgress xprogress = new XProgress(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]));
            lastControl = xprogress;
          }
          if (type.equals("yprogress")) {
            YProgress yprogress = new YProgress(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]));
            lastControl = yprogress;
          }
          if (type.equals("chain")) {
            boolean send = false;
            if (entry.length >= 7 && entry[6].equals("send")) send = true;
            int mx = Integer.parseInt(entry[1]);
            int my = Integer.parseInt(entry[2]);
            int cx = Integer.parseInt(entry[4]);
            int cy = Integer.parseInt(entry[5]);
            grid[my*8+mx].chainTo(grid[cy*8+cx], send);
          }
          if (type.equals("channel")) {
            customChannel = Integer.parseInt(entry[1]);
          }
          if (type.equals("init")) {
            customInit = Integer.parseInt(entry[1]);
          }
          if (type.equals("defaultchannels")) {
            customChannel = 0;
          }
          if (type.equals("led")) {
            new LED(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]));
          }
          if (type.equals("drumrack")) {
            boolean invert = false;
            debug("LENGTH: "+entry.length);
            if (entry.length > 8) {
              if (entry[8].equals("invert")) invert = true;
            }
            new Drumrack(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]), Integer.parseInt(entry[4]), Integer.parseInt(entry[5]), entry[6], Integer.parseInt(entry[7]), invert);
          }
          if (type.equals("pad")) {
            Pad pad = new Pad(Integer.parseInt(entry[1]), Integer.parseInt(entry[2]), Integer.parseInt(entry[3]), Integer.parseInt(entry[4]));
            for (int ii = 0; ii < entry.length-4; ii++) {
              //debug(entry[ii+4]);
              if (split(entry[ii+4], "=")[0].equals("takeover")) pad.setTakeover(Integer.parseInt(split(entry[ii+4], "=")[1]));
              if (split(entry[ii+4], "=")[0].equals("invertx") && split(entry[ii+4], "=")[1].equals("yes") ) pad.invertx();
              if (split(entry[ii+4], "=")[0].equals("inverty") && split(entry[ii+4], "=")[1].equals("yes") ) pad.inverty();
            }
          }
          
          if (lastControl != null && customInit != 0) {
            lastControl.nakedSetValue(customInit);
          }
          /* // Universal arguments
          for (int ii = 0; ii < entry.length; ii++) {
            String arg = split(entry[ii], "=");
            if (arg.equals("channel"))
          }*/
          }
        } catch (Exception e) {
            println("Layout syntax error at: "+layout[i]+"\n"+e);
        }
      }
      
      new PageButton(64);
      
      for (int i = 0; i < 64; i++) {
        if (grid[i] != null) grid[i].page = selectedPage;
      }
    }
  currentPage = selectedPage;
  outputChannel = currentPage-1;
  }
}
