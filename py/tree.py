#! /bin/env python
# -*- coding: utf-8 -*-

import re

class node :

    def __init__(self,name,up) :
        self.name = name
        self.up = up
        self.down = list()
        if up==None :
            self.level = 1
        else :
            self.level = up.level + 1
            up.down.append(self)
        self.filter = True
        self.gui = None

    def __str__(self) :
        if self.up==None : up = ""
        else : up = self.up.name
        return "(%d) %s : %s : %d" % (self.level,self.name,up,len(self.down))

    def print_tree(self) :
        if not self.filter : return
        print self.level*" " + str(self)
        for d in self.down :
            d.print_tree()

    def filter_tree(self,regexp) :
        if re.search(regexp,self.name) :
            self.filter=true
        for d in self.down :
            self.filter = self.filter or d.filter_tree(regexp)
        return self.filter

    def show_hide_below(self,show) :
        self.filter = show
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
    
    pm.print_tree()
    
