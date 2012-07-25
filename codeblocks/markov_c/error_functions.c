#include <stdio.h>  // printf
#include <stdlib.h>  // malloc
#include <string.h>

void * emalloc(size_t n)
{
    void * p;
    p = malloc(n);
    if (p==NULL) printf("ERROR : emalloc : malloc of %u bytes failed",n);
    return p;
}

char * estrdup(char * s)
{
    char * t;
    t = (char *) emalloc( strlen(s) + 1 );
    strcpy(t,s);
    return t;
}
