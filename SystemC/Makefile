
SYSTEMC := /usr/local/systemc-2.2

OPT := -Wno-deprecated -fpermissive
OPT += -L$(SYSTEMC)/lib-linux64 -I$(SYSTEMC)/include

#### test_compteur

sim1 : test_compteur
	./test_compteur

wave1 : test_compteur.vcd
	gtkwave $<

test_compteur : test_% : test_%.cpp %.cpp
	g++ $(OPT) -o $@ $^ -lsystemc

#### test_fifo

sim2 : test_fifo
	./test_fifo | egrep 'empty|full|avail|free'

test_fifo : % : %.cpp
	g++ $(OPT) -o $@ $^ -lsystemc

#### http://www.accellera.org/Discussion_Forums/helpforum/archive/msg?list_name=help_forum&monthdir=201011&msg=msg00042.html

#### The dependencies of the object files and libraries you link are resolved from right to left.  Since you use SystemC (and thus libsystemc.a) in model.cpp, the source file needs to be placed before the '-lsystemc -lm' arguments.

