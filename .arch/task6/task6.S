.include "my-macro" 		# Подключаем файл с макроопределениями
.include "my-func"		# Подключаем файл с нашими макросами



# Получение элемента матрицы.Результат в %eax
.macro get_element matr, i, j
	
	movl \i, %ebx			# Записываем номер столбца в %ebx
	
	movl \j, %ecx			# Записываем номер строки
	movl $24, %eax			# Изменяем значение %eax на 24
	mulw %cx			# Умножаем на %cx
	movw %ax, %cx
	
	movl $\matr, %edx		# Значения элемента матрицы i столбца 1-ой строки переносим в %edx
	addl %ecx, %edx			# Получаем необходимый элемент матрицы
	
	movl (%edx, %ebx, 4), %eax 	# Элемент записываем в %eax и возвращаемся
.endm 
	
.data

delta:	.byte 0x31
	
matrix: 
	.long 1,	 2,	 3,	 4,	 5,	 6
	.long 7,	 8, 	 9,	10,	11,	12	
	.long 13,	14,	15,	16,	17,	18
	.long 19,	20,	21,	22,	23,	24
	.long 25,	26,	27,	28,	29,	30
	.long 31,	32,	33,	34,	35,	36

vector:	.long 0,	0,	0,	0,	0,	0

.bss
	.lcomm out, 11		# То, что выводим на экран
	.lcomm c, 1		# Здесь храним последний прочитанный символ
	.lcomm k, 4		# Элемент k, получаемый от пользователя НОМЕР СТОЛБЦА
	.lcomm kflag, 4		# Флаг элемента k
	.lcomm l, 4		# Элемент l, получаемый от пользователя НОМЕР СТРОКИ
	.lcomm lflag, 4		# Флаг элемента l
	.lcomm e, 4		# Текущий вычисляемый элемент матрицы
	.lcomm tmp, 4		# 
.text

.global _start 			# Точка входа объявлена глобальной меткой

_start:				# Точка входа
	
input:	
	Puts "Введите 2 цифры(1-6)\n" # 
	movl $0,l
show_prompt:
	Getchar $c		# макровызов ввода символа со стандартного ввода
	    
	cmpl $0, %eax		# Конец файл - EOF (введено 0 символов) ? 
	je exit_succesful	# Да - на завершение программы
	
	cmpb $'\n', c 		# это символ перевода строки ?
	je check_input		# Да, проверяем все ли данные введены
	
	cmpb $'6', c		# Число не может быть больше 6
	ja print_err_msg
	cmpb $'1', c		# И меньше 1
	jb print_err_msg
	
	xorl %eax, %eax		
	movb c, %al
	subb delta, %al		# Получаем из кода символа позицию в массиве

check_input:
	cmpl $0, kflag 		# Если в k пусто, записываем туда число
	je add_k
	
	cmpl $0, lflag		# Если в l пусто записываем число туда
	je add_l
	
	jmp calc_vector		# Иначе - переходим к расчёту вектора
	
add_l:
	movl %eax, l
	movl $1, lflag
	jmp show_prompt		# На ввод следующей цифры
add_k:
	movl %eax, k
	movl $1, kflag
	jmp show_prompt		# На ввод следующей цифры
	
calc_vector:
	movl e, %eax		 	# Получаем текущий номер элемента
	movl $0, vector(,%eax,4) 	# Обнуляем текущий элемент вектора
	
	get_element matrix k, e		# Получаем в %eax нужный элемент матрицы
	movl e, %ebx			# Получаем текущий номер элемент
	addl %eax, vector(,%ebx,4) 	# и прибаляем элемент матриц к текущему элементу массива

	get_element matrix, e, l 	# Аналогично верхнему участку кода
	movl e, %ebx
	addl %eax, vector(,%ebx,4)
	
	incl %ebx			# Переходим к следующему элементу
	movl %ebx, e
	
	cmpl $6, %ebx			# Если вычислили не все элементы вектора
	jne calc_vector			# Продолжаем вычислять

	call print_vector		# Выводим вектор
	
	jmp input			# На ввод
	
print_err_msg:
	Puts "Неверный ввод\n"		# вывод сообщения об ошибке

	movl $0, kflag			# Обнуляем флаги
	movl $0, lflag
	
	jmp input 			# на ввод следующего символа
	
	
print_vector:
	Puts "("

	movl $-4, tmp			# Записываем в tmp -4, что бы при прибалении в начале цикла получить 0
	
print_begin:

	movl tmp, %ecx			# Получаем прошлое смещение
	addl $4, %ecx			# и переходим к следующему
	movl %ecx, tmp
	
	ToString vector(%ecx), out 	# Преобразуем число по адресу vector+%ecx в строку
	Write out		     	# И выводим на стандатный вывод
	Puts "; "

	cmpl $16, tmp			# Если не были выведены 5 элементов
	jne print_begin			# то продолжаем выводить
	
	ToString vector+20, out 	# Иначе выводим 6 и выходим
        Write out
        Puts ")\n"

print_end:

	jmp stop
	
exit_succesful:
	call print_vector		# Выводим вектор
	
stop:
	Exit $0 			# Выход

.end

