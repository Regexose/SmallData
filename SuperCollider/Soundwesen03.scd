/* ab minute 30
https://www.youtube.com/watch?v=ztVLMS15n1c&t=1585s

SC trifft alle Soundentscheidungen
- Utterance Dict zählt eintreffende Utts
- special Events bei n Utterances
- setup schaltet auf "empfangsbereit" und startet Grundpatterns (Pbindefs) in der Minimallautstärke
- setup initialisiert auch, das die Grundpatterns kontinuierlich abblenden, solange sie lauter als die Minimalvolume sind
- Die Grundpatterns werden bei eintreffenden Utts um eine Stufe lauter (wird durch die Feedbacks wohl verdeckt)

*/
SynthDescLib.global.browse;
ServerOptions.inDevice_(0);
~fxGroup = nil
(
Server.default.options.numInputBusChannels_(0);
//Server.default.options.outDevice_("BeatsSolo Wireless");
// Server.default.options.inDevice_("Built-in Microph");
// löscht alle funktionen
ServerTree.removeAll;
OSCFunc.trace(false);
s.newBusAllocators; // Busse machen
~fx1Bus = Bus.audio(s,2);
~fx2Bus = Bus.audio(s,2);
~cat = "";
~out = 0;
~totalUtts = 0;
~sharedValues = (
	key: 60,
	tempo: 90/60,
	transpose: 0,
	scale: Scale.major
);
~uttDict = Dictionary.new;
~categories = ['dissence', 'praise', 'insinuation', 'concession', 'lecture'];
~synthDict = Dictionary.new;
~categories.do({arg i;
	~synthDict.add(i -> (synth: List.new, vol: 0.5, pattern: 0.2));
	~uttDict.add(i -> 0);
});
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
		vol = ~synthDict[cat][\pattern];
		// postf("\nthe vol %  of the pattern   %\n", vol, cat);
		c = case
		{(vol > min) && (Pbindef(cat).isPlaying)} {~synthDict[cat][\pattern] = vol - step; vol = vol-step} // make sure only playing Patterns are faded
		{(vol <= min) && (Pbindef(cat).isPlaying)} {~synthDict[cat][\pattern] = min; vol = min}
		{true} {"end of fade Cases"};

		//if (vol > min, {~synthDict[cat][\pattern] = vol - step; vol = vol-step}, {~synthDict[cat][\pattern] = min; vol = min});
		Pbindef(cat, \amp, vol);
	});


};

~addVolume = {
	|cat, add, max|

	if (~synthDict[cat][\pattern] < max, {~synthDict[cat][\pattern] = ~synthDict[cat][\pattern] + add}, {~synthDict[cat][\pattern] = max};
		postf("new vol of %  is % \n", cat, (~synthDict[cat][\pattern]) );
	)
};

