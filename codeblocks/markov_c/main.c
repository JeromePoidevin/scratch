#include <stdio.h>
#include <stdlib.h>

enum { NPREFIX=2 , HASHMUL=37 , NHASH=4093 , MAXGEN=10 } ;

unsigned int hash( char * s[NPREFIX])
{
    unsigned int h;
    unsigned char * p;
    int i;

    h = 0;
    for ( i=0 ; i<NPREFIX ; i++ )
        for ( p=(unsigned char *)s[i] ; *p!=NULL ; p++ )
            h= HASHMUL*h + *p ;
    return h % NHASH;
}

int main()
{
    char * s[NPREFIX];
    s[0] = "toto";
    s[1] = "hello world";
    printf("%s %s : %d\n" , s[0], s[1], hash(s) );
    return 0;
}
