
import re


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

    debug = False
    number = 0
    
    def __init__(self,name,up,level='') :
        CTSNode.number += 1
        self.n = CTSNode.number
        self.name = name
        self.attach(up,level)
        self.down = list()
        self.show = True
        self.highlight = False
        # pointer to gui object (node in Tk Tree)
        self.gui = None
        # this is custom for additional attributes ...
        self.fanout = 0
        self.cone = 0
        self.ff = 0

    def attach(self,up,level='') :
        self.up = up
        if up==None :
            if level != '' : self.level = int(level)
            else           : self.level = 0
        else :
            self.level = up.level + 1
            up.down.append(self)

    def __str__(self) :
        if CTSNode.debug :
            return "%d # %d # %s : %s %s : %d : %d %d %d" % (self.n,self.level,self.name,self.show,self.highlight,len(self.down),self.fanout,self.cone,self.ff)
        else :
            return "%s : %d : %d %d %d" % (self.name,len(self.down),self.fanout,self.cone,self.ff)

    def print_tree(self,file=None) :
        if not self.show : return
        if file == None :
            print self.level*" " + str(self)
        else :
            file.write( self.level*" " + str(self) )
        for d in self.down :
            d.print_tree(file=file)

    # show / hide / find

    def show_node(self,name='',level='') :
        if name!='' and re.search(name,self.name) : return True
        if str(level)!='' and self.level<=int(level) : return True
        return False

    def find_tree(self,hideall=False,name='',level='') :
        # default : de-highlight , and optionally hide
        if hideall :
            self.show = False
        self.highlight = False
        # does self meet criterias ?
        if self.show_node(name,level) :
            self.show = True
            self.highlight = True
        # look down in tree
        for d in self.down :
            # warning : don't swap ! rhs if ir is not evaluated if lhs is true !
            self.show = d.find_tree(hideall,name,level) or self.show
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
## standalone __main__

if ( __name__ == "__main__" ) :

    CTSNode.debug = False

    TOP = CTSNode('TOP',None)
    clk = CTSNode('clk',TOP)
    for i in "abcdefghijklmnopqrstuvwxyz" :
        l = CTSNode(i,clk)
        for j in "123" :
            CTSNode(i+j,l)

    CTSNode.debug = True

    print "\n==== full tree ===="
    TOP.print_tree()

    print "\n==== level 2 ===="
    TOP.find_tree( hideall=True , level=2 )
    TOP.print_tree()

    print "\n==== level 2 + some ===="
    TOP.find_tree( hideall=False , name="b2|z" )
    TOP.print_tree()


