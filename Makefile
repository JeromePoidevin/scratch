
1 : c/1 c++/1
	-cd c && ./1
	-cd c++ && ./1
	-cd py && python 1.py
	-cd gnuplot && gnuplot -p 1.gp

c/% : c/%.c
	gcc $< -o $@

c++/% : c++/%.cpp
	g++ $< -o $@


