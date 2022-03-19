/* 
 * task2 - Программа вычисляющая факториал, аналог task2.S
*/
#include <stdio.h>

int main(void){
    int n = 5;
    int i = 1;
    while (n > 0){
        i = n * i;
	n--;
    }
    return 0;
}
