from surfaces import *
import getpass
# from surfaces import Area, build_areas, sub_surfaces, AREAS

add_library('oscP5') 
addr = "?"

class Listen(OscEventListener):
    def oscEvent(self, m):
        global loc, osc
        if m.checkAddrPattern("/beat")==True:
            current_beat = [str(i) for i in list(m.arguments()[0])][0]
            change_color = [str(i) for i in list(m.arguments()[1])]
            current_part_name = [str(i) for i in list(m.arguments()[2])]
            next_part_name = [str(i) for i in list(m.arguments()[3])]
            change_color = "".join(change_color)
            current_part_name = "".join(current_part_name)
            next_part_name = "".join(next_part_name)
            # print('geil: ', change_color)
            AREAS['part_info'].subsurfaces['beat'].update_beat(current_beat, change_color)
            AREAS['part_info'].subsurfaces['current'].update_current(current_part_name)
            AREAS['part_info'].subsurfaces['next'].update_next(next_part_name)
        elif m.checkAddrPattern("/display_input") == True:
            utterance = "".join([str(i) for i in list(m.arguments()[0])])
            category = "".join([str(i) for i in list(m.arguments()[1])])
            print("utterance" , utterance)
            AREAS['utterances'].subsurfaces['utts'].update_utts(utterance, category)
        

def setup():
    size(1500, 1000)
    font_size = 14
    font = createFont("Arial-BoldMT", font_size, True)
    global osc, loc
    AREAS = build_areas(width/40, height/36)
    sub_surfaces(font)
    osc = OscP5(this, 5040)
    loc = NetAddress('127.0.0.1', 5040) # send to self
    listener = Listen()
    osc.addListener(listener) # assigning a listener to class Listen
    
def draw():
    for a in AREAS:
        area = AREAS[a]
        # surface_dict = area.update_sub(font, font_size, beat_color)
        # print("subsurf: {}, x: {}  y: {}".format(subsurf.width, x, y))
        image(area.surface, area.pos_x, area.pos_y)
        for value in area.subsurfaces.values():
            image(value.surface, value.x_pos, value.y_pos)

def reconnect():
    global osc, loc
    print("Net Address {} connected ?  {}".format(loc, loc.isvalid()))
    osc.disconnect(loc)
    print("Net Address {} connected ?  {}".format(loc, loc.isvalid()))
    osc = OscP5(this, 5040)
    loc = NetAddress('127.0.0.1', 5040)

def stop():
    global osc
    osc.dispose()
    