// wenn gebooted wird, passiert alles folgende, Synthdefs etc
s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	s.sync;
	SynthDef.new(\rauschen, {
		var sig, env;
		env = EnvGen.kr(Env([0, 1, 1, 0], [\atk.kr(1.5), 0.2, \sus.kr(0.2), \rls.kr(2.0)], [1, 0, -2, 3]), doneAction:2);
		sig = BPF.ar(BrownNoise.ar(\mul.kr(0.4)), \ffreq.kr(666), \rq.kr(0.6));
		sig = Pan2.ar(sig * env * \amp.kr(0.1), \pan.kr(0));
		Out.ar(\out.kr(~out), sig);
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);

	}).add;

	SynthDef.new('dissence', {
		|gate=1|
		var sig, gend, env;
		env = EnvGen.kr(Env.adsr(\atk.ir(3.1), releaseTime:\rls.kr(2.9), curve:\crv.kr(-10)), gate, doneAction:2);
		gend = BPF.ar(Gendy1.ar(\ampDist.kr(1.0), \durDist.kr(1.0), 1.0, 1.0, \minfreq.kr(400), \maxfreq.kr(1000), 0.3, 0.05, 5), \ffreq.kr(300), \rq.kr(0.9)) * \gendAmp.kr(0.3);
		sig = LFPulse.ar(\freq.kr(100).varlag(\lag.kr(0.3), \lagcrv.kr(5.0)), \pPhase.kr(0.0), \width.kr(0.4),\pulseMul.kr(0.15)) + gend ;
		sig = Pan2.ar(sig * env * \amp.kr(0.1), \pan.kr(0.0));
		Out.ar(\out.ir(~out), sig);
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef.new('lecture', {
		|gate = 1|
		var detune, sig, env, mod, ampMod;
		env = EnvGen.kr(Env.adsr(\atk.kr(0.01), 0.2, \sus.kr(0.8), \rls.kr(1.0), curve:\crv.ir(-4.0)), gate, doneAction: 2);
		mod = SinOsc.kr(\modRate.kr(1.2));
		detune = {ExpRand(\det1.kr(0.99), \det2.kr(1.01))}!4;
		sig = VarSaw.ar(\freq.kr(41.2)!4 * detune, 0, LFTri.kr(\filTime.kr(0.3)).range(0,1));
		sig = sig * env * mod;
		sig = Splay.ar(sig * \amp.kr(0.15));
		Out.ar(~out, sig);
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef('insinuation', {
		| gate = 1|
		var  sig, env, lagfrq;
		env = EnvGen.kr(Env([0,1,1,0], [\atk.kr(0.05), 0.3, \sustain.kr(0.5), \rls.kr(0.4)], \linear), gate, doneAction: 2) ;
		lagfrq = Lag.kr(\freq.kr(220), \slideTime.kr(0.6));
		sig = PMOsc.ar(lagfrq, LFNoise2.ar(\noisFreq.kr(0.1), \maxF.kr(600)), SinOsc.ar(\ffreq.kr(3.0)), pmindex:\modWidth.kr(0.15), mul:\preamp.kr(0.2)) * \amp.kr(0.4)
		* env ;
		sig = FreqShift.ar(sig, \fShift.kr(100));
		Out.ar(~out, sig ! 2);
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.kr(-30).dbamp);
	}).add;


	SynthDef('concession', {
		var sig, env;
		sig = PlayBuf.ar(2, \buf.kr(0), \rate.kr(1)*BufRateScale.ir(\buf.kr(0)), \trig.kr(1), \spos.kr(0));
		//die Env muss wohl .ar sein, um bufnums austauschen zu können
		env = Env([0, 1, 1, 0], [\atk.kr(0), 0.2,  \sus.kr(0), \rls.kr(1)], [0, 0, 0]).kr(2);
		sig = LPF.ar(sig, \freq.kr(440));
		sig = sig * env;
		sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5));
		Out.ar(\out.ir(~out), sig) ;
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef('praise', {
		|gate=1|
		var amp1, amp2, freq1, freq2, sig1, sig2, env1, env2;
		amp1 = LFPulse.kr(\ampHz.kr(4.0), 0, \pulWidth.kr(0.12)) * \ampScale.kr(0.75);
		amp2 = LFPulse.kr(\ampHz.kr(4.0), 0, \pulWidth.kr(0.12)) * \ampScale.kr(0.75);
		env1 = EnvGen.kr(Env.adsr(\atk.kr(0.5), 0.2, 0.7, \rls.kr(0.9)), gate, doneAction:2);
		env2 = EnvGen.kr(Env.adsr(\atk.kr(0.5), 0.1, 0.7, \rls.kr(0.9)), gate, doneAction:2);
		freq1 = LFNoise0.kr(\fRate.kr(4.0)).exprange(\freq.kr(40), \freq.kr(40) * \fMul.kr(8)).round(\freq.kr(40) * \rnd.kr(1.0));
		freq2 = LFNoise0.kr(\fRate.kr(4.0)).exprange(\freq.kr(40), \freq.kr(40) * \fMul.kr(8)).round(\freq.kr(40) * \rnd.kr(1.0));
		freq1 = freq1 * LFPulse.kr(\pulRate.kr(4.0));
		freq2 = freq2 * LFPulse.kr(\pulRate.kr(4.0));
		sig1 = RHPF.ar(Pulse.ar(freq1, \width.kr(0.2)), \ffreq.kr(300),  \rq.kr(1.0)) * amp1 * env1 * \amp.kr(0.1) ;
		sig2 = RHPF.ar(Pulse.ar(freq2, \width.kr(0.2)), \ffreq.kr(300), \rq.kr(1.0)) * amp2 * env2 * \amp.kr(0.1);
		sig1 = BPF.ar(sig1, \bpf.kr(120));
		sig2 = BPF.ar(sig2, \bpf.kr(120)) ;
		Out.ar(~out, [sig1, sig2]);
		Out.ar(\outfx.kr(~fx1Bus), [sig1, sig2] * \send.kr(-30).dbamp);
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
		sig = LPF.ar(sig, 1200);
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

	t = TempoClock.new(90/60).permanent_(true);

	/// Osc Section

	// n = NetAddr("127.0.0.1", NetAddr.langPort); // local machine
	n = NetAddr("127.0.0.1", 57120); // local machine
	m = NetAddr("127.0.0.1", 5010); // beat send
/*
	f = { |msg, time, addr|
		if(msg[0] != '/status.reply') {
			"time: % sender: %\nmessage: %\n".postf(time, addr, msg);
		}
	};
	//thisProcess.addOSCRecvFunc(f);
	// stop posting.
	//thisProcess.removeOSCRecvFunc(f);
	*/


	OSCdef.newMatching(
		\interpreter,
		{ arg msg;
			var c;
			postf("\nnew cat: %", msg[1]);
			postf("\nnew count: %", msg[2]);
			~cat = msg[1];
			~totalUtts = ~totalUtts + 1;
			~uttDict[~cat] = ~uttDict[~cat] + 1;
			postf("\n~uttDict changed %\n", ~uttDict);
			//add volume to incoming cat Pattern
			~addVolume.value(~cat, 0.1, 0.99);
			c = case
			//{~totalUtts < 2} {~setRauschen.value(msg[2])}
			{~totalUtts >= 2} {~allocateSynth.value(msg[1], msg[2]); ~setGlobal.value.(~cat)}
			{true}{postf("\nend of cases %\n", ~totalUtts)};


		},
		'/interpreter_input'
	);


	CmdPeriod.add(s.freeAll);
	// https://composerprogrammer.com/teaching/supercollider/sctutorial/Technicalities/05%20Clocks%20and%20Scheduling.html
	// send beat
	t.schedAbs(t.nextTimeOnGrid, { m.sendMsg("/beat", (t.elapsedBeats.floor % 8).asInteger + 120); 1});


~makeSynth = {
	|cat, count|
	var params, index;
	params = List.new;
	~reset[cat].keys.do({
		|k|
		params.addAll([k, ~reset[cat][k]])
	});
	params.asArray.postln;
	Synth(cat, params.asArray);
};

	s.sync;
	"done".postln;
}
);
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
//start all Pbindefs with minimal volume and a 10 second delay
(
Routine.new({~categories.scramble.do({|cat| cat.postln; Pbindef(cat).play(t, quant:1); postf("pattern % is playing % \n", cat, Pbindef(cat).isPlaying); 10.wait})}).play;
// continuousFadeOut(min, step)
t.schedAbs(t.nextTimeOnGrid, { ~continuousFadeOut.value(0.001, 0.0052); 1});

)
(
~categories.do({|cat| Pbindef(cat).stop})
)
	OSCFunc.trace(true);


/// reset ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(

Pbindef(\rausch,
	\instrument, \rauschen,
	\dur, t.tempo *4,
	\ffreq, Pseq([666, 150], inf),
	\pan, Pwhite(-1,1, inf),
	\amp, 0.3
);
Pbindef(\lecture,
	\instrument, \lecture,
	\scale, Pfunc({~sharedValues[\scale]}),
	\degree, Pseq([0, [3, 7], [4, 2, 7], 7].mirror, inf),
	\ctranspose, Pfunc({~sharedValues[\transpose]}),
	\dur, t.tempo *3,
	\amp, 0.05);


Pbindef(\praise,
	\instrument, \praise,
	\scale, Pfunc({~sharedValues[\scale]}),
	\degree, Pseq([[0, 4, 7], [0, 3, 7], [0, 2, 7]], inf),
	\ctranspose, Pfunc({~sharedValues[\transpose]}),
	\dur, t.tempo *2,
	\amp, 0.15

);

Pbindef(\dissence,
	\instrument, \dissence,
	\scale, Pfunc({~sharedValues[\scale]}),
	\degree, Pseq([[0, 4, 7], [0, 3, 7], [0, 2, 7]], inf),
	\ctranspose, Pfunc({~sharedValues[\transpose]}),
	\dur, t.tempo *3,
	\amp, 0.05
);

Pbindef(\insinuation,
	\instrument, \insinuation,
	\scale, Pfunc({~sharedValues[\scale]}),
	\degree, Pseq([[0, 4, 7], [0, 3, 7], [0, 2, 7]], inf),
	\ctranspose, Pfunc({~sharedValues[\transpose]}),
	\dur, t.tempo *3,
	\amp, 0.05
);

Pbindef(\concession,
	\instrument, \concession,
	\buf, Prand(~buffers[\tonal], inf),
	\dur, t.tempo,
	\rate, Pwhite(0.2, 1.8, inf),
	\pan, Pwhite(-0.5, 0.5, inf),
	\amp, 0.05,
	\lpf, Pseq((220, 270 .. 1270), inf),
	\outfx, ~fx1Bus,
	\send, Pseq((-35, -30 .. -10), inf)
);

~reset = (
	dissence: (
		instrument: 'dissence',
		atk:0.3,
		sus: 0.7,
		rls: 1.9,
		ampDist: 0.5,
		durDist: 1.0,
		minfreq: 400,
		maxfreq: 750,
		ffreq: 300,
		gendAmp: 0.2,
		rq: 0.9,
		freq:  110,
		pPhase: 0.0,
		width: 0.1,
		pulseMul: 0.2,
		amp: 0.3,
		pan:0.0,
		send: -30
	),

	lecture: (
		instrument: 'lecture',
		atk: 0.01,
		sus: 3.0,
		rls: 1.0,
		crv: -4.0,
		modRate: 1.2,
		det1: 0.99,
		det2: 1.01,
		freq: 41.2,
		filTime: 0.3,
		amp: 0.15,
		send: -30
	),

	insinuation: (
		instrument: 'insinuation',
		atk: 0.05,
		sustain: 0.5,
		rls: 0.4,
		freq: 220,
		slideTime: 0.6,
		noisFreq: 0.1,
		maxF: 600,
		ffreq: 3.0,
		modWidth: 0.15,
		preamp: 0.3,
		amp: 0.4,
		fShift: 100,
		send: -30
	),

	concession: (
		instrument: 'concession',
		freq: 440,
		bd: (buf: ~buffers[\bd][1], dur: 1),
		sn: (buf: ~buffers[\sn][0], dur: 3),
		dry: (buf: ~buffers[\dry][0], dur: 1),
		hh: (buf: Pxrand(~buffers[\hh], inf), dur: 1.5),
		tonal: (buf: Pxrand(~buffers[\tonal], inf), dur: Pwhite(0.1, 0.3, inf))
	)
);
)

/// set functions
(
~setDissence = {
	|s_name, count|
	var c, dura, now, amp;
	amp = ~synthDict[\dissence][\vol];
	postf("\nsetting %\t with count %\n and amp %\n", s_name, count, amp);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 0) && (count < 30)} {// 1. Feedback Sound
				count.do({|i|
					 Pbind(\instrument, \dissence,
				\width, exprand(0.4, 0.9), \freq, exprand(200, (200 + count + i)), \amp, amp, \rls, Pn(1, 1)).play});
		~addVolume.value(s_name, 0.1, 0.98);
	}
	{true} {"end of dissence reached".postln};

};

~setInsinuation = {
	|s_name, count|
	var c, dura, now, amp;
	amp = ~synthDict[\insinuation][\vol];
	postf("\nsetting %\t with count %\n", s_name, count);
	//base = ~reset[\insinuation03].value;
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 0) && (count < 30)} {
		count.do({|i|
			Pbind(\instrument, \insinuation,
				\lfreq, [exprand(100, 120 + i), exprand(200, (200 + i))],\amp, amp/2, \rls, Pn(1, 1)).play});
		~addVolume.value(s_name, 0.1, 0.98);
	}
{true} {"end of insinuation reached".postln};


};
~setLecture = {
	|s_name, count|
	var c, dura, now, amp;
	amp = ~synthDict[\lecture][\vol];
	postf("\nsetting %\t with count %\n", s_name, count);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 0) && (count < 30)} {count.do({|i|
			Pbind(\instrument, \lecture,
				\freq, [exprand(80, 90 + i), exprand(160, (160 + i))],\amp, amp/count, \filTime, 0.8, \rls, Pn(1, 1)).play});
	~addVolume.value(s_name, 0.1, 0.98);
	}

	{true} {"end of lecture reached".postln;};

};
~setConcession = {
	|s_name, count|
	var c, dura, amp;
	amp = ~synthDict[\lecture][\vol];
	postf("\nsetting %\t with count %\n", s_name, count);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{count < 30} {
		Pbind(\instrument, \concession, \buf, Pxrand(~buffers[\tonal], 10), \dur, 0.1, \amp, amp * dura).play(t)}
	{ (count >= 30) && (count.odd) } {
		Pbind(\instrument, \concession, \buf, ~buffers[\tonal][9], \dur, Pseq((0.8,0.78 ..0.04), 1) /2, \rate, Pseries(1.3, 0.15, count), \send, Pseq((-30, -28 .. -20).mirror,inf), \amp, 0.7).play(t);
		~addVolume.value(s_name, 0.1, 0.98);
	}
	{true} {"end of insinuation reached".postln};

};
~setPraise = {
	|s_name, count|
	var c, sl, dura, amp;
	postf("\nsetting %\t with count %\n", s_name, count);
	amp = ~synthDict[\praise][\vol];
	dura = Env.new([1,0], [count], [-2]).asPseg;
	// sl = ~synthDict['praise'][\synth];
	c = case
	{(count > 0) && (count < 30)} {5.do({|i|
		Pbind(\instrument, s_name,
			\freq, [exprand(120, (120 * 2)), exprand(240, (240 * 2))], \amp, 0.2, \pulRate, 4, \bpf, 500, \rls, Pn(1, 1)).trace.play});
	~addVolume.value(s_name, 0.1, 0.98);
	}
	{true} {"end of insinuation reached".postln;};

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

~allocateSynth ={
	|s_name, count|
	var c;
	postf("\nallocating to Synth %\t as %   with count %\n", s_name, s_name.class, count);
	postf("\ntotalUtts %\t", ~totalUtts);
	c = case
	{s_name == \lecture} {~setLecture.value(s_name, count);}
	{s_name == \praise} {~setPraise.value(s_name, count)}
	{s_name == \dissence} {~setDissence.value(s_name, count)}
	{s_name == \concession} {~setConcession.value(s_name, count)}
	{s_name == \insinuation} {~setInsinuation.value(s_name, count)}
	{true}{"end of allocation".postln};
	c.postln;
	// ~setCommon.value(~commonNow, count)

};
~setGlobal = {
	|s_name|
	var c;

	postf("\nglobal settings  %\t ", s_name);
	c = case
	{~totalUtts >= 30} {Scale.choose}
	{~totalUtts % 5 ==0} {Scale.choose}
	{~totalUtts >=20} {~sharedValues[\transpose] = -3}
	{~totalUtts >=15} {~sharedValues[\transpose] = 0}
	{~totalUtts >=10} {~sharedValues[\transpose] = -1}
	{~totalUtts >=4} {~sharedValues[\transpose] = 3}
	{true} {"end of global settings".postln};
	if (s_name != ~commonNow, {Pbindef(~commonNow).stop;
		~commonNow = s_name
	});
};

~setCommon = {
	|s_name, count|
	var c;
	postf("\nset common  with name \t  % and count % ", s_name,count);
	//ausschliessen dass ~commonNow Pbindef(~commonNow) beschickt
	c = case
	{s_name == \lecture} {Pbindef(\lecture, \modRate, count )}
	{s_name == \praise} {Pbindef(\praise, \fMul, count )}
	{s_name == \dissence} {Pbindef(\dissence, \ffreq, 200 + (count * 30) )}
	{s_name == \insinuation} {Pbindef(\insinuation, \noisFreq, count.reciprocal)}
	{s_name == \concession} {Pbindef(\concession, \rate, Pwhite(0.2, 1.8, inf) * (count/15))}
	{true}{"end of setCommon".postln};
};

~stopList = {arg list;
	postf("\nstopped list \t  % ", list);
	list.do{|s| s.set(\gate, 0) };
	list.clear;
};

)



