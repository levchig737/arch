#include <stdio.h>
#include <string.h>

/* Максимальный размер строки для обработки */
#define max 10

/* прототип внешней функции

   Параметр 1 - количество символов, кот. надо обработать
   Параметр 2 - адрес первого элемента массива

*/

extern void *Read_Sym(int, char*);

/* массив результатов*/

int Numbers[max];

/* функция подсчёта цыфр в массиве */
extern int Sum(int, int*);

int main()
{
    int n =0;
    int i = 0;

    printf("%s", "Введите строку: ");

    char Symbols[max]; 

    fgets(Symbols, max, stdin);
    
    /* Сколько элементов массива считать*/
    int c = strlen(Symbols);

    Read_Sym(c, Symbols);          /* вызов as функции */

/*Вызов ассемблерного суммирования*/
    n = Sum(c, Numbers);
    
    /* печать результата */
    
    printf("\n%d\n", n);
    return 0; 
}
