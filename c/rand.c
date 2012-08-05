#include <stdlib.h>
#include <stdio.h>

main()
{
    int i,j;
    int r;

    printf("RAND_MAX = %d\n\n" , RAND_MAX );

    for (i=1;i<100;i++) 
    {
        r = rand();
        printf( "%d (%d) ", r , (r%3) );
    }
    printf("\n\n");

    j=1;
    for (i=1;i<1000;i++)
    {
        r = rand() % ++j;
        printf( "%d ", r );
        if ( r != 0 ) { printf( "=> %d\n" , j ) ; j=0 ; }
    }
    printf("\n\n");

}

