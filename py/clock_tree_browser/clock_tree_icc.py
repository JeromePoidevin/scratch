
import re
from clock_tree_CTSNode import CTSNode

debug = False


########################################
## read file
## return pointer to top-most CTSNode
##
## note : use upper case for CTSNode's

def read_cts_icc( filename , TOP=None ):

    global debug

    print( "Info : read_cts_icc '%s'" % filename )

    F = open(filename,'r')
    if TOP == None :
        CTS = CTSNode( filename, None, level=-2 )
    else :
        CTS = CTSNode( filename, TOP )
    clk = ''

    for line in F :

        ## clock declaration
        m = re.match('Printing structure within exceptions of (\w+) at root pin ',line)
        if m :
            clk = m.group(1)
            CLK = CTSNode( clk, CTS )
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

    CTS.statistics()

    return CTS



########################################
## standalone __main__

if ( __name__ == "__main__" ) :

    debug = False

    TOP = read_cts_icc( 'clock_tree_report_icc_init_design_CTS_scenario/clk_ahb.txt' )

    print "\n==== full tree ===="
    TOP.print_tree()

    print "\n==== level 2 ===="
    TOP.find_tree( hideall=True , level=2 )
    TOP.print_tree()

    print "\n==== level 2 + NVM ===="
    TOP.find_tree( hideall=False , name='.*i_nvm_block/clk' )
    TOP.print_tree()


