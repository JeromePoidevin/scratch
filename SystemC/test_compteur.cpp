#include <iostream>
#define SC_INCLUDE_FX
#include "systemc.h"
#include "compteur.h"

void next_cycle( sc_signal<bool> & clk , int n=1 );

int cycle = 0 ;

int sc_main( int argc , char * argv[] )
{
    int i;

    sc_signal<bool> clk;
    sc_signal<bool> rst;
    sc_signal<sc_uint<5> > out;
    sc_signal<sc_ufixed<5,2,SC_TRN,SC_SAT> > outf;

    sc_trace_file * vcd_file;
    vcd_file = sc_create_vcd_trace_file( "test_compteur" );
    sc_trace( vcd_file , clk , "clk" );
    sc_trace( vcd_file , rst , "rst" );
    sc_trace( vcd_file , out , "out" );
    sc_trace( vcd_file , outf , "outf" );

    compteur compteur("u_compteur");
    compteur.clk(clk);
    compteur.rst(rst);
    compteur.out(out);
    compteur.outf(outf);

    rst = true;
    next_cycle(clk);
    rst = false;
    next_cycle(clk);
    rst = true;
    next_cycle(clk,40);

    sc_close_vcd_trace_file( vcd_file );

    return EXIT_SUCCESS;
}


void next_cycle( sc_signal<bool> & clk , int n=1 )
{
    int i;

    std::cout << "next_cycle +" << n << std::endl ;
    for (i=1;i<=n;i++)
    {
        clk = false;
        sc_start(1);
        clk = true;
        cycle++ ;
        sc_start(1);
    }
    std::cout << "next_cycle =" << cycle << std::endl ;
}

