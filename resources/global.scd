
~feedBackSounds = {
    |cat|
    var numNotes = 1;
    "feedback sounds solo with %".format(cat).postln;

    Pbind(
        \instrument, \sampMon,
        \dur, Prand([0.25, 0.31], numNotes),
        \buf, ~melos[\slots][cat].normalize,
        \amp, ~fbVol, \pan, 0,
        \rate, Prand([[1, 1.03], [1, 1.18], [0.97, 1.101], [0.83, 0.91]], 1),
        \atk, 0.05, \rls, Pkey(\dur), \crv, -4,
        \out, ~utt.inbus
    ).play;

    Pbind(
        \instrument, \fm,
        \dur, Prand([0.35, 0.38], numNotes),
        \freq, Array.fill(2, {~melos[\feedbacks][cat].midicps}),
        \amp, ~fbVol , \pan, 0,
        \mod, 0.8,
        \fmFreq, numNotes * Pkey(\freq),
        \fmVol, [100, 60],
        \atk, 0.05, \rls, 2, \crv, -4,
        \cgain, 1,
        \out, ~utt.inbus
    ).play;

};


~setGlobal = {
    var count, case_count, c, uttCount;

    if (~upm >= ~upmMax, {
        var cat, buf;
        "upmMax reached upm %, switching to Mumbles".format(~upm).postln;
        Pbindef.all.do({|p| p.pause});
        cat = ~categorySymbols[~cat];
        ~mum.(cat, ~uttsPerMinute[cat], 0.25);
    },{
        //"upm %, switching to Patterns".format(~upm).postln;
        Pbindef.all.do({|p| if (p.isPlaying == false, {p.resume})});
        ~allocate.(~categorySymbols[~cat], ~uttDict[~cat]);

    });
    uttCount = (~totalUtts * ~factor).ceil.asInteger;
    //"uttCount % totalUtts %".format(uttCount, ~totalUtts).postln;
    c = case
    //wieder von vorne
    {~uttDict.values.every({|i| i>=40})}{"all cats > 40".postln;
        ~categoryTranslator.keys.do({|k| ~uttDict[k.asSymbol] = 0});
        ~totalUtts = 1;
        ~fadingSynths.do({|k| var pat= (k.asString ++ "00").asSymbol; Pbindef(k, *~states[k][pat].asPairs)});
    }
    // herunterfahren
    {(uttCount > 200) && (uttCount < 205) }{ Synth(\sampSt, [\buf, ~buffers[\atmos][\rain], \atk, 2.5, \rls, 20, \amp, 1 ])}
    {(uttCount > 180) && (~uttDict[~cat] >= 34)}{  [\snip01, \hh01, \bass].do({|k| Pbindef(k).stop}) }
    {(uttCount > 170) && (~uttDict[~cat] >= 33)}{  [\sn01, \kik02].do({|k| Pbindef(k).stop}) }
    {(uttCount > 160) && (~uttDict[~cat] >= 32)}
    {
        count = ~uttDict[~cat];
        case_count = count - 34;
        Pbindef(\kik02, \amp, 1 - (case_count * 0.05)).quant_(4);
        Pbindef(\sn01, \amp, 1 - (case_count * 0.05)).quant_(4);
        Pbindef(\bass, \amp, 1 - (case_count * 0.05)).quant_(4);
        "setting global at 160".postln;
    }

    {(uttCount > 145) && (~uttDict[~cat] >= 30)}{
        count = ~uttDict[~cat];
        case_count = count -29;
        Pbindef(\bass, \dur,  ~melos.dur.bass25 , \modRate, 1.5, \amp, 0.45,
            \midinote,  ~melos.melo.bass33,
            \rls, 1.5, \fmratio, 3, \slide1, 0.6, \distort, 1.5, \oscFB, pi/4, \cgain, 1.5).quant_(8);
       Pbindef(\kik02, \timb1, -4, \amp, 0.5,
            \freq, Pif((count%3==0), ~melos.melo.kick07,~melos.melo.kick02),
            \dur, Pif((count%3==0), ~melos.dur.kick07,~melos.dur.kick02),
            \dist, case_count * 0.75, \amp, 0.55).quant_(8);
       Pbindef(\sn01,
            \freq, Pif((count%3==0),~melos.melo.sn11, ~melos.melo.sn02),
            \dur, Pif((count%3==0), ~melos.dur.sn11, ~melos.dur.sn02),
            \dist1, 0, \rls, 1.5,
            \shaper1, 1.0, \shaper2, 0.7,
            \amp, 0.3).quant_(8);
         "setting global at 145".postln;
    }
    {(uttCount > 130) && (~uttDict[~cat] >= 27)}{

        count = ~uttDict[~cat];
        case_count = count -27;
        Pbindef(\kik02, \timb1, case_count.reciprocal,
            \freq, Pif((count%3==0), ~melos.melo.kick07,~melos.melo.kick06),
            \dur, Pif((count%3==0), ~melos.dur.kick07,~melos.dur.kick06),
            \dist, case_count * 0.75).quant_(8);
        Pbindef(\sn01,
            \freq, Pif((count%3==0),~melos.melo.sn01, ~melos.melo.sn10),
            \dur, Pif((count%3==0), ~melos.dur.sn01, ~melos.dur.sn10),
            \dist1, 13, \dist2, -4, \rls, 1, \shaper1, 1.2 ).quant_(8);
        Pbindef(\hh01, \dur, Pif((count%3==0), 0.0625, 0.25), \decayScale, Pwhite(0.6, 1.2, inf),
            \carAmp, Pif((count%3==0), ~melos.melo.hh02, ~melos.melo.hh01), \amp, 0.6
        ).quant_(8);
        Pbindef(\bass, \dur, Pif((uttCount%4==0), 0.25, ~melos.dur.bass24) , \modRate, 1.5,
            \midinote, Pif ((count%4==0), ~melos.melo.bass20 +3, ~melos.melo.bass20),
            \rls, 0.5, \fmratio, 1, \slide1, 0.1, \distort, 1.0, \oscFB, pi/4).quant_(8);
        Pbindef(\snip01, \zit1, 10, \lag, Pif((count%3==0), 0.005, 0.0002)).quant_(4)
        // "setting global at 130".postln;
    }
    {(uttCount > 100) && (~uttDict[~cat] >= 25)}{

        count = ~uttDict[~cat] ;
        case_count = count -24;

        Pbindef(\kik02, \freq, ~melos.melo.kik02, \dur, ~melos.dur.kik02, \lpf, Pif((uttCount%3==0), 2000, 1220) ).quant_(8);
        Pbindef(\sn01,
            \freq, Pif((uttCount%3==0),~melos.melo.sn01, ~melos.melo.sn02),
            \dur, Pif((uttCount%3==0),~melos.dur.sn01,  ~melos.dur.sn02),
            \shaper1, uttCount.linlin(100, 140, 0.8, 2.8), \shaper2, uttCount.linlin(100, 130, 0.1, 1.5),
            \rls, Pif((count%3==0), 1, 0.35)).quant(8);
        Pbindef(\bass, \midinote, Pif((count%3==0), ~melos.melo.bass23 +5, ~melos.melo.bass23 ), \dur, Pif((count%4 ==0), ~melos.dur.bass23, ~melos.dur.bass24),  \rls, 0.3, \oscFB, [pi/4,  pi*3/4, pi*3/5 ,pi/2].choose).quant_(8);

        "setting global at 100".postln;
    }
    {(uttCount >= 98) && (uttCount <= 103)}{
        if ( Pbindef(\sn01).isPlaying==false, { Pbindef(\sn01, \freq, ~melos.melo.sn02, \dur, ~melos.dur.sn02, \shaper2, 0.8).play(~t, quant:8)})
    }
    {(uttCount > 90)}{Pbindef(\snip01, \zit1, uttCount.linlin(90,100, 0, 50)).quant_(4); }
    {(uttCount >= 88) && (uttCount <= 93)}{
    if( Pbindef(\snip01).isPlaying==false, {Pbindef(\snip01).play(~t, quant:8);
        Synth(\sampSt, [\buf,~buffers[\atmos][\dickerpott], \atk, 2.5, \rls, 40, \amp, 0.8 ]);
    });

    }
    {(uttCount >= 80) && (~uttDict[~cat] >= 15)}{

        count = ~uttDict[~cat];
        case_count = count -14;

        Pbindef(\bass,
            \midinote, Pif((count%4 ==0), ~melos.melo.bass20, ~melos.melo.bass25),
            \dur, Pif((count%4 ==0), ~melos.dur.bass20, ~melos.dur.bass25)).quant_(8);
        Pbindef(\kik02, \cgain, 1.2, \lpf, 1500 ).quant_(8);
        Pbindef(\hh01, \freq, 200, \maxFreq, 800 , \decayScale, 1, \maxRing, Pwhite(0.1, 1, inf), \fade, 0.6).quant_(4);

    }
    {(uttCount >= 61) && (uttCount <= 66)}{
        if (Pbindef(\kik02).isPlaying==false, { Pbindef(\kik02).play(~t, quant:4)});

        Pbindef(\hh01, \decayScale, 1, \maxRing, 0.35, \fade, 0.35 ).quant_(4);
    }
    {(uttCount >= 56) && (~uttDict[~cat] >= 10)}{
        count = ~uttDict[~cat];
        Pbindef(\hh01, \fade, 0.25, \decayScale, 0.5, \maxRing, 0.25, \frqOff, Pwhite(0, 8, inf)).quant_(4);
        Pbindef(\bass, \midinote, ~melos.melo.bass10,  \dur, Pif((count%3==0), 0.25, ~melos.dur.bass10)).quant_(8);
    }
    {uttCount >= 50}{Pbindef(\hh01, \dur, 0.25, \fade, 0.25, \decayScale, 0.5, \maxRing, 0.25).quant_(4)}

    {(uttCount > 40) && (~uttDict[~cat] >= 7)}{

        count = ~uttDict[~cat];
        case_count = count -6;
        /* Bass und Beat auslagern, damit es sich nicht dauernd ändert.
        das sollte erst getriggert werden, wenn eine Kategorie 10 counts hat*/

        Pbindef(\bass,
            \midinote, Pif((count%4==0), ~melos.melo.bass15, ~melos.melo.bass10),
            \dur, Pif((count%4==0), ~melos.dur.bass15, ~melos.dur.bass10),
            \ipeak, 1 + (case_count * 0.3),
            \fmratio, Pif(count.odd, 1, 2),
            \fade, 1).quant_(8);
        Pbindef(\hh01, \freq, 900, \maxFreq, 1200, \fade, 0.25).quant_(0);
    }
    {(uttCount >= 35) && (uttCount <= 39) }{
        if (Pbindef(\bass).isPlaying==false, {Pbindef(\bass, *~states[\bass].asPairs).play(~t, quant:8)})
    }
    {(uttCount > 20) && (~uttDict[~cat] >= 5)}{
        count = ~uttDict[~cat];
        case_count = count -4;
        Pbindef(\hh01, \decayScale, 2 + (case_count * 1.5), \maxRing, case_count/2, \accent, 2 + (0.3 * case_count)).quant_(0);
    }
    {(uttCount >= 15) && (uttCount <= 19)}{if (Pbindef(\hh01).isPlaying==false, {Pbindef(\hh01, *~states[\hh01].asPairs).play(~t, quant:4)})}
    {uttCount == 8}{
        //bird Atmosphere

         Synth(\sampSt, [\buf, ~buffers[\atmos][\birds], \atk, 0.5, \rls, 40, \amp, 1 ]);
    }
    {(uttCount == 1)}{
        var lastMinute=0, elapsed=0;
        "first utt".postln;

        ~runFx.();
        ~activateFaders.();
        //init continuous Fadeout Function
        ~fadeOut.();

        Pdefn(\melody).play(~t, quant:0);

        //initiate CategoriesPerMinute Counter EINMALIG, das funktioniert UNABHÄNGIG von einkommenden Utts
        ~upmManage.();

    }
    {true} {"end of global settings".postln};

    //add new timestamp in respective category list
    ~uttsPerMinute[~categorySymbols[~cat]].add((~t.beats/~t.tempo));
};