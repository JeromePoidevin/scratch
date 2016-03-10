#include <systemc.h>

#define FIFO_SIZE 16

SC_MODULE(test_fifo) {

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
    wait(10, SC_NS);

    std::cout << sc_time_stamp() << " :"
              << " avail " << u_fifo.num_available()
              << " free " << u_fifo.num_free()
              << std::endl;
  }
}

int sc_main(int argc, char* argv[]) {
  test_fifo u_test_fifo ("TEST FIFO");
  sc_start(1000, SC_NS);
  return 0;
}

