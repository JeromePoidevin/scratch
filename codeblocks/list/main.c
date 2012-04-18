#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "list.h"


Element mylist ;

char * copy_string ( char * string )
{
    char * copy = malloc( strlen(string) * sizeof(char) ) ;
    strcpy( copy , string) ;
    return copy ;
}

void print_string( Element * elem )
{
    if (elem != NULL ) printf( "%s\n" , (char *)elem->data  ) ;
}

int compare_two_strings( Element * elem1 , Element * elem2 )
{
    int cmp = strcmp( elem1->data , elem2->data ) ;
    printf( ".. strcmp %s , %s = %d\n" , (char *) elem1->data , (char *) elem2->data , cmp ) ;
    return cmp ;
}

int main()
{
    mylist.data = copy_string("a /") ;
    mylist.next = (Element *) NULL ;
    mylist.previous = (Element *) NULL ;

    list_add( &mylist , copy_string("b Hello world!") );
    list_add( &mylist , copy_string("c toto") );
    list_add( &mylist , copy_string("d abc") );
    list_add( &mylist , copy_string("e 123") );

    puts( "" ) ;
    list_print( &mylist , print_string ) ;

    puts( "" ) ;
    list_sort( &mylist , compare_two_strings ) ;

    puts( "" ) ;
    list_print( &mylist , print_string ) ;

    list_remove( (&mylist)->next->next ) ;

    puts( "" ) ;
    list_print( &mylist , print_string ) ;

    return 0;
}
