class DisplayTD {
  PFont font;
  int font_size, index;
  float x, y, sX, sY, angle;
  PVector pos;
  String utt, cat, fontName;
  PShape shape;
  RShape area;
  color shapeColor; 
  boolean isShape, matched;
  float shapeSize;

  DisplayTD(int index, String utterance, String category, PShape shape, float sSize, boolean isShape) {
    this.index = index;
    this.utt = utterance;
    this.cat = category.toLowerCase();
    this.isShape = isShape;
    this.matched = false; // should be checked only once between to incoming messages: line 70
    this.shape = shape;
    this.shapeSize = sSize;
    shapeColor = attributeUtt(this.cat);
    this.area = areas.findArea(this.cat);
    this.pos = new PVector(area.getCenter().x, area.getCenter().y);
    this.font_size = 25;
    this.angle = int(random(TWO_PI));
    this.fontName = fontlist[int(random(fontlist.length))];
    this.font = createFont(this.fontName, font_size, true);
  }

  void draw() {
    mainSurf.s.beginDraw();
    mainSurf.s.textFont(this.font);
    mainSurf.s.fill(this.shapeColor, 60);
    // mainSurf.s.fill(this.shapeColor);
    mainSurf.s.pushMatrix();
    mainSurf.s.translate(this.x, this.y);
    mainSurf.s.rotate(this.angle);
    this.shape.disableStyle();
    mainSurf.s.fill(shapeColor);
    mainSurf.s.shape(this.shape, 0, 0, this.shapeSize, this.shapeSize);
    moveText();
    mainSurf.s.popMatrix();
    mainSurf.s.endDraw();
  }

  void moveText() {
    RPoint center = area.getCenter();
    float aW = area.getWidth();
    float aH = area.getHeight();
    this.x = random(center.x - aW/3, center.x + aW/3);
    this.y = random(center.y - aH/3, center.y + aH/3);
    if (this.x < width && this.y < height) {
      this.x += random(-10, 10);
      ;
      this.y += random(-8, 8);
    } 
    this.angle += random(-0.05, 0.05);
  }

  void matchInput(String incoming) {
    if (this.utt.equals(incoming) && !messageLock && !this.matched && !mFade) {
      messageLock = true;
      mH.related = this.utt;
      this.matched = true;
      titleSurf1.col = shapeColor;
      titleSurf2.col = attributeUtt(cat);
      // println("matched!  " + incoming + "    with   " + this.utt);
    }
  }
}


color attributeUtt(String cat) {
  color col = color(0);
  switch(cat) {
  case "praise" : 
    // col =  color(171, 138, 132, 150);
    col =  color(196, 128, 79);
    break;
  case "dissence" : 
    col = color(150, 63, 146);
    break;
  case "insinuation" : 
    col =  color(21, 143, 84);
    break;
  case "lecture" : 
    col = color(23, 139, 189);
    break;
  case "concession" : 
    col = color(133, 138, 37);
  }
  return col;
}
