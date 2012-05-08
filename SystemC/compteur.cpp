#include <iostream>
#define SC_INCLUDE_FX
#include "systemc.h"

#include "compteur.h";

void compteur::compte()
{
    if (rst==false) { val=0 ; valf=0 ; }
    else            { val++ ; valf+=0.3 ; }
    out = val ;
    outf = valf ;
    std::cout << "compteur : "
              << val << " : " << valf << std::endl ;
};

