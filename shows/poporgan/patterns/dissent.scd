(
patterns:(

	dis0: (
		instrument: 'fm',
		midinote: ~melos.melo.dis,
		detune: 0,
		modRate: 0.4,
		fmVol: 10,
		devMin: 0.999,
		devMax: 1.0001,
		distort: 1.5,
		thr: 0.99,
		cgain: 1.0,
		atk: 0.02,
		rls: 0.17,
		crv: -5,
		dur: 0.25,
		amp: Pfunc({~melos.amps.dis}),
		fade: 0.8,
		sustain: 0.14,
		out: ~ch1.inbus
	),

	dis1: (
		instrument: 'fm',
		midinote: ~melos.melo.dis,
		amp: Pfunc({~melos.amps.dis}),
		fade: 0.8,
		detune:0,
		modRate: 0.4,
		fmVol: 10,
		devMin: 0.999,
		devMax: 1.0001,
		distort: 1.5,
		thr: 0.99,
		cgain: 1.0,
		atk: 0.02,
		rls: 0.27,
		crv: -8,
		dur: 0.25,
		sustain: 0.14

	),

	dis05: (
		instrument: 'fm',
		midinote: ~melos.melo.dis05,
		dur: 0.25,
		amp: 0.1,
		fade: 0.8,
		thr: 0.5,
		cgain: 1,
		pan: 0,
		atk: 0.05,
		rls: 0.12,
		vibF: 0.6,
		vibVol: 30,
		dev: 0.08,
		spread: 0.5,
		bpf1: 300,
		bpf2: 5,
		bpf3: 0.3,
		bpfQ: 0.9,

	),
	dis10: (
		instrument: 'quitt',
		midinote: ~melos[\melo][\dis10],
		dur: 1,
		amp:  Pfunc({~melos.amps.dis}),
		fade: Pkey(\midinote).lincurve(20, 100, 0.75, 0.25, -4),
		thr: 0.5,
		cgain: 2,
		pan: 0,
		atk: 0.1,
		rls: 0.9,
		minfreq: 100,
		maxfreq: 1000,
		ffreq: 600,
		width: 0.4,
		pulseMul: 0.15,

	),
	dis16: (
		instrument: 'quitt',
		midinote: ~melos.melo.dis20,
		dur: 0.25,
		amp: Pfunc({~melos.amps.dis}),
		fade: 0.9,
		thr: 0.5,
		cgain: 3,
		pan: 0,
		atk: 0.02,
		rls: 0.14,
		width: 0.4,
		detune: Pn(Pgeom(30, 0.89, 16),inf),
		gendAmp: 0.9,
		pulseMul: 0.35,
		lag: 0,
		ffreq: 2000,
		rq: 0.8,
		width: 0.3,
	),

	dis21: (
		instrument: 'fm',
		midinote:~melos.meloPoporgan.dis21,
		dur: ~melos.duras.dis21,
		amp: Pfunc({~melos.amps.dis}),
		modRate: 0.4,
		fmVol: 10,
		devMin: 0.999,
		devMax: 1.0001,
		distort: 1.5,
		thr: 0.99,
		cgain: 1.0,
		atk: 0.02,
		rls: 0.1,
		crv: -5,
		fade: 0.8,
		sustain: 0.14
	),

)
)