/*
Begrüßung: Mic an

Rauschen beginnt+ Feedbacks
Synth insinuation evtl BufRd mit dem text-to-speech engine
Patterns bekommen ~addVolume message
Patterns morphen von der Ausgangsposition in eine deutlich andere Bewegung



Utts > 5, 8: Patterns ctranspose(-2, 2).choose
Utts = 10: Feedback variieren + Patterns randomize

*/

SynthDescLib.global.browse;
ServerOptions.devices;
ServerOptions.inDevices;
~fxGroup = nil
(
Server.default.options.numInputBusChannels_(2);
//Server.default.options.outDevice_("BeatsSolo Wireless");
// Server.default.options.outDevice_("SoundFlower (2ch)");
// Server.default.options.outDevice.postln;
Server.default.options.inDevice_("Fireface 400 (BEF)");

ServerTree.removeAll; // löscht alle funktionen
OSCFunc.trace(false);
s.newBusAllocators; // Busse machen
~fx1Bus = Bus.audio(s,2);
~fx2Bus = Bus.audio(s,2);
~cat = "";
~out = 0;

// wird später in ServerTree angemeldet
~makeNodes = {
	s.bind(
		~fxGroup = Group.new;
		//später: Fx Synth machen und hier instantiieren zB ....
		~reverb = Synth('reverb', [\in, ~fx1Bus], ~fxGroup);
		~delay = Synth('delay', [\in, ~fx2Bus], ~fxGroup);
)};

~fadeIn = {
	|cat, step, max|
	// das geht nicht. braucht ich globale variable fürs volume?
	var vol = ~synthDict[cat][\vol];
	vol.postln;
	if (vol < max, {~synthDict[cat][\vol] = vol* step; vol = vol * step}, {~synthDict[cat][\vol] = max; vol = max});

};

~fadeOut = {
	|cat, step, min|
	// das geht nicht. braucht ich globale variable fürs volume?
	var vol = ~synthDict[cat][\vol];
	vol.postln;
	if (vol > min, {~synthDict[cat][\vol] = vol* step; vol = vol * step}, {~synthDict[cat][\vol] = min; vol = min});

};

~continuousFadeOut = {
	|min, step|
	~categories.do({|cat|
		var vol, c;
		vol = ~synthDict[cat][\patternVol];
		//postf("\nthe vol %  of the pattern   %\n", vol, cat);
		c = case
		{(vol > min) && (Pbindef(cat).isPlaying)} {~synthDict[cat][\patternVol] = vol - step; vol = vol-step} // make sure only playing Patterns are faded
		{(vol <= min) && (Pbindef(cat).isPlaying)} {~synthDict[cat][\patternVol] = min; vol = min}
		{true} {"end of fade Cases"};
		//if (vol > min, {~synthDict[cat][\pattern] = vol - step; vol = vol-step}, {~synthDict[cat][\pattern] = min; vol = min});
		Pbindef(cat, \amp, vol);
	});

};

~addVolume = {
	|cat, add, max|
	if (~synthDict[cat][\patternVol] < max, {~synthDict[cat][\patternVol] = ~synthDict[cat][\patternVol] + add}, {~synthDict[cat][\patternVol] = max};
		postf("new vol of %  is % \n", cat, (~synthDict[cat][\patternVol]) );
	)
};

// wenn gebooted wird, passiert alles folgende, Synthdefs etc
s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	s.sync;
	t = TempoClock.new(60/60).permanent_(true);
	~totalUtts = 0;
	~sharedValues = (
		key: 60,
		tempo: t.tempo/4,
		transpose: 0,
		scale: Scale.major,
		vol: 0.2
	);
	~uttDict = Dictionary.new;
	~categories = ['dissent', 'praise', 'insinuation', 'concession', 'lecture'];
	~synthDict = Dictionary.new;
	~patternDict = Dictionary.new;
	~categories.do({arg cat;
		~synthDict.add(cat -> (synth: List.new, vol: 0.5, patternVol: 0.2));
		~uttDict.add(cat -> 0);
	});
	s.sync;
	SynthDef.new(\rauschen, {
		var sig, env;
		env = EnvGen.kr(Env([0, 1, 1, 0], [\atk.kr(1.5), 0.2, \sus.kr(0.2), \rls.kr(2.0)], [1, 0, -2, 3]), doneAction:2);
		sig = BPF.ar(BrownNoise.ar(\mul.kr(0.4)), \ffreq.kr(666), \rq.kr(0.6));
		sig = Pan2.ar(sig * env * \amp.kr(0.1), \pan.kr(0));
		Out.ar(\out.kr(~out), sig);
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);

	}).add;

	SynthDef.new('dissent', {
		|gate=1|
		var sig, gend, env;
		env = EnvGen.kr(Env.adsr(\atk.ir(0.1), releaseTime:\rls.kr(1), curve:\crv.kr(-10)), gate, doneAction:2);
		gend = BPF.ar(Gendy1.ar(\ampDist.kr(1.0), \durDist.kr(1.0), 1.0, 1.0, \minfreq.kr(400), \maxfreq.kr(1000), 0.3, 0.05, 5), \ffreq.kr(300), \rq.kr(0.9)) * \gendAmp.kr(0.3);
		sig = LFPulse.ar(\freq.kr(100).varlag(\lag.kr(0.3), \lagcrv.kr(5.0)), \pPhase.kr(0.0), \width.kr(0.4),\pulseMul.kr(0.15)) + gend ;
		sig = Pan2.ar(sig * env * \amp.kr(0.1), \pan.kr(0.0));
		Out.ar(\out.ir(~out), sig);
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef.new('lecture', {
		|gate = 1|
		var detune, sig, env, mod, ampMod;
		env = EnvGen.kr(Env.adsr(\atk.kr(0.01), 0.2, \sus.kr(0.8), \rls.kr(1.0), curve:\crv.kr(-4.0)), gate, doneAction: 2);
		mod = SinOsc.kr(\modRate.kr(1.2));
		detune = {ExpRand(\det1.kr(0.99), \det2.kr(1.01))}!4;
		sig = VarSaw.ar(\freq.kr(100)!4 * detune, 0, LFTri.kr(\filTime.kr(0.3)).range(0,1));
		sig = (sig * \distort.kr(1.5)).tanh;
		sig = sig * env * mod;
		sig = Splay.ar(sig * \amp.kr(0.15));
		Out.ar(~out, sig);
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);
	}).add;


	SynthDef.new(\fmBass, {
		var sig, car, mod, env;
		env = EnvGen.kr(Env.perc(\atk.kr(0.04), \rls.kr(0.2),  \crv.kr(-4.0)), 1, doneAction:2);
		mod = SinOsc.ar(\freq.kr(100)/5,  mul: \modAmp.kr(20));
		car = SinOsc.ar(\freq.kr(100));
		sig = (car + mod) * \amp.kr(0.15) * env;
		sig = (sig * \distort.kr(1.5)).tanh;
		sig = Splay.ar(sig);
		Out.ar(~out, sig);
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);
	}).add;

	SynthDef('insinuation', {
		| gate = 1|
		var  sig, env, lagfrq;
		env = EnvGen.kr(Env([0,1,1,0], [\atk.kr(0.05), \sus.kr(0.5), \rls.kr(0.4)], \linear), gate, doneAction: 2);
		lagfrq = Lag.kr(\freq.kr(220), \slideTime.kr(0.6));
		sig = PMOsc.ar(lagfrq, LFNoise2.ar(\noisFreq.kr(0.1), \maxF.kr(600)), SinOsc.ar(\ffreq.kr(3.0)), pmindex:\modWidth.kr(0.15), mul:\preamp.kr(0.2)) * \amp.kr(0.4)
		* env ;
		sig = FreqShift.ar(sig, \fShift.kr(100))!2;
		Out.ar(~out, sig);
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.kr(-30).dbamp);
	}).add;


	SynthDef('concession', {
		var sig, env;
		sig = PlayBuf.ar(2, \buf.kr(0), \rate.kr(1)*BufRateScale.ir(\buf.kr(0)), \trig.kr(1), \spos.kr(0));
		//die Env muss wohl .ar sein, um bufnums austauschen zu können
		env = Env([0, 1, 1, 0], [\atk.kr(0), 0.2,  \sus.kr(0), \rls.kr(1)], [0, 0, 0]).kr(2);
		sig = LPF.ar(sig, \freq.kr(440));
		sig = sig * env;
		sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(5));
		sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5));
		Out.ar(\out.ir(~out), sig) ;
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef('praise', {
		|gate=1|
		var channels;
		channels = {
			var amp1, freq1, sig1, env1;
			amp1 = LFPulse.kr(\ampHz.kr(0.2), 0, \pulWidth.kr(0.9)) * \ampScale.kr(0.75);
			env1 = EnvGen.kr(Env.adsr(\atk.kr(1.5), 0.2, 0.7, \rls.kr(2.9)), gate, doneAction:2);
			freq1 = LFNoise0.kr(\fRate.kr(0.2)).exprange(\freq.kr(120), \freq.kr(120) * \fMul.kr(4)).round(\freq.kr(120) * \rnd.kr(1.0));
			freq1 = freq1 * LFPulse.kr(\pulRate.kr(0.2));
			sig1 = RHPF.ar(Pulse.ar(freq1, \width.kr(0.2)), \ffreq.kr(300),  \rq.kr(1.0)) * amp1 * env1 * \amp.kr(0.3) ;
			sig1 = BPF.ar(sig1, \bpf.kr(120));
		}!2;
		Out.ar(~out, channels);
		Out.ar(\outfx.kr(~fx1Bus), channels * \send.kr(-30).dbamp);
	}).add;

	SynthDef(\mic, {
		var sig, verb;
		sig = SoundIn.ar(1) * \amp.kr(0.3);
		sig = LPF.ar(sig, \ffreq.kr(200));
		Out.ar(0, sig!2);
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-40).dbamp);
	}).add;

	SynthDef('reverb', {
		var sig, wet;
		sig = In.ar(\in.ir(~fx1Bus), 2);
		sig = FreeVerb2.ar(sig[0], sig[1], mix:1, room:0.99, damp:0.99);
		sig = LPF.ar(sig, 900);
		Out.ar(\out.ir(~out), sig);
	}).add;

	SynthDef('delay', {
		var sig, wet;
		sig = In.ar(\in.ir(~fx2Bus), 2);
		sig = CombL.ar(sig, \maxdel.kr(0.6), \deltime.kr(0.8), \decayT.kr(3.0),\mul.kr(1.2));
		sig = LPF.ar(sig, 300);
		Out.ar(\out.ir(~out), sig);
	}).add;

	~buffers= Dictionary.new;
	~path = "/Volumes/Macintosh HD 2/projekte/Meinung/Instruments/SuperCollider/percSamples01";
	PathName(~path).entries.do({
		arg subfolder;
		~buffers.add(
			subfolder.folderName.asSymbol ->
			Array.fill(
				subfolder.entries.size,
				{
					arg i;
					Buffer.read(s, subfolder.entries[i].fullPath);
				}
			)
		)
	});
	//Server wartet, bis dieser Block fertig ist
	s.sync;

	// ~postBeats = {t.beats.postln; 1};
	//t.schedAbs(t.nextBar, {~postBeats.value});
	// Funktionen, die bei jedem cmd-. oder freeAll Aufruf automatisch neu gestartet werden
	ServerTree.add(~makeNodes);
	ServerTree.run;
	Server.default.options.device_("Fireface 400 (BEF)");
	s.options.numOutputBusChannels = 6;
	s.sync;


	/// Osc Section
	// n = NetAddr("127.0.0.1", NetAddr.langPort); // local machine
	n = NetAddr("127.0.0.1", 57120); // local machine
	m = NetAddr("127.0.0.1", 5010); // beat send

	OSCdef.newMatching(
		\interpreter,
		{ arg msg;
			postf("\nnew cat: %", msg[1]);
			postf("\nnew count: %\n", msg[2]);
			if (msg[1] == 'dissence', {~cat = 'dissent'},{~cat = msg[1]});
			~totalUtts = ~totalUtts + 1;
			~uttDict[~cat] = ~uttDict[~cat] + 1;
			postf("\n~uttDict changed %\n", ~uttDict);
			//add volume to incoming cat Pattern
			~addVolume.value(~cat, 0.1, 0.99);
			~allocateSynth.value(~cat, msg[2]);
			~setGlobal.value(~cat);

		},
		'/interpreter_input'
	);


	// CmdPeriod.add(s.freeAll);
	// https://composerprogrammer.com/teaching/supercollider/sctutorial/Technicalities/05%20Clocks%20and%20Scheduling.html
	// send beat
	// t.schedAbs(t.nextTimeOnGrid, { m.sendMsg("/beat", (t.elapsedBeats.floor % 8).asInteger + 120); 1});

	~reset = (
		dissent: (
			instrument: 'dissent',
			scale: Pfunc({~sharedValues[\scale]}),
			degree: Pwrand([Pseq([[0, 6], Pseq([\r], 15)], 1),
				Pseq([[0,3], Pseq([\r], 15)], 1),
				Pseq([[0, -3], Pseq([\r], 15)], 1)
			], [0.7, 0.2, 0.1], inf),
			ctranspose: Pfunc({~sharedValues[\transpose]}),
			dur: Pfunc({~sharedValues[\tempo]}),
			atk:1.5,
			sus: 0.9,
			rls: 4.5,
			ampDist: 0.5,
			durDist: 1.0,
			minfreq: 400,
			maxfreq: 750,
			ffreq: 300,
			gendAmp: 0.1,
			rq: 0.9,
			pPhase: 0.0,
			width: 0.1,
			pulseMul: 0.2,
			amp: Pfunc({~sharedValues[\vol]}),
			pan:0.0,
			sustain: 2.0,
			send: -30,
		),

	lecture: (
			instrument: 'lecture',
			scale: Pfunc({~sharedValues[\scale]}),
			ctranspose: Pfunc({~sharedValues[\transpose]}) -12,
			degree: Pwrand([
				Pseq([Prand([0,-12]), Pseq([\],3)], 1),
				Pseq([0, \r, \r, \r,
				0,  \r, \r, \r,
				-3,  \r, \r, \r,
					Pseq([\], 4)],1)], [0.65, 0.35], inf),
			dur: Pfunc({~sharedValues[\tempo]}) *4,
			atk: 0.05,
			sus: 0.9,
			rls: 1.2,
			crv: -3.0,
			modRate: 0.8,
			det1: 0.98,
			det2: 1.02,
			filTime: 0.6,
			amp: Pfunc({~sharedValues[\vol]}),
			send: -30,
			sustain: 0.2
		),

		fmBass: (
			instrument: \fmBass,
			scale: Pfunc({~sharedValues[\scale]}),
			ctranspose: Pfunc({~sharedValues[\transpose]}),
			degree: Pseq([0, \r, \r, \r,
				-6, Pseq([\r], 3),
			    -5, Pseq([\r], 3),
			    -6, Pseq([\r], 3),
			], inf),
			dur: Pfunc({~sharedValues[\tempo]}) *2,
			atk: 0.04,
			rls: 0.4,
			crv: -4.0,
			distort: 1,
			amp: Pfunc({~sharedValues[\vol]}),
			send: -40,
			sustain: 0.3

		),

		insinuation: (
			instrument: 'insinuation',
			scale: Pfunc({~sharedValues[\scale]}),
			ctranspose: Pfunc({~sharedValues[\transpose]}),
			degree: Pwrand([
				Pseq([[0,12], Pseq([\r],8),
					[-1, 11], Pseq([\r], 8)],1),
				Pseq([[0,12], Pseq([\r],8),
					[-1, 12], Pseq([\r], 8)],1), [0.82, 0.18]
		], inf),
			dur: Pfunc({~sharedValues[\tempo]}),
			atk: 1,
			rls: 2.0,
			slideTime: 0.6,
			noisFreq: 0.1,
			maxF: 600,
			ffreq: 3.0,
			modWidth: 0.15,
			preamp: 0.3,
			amp: Pfunc({~sharedValues[\vol]}),
			fShift: 100,
			send: -30
		),

		concession: (
			instrument: 'concession',
	    	buf: Pseq([
				~buffers[\low][2], \, \, \,
				Pn(Pseq([~buffers[\himid][2], \, \, \,
					~buffers[\himid][3],\, \, \,
					~buffers[\himid][7],\, \, \,
				]),1)
			],inf),
			dur: Pfunc({~sharedValues[\tempo]}) ,
			rate: Pwhite(0.9, 1.1, inf),
			pan: Pwhite(-0.5, 0.5, inf),
			lpf: Pseq((220, 270 .. 1270), inf),
			outfx: ~fx1Bus,
			amp: 0.5,
			send: -35
		),

		praise: (
			instrument:'praise',
			ampHz: 0.2,
			pulWidth: 0.9,
			ampScale: 0.75,
			atk: 0.01,
			rls: 3.5,
			fRate: 0.2,
			//degree: Pseq([[0, 4, 7], [2, 8, 11], [4, 2, 5]], inf),
			degree: Pwrand(
				[
					Pseq([12, \r, \r, \r,
						Prand([9, 6, 10],1), \r, \r, \r,
						Prand([10, 9, 6], 1), \r, \r, \r,
						Pseq([\], 4)],1),
					Pseq([12, \r, \r, \r,
						9, \r, \r, \r,
						10, \r, \r, \r,
						Pseq([\], 4)],1),
					Pseq([[12, 9 ,4], \r, \r, \r,
						[9, 12], \r, \r, \r,
						4, \r, \r, \r,
						Pseq([\], 4)],1),
					Pseq([\r],16)
			], [0.1, 0.5, 0.1, 0.2].normalizeSum, inf),
			fMul: 1,
			rnd: 1.0,
			pulRate: Pwrand([Pn(Pseq([0.2], 11), Pseq([5], 5), 1), Pseq([0.2], 16)], [0.1, 0.9], inf),
			width: 0.2,
			ffreq: 300,
			rq: 1.0,
			bpf: Prand([120, 130, 220, 330], inf),
			send: -30,
			dur: Pfunc({~sharedValues[\tempo]}),
			sustain: 1.2

		),
	);

	//makePatterns
	~makePatterns = {
		~categories.do({
			|cat|
			var c;
			cat.postln;
			c = case
			{cat == 'praise'}{ ~patternDict.add(\pr -> Pbindef(cat, *~reset[cat].asPairs))}
			{cat == 'insinuation'}{ ~patternDict.add(\ins -> Pbindef(cat, *~reset[cat].asPairs))}
			{cat == 'dissent'}{ ~patternDict.add(\dis -> Pbindef(cat, *~reset[cat].asPairs))}
			{cat == 'concession'}{ ~patternDict.add(\con -> Pbindef(cat, *~reset[cat].asPairs))}
			{cat == 'lecture'}{ ~patternDict.add(\lec -> Pbindef(cat, *~reset[cat].asPairs))}
			{true}{"end of makePatters".postln};
			Pbindef(cat, \amp, 0.2);
		});
	};
	~makePatterns.();
	~startAllPatterns = {
		//start all Pbindefs with minimal volume and a 10 second delay
		Routine.new({
			~categories.scramble.do({
				|cat|
				~patternDict[cat].play(t, quant:4);
				postf("pattern % is playing % \n", cat,
					Pbindef(cat).isPlaying); 10.wait})
		}).play;
		// continuousFadeOut(min, step)
		t.schedAbs(t.nextTimeOnGrid, {~continuousFadeOut.value(0.01, 0.005); 1});
	};

	///basic patterns

	Pbindef(\rausch,
		\instrument, \rauschen,
		\dur, t.tempo *5,
		\ffreq, Pseq([666, 150], inf),
		\pan, Pwhite(-1,1, inf),
		\amp, 0.3
	);


	// set functions
	~setDissent = {
		|s_name, count|
		var c, dura, now, amp;
		amp = ~synthDict[\dissent][\vol];
		postf("\nsetting %\t with count %\n and amp %\n", s_name, count, amp);
		dura = Env.new([1,0], [count], [-2]).asPseg;
		5.do({|i|
			Pbind(\instrument, \dissent,
				\width, Pwhite(0.4, 0.9, 1), \freq, Pxrand([200, (200 + (count + 10))], 1), \amp, amp, \atk, Pn(Pwhite(0.01, 0.05), 1), \rls, Pn(Pwhite(0.02, 0.59), 1), \sustain, 0.15).play});
		c = case
		{(count > 0) && (count <= 5)} {// 1. Feedback Sound
			~dis = Pbindef(\dissent, *~reset[\dissent].asPairs);
			~dis = Pbindef(\dissent, \width, Pwhite(0.2, 0.5, inf), \dur, t.tempo *2,  \degree, Pwrand([
				Pseq([0, 4, -2, (3 +count)], 1),
				Pseq([[0, 4, -2], [0, 4, (3 +count)]], 1),
			], [0.64, 0.36],inf))

		}
		{(count > 5) && (count <=10)} {
			~dis = Pbindef(\dissent, \degree, Pseq([[0, 4], [4, 8], [-2, 2], [count%5, (count%5) +3]], inf), \dur, t.tempo*3, \amp, amp, \rls, (0.15 * count));
		}
		{(count > 10) && (count <=20)} {
			~dis = Pbindef(\dissent,
				\degree, Prand([[0, 4, 7], [4, 8, 12], [-2, 2, 6], [count%5, ((count%5) +3), ((count%5) + 5)]], inf),
				\dur, Pwrand([ 0.4, t.tempo *2, t.tempo*3], [0.05, 0.35, 0.6].normalizeSum, inf),
				\amp, amp,
				\rls, 1.5 - (count * 0.02),
				\sustain, Pkey(\rls),
				\atk, Pwhite(0.02, 0.1, inf)
			);
		}
		{(count > 20) && (count <= 30)} {

			~dis = Pbindef(\dissent, \degree, Pxrand([
				Pseq([[0, 1, 2], [0, 1, 3, 4], [0, 3, 8]], 1),
				Pseq([[2, 3, 5], [2, 4, 5], [2, 3, 4]], 1),
				Pseq([[7, 9, 10], [7, 8, 9], [7, 11, 13]], 1)],inf),
			\sustain, 0.3,
			\rls, Pwhite(0.05, 1.1, inf),
			\width, Pwhite(0.1, 0.5, inf),
			\amp, amp,
			\dur, Pwrand([0.8, 1.0, 1.5, 1.6, t.tempo], [0.3, 0.1, 0.05, 0.1, 0.4].normalizeSum, inf),
			);
		}
		{count > 30} {

			~dis = Pbindef(\dissent,
				\degree, Pseq((24, 22 .. (-12)), inf) ,
				\sustain, 0.3,
				\rls, Pwhite(0.05, 1.1, inf),
				\width, Pwhite(0.1, 0.5, inf),
				\minFreq, Pwhite(100, 600, inf),
				\maxFreq, Pkey(\minFreq) *2,
				\amp, amp,
				\dur, 1
			);
		}
		{true} {"end of dissent reached".postln};
		~addVolume.value(s_name, 0.2, 0.98);

	};

	~setInsinuation = {
		|s_name, count|
		var c, dura, now, amp;
		amp = ~synthDict[\insinuation][\vol];
		postf("\nsetting %\t with count %\n", s_name, count);
		//base = ~reset[\insinuation03].value;
		dura = Env.new([1,0], [count], [-2]).asPseg;
		5.do({|i|
			Pbind(\instrument, \insinuation,
				\freq, [exprand(100, 250), exprand(1700, 2300)], \amp, amp/4, \rls, Pn(3, 1)).play});
		c = case
		{(count > 0) && (count <= 5)} {
			~ins = Pbindef(\insinuation,  *~reset[\insinuation].asPairs);
			~ins = Pbindef(\insinuation, \dur, t.tempo, \degree, Pseq([[0,12], \r,  [-2, 10], \r, [0, 13], \r, \r, \r], inf) - count, \rls, Pseq([1.8, Pn(0.4, 7)], inf))
		}
		{(count > 5) && (count <= 10)} {}
		{(count > 10) && (count <= 20)} {}
		{(count > 20) && (count <= 30)} {}
		{count < 30} {
			~ins = Pbindef(\insinuation, \degree, Pseq([[0, 2, 4], [0, 4, 8], [2, 5, 9]], inf), \strum, Pseq([0.2, 0.4, 0.8], inf));
		}

		{true} {"end of insinuation reached".postln};
		~addVolume.value(s_name, 0.1, 0.98);

	};
	~setLecture = {
		|s_name, count|
		var c, dura, factor, amp;
		amp = ~synthDict[\lecture][\vol];
		postf("\nsetting %\t with count %\n", s_name, count);
		dura = Env.new([1,0], [count], [-2]).asPseg;
		factor = count%5;
		5.do({|i| Pbind(\instrument, \lecture,
			\freq, [exprand(80, 90 + i), exprand(160, (160 + i))], \amp, amp/3, \filTime, 0.8, \rls, Pn(1, 1)).play});
		c = case
		{(count > 0) && (count <= 5)} {
			~lec = Pbindef(\lecture, *~reset[\lecture].asPairs);
			~bass = Pbindef(\fmBass, *~reset[\fmBass].asPairs);
			~bass = Pbindef(\fmBass, \freq, Prand([100, 200, 300, 400],inf));
			~lec = Pbindef(\lecture, \degree, Pseq([Pn(0, 3), 12], inf));
		}
		{(count > 5) && (count <= 10)} {
			~lec = Pbindef(\lecture, \filTime, 0.3 + ((count -5) * 0.08), \degree, Pseq([0, 0, 3, 0, 1], inf), \sustain, 0.2);
		}
		{(count > 10) && (count <= 20)} {
			~lec =Pbindef(\lecture, \filTime, Pwhite(0.6, 0.85, inf), \modRate, 1.2 + ((count-10) * 0.1), \sustain, 1.6, \dur, Pfunc{(~sharedValues[\tempo])},
				\degree, Pseq([0, \r, 0, \r, 3, \r, 2, \r, 0, \r, 0, \r, 4, \r, 2, \r ], inf));
		}
		{(count > 20) && (count <= 30)} {
			~lec = Pbindef(\lecture, \sustain, 0.3, \rls, 1.0 - ((count-20) * 0.03),
				\degree, Pseq([Pseq([12, 11, 11, 8, 8, \r, 6], 15), Pseq([6, 6, 8, 8, 3, \r, 8], 1)], inf), \dur, t.tempo);
		}
		{count > 30} {
			~lec = Pbindef(\lecture, \dur, t.tempo/4, \modRate, exprand(0.8, 1.4), \filTime, exprand(0.55, 0.75), \degree, Pseq([0, \r, \r, \r, 2, \r, \r, -2, \r ], inf) +12, \atk, 0.08, \rls, 0.1, \sustain, 0.15)
		}
		{true} {"end of lecture reached".postln;};
		~addVolume.value(s_name, 0.1, 0.98);
	};
	~setBass = {
		|s_name, count|
		var c, dura, factor, amp;
		amp = ~synthDict[\lecture][\vol];
		postf("\nsetting %\t with count %\n", s_name, count);
		dura = Env.new([1,0], [count], [-2]).asPseg;
		5.do({|i| Pbind(\instrument, \lecture,
			\freq, [exprand(80, 90 + i), exprand(160, (160 + i))], \amp, amp/3, \filTime, 0.8, \rls, Pn(1, 1)).play});
		c = case
		{(count > 0) && (count <= 5)} {
			~bass = Pbindef(\bass, *~reset[\bass].asPairs);
			~bass = Pbindef(\bass, \degree, Pseq([Pn(0, 3), 12], inf));
		}
		{(count > 5) && (count <= 10)} {
			~bass = Pbindef(\bass, \degree, Pseq([0, 0, 3, 0, 1], inf), \sustain, 0.2);
		}
		{(count > 10) && (count <= 20)} {
			~bass =Pbindef(\bass, \modRate, 1.2 + ((count-10) * 0.1), \sustain, 1.6, \dur, Pfunc{(~sharedValues[\tempo])},
				\degree, Pseq([0, \r, 0, \r, 3, \r, 2, \r, 0, \r, 0, \r, 4, \r, 2, \r ], inf));
		}
		{(count > 20) && (count <= 30)} {
			~bass = Pbindef(\bass, \sustain, 0.3, \rls, 1.0 - ((count-20) * 0.03),
				\degree, Pseq([Pseq([12, 11, 11, 8, 8, \r, 6], 15), Pseq([6, 6, 8, 8, 3, \r, 8], 1)], inf), \dur, t.tempo);
		}
		{count > 30} {
			~bass = Pbindef(\bass, \dur, t.tempo/4, \modRate, exprand(0.8, 1.4), \degree, Pseq([0, \r, \r, \r, 2, \r, \r, -2, \r ], inf) +12, \atk, 0.08, \rls, 0.1, \sustain, 0.15)
		}
		{true} {"end of lecture reached".postln;};
		~addVolume.value(s_name, 0.1, 0.98);
	};

	~setConcession = {
		|s_name, count|
		var c, dura, amp, bufs;
		amp = ~synthDict[\concession][\vol];
		postf("\nsetting %\t with count %\n", s_name, count);
		bufs= ~buffers[\tonal];
		dura = Env.new([1,0], [count], [-2]).asPseg;
		Pbind(\instrument, \concession, \buf, Pxrand(~buffers[\tonal], 10), \dur, 0.1, \amp, amp).play(t);
		c = case
		{(count > 0) && (count <= 5)}{~con = Pbindef(\concession,  *~reset[\concession].asPairs);
			~con = Pbindef(\concession, \rate, Pseq([Pn(Pwhite(0.3, 0.45, 1), 4), Pn(Pwhite(1.0, 1.3,1), 4)], inf), \amp, amp);
		}
		{(count > 5) && (count <= 10)}{~con = Pbindef(\concession, \dur,  Pfunc{(~sharedValues[\tempo])}/2, \buf, Pseq([Pn(Prand(~buffers[\low], 1), 1), Pn(Prand(~buffers[\lowmid], 1), 2), Pn(Prand(~buffers[\hi],1), 5)], inf), \rate, Pwhite(0.9, 1.11, inf))}
		{(count > 10) && (count <= 20)}{~con = Pbindef(\concession,
			\buf, Pseq([Pn(Prand(~buffers[\low], 1), 3), Pn(Prand(~buffers[\himid], 1), 1), Pn(Prand(~buffers[\mid],1), 2), Prand(~buffers[\hi], 1), Pn(Prand(~buffers[\mid],1), 1)], inf), \rate, Pwhite(0.9, 1.11, inf), \amp, amp * Pwhite(0.4, 0.9, inf))}
		{(count > 20) && (count <= 30)}{~con = Pbindef(\concession, \dur, Pseq([Pn(t.tempo/2, 15), Pn(0.25, 8)], inf), \send, -30)}
		{count > 30} { ~con = Pbindef(\concession, \dur, t.tempo/4, \send, -30,
			\buf, Pseq([bufs[1], bufs[3], bufs[0], bufs[8], bufs[3], bufs[3], bufs[6], bufs[7]], inf), \rate, Pwhite(0.8, 1.1, inf), \amp, Pwhite(amp/3, amp, inf))
		}
		{true}{"end of setconcession reached".postln};
		~addVolume.value(s_name, 0.1, 0.98);
	};

	~setPraise = {
		|s_name, count|
		var c, pat, dura, amp;
		postf("\nsetting %\t with count %\n", s_name, count);
		amp = ~synthDict[\praise][\vol];
		dura = Env.new([1,0], [count], [-2]).asPseg;
		5.do({|i|
			Pbind(\instrument, \praise,
				\freq, Pxrand([Pwhite(120, 240, 1), Pwhite(240, 480, 1)], 1), \amp, amp/2, \pulRate, 20, \bpf, 500, \rls, Pn(0.3, 1), \sustain, 0.3).play});
		c = case
		{(count > 0) && (count <= 5)} {
			~pr = Pbindef(\praise, *~reset[\praise].asPairs);

		}
		{(count > 5) && (count <= 10)} {
			~pr = Pbindef(\praise, \degree, Pseq([[0, 4, 7], [1, 3, 7], [4, 2, 5], [1, 3, 6]], inf) * Pwrand([1, count.reciprocal], [0.9, 0.1], inf), \dur, t.tempo * 3);
		}
		{(count > 10) && (count <= 20)} {
			~pr = Pbindef(\praise, \degree, Pseq([Pseq([-12, -10, -4, 0], 1), Pseq([[-12, -7], [-10, -10], [-4, -12], [0, 5]],1)], inf) * Pwrand([1, count.reciprocal], [0.9, 0.1], inf), \amp, amp,
				\ampHz, 1,
				\fRate, Pwrand([0.2, 4, 6], [0.8, 0.15, 0.05], inf),
				\pulRate, Pkey(\fRate) / 4,
				\dur, t.tempo *2

			);
		}
		{(count > 20) && (count <= 30)} {
			~pr = Pbindef(\praise,
				\degree, -12,
				\ampHz, Pwhite(2, 8, inf),
				\fRate, Pwrand([3, 18], [0.95, 0.05], inf),
				\pulRate, Prand([ 2, 4, 8], inf),
				\fMul, Prand([1, 3.8, 4, 6.3, 20], inf),
				\rnd, 1.0,
				\sustain, 0.2,
				\atk, 0.1,
				\rls, Pkey(\fRate)/8,
				\dur, t.tempo/4
			);
		}
		{count > 30} {~pr = Pbindef(\praise,
			\degree, Pwrand([-12, -24, 0], [0.75, 0.2, 0.05],inf),
			\ampHz, 8,
			\fRate, 12,
			\pulRate, 8,
			\fMul, Pwhite(6.1, 8.2, inf),
			\rnd, 1.0,
			\sustain, 0.2,
			\atk, 0.1,
			\rls, 0.2,
			\dur, (count - 27).reciprocal
		)}
		{true} {"end of insinuation reached".postln;};
		~addVolume.value(s_name, 0.1, 0.98);

	};
	~setRauschen = {
		|count|
		var c, dura, now;
		postf("\nsetting rauschen with count %\t", count);
		dura = Env.new([1,0], [count], [-2]).asPseg;
		c = case
		{(count > 1) && (count <= 10)}{Pbindef(\rausch, \ffreq, Pxrand([exprand(300, 666), 150], inf), \rq, Pxrand((0.05, 0.1 .. 2.0), inf), \rls, 0.3).trace;}
		{true} {"end of rauschen cases".postln};
	};

	~allocateSynth = {
		|s_name, count|
		var c;
		postf("\nallocating to Synth %\t as %   with count %\n", s_name, s_name.class, count);
		postf("\ntotalUtts %\t", ~totalUtts);
		c = case
		{s_name == \lecture} {~setLecture.value(s_name, count);}
		{s_name == \praise} {~setPraise.value(s_name, count)}
		{s_name == \dissent} {~setDissent.value(s_name, count)}
		{s_name == \concession} {~setConcession.value(s_name, count)}
		{s_name == \insinuation} {~setInsinuation.value(s_name, count)}
		{true}{"end of allocation".postln};
	};

	~setGlobal = {
		|s_name|
		var c;
		postf("\nglobal settings  %\t ", s_name);
		c = case
		/*{~totalUtts >= 30} {Scale.choose}
		{~totalUtts % 5 ==0} {Scale.choose}*/
		{~totalUtts >=20} {~sharedValues[\transpose] = -3}
		{~totalUtts >=15} {~sharedValues[\transpose] = 0}
		{~totalUtts >=10} { ~startAllPatterns.()}
		{~totalUtts >=5} {Pbindef(\rausch).play(t, quant:1); ~mic.set(\send, -8);}
		{~totalUtts > 0 } {~mic.set(\send, (-35 + (~totalUtts * 6)));  }
		{true} {"end of global settings".postln};

	};

	s.sync;
	"done".postln;

});
)



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/* Das Soundwesen


*/
///start////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//activate Mic
~mic = Synth(\mic, [\amp, 0.75, \ffreq, 500]);



