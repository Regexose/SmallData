from surfaces import *
import pickle
import json
from collections import OrderedDict

add_library('oscP5')
addr = "?"

AREAS = OrderedDict()

class Listen(OscEventListener):

    def oscEvent(self, m):
        global loc, osc
        if m.checkAddrPattern("/beat") == True:
            current_beat = "".join([str(i) for i in list(m.arguments()[0])][0])
            change_color = "".join([str(i) for i in list(m.arguments()[1])])
            current_part_name = "".join(
                [str(i) for i in list(m.arguments()[2])])
            next_part_name = "".join([str(i) for i in list(m.arguments()[3])])
            AREAS['part_info'].update_parts(
                current_part_name, next_part_name, current_beat, change_color)
        if m.checkAddrPattern("/counter"):
            new_counter = json.loads(m.arguments()[0])["category_counter"]
            machine_is_locked = json.loads(m.arguments()[0])["is_locked"]
            AREAS['status'].update_status(new_counter, machine_is_locked)
    
def setup():
    size (1000, 500)
    background(200)
    global font, font_bold, loc
    font_size = width/20

    font = createFont("Helvetica", font_size, True)
    font_bold = createFont("Helvetica-Bold", font_size, True)
    global osc, loc
    AREAS = build_areas()
    osc = OscP5(this, 5050)  # the PERFORMER_PORT
    loc = NetAddress('192.168.1.156', 5050)  # send to self
    global listener
    listener = Listen()
    osc.addListener(listener)  # assigning a listener to class Listen

def draw():
    for area in AREAS.values():
        area.draw()

def build_areas():
    global font
    y_spacing = height / 100
    x_spacing = width / 50
   
    AREAS["part_info"] = PartArea(
        "part_info", x_spacing, y_spacing, width/2, height - 2 * y_spacing, font)
    AREAS["status"] = SongStatus(width/2, 0, width/2, height, font)
    AREAS["article"] = ArticleArea(
        "Moderation.tsv", width/16, 0, width *7/8, height/8, font)
    return AREAS

def sendOsc(message):
    global loc
    myMessage = OscMessage("/article") 
    serialized = json.dumps(message)
    myMessage.add(serialized)
    print("serialized: ", serialized)
    osc.send(myMessage, loc)

def keyReleased():
    article = AREAS["article"]
    if key == 'n':
        article.art_index += 1
        article.update_line()
        sendOsc(article.article_line)
        

def stop():
    global osc
    osc.dispose()