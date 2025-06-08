(
~sim = Routine(
    { loop ( {
        ~mock.();
        [3.76, 3.5].choose.wait;
		//"mocked" .postln;
        }
) }).play;
)


~sim.stop
s.makeWindow

 Synth(\sampSt, [\buf, ~buffers[\atmos][\rain], \atk, 2.5, \rls, 12, \amp, 1 ])
Pbindef.all.do(_.stop)

 ~mum.(~cat, ~uttsPerMinute[~cat], 0.25);
(
//Zugriff auf Synths
var synthArgs;
SynthDescLib.global.browse;
SynthDescLib.global.synthDescs.at(\bellFm)
SynthDescLib.at(~states.pr.pr0.instrument).controlNames;
SynthDescLib.global.synthDescs.at(~states.pr.pr10.instrument);
synthArgs = SynthDescLib.at(~states.pr.pr0.instrument).controlDict.collect(_.defaultValue);
synthArgs.postln;
Synth(~states.pr.pr0.instrument, [\freq, 300]);
)
(
var buf, start, dur, end, opm;
opm = 10;
buf = ~buffers[\catSampEn];
start = opm.linlin(0, 10, 0, buf.numFrames-1);
dur = opm.linlin(0, 10, 1000, buf.numFrames/2);
x = Synth(\brPhsr, [\buf, buf, \start, start, \end, start+dur]);
)

~ch3.level
(
~b = ~buffers[\hits][\SnoopSetsUp];
~hitPlay = Synth(\hitSt, [\buf, ~hitSample.normalize, \amp, 0.6, \start, 0, \end, ~hitSample.numFrames, \rls, 7])
~hitPlay.set(\amp, 0.5)
~hitPlay.set(\harm, 5)
~hitPlay.set(\gate, 1)
~hitPlay.release(2)
Pbindef(\bass).play(~t, quant:8)

)
(
Pbindef(\hh01, \dur, 0.25, \freq, 600, \maxFreq, 1300, \fade, 1).play(~t, quant:8);
Pbindef(\kik02).play(~t, quant:8);
Pbindef(\kik02, \freq, ~melos.melo.kik01, \sweep, 0.09, \timb2, -12, \timb1, -12, \rls, 2, \lpf, 1300, \thr, 0.85, \cgain, 1.3).quant_(4);
Pbindef(\sn01, \freq, Pseq([ \, 67, \, 67, \, 67, \, 67, \, 67, 67, \, 67, \, 67, \, 67 ], inf), \dur, 0.5).play(~t, quant:8);
Pbindef(\sn01, \shaper1, 2.2, \shaper2, 2.2)
Pbindef(\bass, \oscFB, pi *3/4).quant_(8)
Pbindef(\bass, ).isPlaying;
Pbindef(\hh01, \dur, 0.25, \freq, 600, \maxFreq, 1300, \fade, 1).quant_(8);
Pbindef(\kik02, \freq, ~melos.melo.kik02, \timb1, -3, \timb2, -16, \sweep, 0.03, \rls, 2, \dist, 2, \amp, 0.65).quant_(8);
Pbindef(\sn01, \freq, ~melos.melo.sn02, \dist1, 13, \dist2, -4, \rls, 2 ).quant_(8);
Pbindef(\hh01, \decayScale,1 , \freq, 200, \maxfrq, 800, \minRing, 0.1, \maxRing, 1, \dur, 0.25, \accent, 3);
Pbindef(\con);
Pbindef(\bass, \midinote, Pseq([36, 39, 36, 36, 36, 36, 36, \ ], inf), \dur,  Pseq([0.5, 0.5, 0.5, 0.75, 0.75, 0.25, 0.75, 0.25], inf)).play(~t);
Pbindef(\pr, *~states[\pr][\pr20].asPairs).play(~t);
Pbindef(\dis, *~states[\dis][\dis20].asPairs).play(~t);
Pbindef(\ins, *~states[\ins][\ins20].asPairs).play(~t);
Pbindef(\pr, *~states[\lec][\lec20].asPairs).play(~t);
Pbindef(\pr, *~states[\pr][\pr20].asPairs).play(~t);
Pbindef(\pr, *~states[\pr][\pr20].asPairs).play(~t);
Pbindef(\dis, \rls, 0.2, \vibF, 0.2, \vibVol, 90,  \index, 9);
Pbindef(\dis, \rls, 0.6, \vibF, 3, \vibVol, 10, \fmDur, 0.05, \index, 1, \mRatio, 1, \cRatio, 2, \bpf1, Pn(Pgeom(1500, 0.8, 16), inf), \bpf2, 6, \crv, 5 );
Pbindef(\pr, \rls, 0.03, \vibF, 1, \vibVol, 20, \fmDur, 0.04, \index, 1, \mRatio, 1, \cRatio, 0.5, \bpf1, Pn(Pgeom(150, 1.05, 16), inf), \bpf2, 1, \crv, -5, \spread, 0.3, \dev, 0.9)
Pbindef(\con).play(~t.con);
Pbindef(\con, \rls, 0.6, \vibF, 12, \vibVol, 40, \fmDur, 0.1, \index, 1, \mRatio, 2, \cRatio, 3, \bpf1, Pn(Pgeom(3000, 0.93, 16), inf), \bpf2, 3, \spread, 0.3, \dev, 0.9, \crv, -5);
Pbindef(\ins, \rls, 1.2, \vibF, 1, \vibVol, 50,  \index, 1, \mRatio, 1, \cRatio, 1, \bpf1, Pn(Pgeom(400, 1.1, 16), inf), \bpf2, 2, \fmDur, 0.04);
Pbindef(\lec, \rls, 0.5, \vibF, 3, \vibVol, 10, \fmDur, 0.05, \index, 1, \mRatio, 1, \cRatio, 2, \bpf1, Pn(Pgeom(2500, 0.8, 16), inf), \bpf2, 6, \bpf3, 0.06, \crv, 5);

)
Pbindef.all.do(_.stop)
Pbindef(\sn01, \shaper1, 0.1, \shaper2, 0.8, \rls, 0.1)
Pbindef(\kik02, \timb1, -1, \timb2, -2, \rls, 1, \amp, 0.5, \dist, 3, \sweep, 0.1, \lpf, 2000)

