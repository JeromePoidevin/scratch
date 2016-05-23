
import Tkinter as tk
import re
import sys
import gzip


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

    def draw_point (self,size,**arg) :  # **arg : key=value options for create_rectangle
        global tkcanva
        if self.point == None :
            ( x  , y  ) = xy_def2win( self.x , self.y )
            ( x1 , y1 ) = ( x-size , y-size )
            ( x2 , y2 ) = ( x+size , y+size )
            self.point = tkcanva.create_rectangle(x1,y1,x2,y2,arg)
        else :
            tkcanva.itemconfig(self.point,arg)


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
        global tkcanva
        if self.bbox == None :
            ( x1 , y1 ) = xy_def2win( self.x1 , self.y1 )
            ( x2 , y2 ) = xy_def2win( self.x2 , self.y2 )
            self.bbox = tkcanva.create_rectangle(x1,y1,x2,y2,arg)
        else :
            tkcanva.itemconfig(self.bbox,arg)


########################################
## read LEF file
## 1) MACRO
## 2) SIZE
## 3) END <macro>

def read_lef( filename ) :

    debug = False
    global lef

    print( "Info : read_lef '%s'" % filename )

    if filename[-3:] == '.gz' :
        F = gzip.open(filename,'rb')
    else :
        F = open(filename,'r')

    test = 0

    while test==0 :
        test += 1  # when eof , test gets > 1

        ## MACRO
        for line in F :
            m = re.match('MACRO +(\w+)' ,line)
            if m :
                if debug : print line,
                test = 0
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
                break

        ## END
        endmacro = 'END '+macro
        for line in F :
            if re.match(endmacro ,line) :
                if debug : print line,
                macro = ''
                break

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

    print( "Info : read_def '%s'" % filename )

    if filename[-3:] == '.gz' :
        F = gzip.open(filename,'rb')
    else :
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
        m = re.match('^- *(\S+) +(\S+) *.*\+ *\w+ *\( *(\d+) +(\d+) *\) +(\w+)',line)
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
        else           : inst.draw_bbox(fill='grey') # inst.draw_point(1,outline='red',fill='red')


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
## read hier file for coloring

def read_hier( filename ) :

    debug = False
    hier_l = list()

    print( "Info : read_hier '%s'" % filename )

    F = open(filename,'r')

    for line in F :
        hier = line.strip()  # remove white spaces including newline
        hier_l.append(hier)

    return hier_l


########################################
## draw_hier

def draw_hier( hier_l ) :

    debug = False
    MacroInst.debug = False

    global floorplan
    global instances

    print( "Info : draw_hier" )

    colors = Colors( 'yellow green' , 'dodger blue' , 'orange2' , 'indian red' , 'burlywood3' ,
                     'DarkOliveGreen2' , 'SkyBlue1' , 'sienna1' , 'coral1' , 'khaki3' )

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

    global tkcanva
    global floorplan
    global instances

    xy_l = list()

    for (i,name_hi) in enumerate( inst_l ) :
        (name,hi) = name_hi
        inst = floorplan.get(name) or instances.get(name)
        if inst==None : print "%4d    .. not found .. %s" % (i,name)
        else          : print "%4d    %s" % (i,inst)
        if inst != None :
            if hi : inst.draw_point( 2 , fill=color , outline='white' )
            else  : inst.draw_point( 1 , fill=color )
           # FIXME create_text ignored ?
           #tkcanva.create_text( inst.x,inst.y , fill=color , text=str(i) , font=('Arial',8) , anchor='n' )
            xy_l.append( xy_def2win(inst.x,inst.y) )

    tkcanva.create_line( xy_l , fill=color )


def pin2inst( line ) :
    instpin = line.split()[0]
    inst    = instpin.rsplit('/',1)[0]
    return inst
   #if instpin.rfind('/') >= 0 :
   #    (inst,pin) = instpin.rsplit('/',1)
   #    return inst
   #else :
   #    return instpin  # top level ports


