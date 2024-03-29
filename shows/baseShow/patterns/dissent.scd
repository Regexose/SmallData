(
patterns:(

	dis0: (
		instrument: 'bellFm',
		midinote:  ~melos.melo.dis,
		dur: Pseq(~melos[\duras][\dis], inf),
		amp: Pfunc({~melos.amps.dis}),
		fade: 0.5,
		thr: 0.5,
		cgain: 1,
		pan: 0,
		atk: 1,
		rls: 2.7,
		vibF: 0.2,
		vibVol: 30,
		dev: 0.04,
		spread: 0.02,
		bpf: 300,
		bpf2: 10,
		bpf3: 4,
		bpfQ: 0.2,
		bpfMul: 10,
		mRatio: 0.8,
		cRatio: 1.05,
		fmDur: 4,
		out: ~ch1.inbus

	),

	dis1: (
		instrument: 'bellFm',
		midinote:  ~melos.melo.dis,
		dur: Pseq(~melos.duras.dis[..1], 1),
		amp: Pfunc({~melos.amps.dis}),
		fade: 0.5,
		thr: 0.5,
		cgain: 1,
		pan: 0,
		atk: 1,
		rls: 2.7,
		vibF: 0.6,
		vibVol: 30,
		dev: 0.08,
		spread: 0.5,
		bpf: 300,
		bpf2: 10,
		bpf3: 4,
		bpfQ: 0.2,
		bpfMul: 10,
		mRatio: 1,
		cRatio: 1,
		fmDur: 0,

	),

	dis10: (
		instrument: 'quitt',
		midinote: ~melos[\melo][\cad01],
		dur: Pseq([2, 2, 1, 1], inf),
		amp:  Pfunc({~melos.amps.dis}),
		fade: 0.22,
		thr: 0.5,
		cgain: 2,
		pan: 0,
		atk: 0.1,
		rls: 0.9,
		minfreq: 100,
		maxfreq: 1000,
		ffreq: 300,
		width: 0.4,
		pulseMul: 0.15,

	),

	dis11: (
		instrument: 'bellFm',
		midinote:  ~melos.meloBase.dis11,
		amp: Pfunc({~melos.amps.dis}),
		dur: Pseq([Pn(1, 6), Pn(0.25, 8)], inf),
		fade: 0.5,
		thr: 0.5,
		cgain: 1,
		pan: 0,
		atk: 0.061,
		rls: 0.14,
		vibF: 0.6,
		vibVol: 30,
		dev: 0.08,
		spread: 0.5,
		bpf: 300,
		bpf2: 10,
		bpf3: 4,
		bpfQ: 0.2,
		bpfMul: 10,
		mRatio: 1,
		cRatio: 1,
		fmDur: 0,

	),
	dis20: (
		instrument: 'quitt',
		midinote:  ~melos.melo.dis,
		amp:  Pfunc({~melos.amps.dis}),
		dur: Pseq(~melos[\duras][\dis], inf),
		fade: 0.5,
		thr: 0.5,
		cgain: 2,
		pan: 0,
		atk: 0.1,
		rls: 0.9,
		minfreq: 100,
		maxfreq: 1000,
		ffreq: 300,
		width: 0.4,
		pulseMul: 0.15,

	),
	dis21: (
		instrument: 'quitt',
		midinote: ~melos.melo.dis,
		amp: Pfunc({~melos.amps.dis}),
		dur: Pseq(~melos[\duras][\dis], inf),
		fade: 0.5,
		thr: 0.5,
		cgain: 2,
		pan: 0,
		atk: 0.8,
		rls: 2,
		minfreq: 100,
		maxfreq: 1000,
		ffreq: 300,
		width: 0.4,
		pulseMul: 0.15,

	),
	dis12: (
		instrument: 'quitt',
		midinote:  ~melos.melo.dis,
		amp: Pfunc({~melos.amps.dis}),
		dur: Pseq(~melos[\duras][\dis], inf),
		fade: 0.5,
		thr: 0.5,
		cgain: 2,
		pan: 0,
		atk: 0.8,
		rls: 2,
		minfreq: 100,
		maxfreq: 1000,
		ffreq: 300,
		width: 0.4,
		pulseMul: 0.15,

	),
)
)