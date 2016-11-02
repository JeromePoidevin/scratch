
import re
from clock_tree_CTSNode import CTSNode

debug = False


########################################
## indent_to_level
## check_indent_vs_level

def indent_to_level( indent ) :
    return len(indent) / 2


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

def read_cts_at91cts( filename , TOP=None ):

    global debug

    print( "Info : read_cts_at91cts '%s'" % filename )

    F = open(filename,'r')
    if TOP == None :
        CTS = CTSNode( filename, None, level=-2 )
    else :
        CTS = CTSNode( filename, TOP )
    clk = None
    prev = None

    for line in F :

        line = line.rstrip()

        ## clock declaration
        m = re.match('-I-   ( *)\*DEPTH (0): (.*?) ',line)
        if m :
            clk = m.group(3)
            CLK = CTSNode( clk, CTS )
            hier = list()
            hier.append(CLK)

        if line == '' : clk = None
        if clk == None : continue

#        ## tool warnings
#        if re.match('.* reconvergent clock path found',line) :
#            print("Warning : " + clk + line)
#            continue

        ## line matches tree structure
        m1 = re.match('-I-   ( *)\*DEPTH (\d+):',line)
        m2 = re.match('-I-   ( *)\((\w+)\)\S+/(\w+)',line)   # (2) = (Leaf|Sync|Excl|Gating|Preserve|Data)

        if (not m1) and (not m2) : continue

        is_ff = False

        if m1 :
            (indent,level) = m1.group(1,2)
            check_indent_vs_level( indent , level )
            if prev != None :
                line += prev

        if m2 :
            indent = m2.group(1)
            level = indent_to_level( indent )
            ## test level + hier
            if level+1 < len(hier) : # step up in hier
                hier = hier[0:level+1]  # level included
            ## Gating pins : don't print now , append to next line
            if m2.group(2) in ('Gating','gating','Preserve','preserve','Through','through') :
                prev = ' (%s %s)' % m2.group(2,3)
                continue
            else :
                prev = None
            ## FF pins
            if m2.group(2) in ('Sync','sync','Leaf','leaf') :
                is_ff = True
    
        UP = hier[-1]
        CURRENT = CTSNode( line , UP , is_ff=is_ff )

        if m1 :
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

    TOP = read_cts_at91cts( 'check_func_spec.log' )

    print "\n==== full tree ===="
    TOP.print_tree()

    print "\n==== level 2 ===="
    TOP.find_tree( hideall=True , level=2 )
    TOP.print_tree()

    print "\n==== level 2 + NVM ===="
    TOP.find_tree( hideall=False , name='.*i_nvm_block/clk' )
    TOP.print_tree()


