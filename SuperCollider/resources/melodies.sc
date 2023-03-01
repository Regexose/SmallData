(
melo: (
    pr: Array.fill(~numSlots, {68}),
    ins: Array.fill(~numSlots, {73}),
    con: Array.fill(~numSlots, {74}),
    lec: Array.fill(~numSlots, {75}),
    dis: Array.fill(~numSlots, {65}),

),

duras:(
    pr: Array.fill(~numSlots, {1}),
    ins: Array.fill(~numSlots, {1}),
    con: Array.fill(~numSlots, {1}),
    lec: Array.fill(~numSlots, {1}),
    dis: Array.fill(~numSlots, {1}),

),

amps:(
    pr: Array.fill(~numSlots, {0.15}),
    ins: Array.fill(~numSlots, {0.15}),
    con: Array.fill(~numSlots, {0.15}),
    lec: Array.fill(~numSlots, {0.15}),
    dis: Array.fill(~numSlots, {0.15}),

),

pauses: (
    lecture: 2,
    dissent: 3,
    insinuation: 4,
    praise: 5,
    concession: 6
),

slots:(
	// sample Slots
	zahlen: ~numSlots.collect({|n| var i = n%7; ~buffers[\zahlen][i]}),
	//pattern slots
	a: Pbind(\instrument, \sampSt, \buf, Pxrand(~buffers[\bd], inf), \amp, 0.4, \dur, 0.5),
	b: Pbind(\instrument, \sampSt, \buf, Pxrand(~buffers[\Bells], inf), \amp, 0.9, \dur, 0.5, \cgain, 3),
	uttpra: Pbindef(\uttpra, \instrument, \sampMon, \buf, ~uttSample),
	uttdis: Pbindef(\uttdis, \instrument, \sampMon, \buf, ~uttSample),
	uttins: Pbindef(\uttins, \instrument, \sampMon, \buf, ~uttSample),
	uttcon: Pbindef(\uttcon, \instrument, \sampMon, \buf, ~uttSample),
	uttlec: Pbindef(\uttlec, \instrument, \sampMon, \buf, ~uttSample),
	pr: Pbindef(\pr),
	dis: Pbindef(\dis),
	ins: Pbindef(\ins),
	con: Pbindef(\con),
	lec: Pbindef(\lec),
)




)

