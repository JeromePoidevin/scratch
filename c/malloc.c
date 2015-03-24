#include <stdio.h>  // printf
#include <stdlib.h> // malloc

void * emalloc(size_t n)
{
    void * p;
    p = malloc(n);
    if (p==NULL) printf("ERROR : emalloc : malloc of %u bytes failed",n);
    return p;
}

int main( void )
{
    char *a, *b;
    int *c, *d;
    int i,j=0;

    while (j<500)
    {
        printf("%d" , j ) ;
        a = emalloc(sizeof(char)) ;
        b = emalloc(10*sizeof(char)) ;
        c = emalloc(sizeof(int)) ;
        d = emalloc(10*sizeof(int)) ;
        *a = (char) ++j ;
        for (i=0;i<10;i++) { b[i] = (char) ++j ; }
        *c = (int) ++j ;
        for (i=0;i<10;i++) { d[i] = (int) ++j ; }
        printf(" | a : %p = %d | b : %p..%p = %d..%d" ,
                        a , *a , &b[0],&b[9],b[0],b[9] ) ;        
        printf(" | c : %p = %d | d : %p..%p = %d..%d" ,
                        c , *c , &d[0],&d[9],d[0],d[9] ) ;        
        printf("\n") ;
        free(a) ;
        free(b) ;
        free(c) ;
        free(d) ;
    }
}

/*
malloc allocates 32 bytes (0x20) for char / 10*char / int -> oversized 
malloc allocates 40 bytes (0x28) for 10*int -> exact 

0 | a : 0xf30010 = 1 | b : 0xf30030..0xf30039 = 2..11 | c : 0xf30050 = 12 | d : 0xf30070..0xf30094 = 13..22
22 | a : 0xf30050 = 23 | b : 0xf30030..0xf30039 = 24..33 | c : 0xf30010 = 34 | d : 0xf30070..0xf30094 = 35..44
44 | a : 0xf30010 = 45 | b : 0xf30030..0xf30039 = 46..55 | c : 0xf30050 = 56 | d : 0xf30070..0xf30094 = 57..66
66 | a : 0xf30050 = 67 | b : 0xf30030..0xf30039 = 68..77 | c : 0xf30010 = 78 | d : 0xf30070..0xf30094 = 79..88
88 | a : 0xf30010 = 89 | b : 0xf30030..0xf30039 = 90..99 | c : 0xf30050 = 100 | d : 0xf30070..0xf30094 = 101..110

*/

