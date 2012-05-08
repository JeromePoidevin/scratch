#include <iostream>
#define SC_INCLUDE_FX
#include "systemc.h"

SC_MODULE(compteur)
{
    sc_in<bool> clk;
    sc_in<bool> rst;
    sc_out<sc_uint<5> > out;
    sc_out<sc_ufixed<5,2,SC_TRN,SC_SAT> > outf;

    sc_uint<5> val;
    sc_ufixed<5,2,SC_TRN,SC_SAT> valf;

    void compte();

    SC_CTOR(compteur)
    {
        SC_METHOD(compte);
        sensitive << clk.pos();
    };
};

