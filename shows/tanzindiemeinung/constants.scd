~numSlots = 16;
~storyIndex = 0;
~currentUttPattern = \mono;
~factor = 1;
~totalUtts = 0;
~isPrelude = true;
///////
~fbVol = 0.2; //global Volume of feedback for incoming Utts
// values for addVolume
~volPlus = 0.06; // this much volume is added each time a category comes in
~addFac = 1.0; // factor of volPlus with vols below the threshold
~subFac = 0.5; // factor of volStep with vols below the threshold
~volMax = 0.25; // max Volume should be less than 1.0/5
~volMin = 0.0005; // the min Volume for a faded Pattern
~volThres = 0.15; // Threshold managed by ~addVolume and ~continuousFade
~volStep = 0.003; //vol reduction in continuous FadeOut
~fadeVols = 0; //the volumes of all fading Patterns
~thresCont = 0.1; // threshold from which to continuously fade Out
~maxCatCounter = 60;