(
// stop all patterns
~categories.do({|cat| Pbindef(cat).stop})
)
	OSCFunc.trace(true);


/// reset ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

currentEnvironment
// tests
~buffers[\bd][0].play;
// http://sc3howto.blogspot.com/2010/06/pfunc.html  beispiel für ein Fade
3.do({|item, i| Pbind(\instrument, \insinuation, \amp, 0.4, \lfreq, [exprand(100, (200 + (item * 5))), 50], \rls, Pn(3, 1)).play});
~setGlobal.("praise")
~totalUtts =5

(
var test;
test = ExpRand(40, 320).round(20);
~addVolume.value(\insinuation, 0.1, 0.98);
~addVolume.value(\praise, 0.1, 0.98);
~addVolume.value(\dissent, 0.1, 0.98);
~addVolume.value(\concession, 0.1, 0.98);
~addVolume.value(\lecture, 0.1, 0.98);

)
(
// reset patterns
~patternDict.keys.do({|k| ~patternDict[k].postln; ~patternDict[k].clear});
~makePatterns.();
)
(
Pbindef.all.do(_.stop);
~con = ~patternDict[\con].play(t).quant_(4);
~fmbass = Pbindef(\fmBass, *~reset[\fmBass].asPairs).play(t).quant_(4);
~lec = ~patternDict[\lec].play(t).quant_(4);
~pr = ~patternDict[\pr].play(t, quant:4);
~dis = ~patternDict[\dis].play(t, quant:4);
~ins = ~patternDict[\ins].play(t, quant:4);
)

