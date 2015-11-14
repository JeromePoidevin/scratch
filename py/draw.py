from Tkinter import *

debug = True 

########################################
## (def coordinates) -> (win coordinates)

def xy_def2win (dx,dy) :
    global scale
    global win_y
    wx = (dx * scale)  # fixme : + fp_x1
    wy = win_y - (dy * scale)  # fixme : + fp_y1
    if debug : print "( %d , %d ) -> ( %d , %d )" % (dx,dy,wx,wy) 
    return (wx,wy)


########################################
## classes for DEF objects

class Inst :

    def __init__ (self,name,x,y) :
        self.name = name
        ( self.x , self.y ) = ( x , y )
        global debug
        if debug : print self

    def __str__ (self) :
        return "Inst ( %d , %d ) %s" % (self.x,self.y,self.name)

    def draw (self,**arg) :  # **arg : key=value options for create_rectangle
        global w
        ( x1 , y1 ) = xy_def2win( self.x , self.y )
        ( x2 , y2 ) = ( x1+5 , y1-5 )  # y-5 because of inverted y-axis
        w.create_rectangle(x1,y1,x2,y2,arg)


class MacroInst :

    def __init__ (self,name,x,y,sizex,sizey) :
        self.name = name
        ( self.x1 , self.y1 ) = ( x , y )
        ( self.x2 , self.y2 )  = ( x+sizex , y+sizey )
        ( self.x  , self.y  ) = ( x+0.5*sizex , y+0.5*sizey )
        global debug
        if debug : print self

    def __str__ (self) :
        return "MacroInst ( %d , %d ) %s" % (self.x,self.y,self.name)

    def draw (self,**arg) :   # **arg : key=value options for create_rectangle
        global w
        ( x1 , y1 ) = xy_def2win( self.x1 , self.y1 )
        ( x2 , y2 ) = xy_def2win( self.x2 , self.y2 )
        w.create_rectangle(x1,y1,x2,y2,arg)


########################################
## read file

def read_def( filename ):

    global debug
    global scale
    global floorplan
    global instances
    scale     = float()
    floorplan = dict()
    instances = dict()

    section = ''

    print( "Info : read_def '%s'" % filename )

    F = open(filename,'r')

    for line in F :

        ## size
        m = re.match('DIEAREA \( (\d+) (\d+) \) \( (\d+) (\d+) \)' ,line)
        if m :
            fp_x1 = m.group(1)
            fp_y1 = m.group(2)
            fp_x2 = m.group(3)
            fp_y2 = m.group(4)
            scale = min( win_x/(fp_x2-fp_x1) , win_y/(fp_y2-fp-y1) )
            floorplan[''] = MacroInst('',fp_x1,fp_y1,fp_x2,fp_y2)
            continue

        ## instances
        if re.match('COMPONENTS ',line) :
            section = 'COMPONENTS'
            continue
        elif re.match('END COMPONENTS ',line) :
            section = ''
            return  ## only read COMPONENTS !

        if section != 'COMPONENTS' :
            continue


########################################
## standalone __main__

if ( __name__ == "__main__" ) :

    master = Tk()
    
    win_x = 500
    win_y = 500
    w = Canvas(master, width=win_x, height=win_y)
    w.pack()
    
   #read_def( 'chip_floor.def' )

    fp_x = float(1200)
    fp_y = float(900)
    scale = min( (win_x/fp_x) , (win_y/fp_y) )
    # floorplan is a regular Rectangle with no fill
    fp = MacroInst('',0,0,fp_x,fp_y)
    fp.draw()
    
    MacroInst('m1',100,100,200,200).draw(fill='grey')
    MacroInst('m2',300,300,200,200).draw(fill='blue')
    Inst('i1',100,100).draw(fill='red')
    Inst('i2',300,300).draw(fill='green')

   
    mainloop()
    
    #w.create_rectangle( (100,100),(300,300), fill='yellow' )
    #w.create_line(0, 0, 200, 100)
    #w.create_line(0, 100, 200, 0, fill="red", dash=(4, 4))

