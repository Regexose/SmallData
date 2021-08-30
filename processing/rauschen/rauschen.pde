import java.util.Timer;  //<>//
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
ArrayList<DisplayTD> utts = new ArrayList<DisplayTD>(); // list with all the Text Objects
Surface rauschSurf, incSurf, matchSurf, titleSurf1, articleSurf, sculptureSurf, titleSurf2, infoSurf, counterSurf;
Surface[] surfs;
DisplayTD incomingUtt;
DisplayTD currentUtt;
Areas areas;
MessageHighlight mH; // Environment for growing Text display
String[] fontlist;
String[] cats = {"praise", "dissence", "insinuation", "concession", "lecture"};
StringList matchedUtts;
PFont messageFont, infoFont;
JSONObject TD; // TrainingData is stored here
JSONObject oscTextIn, category_counter, ip_config; 
String incomingText, incomingCat, moderation, currentPart; // a mock for incoming OSC text
color currentCol;
boolean messageLock = false; //turns true if incomingText matches an utt chosen in ScaledRotated.draw()
boolean messageIn = false; // background reset
boolean updateUtts = false;
boolean mFade, vector;
StringDict shapeMapping = new StringDict(); // mapping to attribute categories to SVG filenames
int maxUtts = 1;
int cat_limit, cat_counts, noiseStart, noiseLimit, noiseInc;
float prgIncrement;
int uttCount = 0; 
Table article;

void setup() {
  fullScreen();  // size(1000, 700);
  TD = loadJSONObject("TrainingDataPelle01.json");
  ip_config = loadJSONObject("../../config/ip_config.json");
  String ip = ip_config.getString("audience");
  article = loadTable("Moderation.tsv", "header");
  surfs = new Surface[9];
  fontlist = PFont.list();
  messageFont = createFont(fontlist[39], 30, true);
  infoFont = createFont(fontlist[25], 20, true);
  buildSurfaces();
  oscP5 = new OscP5(this, 5040); //Audience Port
  loc = new NetAddress(ip, 5040); // send to self
  RG.init(this);
  RG.ignoreStyles(true);
  RG.setPolygonizer(RG.ADAPTATIVE);
  vector = true;
  areas = new Areas(cats);
  buildUtts(480);
  mH = new MessageHighlight(20, messageFont); // adapted from https://processing.org/examples/forceswithvectors.html
  pickIncoming(); // pick first utt
  prgIncrement = 1.2;
  mFade = false;
  noiseInc = 5;
  noiseStart = 0;
  noiseLimit = noiseInc;
  moderation = "moderation";


  matchedUtts = new StringList();
  // frameRate(20);
}

void draw() {
  //if (frameCount%80 == 0) {
  //  pickIncoming(); //automatische messages werden ausgesucht
  //} 
  if (messageIn) {
    rauschSurf.clearBackground();
    messageIn = !messageIn;
    //sculptureSurf.visible = true;
  }

  for (int x=noiseStart; x<noiseLimit; x++) {
    DisplayTD utt = utts.get(x);
    utt.draw();
    utt.matchInput(incomingText);
  }

  if (messageLock && !mFade) {
    // einblenden der Surfaces
    for (int i=1; i<5; i++) {
      Surface s = surfs[i];
      //s.visible = true;
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

  for (int i=0; i<surfs.length; i++) {
    Surface surf = surfs[i];
    if (surf.visible) {
      surf.display(surf.name);
      image(surf.s, surf.pos.x, surf.pos.y);
    }
  }
  if (noiseLimit <= utts.size() - noiseInc) {
    noiseStart = noiseLimit;
    noiseLimit += noiseInc;
  } else if (noiseLimit > utts.size() - noiseInc ) {
    noiseStart = 0;
    noiseLimit = noiseInc;
  }

  for (Area a : areas.areas) {
    //a.draw(rauschSurf.s);
    //a.drawOutlines();
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
    // int index = int(random(TD.size()));
    JSONObject row = TD.getJSONObject(str(i));
    String utterance = row.getString("utterance");
    String category = row.getString("category").toLowerCase();
    String user = row.getString("user");
    PShape shape = loadShape(shapeMapping.get(category));
    shape.setFill(findColor(category));
    DisplayTD utt = new DisplayTD(i, utterance, category, user, shape, 5, false);
    utts.add(utt);
  }
}

void visibility(char k) {

  switch(k) {

  case '1':
    rauschSurf.visible = !rauschSurf.visible;
    break;
  case '2':
    incSurf.visible = !incSurf.visible;
    matchSurf.visible = !matchSurf.visible;
    titleSurf1.visible = !titleSurf1.visible;
    titleSurf2.visible = !titleSurf2.visible;
    break;
  case '3':
    infoSurf.visible = !infoSurf.visible;
    break;
  case '4':
    counterSurf.visible = !counterSurf.visible;
    break;
  case '5':
    articleSurf.visible = !articleSurf.visible;
    break;
  case '6':
    sculptureSurf.visible = !sculptureSurf.visible;
    break;
  case 'm':
    moderation = "moderation";
    break;
  case 'a':
    moderation = "article";
    break;

  case 'q':
    vector = !vector;
    rauschSurf.s.beginDraw();
    rauschSurf.s.background(222 );
    rauschSurf.s.endDraw();
    break;
    
  case 'r' :
    for (Surface s : surfs) {
      s.s.beginDraw();
      s.s.background(222);
      s.s.endDraw();
    }
  }
}

void keyReleased() {
  if (key == 'n') {
    articleSurf.lineIndex ++;
  }
  visibility(key);
}
