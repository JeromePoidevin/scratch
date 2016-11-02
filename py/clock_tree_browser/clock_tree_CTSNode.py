
import re


########################################
## quite general class for n-trees
##
## self.up = one parent
## self.down = many children
## self.show = show or hide
##
## self.fanout = number of direct children
## self.cone = number of all cells below
## self.ff = number of sink (ff) pins
## self.min = min depth of downstream ff
## self.max = max depth of downstream ff


class CTSNode :

    debug = False
    number = 0
    mode = None
    
    def __init__(self,name,up,level=None,is_ff=False) :
        CTSNode.number += 1
        self.n = CTSNode.number
        self.name = name
        self.attach(up,level)
        self.down = list()
        self.is_ff = is_ff
        self.show = True
        self.highlight = False
        # statistics
        self.fanout = 0
        self.cone = 0
        self.ff = 0
        self.min = None
        self.max = None

    def attach(self,up,level=None) :
        self.up = up
        if up :
            self.level = up.level + 1
            up.down.append(self)
        else :
            if level : self.level = level
            else     : self.level = 0

    def __str__(self) :
        if CTSNode.debug :
            return "%d # %d # %s : %s %s %s : %d : %d %d %d : %s %s" % (self.n,self.level,self.name,self.show,self.highlight,self.is_ff,len(self.down),self.fanout,self.cone,self.ff,self.min,self.max)
        else :
            return "%s : %d : %d %d %d : %s %s" % (self.name,len(self.down),self.fanout,self.cone,self.ff,self.min,self.max)

    def print_tree(self,file=None,indent=None) :
        if not self.show : return
        if indent : tmp = self.level*indent + str(self)
        else      : tmp = str(self)
        if file   : file.write( tmp + "\n" )
        else      : print tmp
        for d in self.down :
            d.print_tree(file=file,indent=indent)

    # show / hide / find

    def show_node( self, name=None, level=None, min=None, max=None, skew=None ) :
        if name !=None and re.search(name,self.name) : return True
        if level!=None and self.level == level       : return True
        if min  !=None and self.ff > 0 and           self.min  <= min  : return True
        if max  !=None and self.ff > 0 and           self.max  >= max  : return True
        if skew !=None and self.ff > 0 and (self.max-self.min) >= skew : return True
        return False

    def find_tree( self, hideall=False, name=None, level=None, min=None, max=None, skew=None ) :
        # default : de-highlight , and optionally hide
        if hideall :
            self.show = False
        self.highlight = False
        # does self meet criterias ?
        if self.show_node(name,level,min,max,skew) :
            self.show = True
            self.highlight = True
        # look down in tree
        for d in self.down :
            d.find_tree(hideall,name,level,min,max,skew)
            self.show = self.show or d.show

    def show_hide_below(self,show) :
        self.show = show
        for d in self.down :
            d.show_hide_below(show)

    # count fanout / cone / ff / min / max
    # cumulating cone and ff for all down cells
    # min and max depth of downstream ff

    def statistics(self) :
        self.fanout = len(self.down)
        self.cone = self.fanout
        self.ff = 0
        self.min = None
        self.max = None

        # is ff ?
#        if CTSNode.mode=='icc' and re.search('SINK PIN|MACRO',self.name) :
#            is_ff = True
#        elif CTSNode.mode=='at91' and re.search('\([Ss]ync\)|\([Ll]eaf\)',self.name) :
#            is_ff = True
#        elif CTSNode.mode=='ccopt' and re.search('Pin=',self.name) :
#            is_ff = True
#        else :
#            is_ff = False
        if self.is_ff :
            self.ff = 1
            self.min = self.level
            self.max = self.level

        # step down
        for d in self.down :
            d.statistics()
            self.cone += d.cone
            if self.ff == 0 :
                self.ff = d.ff
                self.min = d.min
                self.max = d.max
            elif d.ff > 0 :
                self.ff += d.ff
                self.min = min( self.min , d.min )
                self.max = max( self.max , d.max )

        # checks
        if self.level == 0 :
            if self.ff == 0 :
                print "Warning : root pin with no ff attached : "
            print self
#            elif (self.max - self.min) > 10 :
#                print "Warning : root pin with (max-min) > 10 : " , self

        if self.is_ff and self.fanout > 0 :
                print "Warning : ff with fanout>0 : " , self



########################################
## standalone __main__

if ( __name__ == "__main__" ) :

    CTSNode.debug = False

    TOP = CTSNode('TOP',None)
    clk = CTSNode('clk',TOP)
    for i in "abcdef" :
        N1 = CTSNode(i,clk)
        if i in "ef" : N1.is_ff = True
        for j in "123" :
            N2 = CTSNode(i+j,N1)
            for k in "wxyz" :
                CTSNode(i+j+k,N2,is_ff=True)

    TOP.statistics()

    CTSNode.debug = True

    print "\n==== full tree ===="
    TOP.print_tree(indent="  ")

    print "\n==== level 2 ===="
    TOP.find_tree( hideall=True , level=2 )
    TOP.print_tree(indent="  ")

    print "\n==== level 2 + some ===="
    TOP.find_tree( hideall=False , name="b2|z" )
    TOP.print_tree(indent="  ")

    print "\n==== skew >= 2 ===="
    TOP.find_tree( hideall=True , skew=2 )
    TOP.print_tree(indent="  ")


