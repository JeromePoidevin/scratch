
import re

debug = False


########################################
## quite general class for n-trees
##
## class.criteria = for find & filter
##
## self.up = one parent
## self.down = many children
## self.show = show or hide
##
## self.fanout = number of direct children
## self.cone = number of all cells below
## self.ff = number of sink pins


class CTSNode :

    criteria = list()
    
    def __init__(self,name,up,**kwargs) :
        self.name = name
        self.up = up
        self.down = list()
        if up==None :
            if 'level' in kwargs : self.level = kwargs['level']
            else                 : self.level = 0
        else :
            self.level = up.level + 1
            up.down.append(self)
        self.show = True
        # pointer to gui object (node in Tk Tree)
        self.gui = None
        # this is custom for additional attributes ...
        self.fanout = 0
        self.cone = 0
        self.ff = 0

    def __str__(self) :
        return "%d # %s : %s : %d : %d %d %d" % (self.level,self.name,self.show,len(self.down),self.fanout,self.cone,self.ff)

    def print_tree(self) :
        if not self.show : return
        print self.level*" " + str(self)
        for d in self.down :
            d.print_tree()

    # show / hide / find

    def show_node(self) :
        for (c,v) in CTSNode.criteria :
            if c=='name' and re.search(v,self.name) : return True
            elif c=='level' and self.level<=v : return True
        return False

    def find_tree(self,hideall) :
        if hideall :
            self.show = False
        if self.show_node() :
            self.show = True
        for d in self.down :
            # warning : don't swap ! rhs if ir is not evaluated if lhs is true !
            self.show = d.find_tree(hideall) or self.show
        return self.show

    def show_hide_below(self,show) :
        self.show = show
        for d in self.down :
            d.show_hide_below(show)

    # count fanout / cone / ff
    # cumulating cone and ff for all down cells

    def statistics(self) :
        self.fanout = len(self.down)
        self.cone = self.fanout
        self.ff = 0
        if re.search('SINK PIN|MACRO',self.name) :
            self.ff = 1
        for d in self.down :
            (f,c,ff) = d.statistics()
            self.cone += c
            self.ff += ff
        return ( self.fanout, self.cone, self.ff )


########################################
## read file
## return pointer to top-most CTSNode
##
## note : use upper case for CTSNode's

def read_cts_icc( filename ):

    global debug

    print( "Info : read_cts_icc '%s'" % filename )

    F = open(filename,'r')
    TOP = CTSNode( filename, None, level=-2 )
    clk = ''

    for line in F :

        ## clock declaration
        m = re.match('Printing structure within exceptions of (\w+) at root pin ',line)
        if m :
            clk = m.group(1)
            CLK = CTSNode( clk, TOP )
            hier = list()
            hier.append(CLK)
            continue

        if clk == '' : continue

        ## tool warnings
        if re.match('.* reconvergent clock path found',line) :
            print("Warning : " + clk + line)
            continue

        ## line matches tree structure
        m = re.match(' *\((\d+)\) (.*?)( |\[\w+:)',line)
        if not m : continue

        level = m.group(1)
        inst = m.group(2)

        ## test level + hier
        level = int(level)
        if level+1 < len(hier) : # step up in hier
            hier = hier[0:level+1]  # level included

        UP = hier[-1]
        CURRENT = CTSNode( line.rstrip() , UP )
        hier.append(CURRENT)

        if debug :
            print "\nUP = %s\nCURRENT = %s" % (UP,CURRENT)

    F.close()

    TOP.statistics()

    return TOP



########################################
## standalone __main__

if ( __name__ == "__main__" ) :

    debug = False

    TOP = read_cts_icc( 'clock_tree_report_icc_init_design_CTS_scenario/clk_ahb.txt' )

    print "\n==== full tree ===="
    TOP.print_tree()

    print "\n==== level 2 ===="
    CTSNode.criteria = [ ('level',2) ]
    TOP.find_tree( True )
    TOP.print_tree()

    print "\n==== level 2 + NVM ===="
    CTSNode.criteria = [ ('name','.*i_nvm_block/clk') ]
    TOP.find_tree( False )
    TOP.print_tree()


