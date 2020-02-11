from collections import OrderedDict
from linebreak import linebreak

AREA_NAMES = ["song", "utterances", "blocks", "part_info"]
AREAS = {}
UTTERANCE_DICT = OrderedDict()

class SurfaceBase:
    def __init__(self, name, pos_x, pos_y, s_width, s_height):
        self.name = name
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.subsurfaces = OrderedDict()
        self.__create_surface(s_width, s_height)
        
    def __create_surface(self, w, h):
        self.surface = createGraphics(w, h)
        self.surface.smooth()
        with self.surface.beginDraw():
            self.surface.background(222)
    
    def draw(self, surface=None):
        if surface:
            with surface.beginDraw():
                surface.image(self.surface, self.pos_x, self.pos_y)
        else:
            image(self.surface, self.pos_x, self.pos_y)
        for subsurf in self.subsurfaces.values():
            subsurf.draw(self.surface)
        
    def add_subsurface(self, name, area):
        self.subsurfaces[name] = area
        
class UtteranceLine:
    def __init__(self, s_width, s_height, utt, cat, font, pos_x):
        self.pos_x = pos_x
        self.pos_y = 0
        temp_utt_surface = linebreak(s_width * 2/3, s_height, utt, font, 17)
        temp_cat_surface = createGraphics(s_width * 1/3, temp_utt_surface.height)
        utt_cat_surface = createGraphics((temp_utt_surface.width + temp_cat_surface.width) - 10 , temp_utt_surface.height)
        with temp_cat_surface.beginDraw():
            temp_cat_surface.textFont(font)
            temp_cat_surface.textSize(17)
            temp_cat_surface.textAlign(LEFT, TOP)
            temp_cat_surface.fill(0)
            temp_cat_surface.text(cat, 0, 0)
        with utt_cat_surface.beginDraw():
            utt_cat_surface.background(222)
            utt_cat_surface.image(temp_utt_surface, 0, 0)
            utt_cat_surface.image(temp_cat_surface, temp_utt_surface.width + 10 , 0)
            utt_cat_surface.stroke(200)
            utt_cat_surface.strokeWeight(15)
            utt_cat_surface.line(0, utt_cat_surface.height, utt_cat_surface.width, utt_cat_surface.height)
            utt_cat_surface.line(temp_utt_surface.width, 0, temp_utt_surface.width, utt_cat_surface.height)
        self.surface = utt_cat_surface
        
    def set_pos_y(self, pos):
        self.pos_y = pos
    
    def draw(self, surface):
        with surface.beginDraw():
            surface.image(self.surface, self.pos_x, self.pos_y) 

class UtterancesArea(SurfaceBase):
    def __init__(self, name, pos_x, pos_y, s_width, s_height, font):
        SurfaceBase.__init__(self, name, pos_x, pos_y, s_width, s_height)
        self.index = 0
        
        self.font = font
    
    def update_utts(self, utt, cat):
        utt_cat_surf = UtteranceLine(self.surface.width, self.surface.height, utt, cat, self.font, self.pos_x)
        self.add_subsurface(self.index, utt_cat_surf)
        self.index += 1
               
        pos_y = 0
        self.iterate = True
        surfaces_to_iterate = reversed(list(self.subsurfaces.values()))
        for utt_line in surfaces_to_iterate:
            utt_line.set_pos_y(pos_y)
            if pos_y >= self.surface.height:
                break 
            # with area_surf.beginDraw():
            #     area_surf.smooth()
            #     area_surf.image(value, 0, pos_y)
            pos_y += utt_line.surface.height
    
        if pos_y > self.surface.height:
            self.subsurfaces.popitem(last=False)   
   

def build_areas2(font):
    y_spacing = height/100
    x_spacing = width/100
    AREAS["utterances"] = UtterancesArea("utterances", width/100, height/2 + y_spacing, width*8/13, height*7/16, font)
    # utt_cat_area = Area2("utt_cat", width/100, height/2 + y_spacing, width*8/13, height*7/16)
    # utt_area = Utterances("utt", utt_cat_area.pos_x + x_spacing , utt_cat_area.pos_y + y_spacing, utt_cat_area.s_width -10 , utt_cat_area.s_height -10, font)
    # cat_area = Utterances("cat", utt_cat_area.pos_x + utt_area.s_width, height/2 + y_spacing, utt_cat_area.s_width/3, utt_cat_area.s_height,font)
    # part_area = Area2("part_info", utt_cat_area.pos_x + 
    # print("utt_cat pos_x {}\nutt pos_x {}\ncat pos_x {}".format(utt_cat_area.pos_x, utt_area.pos_x, cat_area.pos_x))
    return AREAS

class Area:
    def __init__(self, tempName, surface, pos_x, pos_y):
        self.name = tempName
        self.surface = surface
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.subsurfaces = {}
        self.fill_surface(222)
    
    def fill_surface(self, col):
        if not self.name == "utterances":
            with self.surface.beginDraw():
                self.surface.background(col) 
        # print("filled {} with {}".format(self.name, col))
      
    def update_subsurfaces(self, name, surface):
        # print("subdate: {} with {}".format(self.name, name))
        for value in list(self.subsurfaces.values()):
            surf = value.surface
            if name == value.name:
                surf = surface
    
    def update_utterances(self, utt, cat):
        surf = self.subsurfaces["utts"].update_utts(utt, cat)
        self.surface = surf
    
            
