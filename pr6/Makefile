func: func.o
	ld -melf_i386 -o func-exe-S func.o

func.o: func.S
	as -ahlsm=func.lst --32 -gstabs+ -o func.o func.S
clear:
	rm func.c~

