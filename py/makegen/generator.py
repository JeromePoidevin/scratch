#! /usr/bin/python

class Generator :
  targets = list()
  
  def __init__(self,name,cmd,out,groups) :
    self.name = name
    self.cmd = cmd
    self.out = out
    self.groups = groups

  def __str__(self) :
    return "%s %s : %s > %s" % (self.name,self.groups,self.cmd,self.out)

####

gen = dict()

def def_gen(name, cmd='', out='', groups=[] ) :
  gen[name] = Generator(name,cmd,out,groups)

def_gen('toto',    cmd='cmd1',out='toto.v',groups=('all','rtl'))
def_gen('toto new',cmd='cmd2',out='toto.v',groups=('all','rtl'))

####

def set_targets( more_targets ) :
  Generator.targets = more_targets
  print "targets  = %s" % Generator.targets

####

def run_gen(name, dir=None, opts='', groups=[] ) :
  if name in gen :
    g = gen[name]
  else :
    print "ERROR : %s has no generator defined" % name
    return
  run = False
  for t in Generator.targets :
    if (t == name) : run=True ; break  # t is a generator name
    if (t in groups) : run=True ; break # t is a custom group
    if (t in g.groups) : run=True ; break # t is a predefined group
  if run :
    cmd = g.cmd
    if opts :
      cmd += ' '+opts
    if dir and g.out :
      cmd += ' > '+dir+'/'+g.out
    print "%s => %s" % ( t,cmd )


########################################
## standalone tests

if ( __name__ == "__main__" ) :

  print "## def_gen ##"
  for name in gen :
    print gen[name]

  print "## run_gen ##"
  
  targets = ['all']
  for name in gen :
    run_gen(name, dir='test')