def read_timing( filename ) :

    debug = False

    print( "Info : read_timing '%s'" % filename )

    F = open(filename,'r')

    colors = Colors( 'red' , 'purple' , 'pink' , 'brown' )

    test = 0
    num = -1
    hi = False
    re_comment = re.compile(' *[=\+\*-/:;,#]+')  # space + one or more special character

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
                if debug : print ":"+line,
                inst = pin2inst( line )
                inst_l = list()
                inst_l.append( (inst,True) )
                hi = False
                break

        for line in F :

            if line == '' : continue  # empty line
            if re_comment.match(line) :  # comment
                if re.search('True',line) : hi = True
                elif re.search('False',line) : hi = False
                continue

            if re.match(' *'+inst ,line) : continue  # (inst) repeated (input followed by output)
            if re.match(' *\S+ *\(net\)' ,line) : continue # (net)

            if debug : print "::"+line,
            inst = pin2inst( line )
            inst_l.append( (inst,hi) )
            if inst == end :
                if debug : print "::END"
                draw_path( inst_l , color )
                break

    F.close()


########################################
## parse command line

def usage() :
    print """
def_viewer.py  -def <DEF file> [...]  [-lef <LEF file> ...]  [-color <colors file> ...]  [-timing <timing reports file> ...]  [-window <window size>]

    -def <DEF file> ...
    -lef <LEF file> ...
    -color <colors file> ...
    -timing <timing report file> ...
    -window <window size 500x500>
"""
    sys.exit()


def parse_cmd_line() :

    debug = True

    argv = sys.argv[1:]
    if argv==() : usage()

    def_l = list()
    lef_l = list()
    color_l = list()
    timing_l = list()
    window = '500x500'

    i = 0
    while ( i < len(argv) ) :
        if   argv[i] == '-h' or argv[i] == '-help' : usage()
        elif argv[i] == '-def' : def_l.append( argv[i+1] )
        elif argv[i] == '-lef' : lef_l.append( argv[i+1] )
        elif argv[i] == '-color' : color_l.append( argv[i+1] )
        elif argv[i] == '-timing' : timing_l.append( argv[i+1] )
        elif argv[i] == '-window' : window = argv[i+1]
        else :
            print "ERROR: unkown option '%s' ; exit" % argv[i]
            sys.exit(1)
        i += 2

    if debug :
        print """
def_viewer.py
    -def %s
    -lef %s
    -color %s
    -timing %s
    -window %s
"""  %  ( def_l , lef_l , color_l , timing_l , window )

    return ( def_l , lef_l , color_l , timing_l , window )


########################################
## main

( def_l , lef_l , color_l , timing_l , window ) = parse_cmd_line()

debug = False

if debug :
    def_l = [ 'chip_prects_leak_route_opt.def.gz' ]
    lef_l = [ 'ascdhd.lef' , 'DPRAM_1Kx32cm4bw.lef' , 'DPRAM_256x32cm4bw.lef' , 'SRAM_1Kx32cm4bw.lef' , 'SRAM_6Kx32cm16bw.lef' , 'SRAM_8Kx32cm16bw.lef' ]
    color_l = [ 'def_viewer.color' ]
    timing_l = [ 'flexram_pnr.txt' ]


tkmaster = tk.Tk()

(win_x,win_y) = window.split('x')
(win_x,win_y) = (int(win_x),int(win_y))
tkcanva = tk.Canvas(tkmaster, width=win_x, height=win_y)
tkcanva.pack() 

lef = dict()
for lef_file in lef_l :
    read_lef( lef_file )

floorplan = dict()
instances = dict()
for def_file in def_l :
    read_def( def_file )

draw_floorplan()

hier_l = list()
for color_file in color_l :
    hier_l += read_hier(color_file)
draw_hier( hier_l )

for timing_file in timing_l :
    read_timing( timing_file )

tk.mainloop()

