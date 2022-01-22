/* ab minute 30
https://www.youtube.com/watch?v=ztVLMS15n1c&t=1585s
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
// Env([0, 1, 1, 0], [1.5, 0.2, 0.5, 2.5], [1, 0, -2, -3]).plot
// Env.adsr(1.5, 0.2, 0.8, 2.5, curve: -2.0).plot
// wenn gebooted wird, passiert alles folgende, Synthdefs etc
s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	s.sync;
	SynthDef.new(\rauschen, {
		var sig, env;
		env = EnvGen.kr(Env([0, 1, 1, 0], [\atk.kr(1.5), \dec.kr(0.2), \sus.kr(0.2), \rls.kr(2.0)], [1, 0, -2, -3]), doneAction:2);
		sig = BPF.ar(BrownNoise.ar(\mul.kr(0.4)), \ffreq.kr(666), \rq.kr(0.6));
		sig = sig * env * \amp.kr(0.2);
		Out.ar(\out.kr(~out), sig!2);
		Out.ar(\outfx.kr(~fxBus), sig * \send.kr(-30).dbamp);

	}).add;

	SynthDef.new('dissence', {
		var sig, gend, env;
		env = Env([0, 1, 1, 0], [\atk.ir(0.1), \sus.ir(0.2), \rls.ir(0.9)], \lin).ar(2);
		gend = BPF.ar(Gendy1.ar(1, 1, 1.0, 1.0, \minfreq.kr(400), \maxfreq.kr(1000), 0.3, \gendmul.kr(0.05), 5), \ffreq.kr(300), \rq.kr(0.9));
		sig = LFSaw.ar(\freq.kr(400), 0.0, \sawMul.kr(0.3)) + gend;
		sig = sig * env * \amp.kr(0.6);
		Out.ar(\out.ir(~out), sig!2);
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;

	SynthDef.new('lecture', {
		|gate = 1|
		var temp, sig, env, mod, ampMod;
		env = EnvGen.kr(Env.adsr(\atk.kr(0.01), 0.2, \sus.kr(3.0), \rls.kr(1.0), curve:\crv.ir(-4.0)), gate, doneAction: 2);
		mod = SinOsc.kr(\modRate.kr(1.2));
		// ampMod = Saw.kr(ExpRand(\ampMod1.kr(0.01), \ampMod2.ir(0.3))).range(0, 1);
		sig = VarSaw.ar({\freq.kr(80) * ExpRand(0.99, 1.01)}, 0, LFTri.kr(\filTime.kr(0.3)).range(0,1))!4;
		sig = sig * env;
		sig = Splay.ar(sig * \amp.kr(0.25));
		Out.ar(~out, sig);
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef('insinuation', {
		| gate = 1|
		var  sig, env, frq;
		env = EnvGen.kr(Env([0,1,1,0], [\atk.kr(0.05), 0.3, \sustain.kr(0.5), \rls.kr(0.4)], \linear), gate, doneAction: 2) ;
		frq = Lag.kr(\freq.kr(220), \slideTime.kr(0.6));
		sig = PMOsc.ar(frq, LFNoise2.ar(\noisFreq.kr(0.1), \maxF.kr(600)), SinOsc.ar(\ffreq.kr(3.0)), pmindex:\modWidth.kr(0.15), mul:\preamp.kr(0.6)) * \amp.kr(0.6)
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
		|gate=1, amp=0.3|
		var amp1, amp2, freq1, freq2, sig1, sig2, env1, env2;
		amp1 = LFPulse.kr(\ampHz.kr(4.0), 0, \pulWidth.kr(0.12)) * \ampScale.kr(0.01);
		amp2 = LFPulse.kr(\ampHz.kr(4.0), 0, \pulWidth.kr(0.12)) * \ampScale.kr(0.01);
		env1 = EnvGen.kr(Env.adsr(\atk.kr(0.5), 0.2, 0.7, \rls.kr(0.9)), gate, doneAction:2);
		env2 = EnvGen.kr(Env.adsr(\atk.kr(0.5), 0.1, 0.7, \rls.kr(0.9)), gate, doneAction:2);
		freq1 = LFNoise0.kr(\fRate.kr(4.0)).exprange(\freq.kr(40), \freq.kr(40) * \fMul.kr(80)).round(\freq.kr(40) * \rnd.kr(1.0));
		freq2 = LFNoise0.kr(\fRate.kr(4.0)).exprange(\freq.kr(40), \freq.kr(40) * \fMul.kr(80)).round(\freq.kr(40) * \rnd.kr(1.0));
		freq1 = freq1 * LFPulse.kr(\pulRate.kr(4.0));
		freq2 = freq2 * LFPulse.kr(\pulRate.kr(4.0));
		sig1 = RHPF.ar(Pulse.ar(freq1, \width.kr(0.4)), amp1, \ffreq.kr(90), \rq.kr(1.0)) * env1 * amp ;
		sig2 = RHPF.ar(Pulse.ar(freq2, \width.kr(0.4)), amp2, \ffreq.kr(90), \rq.kr(1.0)) * env2 * amp;
		sig1 = LPF.ar(sig1, \lpf.kr(120));
		sig2 = LPF.ar(sig2, \lpf.kr(120));
		Out.ar(~out, sig1);
		Out.ar(~out +1, sig2);
		Out.ar(\outfx.ir(~fx1Bus), [sig1, sig2] * \send.ir(-30).dbamp);
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

	b= Dictionary.new;
	~path = "/Volumes/Macintosh HD 2/projekte/Meinung/Instruments/SuperCollider/percSamples01";
	PathName(~path).entries.do({
		arg subfolder;
		b.add(
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
	s.options.numOutputBusChannels = 4;
	s.sync;

	t = TempoClock.new(90/60, ).permanent = true;

	/// Osc Section

	n = NetAddr("127.0.0.1", NetAddr.langPort); // local machine
	m = NetAddr("127.0.0.1", 5020); // beat send

	f = { |msg, time, addr|
		if(msg[0] != '/status.reply') {
			"time: % sender: %\nmessage: %\n".postf(time, addr, msg);
		}
	};
	//thisProcess.addOSCRecvFunc(f);
	// stop posting.
	thisProcess.removeOSCRecvFunc(f);
	OSCFunc.trace(false);

	['dissence', 'praise', 'insinuation', 'concession', 'lecture'].do(
		{
			arg catName;
			OSCdef.new(
				catName.asSymbol,
				{ arg msg;
					postf("\nnew cat: %", msg[1]);
					postf("\nnew count: %", msg[2]);
					~cat = msg[1];
					postf("\n~cat renamed %\n", ~cat);
					~allocateSynth.value(msg[1], msg[2]);
				},
				catName
			);
	});

	OSCdef.new(
		\init,
		{arg msg;
			postf("\n init %\t", msg);
			msg[1].postln;
			~allocateSynth.value(msg[1], msg[2])
		},
		'/init'
	);
	// https://composerprogrammer.com/teaching/supercollider/sctutorial/Technicalities/05%20Clocks%20and%20Scheduling.html
	t.schedAbs(t.nextTimeOnGrid, {m.sendMsg("/beat", (t.elapsedBeats.floor % 8).asInteger + 120); 1});


	~reset = Dictionary.new;
	~reset.add(\dissence01 -> {
			Pbind(
			\instrument, 'dissence',
			\dur, 1.0,
			\freq, 333,
			\ffreq, 300,
			\sawMul, 0.2
		);
	});
	~reset.add(\lecture02 -> {
		Pbind(
			\instrument, 'lecture',
			\dur, 2.4,
			\midinote, 36,
			\atk, 0.3,
			\rls, 1.6,
			\ampMod1, 0.1,
			\ampMod2, 0.1,
			\modRate, 0.3,
			\amp, 0.15
		);
	});
	~reset.add(\insinuation03 -> {
		Pbind(
			\instrument, 'insinuation',
			\dur, Pn(2, 1),
			\freq, 100,
			\modWidth, 0.5,
			\rls, 0.8,
			\atk, 0.5,
			\preamp, 2,
			\slideTime, pi,
			\ffreq, 10,
			\maxF, 50,
			\detune, 1
		);
	});

 	~reset.add(\concession04 -> {
		 (
			bd: Pbind(\instrument, 'concession', \buf, b[\bd][1], \dur, 5, \freq, 100),
			sn: Pbind (\instrument, 'concession', \buf, b[\sn][0], \dur, 3, \freq, 600),
			dry: Pbind(\instrument, 'concession', \buf, b[\dry][0], \dur, 1,  \freq, 440),
			hh: Pbind(\instrument, 'concession', \buf, Pxrand(b[\hh], inf), \dur, 1.5, \freq, 1200),
			tonal: Pbind(\instrument, 'concession', \buf, Pxrand(b[\tonal], inf), \dur, Pwhite(0.1, 0.3, inf)),
		)
	});

	~reset.add(\praise05-> {
		Pbind(
			\instrument, 'praise',
			\dur, 1,
			\ampHz , 0.1,
			\ampScale, 0.03,
			\midinote, 80,
			\fMul, 5,
			\pulWidth, 0.24,
			\fRate, 1,
			\width, 0.3,
			\amp, 0.6,
			\atk, 0.05,
			\rls, 1.9,
			\ffreq, 90,
			\rq, 0.3,
			\pulWidth, 5,
			\pulRate, 0.1,
			\lpf, 100
		)
	});

	~reset.add(\rauschen-> {
		Pbind(
			\instrument, \rauschen,
			\dur, 6,
			\ffreq, Pseq([666, 150], inf),
			\amp, 0.8
		)
	});

	s.sync;
	"done".postln;
}
);

)


////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

/* Das Soundwesen
*/
// test

