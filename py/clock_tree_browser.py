#! /usr/bin/env python

import sys , getopt

import clock_tree_icc as cticc
import clock_tree_gui as ctgui
from clock_tree_CTSNode import CTSNode

if ( sys.version_info < (2,7) or sys.version_info >= (3,0) ) :
    print( '''
Error : requires Python 2.7+
        Python 3.x is _not_ supported
''' )
    sys.exit()


########################################
## parse command line

def usage() :
    print( """
--------------------------------------------------------------------------------

clock_tree_browser.py  [-h --help]  <CTS file>

--------------------------------------------------------------------------------

important note : requires Python 2.7+ _and_ Tk 8.5+
                 to get Tk bundled, install Python 2.7 from http://www.activestate.com/activepython/downloads
                 Python 3.x is _not_ supported
""")
    sys.exit()

########################################
## args and options

try:
    opts, args = getopt.getopt( sys.argv[1:], "hd", ["help","debug"] )
except getopt.GetoptError as err:
    print(err)
    usage()
    
debug = False

for o, a in opts:
    if o in ("-h", "--help"): usage()
    elif o in ("-d", "--debug"):
        print( '\n**** Debug Mode ****\n' )
        debug = True
        ctgui.debug = True
       #cticc.debug = True
    else:
        assert False, "Unknown option '%s' , skip" % o

## input files

if ( len(args)<1 ) :
    usage()

TOP = CTSNode( '' , None , level=-3 )
for file in args :
    cts = cticc.read_cts_icc( file , TOP )


########################################
## GUI

ctgui.TOP = TOP
ctgui.ctgui()

