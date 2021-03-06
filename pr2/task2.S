/*
 * Нахождение факториала  для 
 * символьного представления неотрицательного 
 * 32-битового целого числа
*/

.include "my-macro"		# подключение файла с макроопределениями

.text				# секция команд процесора 
        
.global _start			# точка входа - глобальная метка
_start:	
        movl $5, %eax		# аргумент факториала
	movl $1, %ebx		# начальный результат

L1:				# Модуль вычисления факториала
	
        cmpl  $0, %eax		# условие, проверяющее значение аргумента факториала и нуля
	je    L2		# если условие верно, то переходим к модулю L2
				# если НЕТ, то
	imull %eax, %ebx	# умножаем переменную результата ebx на аргумент eax для получения промежуточного значения факториала
	decl  %eax		# отнимаем у eax единицу для последующих вычислений
	jmp   L1		# переход к началу модуля L1
	
L2:				
	
        Finish		  	# конец работы, 
				# возврат в ОС
				# (макро из файла my-macro)
        
.end				# последняя строка исходного текста
				# as прекращает чтение файла исходного текста
        
