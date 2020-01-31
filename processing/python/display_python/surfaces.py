AREA_NAMES = ["song", "utterances", "blocks", "part_info"]
AREAS = {}
# SUBSURFACE_NAMES = ["utts", "cats", "current_part", "next_part", "beat"]


class Area:
    def __init__(self, tempName, surface, pos_x, pos_y):
        self.name = tempName
        self.surface = surface
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.subsurfaces = {}
        self.fill_surface(222)
    
    def fill_surface(self, col):
        with self.surface.beginDraw():
            self.surface.background(col) 
        # print("filled {} with {}".format(self.name, col))
      
    def update_subsurfaces(self, name, surface):
        for value in list(self.subsurfaces.values()):
            surf = value.surface
            if name == value.name:
                surf = surface
            
class Subsurface:
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
        self.utterance_dict = {}
        self.surface = createGraphics(int(self.parent.surface.width * self.x_div), int(self.parent.surface.height * self.y_div))
        self.surface.smooth()
        self.parent.subsurfaces[self.name] = self
    
    def text_on_surface(self, surface, txt, font, font_size,  col):
        with surface.beginDraw():
            surface.background(222)
            surface.textFont(font)
            surface.textSize(font_size)
            surface.textAlign(CENTER)
            surface.fill(col)
            surface.text(txt, surface.width/2, surface.height/2, surface.width, surface.height)
        return surface
    
    def utts_on_surface(self, surface, txt, font):
        pass
    
    def update_beat(self, beat_number, change_color):
        # print("beat {} change?  {}".format(beat_number, change_color))
        if change_color == "True":
            self.beat_color = color(250, 0, 150)
        else: 
            self.beat_color = color(10, 250, 20)
        self.txt = beat_number
        self.surface = self.text_on_surface(self.surface, self.txt, self.font, 80, self.beat_color)
        self.parent.update_subsurfaces(self.name, self.surface)
    
    def update_current(self, current_part):
        self.surface = self.text_on_surface(self.surface, "current part - \n" + current_part, self.font, 20,  color(50))
        self.parent.update_subsurfaces(self.name, self.surface)
    
    def update_next(self, next_part):
        self.surface = self.text_on_surface(self.surface, "next part - \n" + next_part, self.font, 20, color(50))
        self.parent.update_subsurfaces(self.name, self.surface)
    
    def update_utts(self, utterance):
        self.surface = self.text_on_surface(self.surface, utterance, self.font, 20, color(50))
        self.parent.update_subsurfaces(self.name, self.surface)

        

def build_areas(spacing_x, spacing_y): 
    pos_y1 = pos_y2 = height/16
    for i in range(len(AREA_NAMES)):
        if i <= 1:
            surface_width = width*8/13
            surface_height = height*7/16
            pos_x = width*2/3 
            surface = createGraphics(surface_width, surface_height )
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
            sub_surf1 = Subsurface("utts", parent, 0.66, 1, parent.pos_x, parent.pos_y, font)
            sub_surf2 = Subsurface("cats", parent, 0.33, 1, parent.pos_x + sub_surf1.surface.width, parent.pos_y, font)
        elif name == "part_info":
            current_surf = Subsurface("current", parent, 0.5, 0.5, parent.pos_x, parent.pos_y, font)
            current_surf.txt = "current part"
            next_surf = Subsurface("next", parent, 0.5, 0.5, parent.pos_x, parent.pos_y + current_surf.surface.height, font)
            next_surf.txt = "next Part"
            beat_surf = Subsurface("beat", parent, 0.5, 1, parent.pos_x + parent.surface.width/2, parent.pos_y, font)
            beat_surf.txt = 1
        else:
            pass
