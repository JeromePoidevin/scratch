#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main( int argc , char ** argv )
{
    int i;
    char * copy[argc];

    printf("%s %d\n",argv[0],argc);
    for (i=0;i<argc;i++) printf("%s\n",argv[i]) ;

    for (i=0;i<argc;i++)
    {
        copy[i] = malloc( strlen(argv[i]) * sizeof(char) ) ;
        strcpy(copy[i],argv[i]) ;
    }
    return 0;
}
