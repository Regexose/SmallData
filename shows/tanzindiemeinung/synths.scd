SynthDef.new(\bellFm, {
    // Fm so wie https://www.youtube.com/watch?v=dLMSR2Kjq6Y -> 11:30
    //
    |freq=75, index=1, mRatio=1, cRatio=1, atk=0.4, rls=2, crv= 5|
    var sig, sig2, env, volMod, trem, bpf;
    env = EnvGen.kr(Env.perc(atk, rls, curve: crv), doneAction:2);
    volMod = SinOsc.kr(\vibF.kr(0.2), 0, \vibVol.kr(30))  ; // vol modulation
    trem = Vibrato.kr(\trmF.kr(1), \trmRate.kr(2), \trmDep.kr(0.0), \trmDel.kr(1), \onset.kr(2), \rateVar.kr(0.0), \varDur.kr(0));
    sig2 =  SinOsc.ar(freq * XLine.kr(mRatio, mRatio * cRatio, \fmDur.kr(0.02)), mul:freq * mRatio * index);
    sig = 3.collect({
		var spread, temp, bpf;
		spread = LFNoise1.kr(\spread.kr(0.05)).bipolar(\dev.ir(0.7)).midiratio;
		bpf = \bpf1.kr(200);
		temp = SinOsc.ar(freq * trem * spread + sig2, mul: 0.5 + volMod);
		temp = BPF.ar(temp, XLine.kr(bpf, bpf * \bpf2.kr(1) * spread.abs, \bpf3.kr(0.2)), \bpfQ.kr(0.9), \bpfMul.kr(2));
	}).sum;
    sig = Compander.ar(sig, sig, \thr.kr(0.65), 1, 0.3, 0.3, 0.4, \cgain.kr(1));
	//sig = BPF.ar(sig, \ffreq.kr(1000), \rq.kr(1.0));
    sig = sig * \fade.kr(1) * env * \amp.kr(0.1) ;
    sig = Pan2.ar(sig, \pan.kr(0.0));
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\fm, {
    |atk=0.01, rls=1.0|
    var  sig, env, mod;
	env = EnvGen.kr(Env([0, 1, 0], [atk, rls], \crv.kr(-4.0)), doneAction:2);
    mod = SinOsc.kr(\modRate.kr(1.2));
    sig = 5.collect({
		var fm, dev;
		dev = {ExpRand(\devMin.kr(0.999), \devMax.kr(1.001))};
		fm = SinOsc.ar(\fmFreq.kr(2000) * mod, mul:\fmVol.kr(20));
		VarSaw.ar((\freq.kr(100) * dev) + fm, {Rand(0, 2*pi)}, \filTime.kr(0.1), 1);
	}).sum;
    sig = (sig * \distort.kr(1.5)).tanh;
	sig = RLPF.ar(sig, \ffreq.kr(1000), \rq.kr(1.0));
    sig = Compander.ar(sig, sig, \thr.kr(0.65), 1, 0.3, 0.3, 0.4, \cgain.kr(1));
    sig = Pan2.ar(sig * (\amp.kr(0.1) * \fade.kr(1)), \pan.kr(1));
    sig = sig * env;
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\fmFine, {
	|vel=0.5|
	var f, ff0, ff1, ff2, car, mod0, mod1, mod2, env, sig, noiseLag;
	f = \freq.kr(1000);
	env = EnvGen.kr(
		Env.perc(\atk.kr(0.015) * Rand(0.95, 1.05), \rls.kr(2.02), curve: \crv.kr(-4)),
		doneAction:2) * vel;
	car = 3.collect({
		var dev;
		dev = {ExpRand(\devMin.kr(0.99), \devMax.kr(1.01))};
		ff0 = f * (\fratio0.kr(1)) // ffo-ff2 ratios should be integer to keep pitch perception
		* dev.dup;        // However some randomization adds a little nice dirt
		ff1 = f * (\fratio1.kr(1))
		* dev.dup;
		ff2 = f * (\fratio2.kr(4))
		* dev.dup;
		mod0 = SinOsc.ar(ff0, mul: ff0 * \modInd0.kr(1)) * env.pow(0.8); // mod indices correlate with env to emulate brightness
		mod1 = SinOsc.ar(ff1, mul: ff1 * \modInd1.kr(0.6) ) * env.pow(1.4);
		mod2 = SinOsc.ar(ff2, mul: ff2 * \modInd2.kr(0.3))  * env.pow(2.5);
		noiseLag = 0.001 * {Rand(0.9, 1.1)};
		SinOsc.ar(f + [mod0, mod1, mod2].sum
			+ WhiteNoise.ar(f/8 !2).lag(noiseLag))

	}).sum;
	car = HPF.ar(car * env.pow(0.5), f);
	car = RLPF.ar(car, \ffreq.kr(1000), \rq.kr(1.0));
	sig = car * \distort.kr(1.0).tanh;
	sig = sig * \amp.kr(0.3) * \fade.kr(1);
	sig = Pan2.ar(sig, \pan.kr(0.0));
	Out.ar(\out.kr(0), sig)
}).add;

// ienv tutorial https://www.youtube.com/watch?v=5vltzRNQnbo&t=2258s   36:50
SynthDef.new(\bass, {
	|gate = 1, freq=100|
	var  sig, env, ienv, clean, cleanEnv, volMod, fm, fmFreq, slide;
	env = EnvGen.kr(Env.adsr(\atk.kr(0.01), \dec.kr(0.2), \sus.kr(1.0), \rls.kr(1.0), curve:\crv.kr(-4.0)), gate, doneAction:2);
	ienv = Env([1, \ipeak.kr(5), 1], [\iatk.kr(0.01), \irls.kr(1.0)], [1, \icrv.kr(-4.0)]).ar;
	volMod = SinOsc.kr(\modRate.kr(1.2), \modPhase.kr(pi/2));
	slide = XLine.kr(1, \slide1.kr(1.0), \slide2.kr(1.0), \slide3.kr(1));
	fmFreq = freq * \fmratio.kr(1);
	fm = SinOsc.ar(fmFreq * slide, mul: fmFreq * ienv);
	sig = 4.collect({
		var dev;
		dev = {ExpRand(\devMin.kr(1.0), \devMax.kr(1.0))};
		SinOscFB.ar((freq * dev) +fm , \oscFB.kr(pi/4), \oscVol.kr(1.0));
	}).sum;
	sig = (sig) * env * volMod;
	sig = sig * \distort.kr(1.5).tanh;
	sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(1));
	sig = Pan2.ar(sig * (\amp.kr(0.1) * \fade.kr(1)), \pan.kr(1));
	Out.ar(\out.kr(0), sig );
}).add;


SynthDef(\sn1, {
	|freq = 800, ampdecay = 0.2, out = 0|
    var  sig, ghost, gEnv, snEnv, pEnv;
    snEnv = EnvGen.kr(Env.perc(0.001, ampdecay), doneAction:0);
    pEnv = EnvGen.kr(Env.perc(0.005, \pDecay.kr(3.1)), doneAction:2);
    gEnv =  EnvGen.kr(Env.perc(\atk1.kr(0.01), \rls1.kr(0.4), 1.0, \crv1.kr(-4.0)));
	ghost = 3.collect({
		|n|
		var temp, dev;
		dev = {ExpRand(0.6, 1.5)};
		temp = Blip.ar(\ghosts.kr(20) * dev, \numharm.kr(100)) * dev;

	}).sum;
    ghost = ghost * gEnv * \distort.kr(2).tanh;
	sig = WhiteNoise.ar(1) * snEnv;
	sig = RHPF.ar(sig, \ffreq.kr(1000), 0.4);
	sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(1));
	sig = [sig + ghost] * \amp.kr(0.3) * \fade.kr(1);
   Out.ar(out, sig!2);
}).add;

