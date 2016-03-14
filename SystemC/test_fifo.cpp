#include <systemc.h>

#define FIFO_SIZE 16

//----------------------------------------
// module : test_fifo
//----------------------------------------

SC_MODULE(test_fifo) {

  sc_out<int>  out_free;
  sc_out<int>  out_available;
  sc_out<bool> out_full ;
  sc_out<bool> out_empty ;

  void test_fifo::fi(void);
  void test_fifo::fo(void);
  void test_fifo::stats(void);

  // Constructor
  SC_CTOR(test_fifo) {
    SC_THREAD(fi);
    SC_THREAD(fo);
    SC_THREAD(stats);
    sc_fifo<int> u_fifo (FIFO_SIZE);
  }
  
  // Declare the FIFO
  sc_fifo<int> u_fifo;
};

void test_fifo::fi(void) {
  int val = 1000;
	int twait = 1;

  // write every ??ns ; ?? oscillates to create full/empty
  for (;;) {
    wait(twait, SC_NS);
    val++;
		if (val%30==0) twait=8-twait; // oscillate 1 <-> 7

    std::cout << sc_time_stamp() << " : FI ";
		if (u_fifo.nb_write(val)) { std::cout << val << std::endl; }
		else                      { std::cout << "full" << std::endl; }
  }
}

void test_fifo::fo(void) {
  int val ;

  // wait FIFO half-full
  while (u_fifo.num_available() < FIFO_SIZE/2) wait(10,SC_NS) ;

  // read out every 3ns
  for (;;) {
    wait(3, SC_NS);

    std::cout << sc_time_stamp() << " : FO ";
    if (u_fifo.nb_read(val)) { std::cout << val << std::endl; }
    else                     { std::cout << "empty" << std::endl; }
  }
}

void test_fifo::stats(void) {
  for (;;) {
    for (int i=0;i<10;i++)
    {
      wait(1, SC_NS);
      out_free      = u_fifo.num_free();
      out_available = u_fifo.num_available();
      out_full      = (u_fifo.num_free()==0);
      out_empty     = (u_fifo.num_available()==0);
    }      

    std::cout << sc_time_stamp() << " :"
              << " avail " << u_fifo.num_available()
              << " free " << u_fifo.num_free()
              << std::endl;
  }
}

//----------------------------------------
// sc_main
//----------------------------------------

int sc_main(int argc, char* argv[]) {

  sc_signal<int>  out_free ;
  sc_signal<int>  out_available ;
  sc_signal<bool> out_full ;
  sc_signal<bool> out_empty ;

  test_fifo u_test_fifo( "u_test_fifo" ) ;
  u_test_fifo.out_free     ( out_free );
  u_test_fifo.out_available( out_available );
  u_test_fifo.out_full     ( out_full );
  u_test_fifo.out_empty    ( out_empty );

  sc_trace_file * vcd_file;
  vcd_file = sc_create_vcd_trace_file( "test_fifo" );
  sc_trace( vcd_file , out_free      , "out_free" );
  sc_trace( vcd_file , out_available , "out_available" );
  sc_trace( vcd_file , out_full      , "out_full" );
  sc_trace( vcd_file , out_empty     , "out_empty" );

  sc_start(1000, SC_NS);

  sc_close_vcd_trace_file( vcd_file );

  return 0;
}

