(
patterns: (
	ins00: (
		instrument: 'bellFm',
		midinote: 57,
		amp: Pfunc({~melos.amps.ins}),
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
		dev: 01,
		out: ~ch3.inbus
	),
	ins05: (
		instrument: 'bellFm',
		midinote: 69,
		amp: Pfunc({~melos.amps.ins}),
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
		out: ~ch3.inbus
	),
	ins10: (
		instrument: 'fmFine',
		midinote: ~melos.melo.ins10,
		amp: Pfunc({~melos.amps.ins}),
		fade: 0.6,
		dur: 0.25,
		detune: Pwhite( -10, 3, inf),
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
		dur: 0.25,
		out: ~ch3.inbus

	),

	ins15: (
		instrument: 'oscfm',
		midinote: ~melos.melo.ins15,
		buf: Pfunc{~buffers[\wt]},
		amp: Pfunc({~melos.amps.ins}),
		dur: ~melos.dur.ins15,
		fade: 0.8,
		atk: 0.02,
		atkcrv: 0,
		rls: 0.1,
		rlscrv: -8,
		modfreq: 800,
		modamp: 100,
		spread: 5,
		dev: 0.7,

	),
	ins20: (
		instrument: 'fmFine',
		midinote: ~melos.melo.ins20,
		dur: ~melos.dur.ins20,
		amp: Pfunc({~melos.amps.ins}),
		fade: 0.5,
		detune: Pwhite( -1, 1, inf),
		fratio0: 1, // Integer values for pitch accuracy
		modInd1: Pwhite(0.1, 3, inf),
		fratio1: 1,
		modInd2: Pwhite(0.1, 3, inf),
		fratio2: 1,
        ffreq: 3500,
		distort: 1.0,
		thr: 0.65,
		cgain: 1.3,
		protorls: 0.001,
		atk: 0.02,
		rls: 0.15,
		crv: 3,

	),


	ins40: (
		instrument: 'bellFm',
		buf: Pfunc{~buffers[\wt]},
		midinote: ~melos[\melo][\ins25],
		detune: Pn(Pgeom(30, 0.89, 16),inf),
		dur: 0.25,
		amp: Pfunc({~melos.amps.ins}),
		fade: 0.5,
		thr: 0.7,
		cgain: 1.4,
		pan: Pwhite(-0.7, 0.7, inf),
		atk: 0.03,
		rls: 0.15,
		index: 1,
		mRatio: 1,
		cRatio: 1,
		vibF: 1,
		vibVol: 50,
		dev: Pn(Pgeom(0.2, 0.9, 16), inf),
		bpf1: Pn(Pgeom(400, 1.06, 16), inf),
		bpf2: 2,
		bpf3: 0.06,
		bpfQ: 0.33,
		fmDur: 0.04,
	),


)
)