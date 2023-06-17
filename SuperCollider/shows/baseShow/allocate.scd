~allocate = {
    |catName, counter|
    var c, dura, patName, status, count, in_count, local_feedbackVol, numNotes;
    count = floor(counter * ~factor).asInteger;
    status = "";
    local_feedbackVol = 0.4;
    numNotes = 1;
    dura = Env.new([1,0], [count], [-2]).asPseg;
    patName = catName.asString ++ "0";

    c = case
	{count < 5}{
		in_count = count;
		patName = (catName.asString ++ "1").asSymbol;
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
		Pbindef(\bass, *~states[\bass].asPairs).quant_(4);
		Pbindef(\kik01, \freq, ~melos.melo.kik01, \amp, 0.43).quant_(4);
	    Pbindef(\sn01).stop;
		Pbindef(\hh01).stop;
		status = "state 00 layered chords";
	}
    {(count >= 5) && (count <= 10)} {
        in_count = count-4;
        patName = catName.asString ++ "10";
		Pbindef(\metronom, \amp, (0.033 * in_count)).play(~t);
		Pbindef(\bass, *~states[\bass1].asPairs).play(~t, quant:1);
		//Pbindef(\kik01).stop;
		Pbindef(\sn01).play(~t, quant:4);
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
		//Pbindef(catName, \harmonic, [in_count, count]);
        numNotes = 2;
        status = "state 01 instrument changed \n bass line increases, switching beats ";
    }
    {(count > 10) && (count <=20)} {
        in_count = count - 10;
        patName = catName ++ "10";
		Pbindef(\kik01, \freq, ~melos.melo.kik01, \amp, 0.43).quant_(4);
		Pbindef(\hh01, \decayScale, Pwhite(0.1, 0.3, inf)).play(~t, quant:1);
        Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
	    Pbindef(\bass, \amp, Pif((in_count%3 == 0), 0, 0.25, 0.25 ),
			\midinote, Pif(in_count.even, ~melos.melo.bass1 +12, ~melos.melo.bass2, ~melos.melo.bass0);
		).quant_(4);
		Pbindef(\sn01, \freq, Pif((count%3 ==0), ~melos.melo.sn03, ~melos.melo.sn01, ~melos.melo.sn01)).quant_(1);
        numNotes = 3;
        status = "state 02 changing bass lines \n longer notes"
	}
    {(count > 20) && (count <=29)} {
        in_count = count - 10;
        patName = catName ++ "20";
		Pbindef(\kik01, \freq, ~melos.melo.kik01, \amp, 0.43).quant_(4);
		Pbindef(\hh01, \decayScale, Pwhite(0.6, 1.2, inf),
			\carAmp, Pxrand([0.23, 0.33, 0.5], inf)
		).play(~t, quant:1);
        Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
	    Pbindef(\bass, \amp, Pif((in_count%3 == 0), 0, 0.25, 0.25 )).quant_(4);
        numNotes = 3;
        status = "state 03 one-notes with downward glissando";
    }
    {true} { "end of attCat reached".postln};

// feedback sound

    2.do{
        var dur = [0.25, 0.31].choose;
        var samp, pitch;
        samp = Pbind(
            \instrument, \sampMon,
            \dur, dur,
            \buf, ~melos[\slots][catName],
            \amp, ~fbVol * local_feedbackVol, \pan, Pwhite(-1.0, 1.0, 1),
            \rate, [1, (numNotes * 1.33)],
            \atk, 0.05, \rls, Pkey(\dur), \crv, -4);
        pitch = Pbind(
            \instrument, \bellFm,
            \dur, dur,
            \midinote, ~melos.feedback[catName],
            \amp,~fbVol * local_feedbackVol,
            \pan, Pwhite(-1.0, 1.0, 1),
            \atk, 0.04, \rls, 0.2);
        Ppar([samp, pitch], numNotes).play;
    };

   ~addVolume.value(catName);
	defer{~status[1].string = catName ++ " : " ++ status};
   //postf("\nsetting %\to status \t %\n", catName, status);

};