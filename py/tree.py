#! /bin/env python

import re

class node :

    def __init__(self,name,up) :
        self.name = name
        self.up = up
        self.down = list()
        self.level = up.level + 1
        self.filter = true
        self.gui = None

    def __str__(self) :
        return "(%d) %s : %s : %d" % (self.level,self.name,self.up.name,len(self.down))

    def print_tree(self) :
        if not self.filter : return
        print self.level*" " + self
        for d in down :
            d.print_tree()

    def filter_tree(self,regexp,force=false) :
        if force : self.filter=true
        else :
            if re.search(regexp,self.name) : self.filter=true
        if self.filter :
            for d in self.down : d.filter_tree(regexp,true)
        else :
            for d in self.down : self.filter = self.filter or d.filter_tree(regexp)
        return self.filter

####

if __name == "__main__" :