b[\dry][0].play;

/// set functions
(
~setDissence = {
	|s_name, count|
	var c, dura, now, base;
	postf("\nsetting %\t with count %\n", s_name, count);
	base = ~reset[\dissence01].value;
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 0) && (count < 2)} {
		now = Pbindf(base, \amp, Pkey(\amp)* dura)}
	{(count >= 2) && (count < 5) } {
		now = Pbindf(base, \dur, Pn(1.5, count), \atk, 0.6, \rls, 6.2, \amp, 0.25 * dura, \send, -35)}
	{(count >= 5) && (count < 10) } {
		now = Pbindf(base, \dur, Pn(1.4, count), \atk, 0.4, \rls, 4.2, \freq, 666, \minffreq, 600, \amp, 0.25 * dura, \send, -35).trace}
	{count >= 10 } {
		var syn;
		now = Routine({
			5.do({
				var f =rrand(300, 666);
				syn = Synth(\dissence, [\freq, f, \minfreq, f *2,  \atk, 0.6, \rls, 2]);
				2.wait;
			})
	})}
	{true} {"end of dissence reached".postln};
	if(~dissencePlay.isPlaying, {~dissencePlay.stop});
	//postf("\ndissence running after %\t \n", ~dissenceNow.isPlaying);
	~dissencePlay = now.play(t, quant:1);

};

