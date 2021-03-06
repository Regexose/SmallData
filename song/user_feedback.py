from collections import Counter
import copy
from threading import Timer

class Tonality:
    '''
    idea of tonality counter combined with rules for FX chains and Sample Triggering in
    Ableton Live
    '''

    tonality_counter = Counter()

    chain_duration = 5  # specifies how many utterances are needed to change the tonality
    tonality_lock = False
    min_utts = 1
    chain_value = 127
    ccnr = 0
    ctrl_val = 10 # # the value being sent with SongServer.send_fx is calculated with calculate_rack_values

    category_to_chain = {
        # every category points to a FX Chain, init value and a increment value
        'praise': ['Delay', 65, 5],
        'lecture': ['Vocoder', 95, 8],
        'insinuation': ['FreqShift', 65, -7],
        'dissence': ['Distortion', 60, -5],
        'concession': ['Tremolo',105,  2]
    }
    chain_controls = {
        # every chain refers to a LIVE FX Bus  with a Audio Effekt Rack
        # the Rack has a value for the Chain Selector, a ccnr (for Osculator) and a ctrl_value that is
        # manipulated
        'FreqShift': [15, 10, 65],
        'Vocoder': [32, 15, 95],
        'Distortion': [60, 20, 60],
        'Delay': [90, 25, 65],
        'Tremolo': [110, 5, 105],
        'Clean': [120, 0, 0]
    }

    def __init__(self, synth):
        self.synth = synth
        self.FX_KEY = 'Clean'
        self.chain = self.chain_controls[self.FX_KEY]
        self.last_cats = []
        self.last_value = 0
        self.most_common = 'concession'

    def update_tonality(self, cat):
        self.tonality_counter[cat] += 1
        self.calculate_rack_values(cat)
        print("tonality counter: ", self.tonality_counter)

    def calculate_rack_values(self, cat):
        '''
        1. after 10 utterances, the most_common category defines the FX chain
        2. only if all other categories have had at least had 5 updates (self.last_cats), a new FX_kEY is
        generated by the most_common category at that moment
        3. the self.ctrl_value is calculated as a deviation from a standard value defined in self.chain_controls
        '''

        #  an FX chain is selected, if more than 5 entries have occured
        if sum(self.tonality_counter.values()) > self.min_utts:

            # find most_common, define the chain to  be used
            # das lock verlangsamt die Häufigkeit der most_common Suche
            self.most_common = self.tonality_counter.most_common(1)[0][0]
            print("cat {}   most common: {}".format(cat,  self.most_common))
            self.FX_KEY = self.category_to_chain[self.most_common][0]

            # self.tonality_lock = True  warum gibt es dieses Lock?
            if cat not in self.last_cats and self.tonality_counter[cat] % self.chain_duration == 0:
                # füge cat zu last_cats hinzu, wenn von dieser cat 5 Zähler da sind (für Reset)
                self.last_cats.append(cat)
            elif len(self.last_cats) == len(self.tonality_counter):
                # wenn jede cat 5 Zähler hat, RESET
                print("\t RESET FX")
                self.reset_tonality()
                self.FX_KEY = 'Clean'
                self.synth.reset_synth()
                self.tonality_lock = False
                self.last_cats = []

        self.chain_value = self.chain_controls[self.FX_KEY][0]
        self.ccnr = self.chain_controls[self.FX_KEY][1] # the actual ccnr
        self.last_value = self.chain_controls[self.FX_KEY][2] # restore last value of that chain
        self.ctrl_val = self.last_value + self.category_to_chain[cat][2]  # make new actual ctrl_value
        self.chain_controls[self.FX_KEY][2] = self.ctrl_val   # update chain_controls
        # self.chain = self.chain_controls[self.FX_KEY] # self.chain ist aktuelle chain für fx_send
        self.synth.calculate_synth_message(self.most_common) # update Synth_controls

    def reset_tonality(self):
        for v in self.category_to_chain.values():
            init_value = v[1]
            chain_key = v[0]
            self.chain_controls[chain_key][2]= init_value
        self.chain_value = 127
        print("resetted: ", self.chain_controls)

    def fade(self):
        self.ctrl_val -= 1


class SynthFeedback:
    '''
    this calculates controller values for LIVE MIDI Slots with Synthesizers
    an incoming category defines the slot for the synth to be manipulated
    every synth has 5 ccnr with standard value
    the values for each controller deviate from the last value according to the Tonality.ctrl_val
    '''
    category = 'reset'
    synth_controls = []
    # every control refers to a LIVE MIDI Track with a loaded Synth
    # the Synth has a value for the ccnr (for Osculator) and a standard ctrl_value
    # most synth makro controllers have values from 0-100, some -100-100 or 0.1 - 1.0
    # ideally the values can be transformed by Osculators value mapping
    # default values start at 0
    reset_values = {}
    cat2synth = {}
    # 1st value points to the controller that is altered according to a incoming cat
    # important to store the values of the different synths


    def __init__(self, synth_fb):
        self.cat2synth = synth_fb
        self.synth_controls = copy.deepcopy(self.cat2synth[self.category])
        self.reset_values = self.cat2synth["reset"]
        print("reset values init", self.reset_values)
        self.ctrl_message = self.calculate_synth_message(self.category)

    def calculate_synth_message(self, cat):
        # absolute values from cat2synth
        self.category = cat
        controllers = list(self.cat2synth[cat].values())
        # print("controllers:  {}  most common {} ".format(controllers, cat))
        self.ctrl_message = controllers
        return controllers

    def reset_synth(self):
        self.synth_controls = list(self.cat2synth['reset'].values())
        # print("reset synth : ", self.synth_controls)
