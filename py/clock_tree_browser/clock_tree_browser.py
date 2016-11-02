#! /usr/bin/env python

import sys , getopt

import clock_tree_icc as cticc
import clock_tree_at91cts as ctat91
import clock_tree_ccopt as ctccopt
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

clock_tree_browser.py  [-h --help]  (--icc|--at91|--ccopt)  <CTS file>

--------------------------------------------------------------------------------

important note : requires Python 2.7+ _and_ Tk 8.5+
                 Python 3.x is _not_ supported
""")
    sys.exit()

########################################
## args and options

try:
    opts, args = getopt.getopt( sys.argv[1:], "hd", ["help","debug","icc","at91","ccopt"] )
except getopt.GetoptError as err:
    print(err)
    usage()
    
debug = False
mode = ""

for o, a in opts:
    if o in ("-h", "--help"): usage()
    elif o in ("-d", "--debug"):
        print( '\n**** Debug Mode ****\n' )
        debug = True
        ctgui.debug = True
       #cticc.debug = True
    elif o=="--icc" : mode = "icc"
    elif o=="--at91" : mode = "at91"
    elif o=="--ccopt" : mode = "ccopt"
    else:
        assert False, "Unknown option '%s' , skip" % o

if ( mode == "" ) :
    print( "Error: must specify mode : (--icc|--at91cts|--ccopt)" )
    usage()

## input files

if ( len(args)<1 ) :
    print( "Error: no CTS file" )
    usage()

TOP = CTSNode( '' , None , level=-3 )
for file in args :
    if mode=="icc" :
        cts = cticc.read_cts_icc( file , TOP )
    elif mode=="at91" :
        cts = ctat91.read_cts_at91cts( file , TOP )
    elif mode=="ccopt" :
        cts = ctccopt.read_cts_ccopt( file , TOP )


########################################
## GUI

ctgui.TOP = TOP
ctgui.ctgui()

