#! /usr/bin/python

debug = []
stats = dict()

def print_stats():
    global stats
    for lw in stats:
        for word in stats[lw]:
            print "%s / %s : %d" % (lw,word,stats[lw][word])

def read_text_markov( filename , markov_size ):
    global debug
    global stats
    
    filehandle = open( filename , 'r' )
    last_words = list(' ')*(markov_size-1)
    
    for line in filehandle:
        for word in line.split():
            lw = tuple( last_words )
            if 'read' in debug:
                print "%s / %s" % ( lw , word )
            if lw in stats:
                if word in stats[lw]: stats[lw][word] += 1
                else: stats[lw][word] = 1
            else:
                stats[lw] = dict()
                stats[lw][word] = 1
            last_words.append(word)
            last_words = last_words[1:]

    filehandle.close()

def write_text_markov( markov_size , text_length ):
    global debug
    global stats

    import random
    
    last_words = list(' ')*(markov_size-1)
    
    for i in xrange( text_length ):
        lw = tuple( last_words )
        subset = stats[lw].keys()
        r = random.randint( 0 , len(subset)-1 )
        if 'write' in debug:
            print "%s / %s -> random %d" % ( lw , subset , r )
        word = subset[r]
        print " "+word
        last_words.append(word)
        last_words = last_words[1:]
        
    
read_text_markov( '../man_gcc' , 2 )
if debug: print_stats()
write_text_markov( 2 , 10 )
