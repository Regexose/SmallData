class DisplayTD {
  PFont font;
  int x, y, angle, font_size;
  String utt, cat, fontName;
  PShape shape;
  color shapeColor; 
  boolean isShape;
  float shapeSize;
  
  DisplayTD(String utterance, String category, PShape shape, float sSize, boolean isShape) {
    this.utt = utterance;
    this.cat = category.toLowerCase();
    this.isShape = isShape;
    this.shape = shape;
    this.shapeSize = sSize;
    findColor(this.cat);
    this.x = int(random(width));
    this.y = int(random(height));
    this.font_size = 25;
    this.angle = int(random(TWO_PI));
    this.fontName = fontlist[int(random(fontlist.length))];
    this.font = createFont(this.fontName, font_size, true);
  }
  
  void draw() {
    textFont(this.font);
    fill(int(random(240)), int(random(0, 80)));
    pushMatrix();
    rotate(this.angle);
    if (this.isShape) {
      this.shape.disableStyle();
      fill(shapeColor);
      // float shapeSize = random(35);
      shape(this.shape, this.x, this.y, this.shapeSize, this.shapeSize);
    } else if (!this.isShape) {
     
      textAlign(CENTER, CENTER);
      textSize(random(40));
      text(this.utt, this.x, this.y);
    }
    moveText();
    popMatrix();
  }
  
  void moveText(){
    if (this.x < width && this.y < height) {
      this.x +=10;
      this.y +=10;
    } else {
      this.x = int(random(width));
      this.y = int(random(height));
    }
    this.angle+=1;
  }
  
  void matchInput(String incoming) {
    
      if(this.utt.equals(incoming) && !messageLock) {
        messageLock = true;
        mH.reset();
        mH.related = this.utt; 
        println("matched!  " + incoming + "    with   " + this.utt);
        // pMillis = millis();
      }
  }
  
  void findColor(String cat) {
    switch(cat) {
      case "praise" : shapeColor = color(171, 138, 132, 175);
      break;
      case "dissence" : shapeColor = color(181, 201, 187, 125);
      break;
      case "insinuation" : shapeColor = color(120, 145, 148, 125);
      break;
      case "lecture" : shapeColor = color(109, 133, 124, 125);
      break;
      case "concession" : shapeColor = color(198, 199, 177, 180);
    }
  }

}