task4: task4.o
	ld -melf_i386 -o task4-exe-S task4.o

task4.o: task4.S
	as -ahlsm=task4.lst --32 -gstabs+ -o task4.o task4.S
clear:
	rm task4.o
	rm task4.lst
	rm task4-exe-S

