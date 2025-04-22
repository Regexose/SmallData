(
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath;

~configFile = ~projectRoot ++ "config.scd";
~configFile.load;
~resourcePath = ~projectRoot ++ "resources/";

Server.default.options.numInputBusChannels_(1);
Server.default.options.outDevice_(~audioInterface);
Server.default.options.inDevice_(~audioInterface);
s.newBusAllocators;
ServerTree.removeAll; // löscht alle funktionen

s.waitForBoot({
    s.freeAll;
    Buffer.freeAll;
    Pbindef.all.do(_.clear);
    s.sync;
    MIDIClient.init;
    MIDIIn.connectAll;
    ~midiOut = MIDIOut.new(0);
    ~midiIn = MIDIIn.new(0);

    /// load SynthDefs, Constants, Functions
    (~resourcePath ++ "synths.scd").load;
    (~resourcePath ++ "story.scd").load;
    (~resourcePath ++ "constants.scd").load;
    (~resourcePath ++ "initialisation.scd").load;
    (~resourcePath ++ "functions.scd").load;
    (~resourcePath ++ "organist.scd").load;

    // LOAD GUI FILES
    thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI_files/GUI_Styles.scd");
    thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI_files/GUI_Constructor.scd");
    // Wait until boot is done and then begin launching the rest of the prograam
    s.sync;


    // Load song specific files
    ~allocate = (~showFolder +/+ "allocate.scd").load;
    (~showFolder +/+ "constants.scd").load;
    (~showFolder +/+ "synths.scd").load;


    s.sync;
    ServerTree.add(~makeNodes);
    ServerTree.run;
    "serverTree made nodes".postln;
    ~makeWaveTable.(4096); // for WaveTable Synth
    s.sync;

    Window.closeAll;
    thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI_files/sequencer_gui.scd");
    thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI_files/mc_gui.scd");

    //make Dictionary with effekt Patches
    ~patches = (~resourcePath ++ "fx_patches.scd").load;
    //make all other Dictionaries, that can't be made in constants
    // load state patterns into a Dictionary with different states for the 5 categories
    //~states = ~states ? ();
    ~states = ();
    (PathName(~showFolder) +/+ "patterns").entries.do({
        |pathName, i|
        var categorySymbol, category, patternStates;
        category = pathName.fileNameWithoutExtension;
        patternStates = thisProcess.interpreter.compileFile(pathName.absolutePath).value;
        if (~categorySymbols.includesKey(category.asSymbol),
            {
                categorySymbol = ~categorySymbols[category.asSymbol];
                ~states.put(categorySymbol, patternStates[\patterns]);
            },
            {
                categorySymbol = \additional;
                patternStates[\patterns].keys.do{
                    |k|
                    ~states.put(k, patternStates[\patterns][k]);
                    Pbindef(k, *~states[k].asPairs);
                    ~additionalSynths.add(k);
                };
            };
        );
    });

    // set fade volume low at the beginning
    ~fadingSynths.do{| k|  ~faderControl.add(k)};

    [\utt, \perc, \bass].do {|k| ~faderControl.add(k)};
    // make Patterns for all fading Synths
    ~fadingSynths.do{
        |name|
        var default, c;
        default = (name ++ "00").asSymbol;
        default.postln;
        Pbindef(name, *~states[name][default].asPairs);
    };

    // Send Objekte machen
    ~sends = ~sends ? ();

    [~ch1, ~ch2, ~ch3, ~ch4, ~ch5, ~utt, ~perc, ~bass].do{
        |ch, i|
        var sendName;
        //postf("channel %\t i %\n", ch, i);
        [~reverb, ~ringmod, ~chorus].do {
            |fx|
            //postf("fx name %\n", fx.asString);
            sendName = "ch" ++ (i+1).asString ++ "_snd_" ++ fx.asString[13..16];
            ~sends.put(sendName.asSymbol, ch.newPostSend(fx, 0.01) ); // nicht an patch sondern an channel senden
        }
    };

    OSCdef.newMatching(
        \interpreter,
        { arg msg;
            //postf("\nmessage?: %\n", msg);
        /*    postf("\nnew utt: %", msg[1]);
            postf("\nnew cat: %\n", msg[2]);*/
            ~cat = msg[2];
            //if (~td.isConnected, { ~td.sendMsg("/tdIn", msg[1], msg[2])});
            ~td.sendMsg("/tdIn", msg[1], msg[2]);

            if (~isPrelude == true) {
                "prelude".postln;
                ~feedBackSounds.(~categorySymbols[~cat]);
            } {
                ~updateUtts.(msg[1], msg[2]);
                ~blinkSelector.();
                if(msg[3] != nil, {~addNewSample.(msg[3])});
                //~allocate.(~categorySymbols[~cat], ~uttDict[~cat])
                ~setGlobal.value();
                //"debug OSC: cat %".format(msg[2]).postln;
            }
        },
        '/interpreter_input';
    );
    CmdPeriod.add(~mixClear);
    "done".postln;
})
);

(
~sim = Routine(
    { loop ( {
        ~mock.();
        [1.3, 5.2, 3.1, 0.3].choose.wait;
        //"mocked" .postln;
    }
) }).play;
)

~sim.stop;
~isPrelude = true;
~isPrelude = false;

~melos[\slots].keys
 ~buffers[\catSampDe].keys