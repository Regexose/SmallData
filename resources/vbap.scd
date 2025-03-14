
// vbap examples

// a = VBAPSpeakerArray.new(2, [0, 45, 90, 135, 180, -135, -90, -45]); // 8 channel ring
(
Server.default.options.outDevice_("Fireface 400 (BEF)");
Server.default.options.numOutputBusChannels_(4);
s.newBusAllocators;
ServerTree.removeAll; // löscht alle funktionen
s.waitForBoot({
    s.freeAll;
    Buffer.freeAll;
    s.sync;

    ~signal = Bus.audio(s, 1);
    ~panBus = Bus.control;
    ~widthBus = Bus.control.set(60);
    ~eleBus = Bus.control;
    ~buf = Buffer.read(s, "/Volumes/SSD_Sandisk/Kunst/Kommentariat/TestMultichannel/audio/EdgeMock_mon.wav");

    //a = VBAPSpeakerArray.new(2, [-30, 30, 130, -130]); // quadro
    a = VBAPSpeakerArray.new(3, [[-30, 0], [30,0], [130, 45]]); // 3 mal als 3D
    a.speakers[1].dump;
    b = Buffer.loadCollection(s, a.getSetsAndMatrices);
    s.sync;


    SynthDef(\sample, {
    |buf=0, gate=1, rate=1, start=0, end=(buf.numFrames-1)|
    var sig, ptr, env;
    ptr = Phasor.ar(0, BufRateScale.kr(buf)* rate * \harm.kr(0).midiratio, start=0, end, 0);
    env = EnvGen.kr(Env.asr(\atk.kr(0.01), 1, \rls.kr(1), -3), gate, doneAction:2);
    sig = BufRd.ar(1, buf, ptr);
    sig = sig * env * \amp.kr(0.3);
    Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef('VBAP4chan', { |azi = 0, ele = 0, spr = 0, width = 60, vbapBuf,
        buf=0, gate=1, rate=1, start=0, end=(buf.numFrames-1)|
        var panned, source;
        source = SinOsc.ar([440, 660], 0, Decay2.ar(Impulse.ar([1, 0.9]), 0.1, 0.2));
        azi = azi.circleRamp;
        panned = VBAP.ar(4, source, vbapBuf, [azi - (0.5 * width), azi + (0.5 * width)], ele, spr);
        [0, 1, 2, 4].do({arg bus, i; Out.ar(bus, panned[0][i])});
        [0, 1, 2, 4].do({arg bus, i; Out.ar(bus, panned[1][i])});

    }).add;

    SynthDef('VBAP4chan2', { |azi = 0, ele = 0, spr = 0, width = 60, vbapBuf,
        trg=4, punch=0.1, dec=0.9, freqScale=1, decayScale=0.1,
        amp=0.3, ffreq=2000, rq=0.2|
        var exc, sig, env, trig, freqMod, source, panned, freqs, amps, rings;
        freqs = NamedControl.kr(\freq, [80, 120, 350, 1010]);
        amps = NamedControl.kr(\level, [0.5, 0.24, 0.14, 0.423]);
        rings = NamedControl.kr(\ring, [0.1, 0.04, 0.04, 0.023]);
        //env = Env.perc(\atk.kr(0.01), \rls.kr(0.08), curve: \crv.kr(-4.0)).kr(2);
        trig = Dust.kr(trg);
        freqMod = TRand.kr( 1, 5, trig)  ;
        exc = WhiteNoise.ar(punch) * Decay2.kr(trig, 0.001, dec);
        sig = DynKlank.ar(`[
            freqs,
            amps.ampdb.normalizeSum,
            rings
    ], exc, freqScale, 0, decayScale);
        sig = sig * amp ;
        sig = RLPF.ar(sig, ffreq, rq);
        source = SinOsc.ar([440, 660], 0, Decay2.ar(Impulse.ar([1, 0.9]), 0.1, 0.2));
        azi = azi.circleRamp;
        panned = VBAP.ar(4, sig, vbapBuf, [azi - (0.5 * width), azi + (0.5 * width)], ele, spr);
        [0, 1, 2, 3].do({arg bus, i; Out.ar(bus, panned[0][i])}); // in der Liste sind einfach die Outbusse
        [0, 1, 2, 3].do({arg bus, i; Out.ar(bus, panned[1][i])});
    }).add;

   SynthDef('VBAP4chan3', { |azi = 0, ele = 0, spr = 0, width = 60, vbapBuf,
        trg=4, punch=0.1, dec=0.9, freqScale=1, decayScale=0.1,
        amp=0.3, ffreq=2000, rq=0.2|
        var exc, sig, env, trig, freqMod, source, panned, freqs, amps, rings;
        freqs = NamedControl.kr(\freq, [80, 120, 350, 1010]);
        amps = NamedControl.kr(\level, [0.5, 0.24, 0.14, 0.423]);
        rings = NamedControl.kr(\ring, [0.1, 0.04, 0.04, 0.023]);
        //env = Env.perc(\atk.kr(0.01), \rls.kr(0.08), curve: \crv.kr(-4.0)).kr(2);
        trig = Dust.kr(trg);
        freqMod = TRand.kr( 1, 5, trig)  ;
        exc = WhiteNoise.ar(punch) * Decay2.kr(trig, 0.001, dec);
        sig = DynKlank.ar(`[
            freqs,
            amps.ampdb.normalizeSum,
            rings
    ], exc, freqScale, 0, decayScale);
        sig = sig * amp ;
        sig = RLPF.ar(sig, ffreq, rq);
        source = SinOsc.ar([440, 660], 0, Decay2.ar(Impulse.ar([1, 0.9]), 0.1, 0.2));
        azi = azi.circleRamp;
        panned = VBAP.ar(3, sig, vbapBuf, [azi - (0.5 * width), azi + (0.5 * width)], ele, spr);
        [0, 1, 2].do({arg bus, i; Out.ar(bus, panned[0][i])}); // in der Liste sind einfach die Outbusse
        [0, 1, 2].do({arg bus, i; Out.ar(bus, panned[1][i])});
    }).add;

    s.sync;


});
)
// 2D quaadro
v = Synth(\VBAP4chan2, [vbapBuf: b.bufnum, azi: ~panBus.asMap, width: ~widthBus.asMap])
v.set(\trg, 14, \ffreq, 100, \freq, Array.fill(5, {exprand(80, 300)}), \amp, 0.1, \decayScale, 0.9, \freqScale, 0.3, \dec, 2)
~panBus.set(-70)
~widthBus.set(20)

// test them out
{loop{[-30, 0, 30, 130, -130].do({|ang| v.set(\azi, ang); 1.wait; }) }}.fork;
v.free

// 3D mit drei Lautsprechern
q = Synth(\VBAP4chan3, [vbapBuf: b.bufnum])
q.set(\ffreq, 2200, \trg, 20, \punch, 0.03)
q.set(\azi,-30, \ele, 45)

{loop{[[-30, 0], [30, 0], [130, 45], [-30, 0], [30, 45], [30, 0], [30, 45]].do({|ang| q.set(\azi, ang[0], \ele, ang[1]);
    {SinOsc.ar(30 + ang[1] * 100, 0, Env.perc(0.02, 0.2, 0.5).kr(2))}.play;
    1.wait}) }}.fork;
q.free




(

y = Synth(\sample, [\buf, ~buf, \start, 0, \end, ~buf.numFrames-1, \out, ~signal]);
x = { |azi = 0, ele = 0, spr = 0,
    rate=1, start=0, end=(~buf.numFrames-1), amp=0.3|
    var sig, ptr, env;
  /*  ptr = Phasor.ar(0, BufRateScale.kr(~buf)* rate, start, end, 0);
    //env = EnvGen.kr(Env.asr(\atk.kr(0.01), 1, \rls.kr(10), -3), gate, doneAction:2);
    sig = BufRd.ar(1, ~buf, ptr);
    sig = sig * amp;*/


    // mit ~signal.asMap versuchen
    sig = PinkNoise.ar(0.2);
    VBAP.ar(4, ~signal.asMap, b.bufnum, azi, ele, spr);
}.scope;
)



// try the spread
x.set(\azi, 110);
x.set(\spr, 100); // all speakers

x.free; b.free;

// 3D
a = VBAPSpeakerArray.new(3, [[-22.5, 14.97], [22.5, 14.97], [-67.5, 14.97], [67.5, 14.97], [-112.5, 14.97], [112.5, 14.97], [-157.5, 14.97], [157.5, 14.97],
	[-45, 0], [45, 0], [-90, 0], [90, 0], [-135, 0], [135, 0], [0, 0], [180, 0]]); // zig zag partial dome

b = Buffer.loadCollection(s, a.getSetsAndMatrices);

(
// pan around the circle up and down
x = { |azi = 0, ele = 0, spr = 0|
	var source;
	source = PinkNoise.ar(0.2);
	VBAP.ar(16, source, b.bufnum, LFSaw.kr(0.5, 0).range(-180, 180) * -1, SinOsc.kr(3, 0).range(0, 14.97), spr);
}.play;
)

