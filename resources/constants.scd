~fx1Bus = Bus.audio(s,2);
~fx2Bus = Bus.audio(s,2);
~fx3Bus = Bus.audio(s,2);
~numSlots = 16;
~cat = "lecture";
~storyIndex = 0;
~currentUttPattern = \mono;
~factor = 1;
~totalUtts = 0;
~upm = 0; // utts per Minute
~hitIsPlaying = false;
~uttTimeWindow = 30.0;
///////
~fbVol = 0.4; //global Volume of feedback for incoming Utts
// values for addVolume
~volPlus = 0.06; // this much volume is added each time a category comes in
~addFac = 1.0; // factor of volPlus with vols below the threshold
~subFac = 1.8; // factor of volStep with vols above the threshold
//~volMin = 0.0002; // the min Volume for a faded Pattern
~volMin = 0.002; // the min Volume for a faded Pattern
~volThres = 0.15; // Threshold managed by ~addVolume and ~continuousFade
~volStep = 0.004; //vol reduction in continuous FadeOut
~volMax = 0.25; // max Volume should be less than 1.0/5
~fadeVols = 0; //the volumes of all fading Patterns
~thresCont = 0.15; // threshold from which to continuously fade Out
~maxCatCounter = 15; // max value of categoryCounter (counter is reset if this value is reached
~upmMax = 25;
~td = NetAddr("192.168.1.175", 7000);
//~td = NetAddr("127.0.0.1", 7000);
 