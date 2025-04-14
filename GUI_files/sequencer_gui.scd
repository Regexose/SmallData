// Sequencer
(
var buttonsize=40, columns=16, rows=5, offset=10, labelwidth=100, headerheight=100, sliderwidth=300, selectorWidth=200, rotarywidth=200, rotarysize=55;

var window, topLevel, trackButtonsContainer, labels, header, buttons, track, sequencerButtons, densityKnobs, pattern;
var buttonFieldWidth = buttonsize*columns, buttonFieldHeight=buttonsize*rows;

// #########
// BUILD SEQUENCER
// #########

// Build window, topLevel and header
window = ~buildWindow.value("Sequencer", 10, 550,  labelwidth+buttonFieldWidth+sliderwidth+selectorWidth+(8*offset), buttonsize+offset+buttonFieldHeight+headerheight+(6*offset));
topLevel = ~buildTopLevel.value(window, 10, 10, buttonFieldWidth+labelwidth+sliderwidth+selectorWidth+(6*offset), buttonsize+offset+buttonFieldHeight+headerheight+(4*offset));
header = ~buildSequencerHeader.value(topLevel, buttonFieldWidth+labelwidth, headerheight, "Sequencer");

// Build Track
labels = ~buildCategoryLabels.value(topLevel, labelwidth, buttonsize+buttonFieldHeight+(2*offset), buttonsize, offset);
trackButtonsContainer = ~buildTrackButtonsContainer.value(topLevel, buttonFieldWidth+(2*offset), buttonsize+buttonFieldHeight+(2*offset));
track = ~buildSequencerTrack.value(trackButtonsContainer, columns, buttonsize);

// Build the Sequencer Buttons
sequencerButtons = ~buildSequencerButtons.value(trackButtonsContainer, buttonFieldWidth+(2*offset), buttonFieldHeight+(2*offset), buttonsize, offset, rows, columns);

// Build SoundFileView and RangeSliders
~sliderButtons = ~buildSliderButtons.value(topLevel, sliderwidth, buttonFieldHeight, buttonsize, offset, rows);

~utteranceSelectors = ~buildUtteranceSelectors.value(topLevel, selectorWidth, buttonFieldHeight, buttonsize, offset, rows);

// ##############
// Build Patterns
// ##############

Pdefn(\melody, Ppar(
	sequencerButtons[1].collect({
		arg c, r;
		var delta = 0.25, currentVol = 0.9, sustain = 0.1;
		Pbind(
			\instrument, \uttSampler,
			\buf, Pfunc({~uttSamples[~categories[r]][0]}),
			\delta, delta,
			\sustain, sustain,
			\amp,  Pif(Pseq(sequencerButtons[1][r], inf).coin, currentVol, \rest),
			\rate, Pfunc({~melos.seqRates[~fadingSynths[r]].midiratio}),
		    \cgain, 2.3,
			\out, ~utt.inbus,
			\start, Pfunc({~uttSamples[~categories[r]][1]}),
			\end, Pfunc({~uttSamples[~categories[r]][2]}),
			\track_index, Pseq((0..15), inf),
			\track_func, Pfunc({|ev| ~update_track_seq.value(ev.track_index, track)});
)}), inf));


CmdPeriod.add({
	window.close;
});
)
