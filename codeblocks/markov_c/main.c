#include <stdio.h>
#include <stdlib.h>  // malloc ...
#include <string.h>  // strcmp ...

#include "error_functions.h"

enum { HASHMUL=37 , NHASH=4093 } ; // hashtable
enum { NPREFIX=2 , MAXGEN=10 } ; // markov
enum { FREADBUF=100 } ;

typedef struct State State;
typedef struct Suffix Suffix;

struct State { /* one hash element = prefix + list of suffixes */
    char * prefix[NPREFIX]; /* prefix = NPREFIX words */
    Suffix * suffix;  /* list of suffixes */
    State * next;  /* next in hashtable */
};

struct Suffix { /* list of suffixes */
    char * word;
    Suffix * next;
};

State * statetab[NHASH]; /* main hashtable */

// hash : compute index in hashtable
unsigned int hash( char * s[NPREFIX])
{
    unsigned int h;
    unsigned char * p;
    int i;

    h = 0;
    for ( i=0 ; i<NPREFIX ; i++ )
        for ( p=(unsigned char *)s[i] ; *p!='\0' ; p++ )
            h= HASHMUL*h + *p ;
    return h % NHASH;
}

// lookup : look for prefix in hashtable ; create if necessary
State * lookup( char * prefix[NPREFIX], int create )
{
    int i,h;
    State * sp;

    h = hash(prefix);
    // go through hash_list at statetab[h]
    for ( sp = statetab[h] ; sp != NULL ; sp = sp->next )
    {
        for (i=0;i<NPREFIX;i++)
            if ( strcmp(prefix[i], sp->prefix[i]) != 0 ) break;
        if (i==NPREFIX) return sp; // found it
    }
    // not found
    if (! create) return NULL;

    // create and insert at statetab[h]
    sp = (State *) emalloc(sizeof(State));
    for (i=0;i<NPREFIX;i++)
        // store pointer to word ; dupplicate word before !!
        sp->prefix[i] = prefix[i];
    sp->suffix = NULL;
    sp->next = statetab[h];
    statetab[h] = sp;

    return sp;
}

// build : read from file, create hashtable with prefix_suffix
void build(FILE * f)
{
    char buf[FREADBUF];
    char fmt[10];

    char * prefix[NPREFIX];
    char * word;
    State * sp;
    Suffix * suffix;
    int i;

    sprintf(fmt, "%%%ds", FREADBUF);

    while ( fscanf(f, fmt, buf) != EOF )
    {
        // buf is temp ; dupplicate
        word = estrdup(buf);
        printf("%s\n",word);
        // lookup in hashtable + create if not found
        sp = lookup(prefix,1);
        // create suffix
        suffix = emalloc(sizeof(Suffix));
        suffix->word = word;
        suffix->next = sp->suffix;
        // add suffix to hashtable
        sp->suffix = suffix;
        // shift list of prefixes
        for (i=0;i<NPREFIX-2;i++) prefix[i]=prefix[i+1];
        prefix[NPREFIX-1] = word;
    }
}

void print_statetab()
{
    int i,n;
    State * sp;;
    Suffix * suf;
    for (i=0;i<NHASH;i++)
    {
        if (statetab[i]==NULL) continue;
        for ( sp=statetab[i] ; sp!=NULL ; sp=sp->next )
        {
            printf("%d : %u :",i,sp);
            for ( n=0 ; n<NPREFIX ; n++ ) printf(" %s",sp->prefix[n]);
            printf(" /");
            for ( suf=sp->suffix ; suf!=NULL ; suf=suf->next ) printf(" %s",suf->word);
            printf("\n");
        }
    }
}

int main()
{
    char * s[NPREFIX];
    FILE * f;

    s[0] = "toto";
    s[1] = "hello world";
    printf("%s %s : %d\n" , s[0], s[1], hash(s) );

    f = fopen("man_gcc","r");
    build(f);
    fclose(f);
    print_statetab();
    return 0;
}
