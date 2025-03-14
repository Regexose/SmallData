(
~sim = Routine(
    { loop ( {
        ~mock.();
        [1.9, 1, 0.5, 2.5].choose.wait;
		//"mocked" .postln;
        }
) }).play;
)

~sim.stop

~upmMax = 30
~melos[\seqRates]
~isPrelude = false
~isPrelude = true

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
Pbindef(\hh01, \dur, 0.25, \freq, 600, \maxFreq, 1300, \fade, 1).play(~t, quant:8);
Pbindef(\kik02, \freq, ~melos.melo.kik02 *2, \dur, ~melos.dur.kik02).play(~t, quant:8);
Pbindef(\sn01, \freq, ~melos.melo.sn02, \dur, ~melos.dur.sn02, \pan, Pwhite(-1, 1, inf)).play(~t, quant:8);
Pbindef(\hh01, \dur, 0.25, \freq, 600, \maxFreq, 1300, \fade, 1).quant_(8);
Pbindef(\kik02, \freq, ~melos.melo.kik02, \timb1, -3, \timb2, -16, \sweep, 0.03, \rls, 2, \dist, 2, \amp, 0.65).quant_(8);
Pbindef(\sn01, \freq, ~melos.melo.sn02, \dist1, 13, \dist2, -4, \rls, 2 ).quant_(8);
Pbindef(\bass, \midinote, ~melos.melo.bass37, \dur, ~melos.dur.bass37, \dur, 0.5, \modRate, 1.5, \fmratio, 3, \rls, 2, \slide1, 0.9, \slide2, 1).play(~t, quant:8);
Pbindef(\hh01, \decayScale,1 , \freq, 200, \maxfrq, 800, \minRing, 0.1, \maxRing, 1, \dur, 0.25, \accent, 3);
Pbindef(\con);
Pbindef(\bass, \midinote, Pseq([36, 39, 36, 36, 36, 36, 36, \ ], inf), \dur,  Pseq([0.5, 0.5, 0.5, 0.75, 0.75, 0.25, 0.75, 0.25], inf));
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


(
var n = 23;
~totalUtts = 70;
~mock.();
/*~allocate.(\dis, n);
~allocate.(\ins, n);
~allocate.(\lec, n);
~allocate.(\pr, n);
~allocate.(\con, n);*/
Synth(\tgrainsMBS, [\buf, ~mbsGrain2, \pos, 0.03, \azi, 0.25, \rate, 1.0, \amp, 0.1, \grainDur, 0.02, \harm, [2, -3, 5, 1], \grainAmp, 0.3])
Synth(\tgrains, [\buf, ~mbsGrain2, \pos, 0.04, \grainDur, 0.01, \amp, 0.1, \azi, 1.5])

Pbindef(\samp,
    \instrument, \sampleGrains,
    \buf, Pfunc({~buffers[\sn].choose}),
    \dur, 0.3,
    \rls, 0.1,
    \azi, Pwhite(0.0, 1.5, inf),
    \ffreq, Pwhite(1200, 2400, inf),
    \rate, Pwhite(0.8, 1.4, inf),
    \amp, Pwhite(0.1, 0.4, inf)
).play

Pbindef(\samp, \amp, Pwhite(0.4, 0.6, inf), \rate, 1, \rls, 0.2, \ffreq, Pwhite(1200, 2400, inf), \rq, 0.4, \dur, 0.2, \azi, 0.5, \buf, Pfunc({~buffers[\himid].choose}) )
Pbindef(\samp).stop

s.defaultGroup.freeAll
~allocate.(\dis, 1);
~allocate.(\ins, 1);
~allocate.(\lec, 3);
~allocate.(\pr, 1);
~allocate.(\con, 1)

~melos.melo.dis00
~states.dis.dis00
~states.ins.keys.do{|k| ~states.ins[k][\midinote].postln}


~makePatternList.("note", "/Users/borisjoens/Documents/Projekte/Kommentariat/Meinungsorgel_Git/SmallData/shows/edge/midi/Bass23.mid", True)