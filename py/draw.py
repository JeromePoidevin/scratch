
import Tkinter as tk
import re

########################################
## (def coordinates) -> (win coordinates)

def xy_def2win (dx,dy) :
    debug = False
    global scale
    global win_y
    wx = (dx * scale)  # fixme : + fp_x1
    wy = win_y - (dy * scale)  # fixme : + fp_y1
    if debug : print "( %d , %d ) -> ( %d , %d )" % (dx,dy,wx,wy) 
    return (wx,wy)


########################################
## classes for DEF objects

class Inst :

    debug = False

    def __init__ (self,name,x,y) :
        self.name = name
        ( self.x , self.y ) = ( x , y )
        self.point = None
        if Inst.debug : print self

    def __str__ (self) :
        return "Inst ( %d , %d ) %s" % (self.x,self.y,self.name)

    def draw_point (self,**arg) :  # **arg : key=value options for create_rectangle
        global w
        if self.point == None :
            ( x  , y  ) = xy_def2win( self.x , self.y )
            ( x1 , y1 ) = ( x-1 , y-1 )
            ( x2 , y2 ) = ( x+1 , y+1 )
            self.point = w.create_rectangle(x1,y1,x2,y2,arg)
        else :
            w.itemconfig(self.point,arg)


class MacroInst (Inst) :  # Macro extends Inst

    debug = True

    def __init__ (self,name,x,y,sizex,sizey) :
        self.name = name
        ( self.x1 , self.y1 ) = ( x , y )
        ( self.x2 , self.y2 )  = ( x+sizex , y+sizey )
        ( self.x  , self.y  ) = ( x+0.5*sizex , y+0.5*sizey )
        self.point = None
        self.bbox = None
        if MacroInst.debug : print self

    def __str__ (self) :
        return "MacroInst ( %d , %d ) %s" % (self.x,self.y,self.name)

    def draw_bbox (self,**arg) :   # **arg : key=value options for create_rectangle
        global w
        if self.bbox == None :
            ( x1 , y1 ) = xy_def2win( self.x1 , self.y1 )
            ( x2 , y2 ) = xy_def2win( self.x2 , self.y2 )
            self.bbox = w.create_rectangle(x1,y1,x2,y2,arg)
        else :
            w.itemconfig(self.bbox,arg)


########################################
## read LEF file
## 1) MACRO
## 2) SIZE

def read_lef( filename ) :

    debug = False
    global lef

    print( "Info : read_lef '%s'" % filename )

    F = open(filename,'r')

    ## MACRO
    for line in F :
        m = re.match('MACRO +(\w+)' ,line)
        if m :
            if debug : print line,
            macro = m.group(1)
            lef[macro] = (0,0)
            break

    ## SIZE
    for line in F :
        m = re.match(' *SIZE +(\d+\.?\d*) +BY +(\d+\.*\d*)' ,line)
        if m :
            if debug : print line,
            x = float(m.group(1))
            y = float(m.group(2))
            lef[macro] = (x,y)
            if debug : print "%s : %d x %d" % (macro,x,y)
            F.close()
            return


########################################
## read DEF file
## speed-up reading by looking for matches in order
## 1) UNITS
## 2) DIEAREA
## 3) start of COMPONENTS section
## 4) instances
## 5) end of COMPONENTS section

