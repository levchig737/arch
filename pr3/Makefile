task3: task3.o
	ld -melf_i386 -o task3-exe-S task3.o

task3.o: task3.S
	as -ahlsm=task3.lst --32 -gstabs+ -o task3.o task3.S
clear:
	rm task3.o
	rm task3.lst
	rm task3-exe-S

