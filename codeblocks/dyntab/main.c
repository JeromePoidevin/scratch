#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct nv_t nv_t ;
struct nv_t { char * name ; int val ; } ;

struct nvtab_t {
    int n; // nombre courant de valeurs
    int allo; // nombre alloué de valeurs
    nv_t * nvp;
} nvtab ;

enum { NVINIT = 1 , NVGROW = 2 } ;

// add_nv : ajout
int add_nv( char * new_name , int new_val )
{
    nv_t * tmp_nvp ;
    if (nvtab.nvp==NULL) // 1e fois
    {
        tmp_nvp = (nv_t *) malloc( NVINIT * sizeof(nv_t) ) ;
        if (tmp_nvp==NULL) return -1 ;
        nvtab.allo = NVINIT ;
        nvtab.nvp = tmp_nvp ;
    }
    else if (nvtab.n>=nvtab.allo) // grossir
    {
        tmp_nvp = (nv_t *) realloc( nvtab.nvp , (NVGROW*nvtab.allo) * sizeof(nv_t) ) ;
        if (tmp_nvp==NULL) return -2 ;
        nvtab.allo *= NVGROW ;
        nvtab.nvp = tmp_nvp ;
    }
    printf( "add_nv : %d : %d : %d\n" , nvtab.n , nvtab.allo , nvtab.nvp ) ;

    nvtab.nvp[nvtab.n].name = malloc( strlen(new_name) * sizeof(char) ) ;
    strcpy( nvtab.nvp[nvtab.n].name , new_name ) ;
    nvtab.nvp[nvtab.n].val  = new_val ;

    return nvtab.n++ ; // retourne l'indice venant d'etre ajoute
}

int main()
{
    int i;
    int test ;
    char * abc = "abcdefghijklmnopqrstuvwxyz" ;

    for ( i=0 ; i<10 ; i++ )
    {
        printf( "main : %d : %s\n" , i , abc+i ) ;
        test = add_nv( abc+i , i ) ;
        if (test<0) return test ;
    }
    return 0;
}
