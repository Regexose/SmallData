(
musar: (
    instrument: 'bell2',
    scale: Scale.chromatic,
    midinote: Pseq(~melos[\melo][\ruzhim01], inf) , // single notes
	dur: Pseq(~melos[\duras][\ruzhim01], inf),
	amp: 0.11,
    fade: 1,
    pan: 0,
	atk: 0.2,
	rls: 1.3,
    crv: 0,
	sus: Pkey(\dur)
),

musar2: (
    instrument: 'musar2',
    scale: Scale.chromatic,
    midinote: Pseq(~melos[\melo][\ruzhim01], inf), // akkorde
	dur: Pseq(~melos[\duras][\ruzhim01], inf) *2,
    amp: 0.15,
    atk: 0.07,
    sus: 0.99,
    rls: 0.5,
    crv: 0.5,
    modRate: 1,
    filTime: 0.12,
    thr: 0.8,
    cgain: 1,
    fade: 0.5,
    pan: 1,
    send: -35
),

pr: (
    instrument: 'bellFm',
	scale: Scale.chromatic,
    midinote: Pseq(~melos[\melo][\pr], inf) -12, // akkorde
	dur: 2,
	amp: 0.05,
    fade: 0.01,
    thr: 0.5,
    cgain: 2,
    pan: 0,
	atk: 0.8,
	rls: 2,
    vibF: 0.2,
    vibVol: 30,
    bpf1: 300,
    bpf2: 5,
    bpf3: 0.3,
     bpfQ: 0.9

),

dis: (
    instrument: 'bellFm',
	scale: Scale.chromatic,
    midinote: Pseq(~melos[\melo][\dis], inf) , // akkorde
	dur: 2,
	amp: 0.05,
    fade: 0.01,
      thr: 0.5,
    cgain: 2,

    pan: 0,
	atk: 0.8,
	rls: 2,
   vibF: 0.2,
    vibVol: 30,
    bpf1: 300,
    bpf2: 5,
    bpf3: 0.3,
     bpfQ: 0.9

),
//Env.linen(1, 1, 1, 1.0, 10).test.plot

ins: (
      instrument: 'bellFm',
	scale: Scale.chromatic,
    midinote: Pseq(~melos[\melo][\ins], inf) , // akkorde
	dur: 2,
	amp: 0.05,
    fade: 0.01,

      thr: 0.5,
    cgain: 2,
    pan: 0,
	atk: 0.8,
	rls: 2,
   vibF: 0.2,
    vibVol: 30,
      bpf1: 300,
    bpf2: 5,
    bpf3: 0.3,
     bpfQ: 0.9
),

lec: (
    instrument:'bellFm',
	scale: Scale.chromatic,
    midinote: Pseq(~melos[\melo][\lec], inf) , // akkorde
	dur: 2,
	amp: 0.05,
    fade: 0.01,

    thr: 0.5,
    cgain: 2,
    pan: 0,
	atk: 0.8,
	rls: 2,
   vibF: 0.2,
    vibVol: 30,
    bpf1: 300,
    bpf2: 5,
    bpf3: 0.3,
     bpfQ: 0.9
),

con: (
    instrument: 'bellFm',
	scale: Scale.chromatic,
    midinote: Pseq(~melos[\melo][\con], inf) , // akkorde
	dur: 2,
	amp: 0.05,
    fade: 0.01,

    thr: 0.5,
    cgain: 2,
    pan: 0,
	atk: 0.8,
	rls: 2,
    vibF: 0.2,
    vibVol: 30,
    bpf1: 1300,
    bpf2: 5,
    bpf3: 0.3,
     bpfQ: 0.9
),

perc1: (
    instrument: 'percImp',
    dur: Pwrand([0.125, 0.25, 1.0], [3, 2, 1].normalizeSum, inf),
    amp: 0.3,
	accent: Pseq([0.4, -0.4, -0.4], inf),
    decayScale: Pwrand([1.85, 2.7, 4.0], [1, 2, 5].normalizeSum, inf)

),
imp: (
    instrument:'impulse',
    carAmp: 0.1, // the amp of the carrier Noise Signal
    atk: 0.01,
    rls: 0.2,
    dens: 1, //wie oft kommt ein impulse
    knk: 1.0, //mul, wie laut ist der Impulse Max: 1.0
    shift: 0, // frequency shift, ist ein leichter Flangeartiger effekt
    eqfrq1: 2300, // Frequenz des BPF
    boost: 1.6, //mul des BPF
    thr: 0.4, //Compander Threshold
    cgain: 2.3, // compander makeup Gain
    cent:0.0, //Splay center
    amp: 0.1,
    fade: 1.0

),
drum: (
    instrument: 'sampSt',
    buf: ~buffers[\bd][7],
    send: -25,
    cgain:2.2,
    fade: 1

)

)