def read_def( filename ) :

    global scale
    global lef
    global floorplan
    global instances
    scale     = float()
    floorplan = dict()
    instances = dict()

    print( "Info : read_def '%s'" % filename )

    F = open(filename,'r')

    ## UNITS
    for line in F :
        m = re.match('UNITS DISTANCE \w+ (\d+)' ,line)
        if m :
            units = float(m.group(1))
            break

    ## DIEAREA
    for line in F :
        m = re.match('DIEAREA +\( *(\d+) +(\d+) *\) *\( *(\d+) +(\d+) *\)' ,line)
        if m :
            fpx1 = float(m.group(1)) / units
            fpy1 = float(m.group(2)) / units
            fpx2 = float(m.group(3)) / units
            fpy2 = float(m.group(4)) / units
            scale = min( win_x/(fpx2-fpx1) , win_y/(fpy2-fpy1) )
            floorplan[''] = MacroInst('',fpx1,fpy1,fpx2,fpy2)
            break

    ## start of COMPONENTS section
    for line in F :
        if re.match('COMPONENTS ',line) : break

    ## inside COMPONENTS section
    for line in F :

        ## instances
        m = re.match('^- *(\S+) +(\S+) *\+ *\w+ *\( *(\d+) +(\d+) *\) +(\w+)',line)
        if m :
            inst = m.group(1)
            cell = m.group(2)
            x    = float(m.group(3)) / units
            y    = float(m.group(4)) / units
            orient = m.group(5)
            if cell in lef :
                if orient in ( 'N' , 'S' , 'FN' , 'FS' ) :
                    (sizex , sizey) = lef[cell]
                elif orient in ( 'E' , 'W' , 'FE' , 'FW' ) :
                    (sizey , sizex) = lef[cell]    # rotate
                else :
                    print "Warning: LEF cell found , orient unknown : " + line
                m = MacroInst(inst,x,y,sizex,sizey)
                floorplan[inst] = m
            else :
                i = Inst(inst,x,y)
                instances[inst] = i
            continue

        ## end of COMPONENTS section
        if re.match('END +COMPONENTS',line) :
            section = ''
            F.close()
            print( "Info : read_def done" )
            return  ## only read COMPONENTS !



########################################
## draw_floorplan

def draw_floorplan() :

    global floorplan

    for (name,inst) in floorplan.iteritems() :
        if name==''    : inst.draw_bbox()
        else           : inst.draw_bbox(fill='grey') # inst.draw_point(outline='red',fill='red')


########################################
## Colors

class Colors :

    debug = True

    def __init__ (self,*colors) : # *colors = several colors
        self.colors = list( colors )
        self.all    = len( self.colors )
        self.num    = -1
        if Colors.debug : print self

    def __str__ (self) :
        return "Colors ( %s )" % self.colors
 
    def pick (self, num) :
        return self.colors[ num % self.all ] # modulo

    def next (self) :
        self.num += 1
        return self.pick( self.num )


########################################
## draw_hier

def draw_hier( hier_l ) :

    debug = False
    MacroInst.debug = False

    global floorplan
    global instances

    print( "Info : draw_hier" )

    colors = Colors( 'green' , 'blue' , 'orange' , 'lightgreen' , 'lightblue' )

    for (h,hier) in enumerate( hier_l ) :
        print "%d %s : %s" % (h,hier,colors.pick(h))

    ## loop on floorplan MacroInst ; color if it matches hier_l
    for (name,inst) in floorplan.iteritems() :
        if name==''    : continue
        for (h,hier) in enumerate( hier_l ) :
            if re.match( hier , name ) :
                c = colors.pick( h )
                inst.draw_bbox(fill=c)

    ## floorplan -> 100*100 checkerboard
    fp = floorplan['']
    fpx100 = (fp.x2 - fp.x1) / 100
    fpy100 = (fp.y2 - fp.y1) / 100

    instances_100_100 = len(instances) / 100 / 100

    ## loop on instances Inst ; count instances per 100*100 squares
    count = dict()

    for (name,inst) in instances.iteritems() :
        x  = int( (inst.x - fp.x1) / fpx100 )
        y  = int( (inst.y - fp.y1) / fpy100 )
        xy = (x,y)
        if xy not in count :
            count[xy] = dict()
            count[xy][''] = 0
        count[xy][''] += 1  # count all
        for (h,hier) in enumerate( hier_l ) :
            if re.match( hier , name ) :
                if debug : print "%d %s : %s : %s" % (h,hier,name,xy)
                if h not in count[xy] :
                    count[xy][h] = 0
                count[xy][h] += 1  # count hier
                break

    ## loop on 100*100 squares ; color if majority matches hier_l , else grey
    for xy in count :
        # plot only when significant number of instances (ie. std-cells area)
        if count[xy][''] < instances_100_100 : continue
        # default grey
        hier = '?'
        max = 0
        c = 'grey'
        # find max of hier_l 
        for h in count[xy] :
            if h == '' : continue  # all
            if count[xy][h] > max :
                hier = hier_l[h]
                c = colors.pick( h )
                max = count[xy][h]
        ( x , y ) = xy
        ( x , y ) = ( x*fpx100 , y*fpy100 )
        MacroInst(hier,x,y,fpx100,fpy100).draw_bbox(outline=c,fill=c)
        if debug : print( "%s : %s" % (xy,hier) )


########################################
## read timing report

