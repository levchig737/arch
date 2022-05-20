call: func-for-c.o call-as.c
	gcc -m32 -gstabs+ -o call call-as.c func-for-c.o
func-for-c.o:
	as --32 -gstabs+ -o func-for-c.o func-for-c.S