class Subsurface:
    index = 1
    total_height = 0
    iterate = False
    
    def __init__(self, name, parent_surface, x_div, y_div, x_pos, y_pos, font):
        self.name = name
        self.parent = parent_surface
        self.x_div = x_div
        self.y_div = y_div
        self.x_pos = x_pos
        self.y_pos = y_pos
        self.txt = ""
        self.font = font
        self.beat_color = color(0, 230, 20)
        self.utterance_dict = OrderedDict()
        self.surface = createGraphics(int(self.parent.surface.width * self.x_div), int(self.parent.surface.height * self.y_div))
        self.surface.smooth()
        self.parent.subsurfaces[self.name] = self
  
    def text_on_surface(self, surface, txt, font_size, col, spacing=0):
        # print("update txt: {}".format(txt))
        with surface.beginDraw():
            surface.background(222)
            surface.textFont(self.font)
            surface.textSize(font_size)
            surface.fill(col)
            surface.textAlign(CENTER)
            surface.text(txt, surface.width/2, surface.height/2 + spacing)

    def update_beat(self, beat_number, change_color):
        # print("beat {} change?  {}".format(beat_number, change_color))
        if change_color == "True":
            self.beat_color = color(250, 0, 150)
        else: 
            self.beat_color = color(10, 250, 20)
        self.txt = beat_number
        self.text_on_surface(self.surface, self.txt, 80, self.beat_color)
        # print("beat.parent: ", self.parent.name)
        self.parent.update_subsurfaces(self.name, self.surface)
    
    def update_part(self, current_part, prefix):
        self.text_on_surface(self.surface, prefix + current_part, 20,  color(50), 10)
        self.parent.update_subsurfaces(self.name, self.surface)
    
    def create_utt_cat(self, utt, cat):
        temp_utt_surface = linebreak(self.surface, utt, self.font, 17)
        temp_cat_surface = createGraphics(self.parent.surface.width - temp_utt_surface.width, temp_utt_surface.height)
        utt_cat_surface = createGraphics((temp_utt_surface.width + temp_cat_surface.width) - 10 , temp_utt_surface.height)
        with temp_cat_surface.beginDraw():
            temp_cat_surface.textFont(self.font)
            temp_cat_surface.textSize(17)
            temp_cat_surface.textAlign(LEFT, TOP)
            temp_cat_surface.fill(0)
            temp_cat_surface.text(cat, 0, 0)
        with utt_cat_surface.beginDraw():
            utt_cat_surface.background(222)
            utt_cat_surface.image(temp_utt_surface, 0, 0)
            utt_cat_surface.image(temp_cat_surface, temp_utt_surface.width + 10 , 0)
            utt_cat_surface.stroke(200)
            utt_cat_surface.strokeWeight(15)
            utt_cat_surface.line(0, utt_cat_surface.height, utt_cat_surface.width, utt_cat_surface.height)
            utt_cat_surface.line(temp_utt_surface.width, 0, temp_utt_surface.width, utt_cat_surface.height)
        return utt_cat_surface
    
    def update_utts(self, utt, cat):
        utt_cat_surf = self.create_utt_cat(utt, cat)
        area_surf = self.parent.surface
        self.utterance_dict[self.index] =  utt_cat_surf 
        pos_y = 0
        self.iterate = True
        surfaces_to_iterate = reversed(list(self.utterance_dict.values()))
        while self.total_height <= self.surface.height and self.iterate:
            for value in surfaces_to_iterate:
                with area_surf.beginDraw():
                    area_surf.smooth()
                    area_surf.image(value, 0, pos_y)
                pos_y += value.height
                self.total_height += value.height
            self.iterate = False
        
        if self.total_height > self.surface.height:
            current_surfaces = list(self.utterance_dict.values())
            self.utterance_dict.popitem(last=False)
            self.total_height = 0
        self.index += 1
        return area_surf

def build_areas(spacing_x, spacing_y): 
    pos_y1 = pos_y2 = height/16
    for i in range(len(AREA_NAMES)):
        if i <= 1:
            surface_width = width*8/13
            surface_height = height*7/16
            pos_x = width*2/3 
            surface = createGraphics(surface_width, surface_height)
            AREAS[AREA_NAMES[i]] = Area(AREA_NAMES[i], surface, pos_x - surface_width - (spacing_x/2) , pos_y1)
            pos_y1 += surface_height + spacing_y
        else:
            surface_width = width*4/14
            surface_height = height*7/16
            pos_x = width*2/3 
            pos_y = 0
            surface = createGraphics(surface_width, surface_height )
            AREAS[AREA_NAMES[i]] = Area(AREA_NAMES[i], surface, pos_x + (spacing_x/2), pos_y2)
            pos_y2 += surface_height + spacing_y
    return  AREAS   

def sub_surfaces(font):
    for name in AREAS:
        parent = AREAS[name]
        if name == "utterances":
            utt_surf = Subsurface("utts", parent, 0.66, 1, parent.pos_x, parent.pos_y, font)
            cat_surf = Subsurface("cats", parent, 0.33, 1, parent.pos_x + utt_surf.surface.width, parent.pos_y, font)
        elif name == "part_info":
            current_surf = Subsurface("current", parent, 0.5, 0.5, parent.pos_x, parent.pos_y, font)
            current_surf.txt = "current part"
            next_surf = Subsurface("next", parent, 0.5, 0.5, parent.pos_x, parent.pos_y + current_surf.surface.height, font)
            next_surf.txt = "next part"
            beat_surf = Subsurface("beat", parent, 0.5, 1, parent.pos_x + parent.surface.width/2, parent.pos_y, font)
            beat_surf.txt = "1"
