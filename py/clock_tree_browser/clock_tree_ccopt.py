
import re
from clock_tree_CTSNode import CTSNode

debug = False


########################################
## indent_to_level
## check_indent_vs_level

def indent_to_level( indent ) :
    return len(indent) / 4


def check_indent_vs_level( indent , level ):
    indent = indent_to_level( indent )
    level = int(level)
    if indent != level :
        print("Error : indent '%d' > depth '%d'" % (indent,level) )


########################################
## read file
## return pointer to top-most CTSNode
##
## note : use upper case for CTSNode's

def read_cts_ccopt( filename , TOP=None ):

    global debug

    print( "Info : read_cts_ccopt '%s'" % filename )

    F = open(filename,'r')
    if TOP == None :
        CTS = CTSNode( filename, None, level=-2 )
    else :
        CTS = CTSNode( filename, TOP )
    clk = None

    for line in F :

        line = line.rstrip()

        ## clock declaration
        m = re.match('Dump of clock tree (\S+)',line)
        if m :
            clk = m.group(1)
            CLK = CTSNode( clk, CTS )
            hier = list()
            hier.append(CLK)
            continue

        if line == '' : continue

#        ## tool warnings
#        if re.match('.* reconvergent clock path found',line) :
#            print("Warning : " + clk + line)
#            continue

        ## line matches tree structure
        m = re.match('R\(\S+\):',line)
        is_ff = False
        if m :
            level = 0
        else :
            m = re.match('([ \|]*._ )(\S+[:=])',line)   # how to grab '\' (backslash) ?
            if (not m) : continue
            indent = m.group(1)
            level = indent_to_level( indent )
            if (m.group(2) == 'Pin=') :
                is_ff = True

        ## test level + hier
        if level+1 < len(hier) : # step up in hier
            hier = hier[0:level+1]  # level included
    
        UP = hier[-1]
        CURRENT = CTSNode( line , UP , is_ff=is_ff )
        hier.append(CURRENT)

        if debug :
            print "\nUP = %s\nCURRENT = %s" % (UP,CURRENT)

    F.close()

    CTS.statistics()

    return CTS



########################################
## standalone __main__

if ( __name__ == "__main__" ) :

    debug = False

    TOP = read_cts_ccopt( 'report_ccopt_debug_clock_trees.rpt')

    print "\n==== full tree ===="
    TOP.print_tree()

    print "\n==== level 2 ===="
    TOP.find_tree( hideall=True , level=2 )
    TOP.print_tree()

    print "\n==== level 2 + NVM ===="
    TOP.find_tree( hideall=False , name='.*i_nvm_block/clk' )
    TOP.print_tree()


