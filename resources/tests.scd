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
s.defaultGroup.freeAll

~isPrelude = false
~isPrelude = true

~circleRamp.()
(
// quadro tests
~modelKlank.(\ins)
~modelKlank.(\con)
~modelKlank.(\lec)
~modelKlank.(\pr)
~modelKlank.(\dis)

~vbapKlank.(\ins)
~vbapKlank.(\lec)
~vbapKlank.(\con)
~vbapKlank.(\pr)
~vbapKlank.(\dis)

~modelGrains.(\ins)
~modelGrains.(\pr)
~modelGrains.(\dis)
~modelGrains.(\lec)
~modelGrains.(\con)
)

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






~allocate.(\dis, 1);
~allocate.(\ins, 1);
~allocate.(\lec, 3);
~allocate.(\pr, 1);
~allocate.(\con, 1)

