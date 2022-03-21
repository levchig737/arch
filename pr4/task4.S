/*
	Программа для вычесления суммы введенных одноцифровых чисел в буфер размером 2 байта
	Также работает с отрицательными числами и учитывает переполнение безнаковой суммы
	Выводит сумму чисел в 10 сс 8 сс и 2 сс

	Автор: Чекарев Лев 22107 2022г	
*/
	
.include "my-macro" 		# Подключаем файл с макроопределениями

.data
	delta: .byte 0x30	# Переменная для получения из кода символа его числовое представление в c.c
        summ: .short 0	# Переменная для хранения суммы 
	num_system: .short 0 # Переменная для номера с.с.
	count_num: .long 0 # Кол-во возможных цифр в с.с.
	str_len: .long 0 # Кол-во цифр в числе для вывода
	flag_minus: .long 0 # Флаг минуса суммы
	
.bss
        .lcomm c, 1               # Буфер для чтения текущего символа. Размер - 1 байт
        .lcomm out10, 6           # Буфер для вывода.
        .lcomm n, 1		  # Переменная для обработки текущего символа

.text
.global _start

_start:

input:
        Puts "Введите цифру"

show_prompt:
        Getchar $c              # макровызов ввода символа со стандартного ввода
        Cmpl $0, %eax           # Конец файл - EOF (введено 0 символов) ?
        je stop	                # Да - вывод суммы

	movl $0, flag_minus # Обновляем флаг минуса
	
	cmpb $'\n', c           # это символ перевода строки ?
        je print_summ_numbers_10   # да - вывод суммы

	cmpb $'-', c  # Если число отрицательное
	je minus_numb

	cmpb $'9', c            # код больше кода символа '9' ?
        ja print_err            # ДА - на вывод сообщения об ошибке
        cmpb $'0', c            # код меньше кода символа '0' ?
        jb print_err            # ДА - на вывод сообщения об ошибке

        movb c, %al # Передаем значение из с в n
        movb %al, n

plus_numb:
	xorw %ax, %ax		# Обнуление %ax для правильной обработки

        movb n, %al             # Присваеваем %al значение n

	subb delta, %al		# Получаем число из кода
	addw %ax, summ		# Прибавляем число к сумме
	jo err_buf_over		# Проверяем на переполнение

	jmp show_prompt

minus_numb:
	Getchar $c
	xorw %ax, %ax           # Обнуление %ax для правильной обработки

        movb c, %al             # Присваеваем %al значение c

        subb delta, %al         # Получаем число из кода

        subw %ax, summ          # Прибавляем число к сумме
	jo err_buf_over         # Проверяем на переполнение

        jmp show_prompt
	
print_err:
	Puts "Не цифровая клавиша. Повторите ввод"	# вывод сообщения об ошибке
	jmp show_prompt 				# на ввод следующего символа

err_buf_over:	
	Puts "Произошло переполнение. Выход."	# вывод сообщения об переполнении
	jmp stop				# выход из программы

print_summ_numbers_10:
	Puts "Сумма введенных чисел в 10 с.с.: "
        movw $10, num_system  
	movw $4, count_num
	jmp ToString

print_summ_numbers_8:	
	Puts "Сумма введенных чисел в 8 с.с.: "
        movw $8, num_system
	movw $5, count_num
	jmp ToString

print_summ_numbers_2:	
	Puts "Сумма введенных чисел в 2 с.с.: "
        movw $2, num_system
	movw $15, count_num
	jmp ToString

stop:
	Exit $0			# выход из программы

ToString:
        movw num_system, %bx    # Система счисления. На неё будем делить
        movl count_num, %esi    # Адрес самого первого чила. В числе <= count+1 (5 в 10 сс) чисел => count
        movw summ, %ax 		# Копируем номер в %ax
        xorl %edi, %edi         # Обнуляем %edi
	xorl %ecx, %ecx

	cmpw $0, summ
	jl ToStr_begin_minus
	
ToStr_begin:           # Начало цикла
	incl %ecx               # Счетчик длины строки вывода
        movl $0, %edx           # Обнуляем %edx (В нём после операции будет остаток)
        divw %bx                # Делим %ax на %bx, остаток в %dx
        addb $0x30, %dl         # Прибавляем к %dl 0x30, чтобы перейти к коду числа.
        movb %dl, out10(%esi) 	# Копируем содержимое %dl в буфер по нужному смещению

        cmpw $0, %ax            # Дошли до нуля? (В %ax пусто?)
        je some_changes  	# Да, заканчиваем преобразование и гоовим буфер к выводу

        decl %esi               # Нет, уменьшаем %esi на 1
        jmp ToStr_begin     	# и переходим в начало циклa

ToStr_begin_minus:
	movl $1, flag_minus
		
	negw summ

	movw summ, %ax 		# Копируем номер в %ax
	
	jmp ToStr_begin
	
	
some_changes:
	incl count_num  # Прибавляем 1 для сравнения
	movl %ecx, str_len # Счетчик для длины строки вывода

Pre_out:
	cmpl $1, flag_minus
	je ToStr_out_minus	
	
ToStr_out:
        cmpl count_num, %esi  # В %esi макс. кол-во цифр с.с.? (5 в 10 сс)
        je stop_to_string     # Да, выходим

        movb out10(%esi), %al 	# Копируем байт по адресу  out(%esi) в %al
        movb $0, out10(%esi)  	# Записываем 0 по адресу out(%esi)
        movb %al, out10(%edi) 	# Записываем значение %al по адресу out(%edi)
        inc %esi                # Увеличиваем %esi на 1
        inc %edi                # Увеличиваем %edi на 1
        jmp ToStr_out    	# Переходим в начало цикла

ToStr_out_minus:
	movb $45, out10(%edi) 	# Записываем минус по адресу out(%edi)
	incl %edi
	addl $1, str_len
	jmp ToStr_out                    

neg_summ:
	negw summ
	jmp input
	
stop_to_string:   # Вывод суммы
	movl $4, %eax		# номер сист. вызова write
	movl $1, %ebx		# параметр 1: дескриптор стандартного вывода	
	movl $out10, %ecx	# параметр 2: адрес памяти с выводимыми символами
	movl str_len, %edx        # параметр 3: количество байтов для вывода
	int $0x80		# выполнить системный вызов
	Puts ""
	movw $'',out10          # обнуляем буфер вывода

	cmpw $10, num_system    # Если 10 сс была, то идем к 8 сс
	je print_summ_numbers_8

	cmpw $8, num_system     # Если 8 сс была, то идем к 2 сс
	je print_summ_numbers_2

	cmpl $1, flag_minus
	je neg_summ
	
	jmp input # К вводу следующего числа

.end