~setInsinuation = {
	|s_name, count|
	var c, dura, now, base;
	postf("\nsetting %\t with count %\n", s_name, count);
	base = ~reset[\insinuation03].value;
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 0) && (count < 5)} {
		var syn;
		now = Routine.new({
			count.do({
				syn = Synth(\insinuation, [\freq, 111 *count, \modWidth, 0.2 * count.reciprocal, \fShift, 66 * count, \outfx, ~fx2Bus, \send, -10.dbamp]);
				0.3.wait;
		})})
	}
	{(count >= 5) && (count < 10) } {
			now = Pbind(\instrument, \insinuation, \dur, Pseq([3.0, 4.0], count), \rls, Pkey(\dur, count) *1.2, \atk, Pseq([0.1, 0.7], count), \amp, 0.5).trace}
	{(count >= 5) && (count < 10) } {
		~insinuationNow = Pbind(\instrument, \insinuation, \dur, Pseq([3.0, 4.0], 5), \rls, Pkey(\dur, 5) * 0.4, \atk, Pseq([0.1, 0.7], 5)).trace}
	{count >= 10 } {
		~insinuationNow = Pbind(\instrument, \insinuation, \dur, 0.8, \rls, \midinote, Pseq([24,48], count), \atk, Pseq([0.1, 0.7], 5)).trace}
	{true} {"end of insinuation reached".postln};
	if(~insinuationPlay.isPlaying, {~insinuationPlay.stop});
	//postf("\n% running after %\t \n", s_name, ~insinuationNow.isPlaying);
	~insinuationPlay = now.play(t, quant:1);

};
~setLecture = {
	|s_name, count|
	var c, dura, base, now;
	postf("\nsetting %\t with count %\n", s_name, count);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	base = ~reset[\lecture02].value;
	c = case
	{(count > 0) && (count < 2)} {now = Pbindf(base, \amp, Pkey(\amp)*dura)}
	{(count >=2) && (count < 5)} {
		now = Pbindf(base, \dur, Pn(1.8, count), \midinote, Pxrand([60,48], count)).trace}
	{(count >= 5) && (count < 10) } {
		now = Pbindf(base, \dur, Pn(1.2, count), \midinote, Pseq([48, 32, 40, 35], inf)).trace}
	{(count >= 10) && (count < 30) } {
		now = Pbindf(base, \dur, Pn(1.2, count), \midinote, Pxrand([48, 32, 40, 35], count)).trace}

	{true} {"end of lecture reached".postln;};
	if(~lecturePlay.isPlaying, {~lecturePlay.stop});
	~lecturePlay = now.play(t, quant:1);

};
~setConcession = {
	|s_name, count|
	var c, dura, now, basePats;
	postf("\nsetting %\t with count %\n", s_name, count);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	basePats = ~reset[\concession04].value;
	c = case
	{count.even} {
		now = Pbindf(basePats[\tonal], \buf, Pxrand(b[\tonal], inf), \dur, Pwhite(0.1, 0.3, inf), \amp, 1.0 * dura)}
	{count.odd } {
			var tonal;
		tonal = Pbind(\instrument, \concession, \buf, b[\tonal][9], \dur, Pseq((0.8,0.78 ..0.04), 1), \rate, Pseries(1.3, 0.15, count), \send, Pseq((-30, -28 .. -12),inf), \amp, 0.7);
			now = Ppar([ tonal])}
	{true} {"end of insinuation reached".postln;};
	if(~concessionPlay.isPlaying, {~concessionPlay.stop});
	//postf("\n% running after %\t \n", s_name, ~concessionNow.isPlaying);
	~concessionPlay =  now.play(t, quant:1);

};
~setPraise = {
	|s_name, count|
	var c, base, now, dura;
	postf("\nsetting %\t with count %\n", s_name, count);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	base = ~reset[\praise05].value;
	c = case
	{(count > 0) && (count < 2)} {
		now = Pbindf(base, \amp, Pkey(\amp) *dura)}
	{(count >= 2) && (count < 5)} {
		now = Pbindf(base, \dur, Pn(0.98, count), \lpf, Pseries(100, 50, count), \midinote, Pseq([60,72,48], count)).trace}
	{(count >= 5) && (count < 10) } {
		now = Pbindf(base, \dur, Pseries(0.9, -0.05, count), \detune, Pseries(1.6, -0.3, inf), \lpf, Pseries(500, 50, count), \amp, Pkey(\amp) * dura)}
	{(count >= 10) && (count < 30) } {
		now = Pbindf(base, \dur, Pseq((0.4, 0.38 .. 0.1).reverse.mirror, count), \detune, Pwhite(0.95, 1.05, inf), \midinote, Pseq([24, 36], count) + count, \lpf, Pseries(400, 80, count), \amp, Pkey(\amp) * dura, \outfx, ~fx2Bus, \send, Pseq((-35, -33 .. -5), count)).trace}
	{true} {"end of insinuation reached".postln;};
	//if(~praisePlay.isPlaying, {~praisePlay.stop});
	postf("\n% running after %\t \n", s_name, ~praiseNow.isPlaying);
	~praisePlay = now.play(t, quant:1);
};

