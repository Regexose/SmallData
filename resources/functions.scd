
~updateUtts = {
    |utt, cat|
    //postf("\n \n+++ ++++ ++++ \n\nnew UTT %\t \n", cat);
    var lastUtts = ~lastUtterances.rotate(1), lastCats = ~lastCategories.rotate(1);
    lastUtts.put(0, utt);
    lastCats.put(0, cat);
    defer {3. do{|i|
        ~status[2][i].string = lastCats[i] ++ " : " ++ lastUtts[i]
    }};
    ~lastUtterances = lastUtts;
    ~lastCategories = lastCats;
    ~totalUtts = ~totalUtts + 1;
    if(~uttDict[cat] >= ~maxCatCounter, {~uttDict[cat] = 1}, {~uttDict[cat] = ~uttDict[cat] + (1 * ~factor)} );
    ~uttsPerMinute[cat].add(~t.beats/~t.tempo); // add a timestamp to calculate utterances per minute
    defer{var index, count;
        index = ~fadingSynths.detectIndex({|it, i| it == ~categorySymbols[cat.asSymbol]});
        count =  ~uttDict[~cat];
        //postf("\nupdating index % to count % ", index, count);
        ~mcLabels[1][index].string = cat ++ "\n" ++ floor(count).asInteger.asString;
        ~mcLabels[1][5].string = "total utts" ++ "\n" ++ ~totalUtts ;
    }
};

~selectorAction = {
    |menu|
    var cat, pathToFile;
    cat = menu.name.asSymbol;
    pathToFile = ~samplePaths[cat][menu.value];
    Buffer.read(s, pathToFile.fullPath, action: {arg buffer;
        AppClock.sched(0, {
            ~uttSamples.put(cat, [buffer, 0, buffer.numFrames-1]); // update sample
            ~sliderButtons[1][cat][0].readFile(SoundFile.openRead(buffer.path), 0, buffer.numFrames); // update SoundFileView
            ~sliderButtons[1][cat][1].lo_(0); // reset low-end of Slider
            ~sliderButtons[1][cat][1].hi_(1); // reset hi-end of Slider
            ~sliderButtons[1][cat][1]  // update  start and end of sample
            .action_({ |slider|
                ~uttSamples[cat][1] = (slider.lo.lincurve(0, 1, 0 , buffer.numFrames, 0)).asInteger;
                ~uttSamples[cat][2] = (slider.hi.lincurve(0, 1, 0 , buffer.numFrames, 0)).asInteger;
            })
        });
    });
};

~blinkSelector = {
    AppClock.sched(0, {~utteranceSelectors[1][~cat].background_(Color.red)});
    AppClock.sched(1, {~utteranceSelectors[1][~cat].background_(Color.white)});
};


// adds incomming audio samples to the selectors and the ~samplePaths-dictionary
~addNewSample = {
    |pathString|
    var pathToFile, itemlist, itemName, samplesList, indexToRemove, currentValue;
    pathToFile = PathName(pathString ++ "/00_utterance.wav");
    itemName = pathToFile.folderName;
    itemlist = ~utteranceSelectors[1][~cat].items;
    samplesList = ~samplePaths[~cat];
    // remove last element if itemlist is too long (or the one before if the last one is active) to keep the number of choices fixed. Also make sure that the selected element remains correct and store the paths to the samples in ~samplePaths with the correct index
    AppClock.sched(0, {
        currentValue = ~utteranceSelectors[1][~cat].value;
        if (itemlist.size >= itemlist.maxSize,
            {
                if (currentValue == (itemlist.maxSize - 1),
                    {indexToRemove = (itemlist.maxSize - 2);},
                    {
                        indexToRemove = (itemlist.maxSize - 1);
                        currentValue = currentValue + 1;
                    }
                );
                itemlist.removeAt(indexToRemove);
                samplesList.removeAt(indexToRemove);
            },
            {currentValue = currentValue+1};
        );
        itemlist.addFirst(itemName);
        ~utteranceSelectors[1][~cat].items_(itemlist);
        ~utteranceSelectors[1][~cat].value_(currentValue);

        samplesList.addFirst(pathToFile);
        ~samplePaths[~cat] = samplesList;
    });
};


