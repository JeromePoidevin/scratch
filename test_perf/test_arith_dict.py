#! /usr/bin/python

MAX = 100
ta = dict()
tb = dict()
tc = dict()
td = dict()

for i in xrange(-MAX,MAX) :
    for j in range(-MAX,MAX) :
        a = i+j ; ta[i,j] = a
        b = i-j ; tb[i,j] = b
        c = i*j ; tc[i,j] = c
        if (j!=0) : d = float(i)/j
        else      : d = 123.789
        td[i,j] = d
        print( "%d %d : %d %d %d %.1f" % (i,j,a,b,c,d) )

