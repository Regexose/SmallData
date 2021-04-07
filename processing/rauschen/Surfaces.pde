class Surface { //<>//
  /*
  Surfaces haben verschiedene Funktionen
   permanent = main und infosurf, sind immer visible
   matched: 4 Surfs visible. Utt surfs sind animiert (displayUTT), 
   titlesurfs sind statisch und werden ein und ausgeblendet (displayTitle, fadeTitle)
   es gilt, eine display Funktion zu schreiben, die je nach status verschiedene Surfaces erzeugt und malt.
   */
  PVector pos;
  PGraphics s;
  PFont font;
  String name, message;
  ArrayList<SingleLine> uttLines;
  int w, h;
  float  tSize;
  boolean visible, fade;
  color col;

  Surface(String name, int _x, int _y, int _w, int _h, PFont _font, boolean _visible, String _message) {
    this.name = name;
    this.w = _w;
    this.h = _h;
    this.pos = new PVector(_x, _y);
    this.s = createGraphics(_w, _h);
    this.s.smooth();
    this.uttLines = new ArrayList<SingleLine>();
    this.font = _font;
    this.visible = _visible;
    this.fade = false;
    this.message= _message;
    this.tSize = 1;
    initSurf();
  }

  void initSurf() {
    if (this.name.startsWith("title")) {
      makeTitle();
    }
  }

  void clearBackground() {
    this.s.beginDraw();
    this.s.background(222); 
    this.s.endDraw();
  }


  void display(String name) {
    if (name.startsWith("match")) {
      displayUtt();
    }
    if (name.startsWith("title")) {
      makeTitle();
    }
    if (name.startsWith("info")) {
      displayInfo();
    }
    if (name.startsWith("counter")) {
      displayCounter();
    }

    if (mFade) {
      fadeGraphics(this.s, this.name, 2);
    }
  }

  void fadeGraphics(PGraphics c, String name, int fadeAmount) {
    // println("fading   " + name);
    c.beginDraw();
    c.loadPixels();
    // iterate over pixels
    for (int i =0; i<c.pixels.length; i++) {
      // get alpha value
      int alpha = (c.pixels[i] >> 24) & 0xFF ;
      // reduce alpha value
      alpha = max(0, alpha-fadeAmount);
      // assign color with new alpha-value
      c.pixels[i] = alpha<<24 | (c.pixels[i]) & 0xFFFFFF ;
    }
    c.updatePixels();
    c.endDraw();
  }

  void displayUtt() {
    this.s.beginDraw();
    this.s.clear();
    for (SingleLine sl : uttLines) {
      this.s.textFont(this.font, this.tSize);
      this.s.fill(sl.col);
      this.s.text(sl.line, 10, sl.yPos);
    }
    this.s.endDraw();
  }

  void displayInfo() {
    this.s.beginDraw();
    this.s.background(222);
    this.s.textFont(this.font, 15);
    this.s.fill(20, 200);
    this.s.rectMode(CORNER);
    // progress bar for remaining Timer
    this.s.text(incomingText + "\t     " + incomingCat, 0, this.s.height/4, this.s.width, this.s.height);
    this.s.fill(189, 10, 10, 150);
    this.s.rect(0, 0, uttCount * prgIncrement, this.s.height/4);
    this.s.endDraw();
  }

  void displayCounter() {
    this.s.beginDraw();  
    this.s.background(222);
    this.s.textFont(this.font, 10);
    int yPos = 20;
    for (int i=1; i<counter.size()+1; i++) {
      String cat = cats[i-1];
      float rectWidth = float(counter.getInt(cat));
      this.s.rectMode(CENTER);
      this.s.textAlign(LEFT, CENTER);
      color fillcol = attributeUtt(cat);
      int alpha = (fillcol >> 24) & 0xFF;
      alpha = 255;
      fillcol = alpha<<24 | fillcol & 0xFFFFFF ;
      this.s.fill(fillcol);
      this.s.text(cat, 0, yPos*i);
      this.s.noStroke();
      this.s.rect(80, yPos * i, rectWidth, this.h/8);
    }
    this.s.endDraw();
  }

  void makeTitle() {
    this.s.beginDraw();
    // remove alpha color
    int alpha = (this.col >> 24) & 0xFF;
    alpha = 255;
    this.col = alpha<<24 | this.col & 0xFFFFFF ;
    this.s.background(this.col);
    this.s.textFont(this.font);
    this.s.textAlign(CENTER, CENTER);
    this.s.fill(20);
    this.s.text(this.message, this.w/2, this.h/2);
    this.s.endDraw();
  }
}

void buildSurfaces() {
  // println("x " + width/30 + " y " + height/2 + " w " +  width *3/7 + " h " + height/5);
  mainSurf = new Surface("main", 0, 0, width, height, messageFont, true, "");
  incSurf = new Surface("matchSurf1", width/30, height/2, width *3/7, height/5, messageFont, false, incomingText);
  matchSurf = new Surface("matchSurf2", width *5/9, height/2, width *3/7, height/5, messageFont, false, "");
  titleSurf1 = new Surface("titleIncoming", int(incSurf.pos.x), int(incSurf.pos.y-80), int(incSurf.w), 50, infoFont, false, "Dein Kommentar ähnelt...");
  titleSurf2 =  new Surface("titleMatch", int(matchSurf.pos.x), int(matchSurf.pos.y-80), int(matchSurf.w), 50, infoFont, false, "...diesem hier");
  dupSurf1 = new Surface("dup1", int(titleSurf1.pos.x), int(titleSurf1.pos.y), int(incSurf.w), int(incSurf.h + titleSurf1.h), messageFont, false, "");
  dupSurf2 = new Surface("dup2", int(titleSurf2.pos.x), int(titleSurf2.pos.y), matchSurf.w, matchSurf.h + titleSurf2.h, messageFont, false, "");
  infoSurf = new Surface("infoSurf", 0, height-height/12, width, height/12, infoFont, true, incomingText);
  counterSurf = new Surface("counter", 0, height *3/4, width/8, height/6, infoFont, false, "categories");
  surfs[0] = mainSurf;
  surfs[1] = incSurf;
  surfs[2] = matchSurf;
  surfs[3] = titleSurf1;
  surfs[4] = titleSurf2;
  surfs[5] = infoSurf;
  surfs[6] = counterSurf;
  surfs[7] = dupSurf1;
  surfs[8] = dupSurf2;
}