def draw_path( inst_l , color ) :

    global w
    global floorplan
    global instances

    xy_l = list()

    for (i,name) in enumerate( inst_l ) :
        inst = floorplan.get(name) or instances.get(name)
        if inst==None : print "%4d    .. not found .. %s" % (i,name)
        else          : print "%4d    %s" % (i,inst)
        if inst != None :
            inst.draw_point( fill=color )
            xy_l.append( xy_def2win(inst.x,inst.y) )

    w.create_line( xy_l , fill=color )


def pin2inst ( line ) :
    inst = ''
    m = re.match(' *(\S+)/\w+' , line )
    if m :
        inst = m.group(1)
    return inst


def read_timing( filename ) :

    debug = False

    print( "Info : read_timing '%s'" % filename )

    F = open(filename,'r')

    colors = Colors( 'red' , 'purple' , 'pink' , 'brown' )

    test = 0
    num = -1

    while test==0 :
        test += 1  # when eof , test gets > 1

        for line in F :
            m = re.match(' *Startpoint: +(\S+)' ,line)
            if m :
                test = 0
                num += 1
                color = colors.pick(num)
                print "----------------------------------------"
                print "path %d %s" % (num,color)
                print line,
                start = m.group(1)
                break

        for line in F :
            m = re.match(' *Endpoint: +(\S+)' ,line)
            if m :
                print line,
                end = m.group(1)
                break
    
        for line in F :
            m = re.match(' *'+start ,line)
            if m :
                if debug : print line,
                inst = pin2inst( line )
                inst_l = list()
                inst_l.append(inst)
                break

        for line in F :
            if re.match(' *'+inst ,line) : continue
            if debug : print line,
            inst = pin2inst( line )
            inst_l.append( inst )
            if inst == end :
                draw_path( inst_l , color )
                break

    F.close()


########################################
## standalone __main__

if ( __name__ == "__main__" ) :

    lef = dict()

    master = tk.Tk()
    
    win_x = 500
    win_y = 500
    w = tk.Canvas(master, width=win_x, height=win_y)
    w.pack() 

    if True :
        lef['ascdhd_flash1mb'] = (3000000,4000000)
        lef['SRAM_8Kx32cm16bw'] = (500000,500000)
        lef['SRAM_1Kx32cm4bw'] = (200000,200000)
       #read_lef('ascdhd.lef')
       #read_lef('DPRAM_1Kx32cm4bw.lef')
       #read_lef('DPRAM_256x32cm4bw.lef')
       #read_lef('SRAM_1Kx32cm4bw.lef')
       #read_lef('SRAM_2Kx32cm8bw.lef')
       #read_lef('SRAM_6Kx32cm16bw.lef')
       #read_lef('SRAM_8Kx32cm16bw.lef')

        read_def( 'chip_test.def' )

        draw_floorplan()

        hier_l = list()
        hier_l.append( 'U_TOP_LOGIC/U_PDSW/U_CM4' )
        hier_l.append( 'U_TOP_LOGIC/U_PDSW/U_NVMCTRL' )
        hier_l.append( 'U_TOP_LOGIC/U_PDSW/U_FLEXRAM' )
        hier_l.append( 'U_TOP_LOGIC/U_PDSW/U_GCLK' )
        hier_l.append( 'U_TOP_LOGIC/U_PDSW/U_MCLK' )
        draw_hier( hier_l )

        read_timing( 'chip_timing.txt' )

    else :
        fp_x = float(1200)
        fp_y = float(900)
        scale = min( (win_x/fp_x) , (win_y/fp_y) )
        # floorplan is a regular Rectangle with no fill
        fp = MacroInst('',0,0,fp_x,fp_y)
        fp.draw_bbox()
        
        MacroInst('m1',100,100,200,200).draw_bbox(fill='grey')
        MacroInst('m2',300,300,200,200).draw_bbox(fill='blue')
        Inst('i1',100,100).draw_point(fill='red')
        Inst('i2',300,300).draw_point(fill='green')
    
        w.create_line(      0,0  ,  100,100  ,  100,0    , fill='black' )
        w.create_line(   (100,0) , (200,100) , (200,0)   , fill='green' )
        w.create_line( [  200,0  ,  300,100  ,  300,0  ] , fill='red'   )
        w.create_line( [ (300,0) , (400,100) , (400,0) ] , fill='blue'  )

   
    tk.mainloop()