// a helper function to load all samples in the provided path
~addSample = {
    |pathSymbol|
    var path = pathSymbol.asString, samples = Dictionary.new;
    samples.add(
        PathName(path).fileName.asSymbol->
        Array.fill(
            PathName(path).entries.size,
            {
                |i|
                PathName(path).entries[i].postln;
                Buffer.read(s, PathName(path).entries[i].fullPath);
            }
        )
    );
    "updated Sample".postln;
    samples;
};

~runFx = {

    ~fx = (
        \rev: ~reverb.playfx(FxPatch(#[ \busfx, \vrb1 ], ~patches[\reverb2])),
        \ring : ~ringmod.playfx(FxPatch(#[\busfx, \ring1], ~patches[\ring])),
        \chor : ~chorus.playfx(FxPatch(#[\busfx, \chorus], ~patches[\chorus])),
        \mst_lim : ~master.playfx(FxPatch(#[\busfx, \limiter], ~patches[\limiter])),
        \ch1_cmp : ~ch1.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \ch2_cmp : ~ch2.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \ch3_cmp : ~ch3.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \ch4_cmp :~ch4.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \ch5_cmp : ~ch5.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])), //dieser macht den *** ERROR: SynthDef companderd#7HVwu not found
        \utt_cmp : ~utt.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \perc_cmp : ~perc.playfx(FxPatch(#[\busfx, \companderd], ~patches[\companderd_beat])),
        \bass_cmp : ~bass.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander_bass]))
    )
};

~bypass = {
    |key, on|
    if (on, {~fx[key].synth.run(false)}, {~fx[key].synth.run(true);})
};

~activateFaders = {
    var i = 0;
    ~sends.keys.asList.sort.do({
        |snd|
        if ("vrb".matchRegexp(snd.asString), {
            //("found  " ++ snd).postln;
            ~activateReverb.(snd, i, 89 );
            i = i+1;
        })
    });
    ~fadingSynths.do{|chan, idx| ~activatePitch.(chan, idx, 97)};
    ~faderControl.do{|chan, it| ~activateVolume.(chan, it)};
};

~checkFadeVols = {
    var allVolumes=List.new;
    ~fadingSynths.do{
        |n|
        allVolumes.add(~melos.amps[n]);
    };
    //"FadeVolumes Sum    %".format(allVolumes.sum).postln;
    ~fadeVols = allVolumes.sum;
    allVolumes.sum;
};

~addVolume = {
    |cat|
    var c, editVol, allVolumes=List.new;
    editVol =  ~melos[\amps][cat];
    //postf("\n updating volume of %  from % \n ", cat, editVol );
    c = case
    {editVol <= ~volThres}{ ~melos[\amps][cat]= editVol + (~volPlus * ~addFac) }// double enhance when pattern is very quiet
    {(editVol<= ~volMax) && (editVol>= ~volThres)}{ ~melos[\amps][cat] = editVol + ~volPlus}
    {editVol >= ~volMax}{  ~melos[\amps][cat] = ~volMax}
    {true}{"end of addVolume".postln};
    defer{var index, height, text;
        //"updating mc: index % height  % text  %".format(index, height, text);
        index = ~fadingSynths.detectIndex({|it, i| it == cat});
        height = ~melos[\amps][cat].linlin(0.001, 1.0, 10, 360);
        text =  ~melos[\amps][cat].trunc(0.001).asString;
        ~mcTrack[1][index].resizeTo(100, height);
        ~mcTrack[1][index].string = text;
    };
    //"debug addVolume: editVol %".format(editVol).postln;
};

~continuousFadeOut = {
    |listOfPatterns|
    //TODO wann schaltet sich das ein und evtl auch wieder ab?
    listOfPatterns.do({
        |cat|
        var vol, c;
        vol = ~melos[\amps][cat];
        //postf("\nthe vol %  of the pattern   %\n", vol, cat);
        c = case
        {(vol > ~volMin) && (vol >= ~volThres)} {~melos[\amps][cat] = vol - (~volStep * ~subFac)} // loud volumes decrease fast
        {(vol <= ~volThres) && (vol >= ~volMin)} {~melos[\amps][cat]= vol - (~volStep * ~subFac)} // middle volumes decrease slower
        {vol <= ~volMin} {~melos[\amps][cat] = ~volMin}
        {true}{"end of fade cases"};
        Pbindef(cat, \amp, ~melos[\amps][cat]);
        defer{var index, height, text;
            //"updating mc: index % height  % text  %".format(index, height, text);
            index = ~fadingSynths.detectIndex({|it, i| it == cat});
            height = ~melos[\amps][cat].linlin(0.001, 1.0, 10, 360);
            text = ~melos[\amps][cat].trunc(0.001).asString;
            ~mcTrack[1][index].resizeTo(100, height);
            ~mcTrack[1][index].string = text;
        }
    });
};

~mum = {
    |cat, timestamps, waitTime|
    var key = ("mumble_" ++ cat.asString).asSymbol;
    [cat, timestamps, waitTime, key].postln;
    Routine({
        timestamps.do({
            |ts, i|
            var amp;
            var harm = ((ts.floor) % ~uttTimeWindow); // die ts auf einen Wert zwischen 0 und ~uttTimeWindow bringen
            var buf = ~buffers[key].values.choose.normalize;
            harm = harm.lincurve(0, 30, -3, 5); //jetzt die harmoniser mappen
            amp = harm.linlin(-3, 5, 0.05, 0.025); // hohe harmonies sind leiser als tiefe
            //"harmonizing % to % amp %".format(ts.floor, harm, amp).postln;

            Synth(\brPhsr, [\buf, buf, \harm, harm, \start, 0, \end, buf.numFrames,
                \amp, amp, \pan, harm.linlin(-3, 5, -1, 1), \atk, 0.1, \out, ~utt]);
            waitTime.wait;
        })
    }).play
};

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
    var lastMinute=0, elapsed=0, kicks, durkicks, snares, dursnares, basses, durbasses;
    kicks = [\kik01, \kik02, \kik03, \kik04, \kik05, \kik10].collect({|n| ~melos.melo[n]});
    durkicks = [\kik02, \kik02, \kik03,\kik04,\kik05,\kik10].collect({|n| ~melos.dur[n]});
    snares = [\sn02, \sn02,\sn03,\sn04,\sn05,\sn06].collect({|n| ~melos.melo[n]});
    dursnares = [\sn02, \sn02,\sn03,\sn04,\sn05,\sn06].collect({|n| ~melos.dur[n]});
    basses = [\bass37, \bass35,\bass33,\bass25,\bass15,\bass10].collect({|n| ~melos.melo[n]});
    durbasses = [\bass23, \bass24, \bass20, \bass15,\bass10,\bass10].collect({|n| ~melos.dur[n]});
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
    case
    //wieder von vorne
    {~uttDict.values.every({|i| i>=60})}{"all cats > 60".postln;
        ~categoryTranslator.keys.do({|k| ~uttDict[k.asSymbol] = 0});
        ~totalUtts = 1;
       ~fadingSynths.do({|k| var pat= (k.asString ++ "00").asSymbol; Pbindef(k, *~states[k][pat].asPairs)});
    }
    // herunterfahren
       {(~totalUtts > 150) && (~uttDict[~cat] >= 50)}
    {
        var count, case_count;
        count = ~uttDict[~cat];
        case_count = count - 49;
        Pbindef(\kik02, \amp, case_count.reciprocal);
        Pbindef(\sn01, \amp, case_count.reciprocal);
        Pbindef(\bass, \amp, case_count.reciprocal);
        //"setting global at 150".postln;
    }
    {(~totalUtts > 130) && (~uttDict[~cat] >= 40)}{
        var count, case_count;
        count = ~uttDict[~cat];
        case_count = (count -39) % kicks.size;
        Pbindef(\kik02, \timb1, case_count.reciprocal,  \freq, kicks[case_count], \dur, durkicks[case_count], \dist, case_count * 0.75).quant_(8);
        Pbindef(\sn01, \ghosts, 10 * case_count, \freq, snares[case_count], \dur, dursnares[case_count], \dist1, 13, \dist2, -4, \rls, 2 ).quant_(8);
        Pbindef(\hh01, \dur, Pif((count%3==0), 0.0625, 0.25), \decayScale, Pwhite(0.6, 1.2, inf),
            \carAmp, Pif((count%3==0), ~melos.melo.hh02, ~melos.melo.hh01), \amp, 0.6
        ).quant_(8);
        Pbindef(\bass, \dur, durbasses[case_count], \modRate, 1.5,
            \midinote, basses[case_count],
            \rls, 1.2, \fmratio, 3, \slide1, 0.5, \distort, 1.5).quant_(8);
        // "setting global at 130".postln;
    }
    {(~totalUtts > 100) && (~uttDict[~cat] >= 25)}{
        var count, case_count;
        count = ~uttDict[~cat] ;
        case_count = count -19;
        Pbindef(\kik02, \freq, ~melos.melo.kik02, \dur, ~melos.dur.kik02, \timb1, case_count -13 ).quant_(8);
        Pbindef(\sn01, \ffreq, 1000 + (case_count * 50)).quant(8);
        Pbindef(\bass, \midinote, ~melos.melo.bass23, \dur, Pif((count%4 ==0), ~melos.dur.bass23, ~melos.dur.bass24),  \rls, 0.3, \oscFB, pi/4).quant_(8);
/*  Pbindef(\bass,
            \midinote, Pif((count%4 == 0), ~melos.melo.bass23, ~melos.melo.bass24),
            \dur, Pif((count%4 ==0), ~melos.dur.bass23, ~melos.dur.bass24),
            \oscFB, pi/4,
        ).play(~t, quant:8);*/
       // "setting global at 100".postln;
    }
       {(~totalUtts == 100) && (~uttDict[~cat] >= 25)}{Pbindef(\sn01, \freq, ~melos.melo.sn02, \dur, ~melos.dur.sn02).play(~t, quant:8)}
    {~totalUtts >= 90}{Pbindef(\snip01).play(~t, quant:8);}

    {(~totalUtts >= 80) && (~uttDict[~cat] >= 20)}{
        var count, case_count;
        count = ~uttDict[~cat];
        case_count = count -19;
        ~hitSample = ~buffers[\atmos][\dickerpott];
        Pbindef(\bass,
            \midinote, Pif((count%4 ==0), ~melos.melo.bass25, ~melos.melo.bass20),
            \dur, Pif((count%4 ==0), ~melos.dur.bass25, ~melos.dur.bass20)).quant_(8);
        Pbindef(\kik02, \timb2, -28 + (case_count *2), \sweep, 0.4 - (case_count * 0.05)).quant_(8);
        Pbindef(\hh01, \freq, 200, \maxFreq, 800 , \decayScale, 1, \maxRing, 1, \fade, 0.6).quant_(4);

    }
    {~totalUtts >= 70}{
        Pbindef(\kik02).play(~t, quant:8);
        Pbindef(\hh01, \decayScale, 1, \maxRing, 0.35, \fade, 0.35 ).quant_(4); }
    {~totalUtts >= 50}{Pbindef(\hh01, \dur, 0.25, \fade, 0.25, \decayScale, 0.5, \maxRing, 0.25).quant_(4);}

    {(~totalUtts > 40) && (~uttDict[~cat] >= 10)}{
        var count = ~uttDict[~cat];
        var case_count = count -9;
        var bassmelo = ("bass" ++ count.asString).asSymbol;
        /* Bass und Beat auslagern, damit es sich nicht dauernd ändert.
        das sollte erst getriggert werden, wenn eine Kategorie 10 counts hat*/
        Pbindef(\bass,
            \midinote, Pif((count%15==0), ~melos.melo.bass15, ~melos.melo.at(bassmelo)),
            \dur, Pif((count%15==0), ~melos.dur.bass15, ~melos.dur.bass10),
            \ipeak, 1 + (case_count * 0.3),
            \fmratio, Pif(count.odd, 1, 2),
            \fade, 1).quant_(8);
        Pbindef(\hh01, \freq, 900, \maxFreq, 1200, \fade, 0.25).quant_(0);
    }
     {(~totalUtts == 40) && (~uttDict[~cat] >= 10)}{ Pbindef(\bass, *~states[\bass].asPairs).play(~t, quant:8)}
    {(~totalUtts > 20) && (~uttDict[~cat] >= 5)}{
        var count = ~uttDict[~cat];
        var case_count = count -4;
        Pbindef(\hh01, \decayScale, 2 + (case_count * 1.5), \maxRing, case_count/2, \accent, 2 + (0.3 * case_count)).quant_(0);
    }
    {~totalUtts == 18}{Pbindef(\hh01).play(~t, quant:4)}
    {~totalUtts >= 5}{
        //bird Atmosphere
        ~hitSample = ~buffers[\atmos][\birds];
    }
    {(~totalUtts == 1)}{
        //"first utt".post=n;

        ~runFx.();
        ~activateFaders.();

        Pdefn(\melody).play(~t, quant:0);
        //[\kik02, \hh01, \bass].do{|n| Pbindef(n).play(~t, quant:4)};
        //init continuous Fadeout Function
        ~t.schedAbs(~t.nextTimeOnGrid, {
            if(~checkFadeVols.() >= ~thresCont, {
                ~continuousFadeOut.value(~fadingSynths); 1},
            {"not fading: fadeVols = %".format(~fadeVols).postln});

        });
        //initiate CategoriesPerMinute Counter EINMALIG, das funktioniert UNABHÄNGIG von einkommenden Utts
        ~t.schedAbs(~t.nextTimeOnGrid, {
            var upm=0;
            //"after % ".format((~t.beats/~t.tempo)).postln;
            if ((~t.beats/~t.tempo) >= ~uttTimeWindow, {
                lastMinute = (~t.beats/~t.tempo) - ~uttTimeWindow ;
                //scan all timestamp lists and only keep timestamps that are larger than lastMinute
                ~uttsPerMinute.keysValuesDo({|k,v|
                    v = v.select({|ts| ts >= lastMinute});
                    //"new opm % in %".format(v.size, k).postln;
                    ~uttsPerMinute[k] = v;
                });
                1;
            });
            ~uttsPerMinute.values.do({|l| upm = upm + l.size});
            ~upm = upm; // update ~upm
            //"updated upm %".format(upm).postln;
            1;
        });
    }
    {true} {"end of global settings".postln};

    //add new timestamp in respective category list
    ~uttsPerMinute[~categorySymbols[~cat]].add((~t.beats/~t.tempo));
};

~mock = {
    var cat = ~categories.choose,
    m = NetAddr("127.0.0.1", 57120);
    m.sendMsg("/interpreter_input", ~story[~storyIndex % ~story.size], cat, ~resourcePath ++ "samples/lec01/");
    ~storyIndex = ~storyIndex +1;
};

~tdIn = OSCdef(\in, {
    |msg, time, addr, recvPort|
    //[msg, time, addr, recvPort].postln;
    ~mock.();
},
'/tdin');5
