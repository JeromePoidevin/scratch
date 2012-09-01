#! /usr/bin/python

MAX = 100
ta = list()
tb = list()
tc = list()
td = list()

for i in xrange(-MAX,MAX) :
    ii = i+MAX
    ta.append( list() )
    tb.append( list() )
    tc.append( list() )
    td.append( list() )
    for j in range(-MAX,MAX) :
        jj = j+MAX
        a = i+j ; ta[ii].append( a )
        b = i-j ; tb[ii].append( b )
        c = i*j ; tc[ii].append( c )
        if (j!=0) : d = float(i)/j
        else      : d = 123.789
        td[ii].append( d )
        print( "%d %d : %d %d %d %.1f" % (i,j,a,b,c,d) )

