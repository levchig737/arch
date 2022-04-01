task5: task5.o
	ld -melf_i386 -o task5-exe-S task5.o

task5.o: task5.S
	as -ahlsm=task5.lst --32 -gstabs+ -o task5.o task5.S
clear:
	rm task5.o
	rm task5.lst
	rm task5-exe-S

