
# implicit : argv.c -> argv

all : cpp argv
	./argv toto tata tutu

cpp :
	@echo "--------------------"
	cpp cpp.txt
	@echo "--------------------"
	cpp cpp.txt -D IF=toto
	@echo "--------------------"

gcov :
	gcc  argv.c -o argv -fprofile-arcs -ftest-coverage
	./argv toto tata tutu
	gcov argv

gprof :
	gcc  argv.c -o argv -pg
	./argv toto tata tutu
	gprof argv gmon.out

