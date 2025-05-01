var mcWindow, mcTop, mcToplevel, mcCatwidth, mcCatheight, densityKnobs, buttons;
var buttonsize=40, columns=16, rows=5, offset=10, labelwidth=100, headerheight=100, sliderwidth=300, selectorWidth=200, rotarywidth=200, rotarysize=55;

mcCatwidth = 100;
mcCatheight = 120;
mcWindow = ~buildWindow.("MC", 10, 10, mcCatwidth*14, mcCatheight + 380);
mcTop = ~buildTopLevel.(mcWindow, 10, 10, mcCatwidth*14, mcCatheight*5+360);

// frame for MC Track
~mcTrack = ~buildMcTrack.(mcTop, 10, 0,  mcCatwidth*5+20, mcCatheight *3, 5, mcCatwidth);
~mcLabels = ~buildMcLabels.(mcTop, 10, mcCatheight *3 + 30, mcCatwidth*6 , 60, mcCatwidth, ~uttDict);
~status = ~buildStatus.(mcWindow, mcCatwidth*6 +50, 20, mcCatwidth * 3, mcCatheight * 3.5, ~lastUtterances);
densityKnobs = ~buildRotaryFader.(mcWindow, mcCatwidth*10 , 20,  offset, rotarysize, [\volThres, \addFac, \subFac, \factor, \uttTimeWindow, \bpm], [0.005, 0.5, 0.1, 0.1, 10, 30], [0.4, 1.7, 2.0, 2, 75, 120], [0.1, 1.0, 0.9, 1, 30, 80]);
buttons = ~buildButtons.(mcWindow, mcCatwidth*10 , mcCatheight*3,  offset, rotarysize, [\prelude, \settempo, \fadeOut], [~setPrelude, ~setTempo, ~fadeOut]);

CmdPeriod.add({
	mcWindow.close;
});
