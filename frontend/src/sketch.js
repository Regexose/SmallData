export default function sketch(p){
  let canvas;
  let socket;
  var font;
  let fr = 10;  // Frames per second,
  let currentPart, nextPart;
  let barWidth, barHeight, yPos, tSize;
  var counterData = {};
  var counter;
  var parts = {};
  let categories = ["praise", "dissence", "insinuation", "concession", "lecture"];
  let locked = counterData['is_locked'];
  let yOff, xOff, barOff;

  p.preload = () => {
    font = p.loadFont('../../assets/BebasNeue.otf');
    p.loadJSON('../../assets/parts.json', gotParts);
    fetchData();
  }

  function fetchData() {  //TODO: use websockets for data transfer
    let url = "http://127.0.0.1:8000";
    p.httpGet(url + "/api/category_counter", "json", false,
      function (response) {
        counterData = response;
        counter = counterData['category_counter'];
      },
      function (response) { // Handle unsuccessful loading of data.json
        console.log('Fetching data.json unsuccessfull!')
      });
  }

  function gotParts(data) {
    parts = data;
  }

 function findColor(cat) {
    let col = p.color(0);
    if (cat == "praise") {
      col = p.color(196, 128, 79);
    } else if (cat == "dissence") {
      col = p.color(150, 63, 146);
    } else if (cat == "insinuation") {
      col = p.color(21, 143, 84);
    } else if (cat == "lecture") {
      col = p.color(23, 139, 189);
    } else if (cat == "concession") {
      col = p.color(133, 138, 37);
    }
    return col;
 }

  p.setup = () => {
    p.frameRate(fr);
    canvas = p.createCanvas(500, 600);
    tSize= 25;
    yOff = p.height/2;
    xOff = 50;
    barOff = 120;
    barWidth = 60;
    barHeight = 30;
    yPos = 40;
    p.textFont(font, tSize);
    p.textAlign(p.LEFT, p.TOP);
    p.rectMode(p.CENTER);
    p.noStroke();

     var socketPath = 'ws://'
            + window.location.host
            + '/ws/utterance';

    socket = new WebSocket(socketPath);
    console.log("building websocket")

    socket.onmessage = function(e) {
      console.log(e);
      fetchData();
    };
  }

  p.draw = () => {
    // fetchData()
    if (!counter) {
      // Wait until the counter-data has loaded before drawing.
      return;
    }
    p.background(222);
    displayCounter();
  }

  function displayCounter() {
    for (let i = 0; i < categories.length; i++) {
        let cat = categories[i];
        var limit = p.int(counter[cat].limit);
        var barCount = p.int(counter[cat].count);
        // console.log("cat " + cat + " barcount " + barCount);
        let col = findColor(cat);
        p.fill(col);
        p.textSize(tSize);
        p.noStroke();
      if (limit < 0) {
          barWidth = 0;
          p.text("läuft gerade " + cat + " hat keinen effekt", barOff, yOff + (yPos) * i);
      } else if (limit < 0 && locked) {
          barWidth = 0;
          p.textSize(15);
          p.text('neuer Songpart wird geladen. Eingabe hat gerade keinen Effekt', 200, yOff + (yPos * i), p.width / 3, 200);
      } else {
        barWidth = 60
   }
      p.text(cat, xOff, yOff + (yPos * i));
      p.rectMode(p.CORNER);
      p.rect(xOff + barOff, yOff + (yPos * i), barCount * barWidth, barHeight);
      // p.rect(xOff + barOff, yOff + (yPos * i), 200, barHeight);
      p.noFill();
      p.rect(xOff + barOff, yOff + (yPos * i), limit * barWidth, barHeight + 5);
      p.fill(2);
      if (barCount >= limit - 2 && limit > 0) {
        p.textSize(18);
        p.text("noch " + (limit + 1 - barCount) + " x " + cat + " bis zum " + cat + "-part", 200 , yOff + (yPos * i));
      }
    }
  }

  p.myCustomRedrawAccordingToNewPropsHandler = (newProps) => {
      if(canvas) { //Make sure the canvas has been created
    }
  }
}