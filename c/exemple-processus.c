#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

#define LIGNE 256

int main(void)
{
    char ligne[LIGNE] ;
    int f ;
    while (1)
    {
        fprintf(stderr,">> ") ;
        if (fgets(ligne,LIGNE,stdin)==NULL) break ;
        // supprimer le retour chariot
        ligne[strlen(ligne)-1] = '\0' ;

        f = fork() ;
        if (f==0) {
            // processus fils
            execlp(ligne,ligne,NULL) ;
            perror(ligne) ;
            exit(EXIT_FAILURE) ;
        } else {
            fprintf(stderr,"(%d)\n",f) ;
            // processus pere attend le fils
            waitpid(-1,NULL,0) ;    
        }
    }
    fprintf(stderr,"\n") ;
    return(EXIT_SUCCESS) ;
}

