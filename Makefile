
1 : c/1 c++/1
	-cd c && ./1
	-cd c++ && ./1
	-cd py && python 1.py
	-cd gnuplot && gnuplot -p 1.gp

c/% : c/%.c
	gcc $< -o $@

tcp_client_server : % : c/%/client c/%/server

c++/% : c++/%.cpp
	g++ $< -o $@

java/% : java/%.java
	javac -classpath java/out -d java/out $<
	java  -classpath java/out $(notdir $@)

MARKOV := codeblocks/markov_c
markov : $(MARKOV)/error_functions.c $(MARKOV)/main.c 
	gcc -g -pg $+ -o c/markov_gcc
	cd c && ./markov_gcc && gprof markov_gcc -m gmon.out > markov_gprof.txt

