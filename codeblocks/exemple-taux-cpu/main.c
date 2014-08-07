#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

int main(int argc, char * argv[])
{
    time_t debut;
    long int nb_boucles;
    long int nb_boucles_max;

    debut = time(NULL);

    nb_boucles = 0;
    while ( time(NULL) < debut+10 )
        nb_boucles++;
    printf( "[%d] nb_boucles : %ld " , getpid() , nb_boucles );

    if ( (argc==2) && (sscanf(argv[1],"%ld",&nb_boucles_max)==1) )
        printf( "(%.0f" , 100.0*nb_boucles/nb_boucles_max ) ;

    printf("\n");

    return EXIT_SUCCESS;
}
