#ifndef LIST_H_INCLUDED
#define LIST_H_INCLUDED

typedef struct Element {
    void * data ;
    struct Element * previous ;
    struct Element * next ;
} Element ;

void list_add( Element * where , void * what ) ;

void list_remove( Element * elem ) ;

void list_print( Element * elem , void (* print_element)(Element *) ) ;

void list_sort( Element * elem , int (* compare_two_elements)(Element *, Element *) ) ;

#endif // LIST_H_INCLUDED