//https://www.youtube.com/watch?v=xYc7_PbbtuE&t=1579s  ab 5:00
SynthDef(\kik2, {
	var sig;
	sig = SinOsc.ar(\freq.kr(60) * (1 + (8 * Env.perc(0, \sweep.kr(0.06), curve:-4).ar)) * XLine.ar(1, 0.5, 1));
	sig = sig + (SinOsc.ar(XLine.ar(4000, 50, 0.01) * Env.perc(0.0001, 0.01).ar * \timb1.kr(-5).dbamp)); // punch
	sig = sig + (BPF.ar(Hasher.ar(Sweep.ar), 10120, 0.5) + Env.perc(0.001, 0.03).ar * \timb2.kr(-8).dbamp); // snare
	sig = sig * (1 + (2 * Env.perc(0.001, 0.2).ar));
	sig = (sig * \dist.kr(0).dbamp).tanh;
	sig = sig * Env.perc(0.001, \rls.kr(1.3), curve: -8).ar(Done.freeSelf);
	sig = sig * \amp.kr(0.3) * \fade.kr(1);
	sig = Pan2.ar(sig, \pan.kr(0));
	Out.ar(\out.kr(0), sig);
}).add;

//https://www.youtube.com/watch?v=xYc7_PbbtuE&t=1579s  ab 30:00
SynthDef(\sn2, {
	var sig;
	sig = SinOsc.ar(\freq.kr(200) * (1 + (2* Env.perc(0.001, \sweep.kr(0.1)).ar)) * [1, 2.3, 3.5, 5.8]); // multichannel
	sig = sig * Env.perc(0, [2, 0.4, 0.2, 0.1]).ar; // multichannel
	sig = sig * [0, -20, -12, -24].dbamp; // multichannel
	sig = sig.sum;
	sig = sig + (SinOsc.ar(XLine.ar(3000, 100, 0.03)) * Env.perc(0.01, 0.03).ar); // klick
	sig = sig + (BPF.ar(Hasher.ar(Sweep.ar), 2120, 0.3) + Env.perc(0.05, 0.1).ar * \shaper1.kr(0.5)); // pumps from 1.0 on
	sig = sig + (BPF.ar(Hasher.ar(Sweep.ar), 4120, 0.6) + Env.perc(0.003, 0.15).ar * \shaper2.kr(0.5));// brightness
	sig = sig + ((sig * \dist1.kr(13).dbamp).tanh * \dist2.kr(-10).dbamp); // paralell distortion
	sig = sig * Env.perc(0.001, 0.25, curve: -4).ar;
	sig = sig + ( GVerb.ar(sig, 16, 2) * -30.dbamp);
	sig = sig * Env.perc(0.001, \rls.kr(1.3), curve: -4).ar(Done.freeSelf);
	sig = sig * \amp.kr(0.75) * \fade.kr(1);
	sig = Pan2.ar(sig, \pan.kr(0));
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\percImp, { |accent=0, decayScale=1|
	var env, sig, exc;
    exc = PinkNoise.ar(\carAmp.kr(0.5)) * Decay2.kr(Impulse.kr(0.01), 0.01, 0.05);
    env = EnvGen.kr(Env.perc(\atk.kr(0.01), \rls.kr(1.8), 1.0));
    sig = 3.collect({
		Klank.ar(`[
		{ ExpRand(\freq.kr(80), \maxfrq.kr(1000)) }!2,
        1 !2,
		{ ExpRand(\minRing.kr(0.1),\maxRing.kr(0.4)) }!2
    ], exc, accent + 1, \frqOff.kr(0.0), decayScale);// accent ist die höhe, decayScale die Länge des Sounds
	}).sum;
	sig = sig * env * \amp.kr(0.1) * \fade.kr(1.0);
    DetectSilence.ar(sig, doneAction: Done.freeSelf);
    sig = Pan2.ar(sig,  \pan.kr(0.0));
    Out.ar(\out.kr(0), sig);
}).add;


// Granular Synth

SynthDef(\tgrains, {
	var sig, env;
	env = Env([0,1,1,0], [\atk.ir(1),\sus.ir(4),\rls.ir(1)], [1,0,-1]).kr(2);

	sig = TGrains.ar(
		numChannels: 2,
		trigger: Dust.kr(\dens.kr(40)),
		bufnum: \buf.kr(0),
		rate: \rate.kr(1) * \harm.kr([-9, -7, -4, 0]).midiratio,
		centerPos: \pos.kr(0.5),
		dur: \grainDur.kr(1.5),
		pan: 0,
		amp: \grainAmp.kr(1),
	);

	sig = sig * env * \amp.kr(1);
	Out.ar(\out.kr(0), sig);
}).add;


// wavetable https://www.youtube.com/watch?v=5krJVMxCr8s&t=810s ab 31:00 (für Feedback) und 46:30 für pad sound

SynthDef.new(\oscfm, {
	var sig, env, f;
	f = \freq.kr(200);
	//a chorus of 5 slightly detuned voices
	sig = 5.collect({
		var spread;
		spread = LFNoise1.kr(\spread.kr(0.05)).bipolar(\dev.ir(0.7)).midiratio;
		//carrier
		Osc.ar(\buf.ir(0), f * spread);
	}).sum;
	env = Env(
		[0,1,0],
		[\atk.ir(0.02), \rel.ir(0.5)],
		[\atkcrv.ir(1), \relcrv.ir(-3)]
	).ar(2);
	sig = BPF.ar(sig, \ffreq.kr(1000), \rq.kr(1.0));
	sig = Pan2.ar(sig, \pan.ir(0), \amp.kr(0.2) * \fade.kr(0.5));
	sig = sig * env;
	Out.ar(\out.ir(0), sig);
}).add;



