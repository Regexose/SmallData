class DisplayTD {
  PFont font;
  int font_size, index;
  float x, y, sX, sY, angle;
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
    findArea();
    this.font_size = 25;
    this.angle = int(random(TWO_PI));
    this.fontName = fontlist[int(random(fontlist.length))];
    this.font = createFont(this.fontName, font_size, true);
  }

  void draw() {

    mainSurf.s.beginDraw();
    mainSurf.s.textFont(this.font);
    mainSurf.s.fill(this.shapeColor, int(random(0, 80)));
    mainSurf.s.translate(this.x, this.y);
    mainSurf.s.rotate(this.angle);
    if (this.isShape) {
      float noiseX = noise(sX);
      float noiseY = noise(sY);
      mainSurf.s.pushMatrix();
      mainSurf.s.translate(noiseX, noiseY);
      this.shape.disableStyle();
      mainSurf.s.fill(shapeColor);
      mainSurf.s.shape(this.shape, 0, 0, this.shapeSize, this.shapeSize);
      mainSurf.s.popMatrix();
      sX += 0.01;
      sY += 0.01;
    } else if (!this.isShape) {
      mainSurf.s.textAlign(CENTER, CENTER);
      mainSurf.s.textSize(random(40));
      mainSurf.s.text(this.utt, 0, 0);
    }
    moveText();
    mainSurf.s.endDraw();
  }

  void findArea() {
    for (Area a : areas.areas) {
      if (a.name.equals(this.cat)) {
        this.area = a.rS;
        RPoint center = area.getCenter();
        float aW = area.getWidth();
        float aH = area.getHeight();
        this.x = random(center.x - aW/3, center.x + aW/3);
        this.y = random(center.y - aH/3, center.y + aH/3);
        sX = this.x;
        sY = this.y;
        // println("   cat   " + this.cat + " x  " + this.x + "   y  " + this.y);
      }
    }
  }

  void moveText() {
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
    col =  color(171, 138, 132, 175);
    break;
  case "dissence" : 
    col = color(181, 201, 187, 125);
    break;
  case "insinuation" : 
    col =  color(120, 145, 148, 125);
    break;
  case "lecture" : 
    col = color(109, 133, 124, 125);
    break;
  case "concession" : 
    col = color(198, 199, 177, 180);
  }
  return col;
}
