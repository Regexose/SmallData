(
patterns: (
	con0: (
		instrument: 'percImp',
		midinote: ~melos.melo.con,
		dur: Pseq(~melos[\duras][\con], inf),
		amp:Pfunc({~melos.amps.con}),
		fade: 1,
		accent: Pseq([Pseq([0, -0.01, 0, 0.5, 0, 0.05, 0, -0.02], 4)], inf),
		decayScale: 20,
		maxfrq: 600,
		atk: 0.5,
		rls: 6,
		frqOff: Pseq( [Pseq([0, -300, 0, 800, -100, 0, 0, -500],4)], inf),
		out:~ch4.inbus
	),
	con1: (
	    instrument: 'percImp',
		midinote:  ~melos.melo.con,
		amp: Pfunc({~melos.amps.con}),
		dur: Pseq(~melos[\duras][\con], inf),
		fade:  Pseq([Pseq([0.9, 0.2, 0.2, 0.9, 0.2, 0.2, 0.9, 0.2], 4)], inf),
		accent: Pseq([
			Pseq([0, -0.01, 0, 0.5, 0, 0.05, 0, -0.02], 1),
			Pseq([0, -0.01, 0, 0.5, 0, 0.05, 0, -0.02], 4),
		], inf),
		decayScale: Pkey(\accent) + 0.3,
		minfrq:  Pseq([Pseq([300, 300, 300, 500, 300, 300, 300, 300], 4)], inf),
		maxfrq: Pkey(\minfrq) +300,
		frqOff: Pseq( [Pseq([0, -300, 0, 800, -100, 0, 0, -500],4)], inf)

	),

	con10: (
		instrument: 'bellFm',
		midinote: ~melos[\melo][\cad01],
		dur: Pseq([2, 2, 1, 1], inf),
		amp: Pfunc({~melos.amps.con}),
		fade: 0.22,
		thr: 0.5,
		cgain: 1,
		pan: 0,
		atk: 0.1,
		rls: 0.7,
		vibF: 0.2,
		vibVol: 30,
		dev: 0.04,
		spread: 0.02,
		bpf1: 300,
		bpf2: 5,
		bpf3: 0.3,
		bpfQ: 0.9,
	),

	con11: (
		instrument: 'bellFm',
		midinote:  ~melos.meloBase.con11,
		amp:Pfunc({~melos.amps.con}),
		dur: Pseq([Pn(1, 6), Pn(0.25, 8)], inf),
		fade: 0.5,
		thr: 0.5,
		cgain: 1,
		pan: 0,
		atk: 0.05,
		rls: 0.15,
		vibF: 0.8,
		vibVol: 40,
		dev: 0.08,
		spread: 0.07,
		bpf1: 600,
		bpf2: 5,
		bpf3: 0.3,
		bpfQ: 0.9,

	),

	con20: (
		instrument: 'percImp',
		dur: Pseq(~melos[\duras][\con], inf),
		amp: Pfunc({~melos.amps.con}),
		fade: 0.5,
		pan: 0,
		accent: 0,
		decayScale: 1,
		minfrq: 80,
		frqOff: 0,
	),

	con21: (
		instrument: 'percImp',
		dur: Pseq(~melos[\duras][\con], inf),
		amp:  Pfunc({~melos.amps.con}),
		fade: 0.5,
		pan: 0,
		accent: 0,
		decayScale: 1,
		minfrq: 80,
		frqOff: 0,
	),
)
)
