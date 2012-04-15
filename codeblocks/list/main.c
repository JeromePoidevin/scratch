#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "list.h"


Element mylist ;

void print_string( Element * elem )
{
    if (elem != NULL ) printf( "%s\n" , (char *)elem->data  ) ;
}

int compare_two_strings( Element * elem1 , Element * elem2 )
{
    int cmp = strcmp( elem1->data , elem2->data ) ;
    printf( ".. strcmp %s , %s = %d\n" , elem1->data , elem2->data , cmp ) ;
    return cmp ;
}

int main()
{
    mylist.data = "a /" ;
    mylist.next = (Element *) NULL ;
    mylist.previous = (Element *) NULL ;

    list_add( &mylist , "b Hello world!" );
    list_add( &mylist , "c toto" );
    list_add( &mylist , "d abc" );
    list_add( &mylist , "e 123" );

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
