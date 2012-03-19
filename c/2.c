#include <stdio.h>

int main()

{
    int i,x,y ;
    char line[100] ;

    FILE * fp = fopen( "../gnuplot/test_gnuplot.txt" , "r" ) ;

    i = 0 ;
    while ( fgets( line , sizeof line , fp ) ) {
        int scan = sscanf( line , " %d %d" , &x , &y ) ;
        if (scan<1) x=-999 ;
        if (scan<2) y=-999 ;
        printf( "i,x,y = %d,%d,%d\n" , i++ , x , y ) ;
    }

    fclose( fp ) ;

    return 0 ;
}