Pbindef.all.do(_.stop);

~sharedValues[\tempo] = t.tempo
~sharedValues[\scale] = Scale.choose
t.tempo = 1


(
~postinfo = {
	("beats: "+ ((t.beats.floor) %t.beatsPerBar +1)).postln;
	("bar: "+ (t.bar)).postln;
	"".postln;
	1;
};
t.schedAbs(t.nextBar, {{Blip.ar(500) * EnvGen.kr(Env.perc(0.01, 0.1),doneAction:2)}.play(); ~postinfo.(); });
)
t.beatsPerBar

(
~synthDict['dissent']
Pbindef(\concession).stop;
Pbindef(\rausch).play;
Pbindef(\rausch).stop;
~setDissent.value('dissent', 2);
~setInsinuation.value('insinuation', 2);
~setLecture.value('lecture', 1);
~setConcession.value('concession', 1);
~setPraise.value('praise', 32);
)
Synth(\rauschen, [\ffreq, 1500])
~stopList.value(~synthDict[\dissent][\synth]);
~sharedValues[\transpose] = 12

(
/*
variablen liefern Arrays für Multichannel Expansion (akkorde)
nicht verallgemeinbar, wenn gewünscht müssen diese Arrays - besonders die Synth parameter - manuell bestimmt werden
*/
var freq, minfreq, maxfreq, lag;

freq = Array.exprand(8, 400, 600);
minfreq = Array.exprand(8, 200, 500);
maxfreq = Array.rand(8, 601, 800);
lag = Array.rand(8, 0.3, 1.9);


fork {
    [\freq, freq, \minfreq, minfreq, \maxfreq, maxfreq, \amp, 0.2, \lag, \pulseMul, 0.1].flop.do { |args|
        args.postln;
		~disSynth.add(Synth(\dissent, args));
		~disSynth.postln;
        // 1.wait;
    }
};
)