(
var n = 23;
~totalUtts = 70;
~mock.();
/*~allocate.(\dis, n);
~allocate.(\ins, n);
~allocate.(\lec, n);
~allocate.(\pr, n);
~allocate.(\con, n);*/
s.makeWindow

~allocate.(\dis, 40);
~allocate.(\ins, 41);
~allocate.(\lec, 40);
~allocate.(\pr, 40);
~allocate.(\con, 55)

~percTest = {
    |count=40, case_count=1, melkick, durkick, melsnare, dursnare,  melbass, durbass, melhh|
    var kicks, durkicks, snares, dursnares, basses, durbasses;
    kicks = [\kik01, \kik02, \kik03, \kik04, \kik05, \kik10].collect({|n| ~melos.melo[n]});
    durkicks = [\kik02, \kik02, \kik03,\kik04,\kik05,\kik10].collect({|n| ~melos.dur[n]});
    snares = [\sn02, \sn02,\sn03,\sn04,\sn05,\sn06].collect({|n| ~melos.melo[n]});
    dursnares = [\sn02, \sn02,\sn03,\sn04,\sn05,\sn06].collect({|n| ~melos.dur[n]});
    basses = [\bass37, \bass35,\bass33,\bass25,\bass15,\bass10].collect({|n| ~melos.melo[n]});
    durbasses = [\bass23, \bass24, \bass20, \bass15,\bass10,\bass10].collect({|n| ~melos.dur[n]});
    Pbindef(\kik02, \freq, melkick, \dur, durkick, \dist, 1.5, \cgain, 2.5, \lpf, 2000, \timb1, -3).quant_(8);
    Pbindef(\sn01, \freq, melsnare, \dur, dursnare, \dist1, 13, \dist2, -4, \rls, 1 ).quant_(8);
    Pbindef(\hh01, \dur, Pif((count%3==0), 0.0625, 0.25), \decayScale, Pwhite(0.6, 1.2, inf),
        \carAmp, Pif((count%3==0), melhh, ~melos.melo.hh01), \fade, 1, \amp, 0.5,
    ).quant_(8);
    Pbindef(\bass, \dur, Pif(case_count.even, durbass, 0.25), \modRate, 1.5,
        \midinote, Pif(case_count.even, melbass, melbass),
        \rls, 1.5, \fmratio, 3, \slide1, 0.5, \distort, 1.5).quant_(8);
}

~percTest.(25, 6, ~melos.melo.kik07, ~melos.dur.kik07, ~melos.melo.sn02, ~melos.dur.sn02, ~melos.melo.bass25,  ~melos.dur.bass25, ~melos.melo.hh01 )
(
~isPrelude = false;
~mock.();
~totalUtts = 87;
[\kik02, \sn01, \hh01, \bass].do({|k| Pbindef(k).play(~t)});
Pbindef(\sn01).play(~t, quant:4)
Pbindef(\sn01).stop
~categoryTranslator.keys.do({|k| ~uttDict[k.asSymbol] = 24})
)
(
~categoryTranslator.keys.do({|k| ~uttDict[k.asSymbol] = 33});

~totalUtts = 108;
~setGlobal.()
)


~feedBackSounds.(~categorySymbols['praise']);
~feedBackSounds.(~categorySymbols['concession']);
~feedBackSounds.(~categorySymbols['lecture']);
~feedBackSounds.(~categorySymbols['insinuation']);
~feedBackSounds.(~categorySymbols['dissent']);

~melos.melo.dis00
~states.dis.dis00
~states.ins.keys.do{|k| ~states.ins[k][\midinote].postln}


~makePatternList.("note", "/Users/borisjoens/Documents/Projekte/Kommentariat/Meinungsorgel_Git/SmallData/shows/edge/midi/Bass23.mid", True)