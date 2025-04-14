{
    |catName, counter|
    var c, dura, patName, status, count, case_count, local_feedbackVol, numNotes;
    count = floor(counter * ~factor).asInteger;
    status = "";
    "counter % factor % count %".format(counter, ~factor, count).postln;
    local_feedbackVol = 0.45;
    numNotes = 1;
    dura = Env.new([1,0], [count], [-2]).asPseg;
    patName = (catName.asString ++ "0").asSymbol;

    c = case
    {count <= 4}{
        patName = (catName.asString ++ "00").asSymbol;
        Pbindef(catName, *~states[catName][patName].asPairs).play(~t, quant:1);
        /* hier überschreibe ich den initial status, um einen smootheren Anfang
        zu bekommen, eben mit oktavierten tönen */
        Pbindef(catName, \index, count, \rls, 3 + (count*0.75), \cRatio, count, \mRatio, count).quant_(1);
        status = "State 0 notes increasing harmonies";
    }
    {(count >=5) && (count <= 9)}{
        case_count = count -4;
        patName = (catName.asString ++ "05").asSymbol;
        Pbindef(catName, *~states[catName][patName].asPairs).play(~t, quant:1);
        Pbindef(catName, \mRatio, case_count, \cRatio, 3, \index, case_count, \trmDep, 0.03 * case_count).quant_(1);

        status = "State 01: Notes increasing harmonies, increasing tremolo";
    }
    {(count >= 10) && (count < 20)}{
        case_count = count -9 ;
        patName = (catName.asString ++ "10").asSymbol;
        Pbindef(catName, *~states[catName][patName].asPairs).play(~t, quant:8);
        Pbindef(catName, \rls, 0.3 * case_count , \fratio0, case_count, \modInd0, case_count, \ffreq, 800 + (case_count * 100), \fmVol, Pif(count.odd, 50, 230)).quant_(8);
        numNotes = 2;
        // bass und beat werden ausgelagert in ~setGlobal
        status = "state 02 dotted notes, increasing harmonies & release";
    }
    {(count >= 20) && (count < 40)} {
        case_count = count - 19;
        patName = catName ++ "20";
        // rls, modInd und fratio sind gute Parameter zum spielen
        Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).play(~t, quant:8);
        Pbindef(catName, \modInd0, case_count, \fratio0, case_count * 0.2, \rls, 0.02 * case_count).quant_(8);
        numNotes = 3;
        status = "state 03 notes getting longer, increasing harmonies";
    }

    {(count >= 40) && (count <=60)} {
        case_count = count - 39;
        patName = catName ++ "40";
        Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).play(~t, quant:0);
        Pbindef(catName, \mRatio, case_count ).quant_(4);
        numNotes = 2;
        status = "state 04 one-notes with downward glissando";
    }

    {true} { "end of attCat reached".postln};

    // feedback sound
    if(count >= 10,
        { ~mum.(catName, ~uttsPerMinute[catName], 0.25)}
        ,{2.do{
            |n|
            Pbind(
                \instrument, \sampMon,
                \dur, Prand([0.25, 0.31], numNotes),
                \buf, ~melos[\slots][catName].normalize,
                \amp, ~fbVol * local_feedbackVol, \pan, 0,
                \rate, Prand([[1, 1.03], [1, 1.18], [0.97, 1.101], [0.83, 0.91]], numNotes),
                \atk, 0.05, \rls, Pkey(\dur), \crv, -4,
                \cgain, 1,
                \out, ~utt.inbus
            ).play;
        };}
    );



    ~addVolume.value(catName);
    defer{~status[1].string = catName ++ " : " ++ status};
    postf("\nsetting %  to status \t % with patname % \n", catName, status, patName);
};
