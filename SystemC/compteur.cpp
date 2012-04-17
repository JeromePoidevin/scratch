#include <iostream>
#include "systemc.h"

#include "compteur.h";

void compteur::compte()
{
    if (rst==false) value=0;
    else            value++;
    out = value;
    std::cout << "compteur : "
              << value << std::endl ;
};

