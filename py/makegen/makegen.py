#! /usr/bin/python

import sys
from generator import set_targets,run_gen

set_targets(sys.argv[1:])

print "## run_gen ##"
run_gen('toto')
run_gen('toto',dir='.')
run_gen('toto new',groups='new')
run_gen('NOPE')

