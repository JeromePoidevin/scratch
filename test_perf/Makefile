
ALL := test_arith.out
ALL += test_arith_g.out
ALL += test_arith_pg.out
ALL += test_arith.py.out

.PHONY : $(ALL)
test : $(ALL)

$(ALL) : %.out : %
	@echo ""
	@ls -l $<
	time ./$< > $@

test_arith_g : OPT := -g
test_arith_pg : OPT := -pg

test_arith test_arith_g test_arith_pg : test_arith.c
	gcc $< -o $@ $(OPT)


