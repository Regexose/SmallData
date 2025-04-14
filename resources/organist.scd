
//Aktivieren von Fadern für die Lautstärke Regelung der Patterns
~activateVolume = {
	|ch, i|
	var value;
	//"chan   %    and i   %  current  % ".format(ch, i, ~currentUttPattern.asString).postln;
	value = MIDIFunc.cc({
		arg ...args;
		args[..2].postln;
        "activated  %  channel % level %".format(ch.asString, ~cat2Channel[ch], ~utt.level).postln;
		~cat2Channel[ch].level = args[0].linlin(0, 127, 0.0, 1.0);
	},
	i,
	1
	);
};

//Aktivieren von Sends
~activateReverb = {
	|ch, i, offset|
	var value, sendNum;
	//"making reverb send   % and i %".format(ch, i).postln;
	sendNum = i + offset;
	value = MIDIFunc.cc(
		{arg ...args;
			args[..2].postln;
			~sends[ch].level = args[0].linlin(0, 127, 0.0, 1.0);
		},
		sendNum,
		1
	);

};

//Aktivieren von Pitch Values für utterance sequencer Samples
~activatePitch = {
	|ch, i, offset|
	var value, sendNum;
	//"making pitch wheel for  % and i %".format(ch, i).postln;
	sendNum = i + offset;
	value = MIDIFunc.cc(
		{arg ...args;
			//"pitch wheel for  % :    %".format(ch, args[..2]).postln;
			~melos.seqRates[ch] = args[0].linlin(0, 127, -20, 20);
		},
		sendNum,
		1)
};
