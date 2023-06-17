(
patterns: (
	ins0: (
		instrument: 'fm',
		midinote: ~melos.melo.ins,
		detune: 0,
		modRate: 0.4,
		fmVol: 10,
		devMin: 0.999,
		devMax: 1.0001,
		distort: 1.5,
		thr: 0.99,
		cgain: 1.0,
		atk: 0.02,
		rls: 0.07,
		crv: -3,
		dur: 0.25,
		amp: Pfunc({~melos.amps.ins}),
		fade: 0.8,
		sustain: 0.14

	),
	ins1: (
		instrument: 'fm',
		midinote: ~melos.melo.ins,
		modRate: 0.4,
		fmVol: 10,
		devMin: 0.999,
		devMax: 1.0001,
		distort: 1.5,
		thr: 0.99,
		cgain: 1.0,
		atk: 0.02,
		rls: 0.07,
		crv: -3,
		dur: 0.25,
		amp: Pfunc({~melos.amps.ins}),
		fade: 0.8,
		sustain: 0.14
	),

	 ins05: (
        instrument: 'oscfm',
		midinote: ~melos.melo.ins05,
		buf: Pfunc{~buffers[\wt]},
		amp: Pfunc({~melos.amps.ins}),
		dur: 0.25,
      	fade: 0.5,
		atk: 0.02,
		atkcrv: 0,
		rls: 0.1,
		rlscrv: -8,
		modfreq: 800,
		modamp: 100,
		spread: 5,
		dev: 0.7,

    ),
	ins10: (
		instrument: 'oscfm',
		buf: Pfunc{~buffers[\wt]},
		midinote: ~melos[\melo][\ins10],
		dur: 1,
		amp: Pfunc({~melos.amps.ins}),
		fade: 0.5,
		atk: 0.9,
		atkcrv: 1,
		rls: 2,
		rlscrv: 1,
		modfreq: 1000,
		modamp: 40,
		spread:5,
		dev: 1.2,

	),


	ins20: (
	   instrument: 'oscfm',
		buf: Pfunc{~buffers[\wt]},
		midinote: ~melos[\melo][\ins20],
		detune: Pn(Pgeom(30, 0.89, 16),inf),
		dur: 0.25,
		amp: Pfunc({~melos.amps.ins}),
		fade: 1,
		atk: 0.02,
		atkcrv: 1,
		rls: 0.14,
		rlscrv: 1,
		modfreq: 1000,
		modamp: 40,
		spread: 10,
		dev: Pn(Pgeom(1.2, 0.91, 16), inf),
	),


)
)