~allocateSynth = {
	|s_name, count|
	var c;
	postf("\nallocating to Synth %\t as %   with count %\n", s_name, s_name.class, count);
	c = case
	{s_name == \lecture} {~setLecture.value(s_name, count)}
	{s_name == \praise} {~setPraise.value(s_name, count)}
	{s_name == \dissence} {~setDissence.value(s_name, count)}
	{s_name == \concession} {~setConcession.value(s_name, count)}
	{s_name == \insinuation} {~setInsinuation.value(s_name, count)}
	{s_name == \rauschen} {~rauschenNow = ~reset[\rauschen].value;
		~rauschenPlay = ~rauschenNow.play(t, quant:1)}

	{true}{"end of allocation".postln};
	c.postln;

};

)

~reset[\dissence01].value.play(t, quant:1)
Synth(\rauschen, [\ffreq, 666])
currentEnvironment

(
g = Pbind(
	\instrument, 'dissence',
	\dur, Pseq([1, 0.5], inf),
	\amp, Pkey(\dur),
	\freq, Pwhite(90, 500, inf),
	\ffreq, Pkey(\freq) * 1.3,
	\minfreq, Pwhite(200, 800, inf),
	\maxfreq, Pkey(\minfreq) + 500,
	\atk, 0.03,
	\rls, 0.2
).play(t, quant:1)
)






~setDissence.value('dissence',10);
~setInsinuation.value('insinuation', 5);
~setLecture.value('lecture', 12)
~setConcession.value('concession', 7);
~setPraise.value('praise', 10);
(
~rauschenNow = ~reset[\rauschen].value;
~rauschenPlay = ~rauschenNow.play(t, quant:1)
)

d = nil;
~dissenceNow.isPlaying;
d = ~dissenceNow.asStream;
d.next(());