currentEnvironment


// test
// http://sc3howto.blogspot.com/2010/06/pfunc.html  beispiel für ein Fade
3.do({|item, i| Pbind(\instrument, \insinuation, \amp, 0.4, \lfreq, [exprand(100, (200 + (item * 5))), 50], \rls, Pn(3, 1)).play})
(
var test;
test = ExpRand(40, 320).round(20);


)

~addVolume.value(\insinuation, 0.1, 0.98);
~addVolume.value(\praise, 0.1, 0.98);
~addVolume.value(\dissence, 0.1, 0.98);
~addVolume.value(\concession, 0.1, 0.98);
~addVolume.value(\lecture, 0.1, 0.98);

Pbindef(\praise).play(t, quant:1);
Pbindef(\praise, \amp, Pfunc({~fadeIn.value('praise', 1.1, 0.4)}));
Pbindef(\praise, \amp, Pfunc({~fadeOut.value('praise', 0.4, 0.3)}));


Pbindef(\praise).play;
Pbindef(\praise).stop;
Pbindef(\praise, \amp, Pgeom(0.01, 1.01, inf));
Pbindef(\praise, \pulRate, t.tempo);
Pbindef(\praise).isPlaying
Pbindef(\dissence).play(t, quant:1);
Pbindef(\dissence, \amp, Pgeom(0.4, 0.99, inf));
Pbindef(\dissence, \freq, Pkey(\freq))
Pbindef(\dissence).stop
Pbindef(\lecture).play(t, quant:1);
Pbindef(\lecture, \amp, 0.3);
Pbindef(\lecture, \midinote,Pxrand([28, 35, 40, 52, 47], inf));
Pbindef(\lecture).isPlaying
Pbindef(\insinuation).play(t, quant:1);
Pbindef(\insinuation).isPlaying;
Pbindef(\insinuation, \amp, Pgeom(0.5, 0.93, inf), \rls, 3.3);
Pbindef(\insinuation).stop
Pbindef(\concession).play(t, quant:1);
Pbindef(\concession, \amp, 0.4);
Pbindef(\concession).stop



b[\dry][0].play;
~synthDict['dissence']
Pbindef(\concession).stop;
Pbindef(\rausch).stop;
~setDissence.value('dissence', 9);
~setInsinuation.value('insinuation', 9);
~setLecture.value('lecture', 9);
~setConcession.value('concession', 9);
~setPraise.value('praise', 3);
Synth(\rauschen, [\ffreq, 1500])
~stopList.value(~synthDict[\dissence][\synth]);

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
		~disSynth.add(Synth(\dissence, args));
		~disSynth.postln;
        // 1.wait;
    }
};
)
(

)