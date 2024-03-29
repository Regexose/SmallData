(
patterns: (
	pr00: (
		instrument: 'bellFm',
		midinote: 55,
		amp: Pfunc({~melos.amps.pr}),
		fade: 0.2,
		dur: 8,
		index: 1,
		mRatio: 1,
		cRatio: 1,
		atk: 1,
		rls: 5,
		crv: 2,
		vibF: 0.2,
		vibVol: 1,
		trmF: 1,
		trmRate: 6,
		trmDep: 0.0,
		trmDel: 1,
		onset: 3,
		rateVar: 0.5,
		varDur: pi/4,
		spread: 0.05,
		dev: 0,
		out: ~ch2.inbus
	),
	pr05: (
		instrument: 'bellFm',
		midinote: 67,
		amp: Pfunc({~melos.amps.pr}),
		fade: 0.2,
		dur: 8,
		index: 1,
		mRatio: 1,
		cRatio: 1,
		atk: 1,
		rls: 5,
		crv: 2,
		vibF: 0.2,
		vibVol: 1,
		trmF: 1,
		trmRate: 6,
		trmDep: 0.0,
		trmDel: 1,
		onset: 3,
		rateVar: 0.5,
		varDur: pi/4,
		spread: 0.05,
		dev: 1.5,
		out: ~ch2.inbus
	),
	pr10: (
		instrument: 'fmFine',
		midinote: ~melos.melo.pr10,
		amp: Pfunc({~melos.amps.pr}),
		fade: 0.8,
		dur: 0.25,
		detune: 0,
		fratio0: 1, // Integer values for pitch accuracy
		fratio1: 1,
		fratio2: 1,
		fmVol: 10,
		devMin: 0.91,
		devMax: 1.01,
		distort: 1.0,
		thr: 0.65,
		cgain: 1.3,
		atk: 0.02,
		rls: 0.07,
		crv: -5,
		out: ~ch2.inbus
	),

	pr15: (
		instrument: 'bellFm',
		midinote: ~melos.melo.pr15,
		dur: 0.25,
		amp: Pfunc({~melos.amps.pr}),
		fade: 0.8,
		thr: 0.5,
		cgain: 1.5,
		pan: 0,
		atk: 0.02,
		rls: 0.09,
		vibF: 0.8,
		vibVol: 30,
		dev: 0.08,
		spread: 0.16,
		bpf1: 500,
		bpf2: 5,
		bpf3: 0.3,
		bpfQ: 0.9,

	),

	pr20: (
		instrument: 'fmFine',
		midinote: ~melos.melo.pr20,
		dur: ~melos.dur.pr20,
		amp: Pfunc({~melos.amps.pr}),
		fade: 0.8,
		detune: Pwhite( -10, 3, inf),
		fratio0: 1, // Integer values for pitch accuracy
		modInd1: Pwhite(0.1, 3, inf),
		fratio1: 1,
		modInd2: Pwhite(0.1, 3, inf),
		fratio2: 1,
		ffreq: 2500,
		distort: 1.0,
		atk: 0.02,
		protorls: 0.1,
		rls: 0.07,
		crv: 3,

	),
	pr40: (
		instrument: 'bellFm',
		midinote: ~melos[\melo][\pr25],
		detune: Pn(Pgeom(30, 0.89, 16),inf),
		dur: 0.25,
		amp:  Pfunc({~melos.amps.pr}),
		fade: 0.5,
		thr: 0.7,
		cgain: 1.4,
		pan: Pwhite(-0.7, 0.7, inf),
		atk: 0.03,
		rls: 0.05,
		crv: -5,
		vibF: 1,
		vibVol: 20,
		spread: 0.3,
		dev: 0.2,
		index: 1,
		mRatio: 1,
		cRatio: 0.5,
		bpf1: Pn(Pgeom(150, 1.05, 16), inf),
		bpf2: 1.5,
		bpf3: 0.06,
		bpfQ: 0.33,
		fmDur: 0.04,

	),


)

)