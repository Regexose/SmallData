// eine funktion für model grains
// funktioniert nicht mit synthdefs,
//////// MBS /////////
SynthDef(\modelGrains, {
    var exc, freqs, rings, amps, sig, env, trig, freqMod;
    var freqArray = NamedControl.kr(\freq, [80, 120, 350, 1010]);
    var ampArray = NamedControl.kr(\levels, [0.5, 0.24, 0.14, 0.423]);
    var ringArray = NamedControl.kr(\ring, [0.1, 0.04, 0.04, 0.023]);
    env = Env.perc(\atk.kr(0.01), \rls.kr(0.08), curve: \crv.kr(-4.0)).kr(2);
    freqs = freqArray;
    trig = Dust.kr(\trg.kr(4));
    freqMod = TRand.kr( 1, 5, trig)  ;
    exc = WhiteNoise.ar(\punch.kr(0.1)) * Decay2.kr(trig, 0.001, \dec.kr(0.9));
    sig = DynKlank.ar(`[
        freqs ,
        ampArray.ampdb.normalizeSum,
        ringArray
    ], exc, \freqScale.kr(1), \freqOffset.kr(0), \decayScale.kr(0.1));
    sig = sig * \amp.kr(0.3) * env;
    sig = RLPF.ar(sig, \ffreq.kr(1000), \rq.kr(0.2));
    sig = PanAz.ar(4, sig, \azi.kr(0.0), \level.kr(1.0), 2, 0.5);
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef('VBAP4chan', { |azi = 0, ele = 0, spr = 0, width = 60, vbapBuf,
    trg=4, punch=0.1, dec=0.9, freqScale=1, decayScale=0.1,
    amp=0.3, ffreq=2000, rq=0.2|
    var exc, sig, env, trig, freqMod, source, panned, freqs, amps, rings;
    freqs = NamedControl.kr(\freqs, [80, 120, 350, 1010]);
    amps = NamedControl.kr(\level, [0.5, 0.24, 0.14, 0.423]);
    rings = NamedControl.kr(\ring, [0.1, 0.04, 0.04, 0.023]);
    env = Env.perc(\atk.kr(0.01), \rls.kr(0.08), curve: \crv.kr(-4.0)).kr(2);
    trig = Dust.kr(trg);
    freqMod = TRand.kr( 1, 5, trig)  ;
    exc = WhiteNoise.ar(punch) * Decay2.kr(trig, 0.001, dec);
    sig = DynKlank.ar(`[
        freqs,
        amps.ampdb.normalizeSum,
        rings
    ], exc, freqScale, 0, decayScale);
    sig = sig * amp ;
    sig = RLPF.ar(sig, ffreq, rq) * env;
    source = SinOsc.ar([440, 660], 0, Decay2.ar(Impulse.ar([1, 0.9]), 0.1, 0.2));
    azi = azi.circleRamp;
    panned = VBAP.ar(4, sig, vbapBuf, [azi - (0.5 * width), azi + (0.5 * width)], ele, spr);
    [0, 1, 2, 3].do({arg bus, i; Out.ar(bus, panned[0][i])}); // in der Liste sind einfach die Outbusse
    [0, 1, 2, 3].do({arg bus, i; Out.ar(bus, panned[1][i])});
}).add;

