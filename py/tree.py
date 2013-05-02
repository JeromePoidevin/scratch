#! /bin/env python

import re

class node :

    criteria = list()
    
    def __init__(self,name,up) :
        self.name = name
        self.up = up
        self.down = list()
        if up==None :
            self.level = 1
        else :
            self.level = up.level + 1
            up.down.append(self)
        self.show = True
        self.gui = None

    def __str__(self) :
        if self.up==None : up = ""
        else : up = self.up.name
        return "(%d) %s : %s : %s : %d" % (self.level,self.name,self.show,up,len(self.down))

    def print_tree(self) :
        if not self.show : return
        print self.level*" " + str(self)
        for d in self.down :
            d.print_tree()

    def show_node(self) :
        for (c,v) in node.criteria :
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

####

if __name__ == "__main__" :

    pm = node("papy mamie",None)
    j = node("jerome",pm)
    i = node("isa",pm)
    a = node("tonio",pm)
    for e in ("zoe","lila","amandine") : node(e,j)
    for e in ("marie","rapha","juju","sasa") : node(e,i)
    for e in ("maxime","heloise") : node(e,a)

    print "\n** full tree **"    
    pm.print_tree()
    
    print "\n** hide jerome **"    
    j.show_hide_below(False)
    pm.print_tree()
    
    print "\n** filter lila , then juju, then amandine **"
    node.criteria = [ ("name","lila") ]
    pm.find_tree(True)
    node.criteria = [ ("name","juju") ]
    pm.find_tree(False)
    node.criteria = [ ("name","amandine") ]
    pm.find_tree(False)
    pm.print_tree()
    
    print "\n** filter level 2 **"
    node.criteria = [ ("level",2) ]
    pm.find_tree(True)
    pm.print_tree()
    
    print "\n** filter max or raph **"    
    node.criteria = [ ("name","max.*|raph.*") ]
    pm.find_tree(True)
    pm.print_tree()
    
