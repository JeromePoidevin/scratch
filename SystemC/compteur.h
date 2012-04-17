#include <iostream>
#include "systemc.h"

SC_MODULE(compteur)
{
    sc_in<bool> clk;
    sc_in<bool> rst;
    sc_out<sc_uint<8> > out;

    sc_uint<8> value;

    void compte();

    SC_CTOR(compteur)
    {
        SC_METHOD(compte);
        sensitive << clk.pos();
    };
};