SynthDef(\sampleGrains, {
    |buf=0,  end=(buf.numFrames-1)|
    var sig, ptr, env;
    env = Env.perc(\atk.kr(0.01), \rls.kr(0.08), curve: \crv.kr(-4.0)).kr(2);
    ptr = Phasor.ar(0, BufRateScale.kr(buf)* \rate.kr(1.0) * \harm.kr(0).midiratio, \start.kr(0), end);
    sig = BufRd.ar(2, buf, ptr);
    sig = RLPF.ar(sig, \ffreq.kr(2000), \rq.kr(0.3));
    sig = sig * \amp.kr(0.3) * env;
    sig = PanAz.ar(4, sig, \azi.kr(0.0), 1.0, 2, 0.5);
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\tgrainsMBS, {
    var sig, env, buf, dur, azi;
    buf = \buf.kr(0);
    dur = \grainDur.kr(0.01);
    //azi = LFSaw.kr(0.1).range(0.0, \azi.kr(1.5)).poll;
    env = Env([0,1,1,0], [\atk.ir(1),\sus.ir(4),\rls.ir(1)], [1,0,-1]).kr(2);
    sig = TGrains.ar(
        numChannels: 4,
        trigger: Dust.kr(\dens.kr(32)),
        bufnum: buf,
        rate: \rate.kr(1) * (\harm.kr([0, 0, 0, 0]).midiratio),
        centerPos: \pos.kr(0.0),
        dur: dur,
        pan: \azi.kr(1.5),
        amp: \grainAmp.kr(0.7),
    );
    //sig = RLPF.ar(sig, \ffreq.kr(2000), \rq.kr(0.9), 0.25) ;
    //sig = (dry * (1.0 - \drywet.kr(0).varlag(0.3))) + (sig * \drywet.kr(0).varlag(0.3));
    sig = sig  * \amp.kr(0.4) * \fade.kr(1) * env;
    //sig = PanAz.ar(4, sig, azi, \level.kr(1.0), 2, 0.5);
    Out.ar(\out.kr(0), sig);
}).add;


~vbapDissent = { |azi = 0, ele = 0, spr = 0,
    baseFreq=80, baseAmp=0.5, baseRing= 0.1
    trg=4, punch=0.1, dec=1
    freqScale=1, decayScale=1,  amp= 0.3|
    var exc, sig, env, trig, freqMod;
    var freqs = Array.fill(4, {|n| baseFreq * (n+1)});
    var amps = Array.fill(4, {|n| baseAmp * [0.5, 0.24, 0.14, 0.423]});
    var rings = Array.fill(4, {|n| baseRing * (n+1)});
    //env = Env.perc(0.01, 4).kr(2);
    trig = Dust.kr(trg);
    freqMod = TRand.kr( 1, 5, trig)  ;
    exc = WhiteNoise.ar(punch) * Decay2.kr(trig, 0.001, dec);
    sig = DynKlank.ar(`[
        freqs,
        amps.ampdb.normalizeSum,
        rings
    ], exc, freqScale, 0, decayScale);
    sig = sig * amp ;
    VBAP.ar(4, sig, ~panbuf, azi, ele, spr);
};

// PanAz mit 4 Lautsprechern
~modelKlank = {
    |cat|
    var dur, idx, pans, freqs, punches;
    dur = rrand(1, 4);
    pans = [0.0, 0.25, 0.5, 1.0, 1.5, 0.0, 0.25];
    // Perspektivisch ein Dictionary
    case
    {cat == \dis}{idx = 0; dur = 3; freqs = [146, 293, 370, 587, 1109]; punches = [0.2, 0.21, 0.18, 0.04, 0.1]}
    {cat == \pr}{idx = 1; dur = 4; freqs = [130, 261, 523, 1046, 2093]; punches = [0.07, 0.08, 0.1, 0.04, 0.1]}
    {cat == \con}{idx = 2; dur = 2; freqs = [98, 392, 493, 783, 1174]; punches = [0.14, 0.15, 0.18, 0.04, 0.13]}
    {cat == \lec}{idx = 3; dur = 1; freqs = [329, 659, 987, 1397, 2637]; punches = [0.25, 0.31, 0.23, 0.14, 0.03]}
    {cat == \ins}{idx = 4; dur = 7.2; freqs = [554, 698, 830, 987, 1108]; punches = [0.11, 0.1, 0.03, 0.02, 0.001]}
    {true}{"no more panAz".postln};

    freqs.do({
        |base, i|

        Synth(\modelGrains, [\freq, Array.fill(4, {exprand(base, base * 2)}),
            \ring, [0.2, 0.1, 0.5, 0.1] * dur ,
            \levels, rrand(0.1, 0.5) !4,
            \azi, rrand(pans[idx], pans[idx+1]), \level, 0.5,
            \dec, dur/3, \trg, dur+ i,
            \rls, dur, \punch, punches[idx], \amp, 0.4,
            \decayScale, 2 - (i* rrand(0.01, 0.15)), \freqScale, pans[idx],
            \ffreq, rrand(freqs[3], freqs[4]), \rq, 0.2,
            \out, 0
        ])
    })
};

// VBAP Synth mit 4 Lautsprechern
~vbapKlank = {
    |cat|
    var dur, idx, pans, freqs, punches;
    dur = rrand(1, 4);
    pans = [-30, 30, 130, -130, -30, 30, 130];
    // Perspektivisch ein Dictionary
    case
    {cat == \dis}{idx = 0; dur = 3; freqs = [146, 293, 370, 587, 1109]; punches = [0.2, 0.21, 0.18, 0.04, 0.1]}
    {cat == \pr}{idx = 1; dur = 4; freqs = [130, 261, 523, 1046, 2093]; punches = [0.07, 0.08, 0.1, 0.04, 0.1]}
    {cat == \con}{idx = 2; dur = 2; freqs = [98, 392, 493, 783, 1174]; punches = [0.14, 0.15, 0.18, 0.04, 0.13]}
    {cat == \lec}{idx = 3; dur = 1; freqs = [329, 659, 987, 1397, 2637]; punches = [0.25, 0.31, 0.23, 0.14, 0.03]}
    {cat == \ins}{idx = 4; dur = 7.2; freqs = [554, 698, 830, 987, 1108]; punches = [0.11, 0.1, 0.03, 0.02, 0.101]}
    {true}{"endOfCat".postln};

    /*    Synth(\VBAP4chan, [\freq, Array.fill(4, {exprand(freqs[idx], freqs[idx] * 2)}),
    \ring, [0.2, 0.1, 0.5, 0.1] * dur ,
    \level, rrand(0.1, 0.5) !4,
    // \azi, rrand(pans[idx], pans[idx+1]), \level, 0.5,
    \vbapBuf, ~panBuf,
    \azi, ~panBus, \level, 0.5,
    \dec, dur/3, \trg, dur + idx,
    \rls, dur, \punch, punches[idx], \amp, 0.4,
    \decayScale, 2 - (idx* rrand(0.01, 0.15)), \freqScale, pans[idx],
    \ffreq, rrand(freqs[3], freqs[4]), \rq, 0.2])*/

    Pbindef(\vbapklank,
        \instrument, \VBAP4chan,
        \freq, Pwhite(freqs[idx], freqs[idx] * 2, inf),
        \ring, [0.2, 0.1, 0.5, 0.1] * dur ,
        \level, Pfunc({rrand(0.1, 0.5) }!4),
        \dur, dur,
        // \azi, rrand(pans[idx], pans[idx+1]), \level, 0.5,
        \vbapBuf, ~panbuf,
        \azi, Pfunc({~mbsdata.panbus}),
        \dec, dur/3, \trg, dur + idx,
        \rls, dur, \punch, punches[idx], \amp, 0.2,
        \decayScale, 2 - (idx* rrand(0.01, 0.15)), \freqScale, pans[idx],
        \ffreq, Pfunc({rrand(freqs[3], freqs[4])}), \rq, 0.2
    ).play;



};


~modelGrains = {
    |cat|
    var dur, pan, dens;
    dur = rrand(1, 4);
    // Perspektivisch ein Dictionary
    case
    {cat == \dis}{pan = 0.0; dur = 3; dens = 12}
    {cat == \pr} {pan = 0.25; dur = 4; dens = 9}
    {cat == \con}{pan = 0.5; dur = 2; dens = 18}
    {cat == \lec}{pan = 1.0; dur = 1; dens = 42}
    {cat == \ins}{pan = 1.5; dur = 7.2; dens = 25}
    {true}{"no more panAz".postln};

    Synth(\tgrainsMBS, [
        \buf, ~mbsGrain1,
        \dens, dens,
        \pos, dens.reciprocal,
        \grainDur, 0.05,
        \azi, pan, \grainAmp, dens * 0.01,
        \rls, dur/2,
        \carfreq, rrand(500, 2000), \fmAmp, rrand(0.02, 0.4),
        \ffreq, dens * 80, \rq, 0.2,
        \out, 0
    ])
};
(
/*{
    PanAz.ar(
        numChans: 4,
        in: ClipNoise.ar(0.1),
        pos: LFSaw.kr(0.2).range(-1, 1),
        level: 0.5,
        width: 1,
        orientation: 0.5
    );
}.scope;

x = {PanAz.ar(4, Dust.ar(10), MouseX.kr(0,1).poll, 1, 2, 0.0)}.play;
x.free;*/
);









~aziangles = Routine({
   loop{
        (-180, -175 .. 180).do({
            |ang|
             x.set(\azi, ang);
            0.11.wait;
        })
    }
});

~circleRamp = {
    var speakerList, x=200, y=150, targx=200, targy=150;
    var atorad = (2pi) / 360, rtoang = 360.0 / (2pi);
    var targRotate, actRotate, targPoint, actPoint, layerDist;
    var maxShiftPerFrame = 20, frameInterval = 0.01;
    var resched = false, count = 0;
    var panBus, widthBus, eleBus, recButton;
    var panWidth = 25;
    var a, b, c, e;
    var sig;

    maxShiftPerFrame = maxShiftPerFrame * atorad;
    actPoint = Point(x, y) - Point(200, 200);
    panBus = Bus.control;
    eleBus = Bus.control;
    widthBus = Bus.control.set(60);

    w = Window.new("Quadro Panner", Rect(128, 64, 400, 450)).front;
    w.view.background_(Color.grey(0.3));
    w.view.decorator = FlowLayout(w.view.bounds);

    //speakerList = [[-30, "L"], [30, "R"], [110, "Rs"], [-110, "Ls"]];
    speakerList = [[[-30, 0], "L"], [[30, 0], "R"], [[0, 45], "topC"]];

    // Der Panningbereich (Das ""Tortenstück"")
    e = EZSlider.new(w, Rect(380, 20), "Stereo Width", [0, 180].asSpec, {arg ez; widthBus.set(ez.value);  w.refresh}, panWidth);
    //e.labelView.setProperty(\stringColor,Color.grey(0.8));

    c = UserView.new(w, Rect(0, 0, 400, 380));
    c.canFocus = false;

    c.drawFunc = {
        var radius=150, radius2=100, labelRadius = 170, labelRadius2 = 80;
        Color.grey(0.8).set;
        // draw the speaker layout
        Pen.translate(200,200);
        // Anzeige des Winkels unter dem Kreise
        ((actPoint.theta + (0.5pi)).wrap2(pi) * rtoang).round(0.01).asString.drawCenteredIn(Rect(0, labelRadius, 30, 10), GUI.font.new("Arial", 12), Color.grey(0.8));

        Pen.strokeOval(Rect.aboutPoint(0@0, radius, radius)); // der grosse Pan Kreis
        Pen.strokeOval(Rect.aboutPoint(0@0, radius2, radius2)); // der grosse Pan Kreis
        Pen.rotate(pi); // dreht die ganze Zeichnung um 180 °

        // malt die speaker boxes ..?
        speakerList.do({|spkr|
            Pen.use({
                var r = Rect.aboutPoint(0@labelRadius, 30, 10);
                Pen.rotate(spkr[0][0] * atorad);
                Pen.moveTo(0@labelRadius);

                case
                {(spkr[0][0].abs < 90) && (spkr[0][1].abs == 0)} {
                   Pen.strokeRect(r);
                    Pen.use({
                        Pen.translate(0, labelRadius);
                        Pen.rotate(pi);
                        spkr[1].drawCenteredIn(Rect.aboutPoint(0@0, 30, 10),
                            GUI.font.new("Arial", 10), Color.grey(0.8));
                    });
                }
                {(spkr[0][0].abs < 90) && (spkr[0][1].abs != 0)} {
                r = Rect.aboutPoint(0@labelRadius2, 30, 10);
                   Pen.strokeRect(r);
                    Pen.use({
                        Pen.translate(0, labelRadius2);
                        Pen.rotate(pi);
                        spkr[1].drawCenteredIn(Rect.aboutPoint(0@0, 30, 10),
                            GUI.font.new("Arial", 10), Color.grey(0.8));
                    });
                }
            {(spkr[0][0].abs >= 90) && (spkr[0][1].abs != 0)}{
                  r = Rect.aboutPoint(0@labelRadius2, 30, 10);
                   Pen.strokeRect(r);
                    Pen.use({
                        Pen.translate(0, labelRadius2);
                        Pen.rotate(pi);
                        spkr[1].drawCenteredIn(Rect.aboutPoint(0@0, 30, 10),
                            GUI.font.new("Arial", 10), Color.grey(0.8));
                    });

            }
                {spkr[0][0].abs >= 90}{spkr[1].drawCenteredIn(r, GUI.font.new("Arial", 10), Color.grey(0.8))}
                {true}{"no more speakers".postln};
            });
        });

        Pen.moveTo(0@0);

        // draw the pan point (das Tortenstück)
        Pen.rotate(actPoint.theta + 0.5pi);
        targPoint = Point(x, y) - Point(200, 200);
        // trunc to avoid loops due to fp math
        targRotate = (targPoint.theta - actPoint.theta).trunc(1e-15);
        // wrap around
        if (targRotate.abs > pi, {targRotate = (2pi - targRotate.abs) * targRotate.sign.neg});
        actRotate = targRotate.clip2(maxShiftPerFrame).trunc(1e-15);
        actPoint = actPoint.rotate(actRotate);
        case
        {targPoint.dist(Point(0,0)) < radius2}{layerDist=radius2}
        {(targPoint.dist(Point(0,0)) >= radius2) && (targPoint.dist(Point(0,0)) <= radius)}{layerDist = targPoint.dist(Point(0,0))}
        {targPoint.dist(Point(0,0)) > radius}{layerDist = radius}
        {true}{"distance = 0".postln; layerDist=0};
        Pen.rotate(actRotate);
        Pen.lineTo(0@radius);
        Pen.stroke;
        Pen.fillOval(Rect.aboutPoint(0@layerDist, 7, 7)); // der Pan Point
        Pen.fillOval(Rect.aboutPoint(0@0, 7, 7)); // der Pan Point
        Pen.addWedge(0@0, 140, neg(e.value * 0.5) * atorad + 0.5pi, e.value * atorad);
        Pen.stroke;
        Color.grey(0.8).alpha_(0.1).set;
        Pen.addWedge(0@0, 140, neg(e.value * 0.5) * atorad + 0.5pi, e.value * atorad);
        Pen.fill;
        ((layerDist/radius).acos * rtoang).postln;
        if((actRotate.abs > 0), {AppClock.sched(frameInterval, {w.refresh})}, {count = 0;});
        // hier wird der panbus, also der azimuth Wert generiert
        //if(count%4 == 0, {~mbsdata.panbus = ((actPoint.theta + (0.5pi)).wrap2(pi) * rtoang)});
        if(count%4 == 0, {panBus.set((actPoint.theta + (0.5pi)).wrap2(pi) * rtoang);
            eleBus.set((layerDist/radius).acos * rtoang);
        });
    };


    c.mouseMoveAction_({|v,inx,iny| x = inx; y = iny; w.refresh;});
    c.mouseDownAction_({|v,inx,iny| x = inx; y = iny; w.refresh;});


    w.refresh;

    // VBAP
    SynthDef(\sine, {
    var mem;
    mem = SinOsc.ar([440, 660], 0, Decay2.ar(Impulse.ar([1, 0.9]), 0.1, 0.2));
    Out.ar(\out.kr(0), mem);
    }).add;

    //sig = Synth(\sine, [\out,  0]);
    //sig.free;
    a = VBAPSpeakerArray.new(3, speakerList.collect(_.first));
    b = Buffer.loadCollection(s, a.getSetsAndMatrices);
    //sig = Synth(\rec, [\in, 4,  \out, ~vbapOut ]);
    SynthDef('VBAP 3 chan', { |inbus, azi = 0, ele=0, spr = 0, panWidth, vbapBuf|
        var panned, source;
        source = SinOsc.ar([440, 660], 0, Decay2.ar(Impulse.ar([1, 0.9]), 0.1, 0.2));
        //source = In.ar(inbus);
        azi = azi.circleRamp;
        panned = VBAP.ar(3, source, vbapBuf, [azi - (0.5 * panWidth), azi + (0.5 * panWidth)], ele, spr);
        // 'standard' channel order for 5.1
        [0, 1, 2].do({arg bus, i; Out.ar(bus, panned[0][i])});
        [0, 1, 2].do({arg bus, i; Out.ar(bus, panned[1][i])});

    }).play(s, [inbus: ~vbapOut, vbapBuf: b.bufnum, azi: panBus.asMap, ele: eleBus.asMap, width: widthBus.asMap]);

};

