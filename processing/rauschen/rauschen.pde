import java.util.Timer;   //<>//
import java.util.TimerTask;
import java.util.Map;
import java.util.List;
import java.util.Iterator; 
import geomerative.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress loc;

final Timer t = new Timer();
ArrayList<DisplayTD> utts = new ArrayList<DisplayTD>(); // list with all the TrainingData Objects
Surface mainSurf, incSurf, matchSurf, titleSurf1, dupSurf1, dupSurf2, titleSurf2, infoSurf, counterSurf;
Surface[] surfs;
DisplayTD incomingUtt;
DisplayTD currentUtt;
Areas areas;
RShape area, newarea;
MessageHighlight mH; // Environment for growing Text display
String[] fontlist;
String[] cats = {"praise", "dissence", "insinuation", "concession", "lecture"};
PFont messageFont, infoFont;
JSONObject TD; // TrainingData is stored here
JSONObject oscTextIn, counter; 
String incomingText, incomingCat; // a mock for incoming OSC text
color currentCol;
boolean messageLock = false; //turns true if incomingText matches an utt chosen in ScaledRotated.draw()
boolean messageIn = false; // background reset
boolean updateUtts = false;
boolean mFade;
StringDict shapeMapping = new StringDict(); // mapping to attribute categories to SVG filenames
int maxUtts = 1;
float prgIncrement;
int uttCount = 0; 
int startU, endU; // indices für das Hintergrundrauschen (utt.draw()
static int window;

void setup() {
  size(1800, 1300);
  //fullScreen();
  TD = loadJSONObject("TrainingDataPelle01.json");
  surfs = new Surface[9];
  fontlist = PFont.list();
  messageFont = createFont(fontlist[39], 30, true);
  infoFont = createFont(fontlist[25], 20, true);
  oscP5 = new OscP5(this, 5040); //Audience Port
  loc = new NetAddress("127.0.0.1", 5040); // send to self
  RG.init(this);
  RG.ignoreStyles(false);
  RG.setPolygonizer(RG.ADAPTATIVE);
  areas = new Areas(cats);
  buildUtts(900);
  mH = new MessageHighlight(20, messageFont); // adapted from https://processing.org/examples/forceswithvectors.html
  // margin1 = new Margin(incSurf.w, incSurf.h, 0.05);
  pickIncoming(); // pick first utt
  prgIncrement = 1.2;
  mFade = false;
  startU = 0;
  endU = 5;
  window = 5;
  frameRate(30);
}

void draw() {
  //if (frameCount%80 == 0) {
  //  pickIncoming(); //automatische messages werden ausgesucht
  //} 
  if (messageIn) {
    surfs[0].clearBackground();
    messageIn = !messageIn;
  }

  for (int x=startU; x<endU; x++) {
    println("utt(x)   " + x + " endU  " + endU);
    DisplayTD utt = utts.get(x);
    utt.draw();
    currentCol = utt.shapeColor;
    utt.matchInput(incomingText);
  }

  if (messageLock && !mFade) {
    // einblenden der Surfaces
    for (int i=1; i<5; i++) {
      Surface s = surfs[i];
      s.visible = true;
    }
    float gravity = 3 * mH.mass;
    mH.applyForce(gravity);
    mH.update();
    mH.checkEdge();
  }
  if (mFade) {
    // ausblenden der surfaces
    float gravity = - 2 * mH.mass;
    mH.applyForce(gravity);
    mH.updateFade();
  }

  for (Surface surf : surfs) {
    if (surf.visible) {
      surf.display(surf.name);
      image(surf.s, surf.pos.x, surf.pos.y);
    }
  }
  if (startU >= utts.size()- window || endU > utts.size()-1) {
    startU = 0;
    endU = 10;
  } else {
    startU += window;
    endU += window;
  }
}

void createScheduleTimer(final float ms) {
  messageLock = true;
  t.schedule(new TimerTask() {
    public void run() {
      mFade = true;
    }
  }
  , (long) (ms));
}

void buildUtts(int amount) {
  shapeMapping.set("praise", "knacks01.svg");
  shapeMapping.set("dissence", "knacks02.svg");
  shapeMapping.set("insinuation", "knacks03.svg");
  shapeMapping.set("concession", "knacks04.svg");
  shapeMapping.set("lecture", "knacks05.svg");
  for (int i=0; i<amount; i++) {
    int index = int(random(TD.size()));
    JSONObject row = TD.getJSONObject(str(index));
    String utterance = row.getString("utterance");
    String category = row.getString("category").toLowerCase();
    PShape shape = loadShape(shapeMapping.get(category));
    DisplayTD utt = new DisplayTD(i, utterance, category, shape, 5, false);
    utts.add(utt);
  }
}
