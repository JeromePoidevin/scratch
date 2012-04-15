
#include <stdlib.h>
#include <string.h>

#include "list.h"

void list_add( Element * where , char * what )
{
    Element * elem = malloc( sizeof(Element) ) ;
    elem->data = malloc( strlen(what) * sizeof(char) ) ;
    strcpy( elem->data , what) ;
    elem->previous = where ;
    elem->next = where->next ;
    where->next = elem ;
}

void list_remove( Element * elem )
{
    elem->next->previous = elem->previous ;
    elem->previous->next = elem->next ;
    free( elem-> data ) ;
    free( elem ) ;
}

void list_print( Element * elem , void (* print_element)(Element *) )
{
    print_element( elem ) ;
    if ( elem->next != NULL ) list_print( elem->next , print_element ) ;
}

void list_sort( Element * elem , int (* compare_two_elements)(Element *,Element *) )
{
    int cmp ;
    char * tmp_data ;

    if ( elem->next == NULL ) return ;

    cmp = compare_two_elements( elem , elem->next ) ;
    if (cmp>0)
    {
        tmp_data = elem->data ;
        elem->data = elem->next->data ;
        elem->next->data = tmp_data ;
        list_sort( elem->next , compare_two_elements ) ;
        list_sort( elem , compare_two_elements ) ;
    }
    else
    {
        list_sort( elem->next , compare_two_elements ) ;
    }

}
