/* Программа для ввода последовательности цифр и вывода их повторений */
	
.include "my-macro" 		# Подключаем файл с макроопределениями
.include "my-func" 		# Подключаем файл с моими макрокомандами
.data
	delta: .byte 0x30		# Переменная для получения из кода символа его числовое представление в десятичной системе
	summ: .short 65530
.bss
        //.lcomm summ, 2          # Сумма чисел. Размер - 2 байта
        .lcomm c, 1               # Буфер для чтения текущего символа. Размер - 1 байт
        .lcomm out10, 6           # Буфер для вывода.
	.lcomm out8, 6		  # Буфер для вывода в 8-ой  СС
	.lcomm out2, 6		  # Буфер для вывода в 2-ой СС
        .lcomm n, 1		  # Переменная для обработки текущего символа

.text
.global _start

_start:

input:
        Puts "Введите цифру"

show_prompt:
        Getchar $c              # макровызов ввода символа со стандартного ввода
        Cmpl $0, %eax           # Конец файл - EOF (введено 0 символов) ?
        je print_summ_numbers         # Да - вывод суммы

	cmpb $'\n', c           # это символ перевода строки ?
        je print_summ_numbers   # да - вывод суммы

	cmpb $'-', c
	je minus_numb

	cmpb $'9', c            # код больше кода символа '9' ?
        ja print_err            # ДА - на вывод сообщения об ошибке
        cmpb $'0', c            # код меньше кода символа '0' ?
        jb print_err            # ДА - на вывод сообщения об ошибке

        movb c, %al
        movb %al, n

plus_numb:
	xorw %ax, %ax		# Обнуление %ax для правильной обработки

        movb n, %al             # Присваеваем %al значение n

	subb delta, %al		# Получаем число из кода
	addw %ax, summ		# Прибавляем число к сумме
	jc err_buf_over		# Проверяем на переполнение

	jmp show_prompt

minus_numb:
	Getchar $c
	xorw %ax, %ax           # Обнуление %ax для правильной обработки

        movb c, %al             # Присваеваем %al значение n

        subb delta, %al         # Получаем число из кода

        subw %ax, summ          # Прибавляем число к сумме
	jc err_buf_over         # Проверяем на переполнение

        jmp show_prompt
	
print_err:
	Puts "Не цифровая клавиша. Повторите ввод"	# вывод сообщения об ошибке
	jmp show_prompt 				# на ввод следующего символа

err_buf_over:	
	Puts "Произошло переполнение. Выход."	# вывод сообщения об переполнении
	jmp stop				# выход из программы

print_summ_numbers:
	Puts "Сумма введенных чисел: "
	jmp ToString10

stop:
	Exit $0			# выход из программы

ToString10:
        movw $10, %bx           # Система счисления. На неё будем делить
        movl $4, %esi           # Адрес самого первого чила. В числе не может быть больше 5 чисел, поэтому устанавливаем смещение на 4
        movw summ, %ax 		# Копируем номер в %ax
        xorl %edi, %edi         # Обнуляем %edi

ToStr10_begin:                  # Начало цикла
        movl $0, %edx           # Обнуляем %edx (В нём после операции будет остаток)
        divw %bx                # Делим %ax на %bx, остаток в %dx
        addb $0x30, %dl         # Прибавляем к %dl 0x30, чтобы перейти к коду числа.
        movb %dl, out10(%esi) 	# Копируем содержимое %dl в буфер по нужному смещению

        cmpw $0, %ax            # Дошли до нуля? (В %ax пусто?)
        je ToStr10_out     	# Да, заканчиваем преобразование

        decl %esi               # Нет, уменьшаем %esi на 1
        jmp ToStr10_begin     	# и переходим в начало цикла

ToStr10_out:
        cmpl  $5, %esi          # В %esi 5?
        je stop_to_string10     # Да, выходим

        movb out10(%esi), %al 	# Копируем байт по адресу  out(%esi) в %al
        movb $0, out10(%esi)  	# Записываем 0 по адресу out(%esi)
        movb %al, out10(%edi) 	# Записываем значение %al по адресу out(%edi)
        inc %esi                # Увеличиваем %esi на 1
        inc %edi                # Увеличиваем %edi на 1
        jmp ToStr10_out    	# Переходим в начало цикла

stop_to_string10:
	Write out10
	Puts ""
	movw $'',out10

ToString8:
	Puts "В восьмеричной cc:"
        movw $8, %bx           # Система счисления. На неё будем делить
        movl $5, %esi           # Адрес самого первого чила. В числе не может быть больше 5 чисел, поэтому устанавливаем смещение на 4
        movw summ, %ax 		# Копируем номер в %ax
        xorl %edi, %edi         # Обнуляем %edi

ToStr8_begin:                  # Начало цикла
        movl $0, %edx           # Обнуляем %edx (В нём после операции будет остаток)
        divw %bx                # Делим %ax на %bx, остаток в %dx
        addb $0x30, %dl         # Прибавляем к %dl 0x30, чтобы перейти к коду числа.
        movb %dl, out8(%esi) 	# Копируем содержимое %dl в буфер по нужному смещению

        cmpw $0, %ax            # Дошли до нуля? (В %ax пусто?)
        je ToStr8_out     	# Да, заканчиваем преобразование

        decl %esi               # Нет, уменьшаем %esi на 1
        jmp ToStr8_begin     	# и переходим в начало цикла

ToStr8_out:
        cmpl  $6, %esi          # В %esi 6?
        je stop_to_string8     # Да, выходим

        movb out8(%esi), %al 	# Копируем байт по адресу  out(%esi) в %al
        movb $0, out8(%esi)  	# Записываем 0 по адресу out(%esi)
        movb %al, out8(%edi) 	# Записываем значение %al по адресу out(%edi)
        inc %esi                # Увеличиваем %esi на 1
        inc %edi                # Увеличиваем %edi на 1
        jmp ToStr8_out    	# Переходим в начало цикла

stop_to_string8:
	Write out8
	Puts ""
	movw $'',out8
ToString2:
	Puts "В двоичной cc:"
        movw $2, %bx           # Система счисления. На неё будем делить
        movl $15, %esi           # Адрес самого первого чила. В числе не может быть больше 16 чисел, поэтому устанавливаем смещение на 15
        movw summ, %ax 		# Копируем номер в %ax
        xorl %edi, %edi         # Обнуляем %edi

ToStr2_begin:                  # Начало цикла
        movl $0, %edx           # Обнуляем %edx (В нём после операции будет остаток)
        divw %bx                # Делим %ax на %bx, остаток в %dx
        addb $0x30, %dl         # Прибавляем к %dl 0x30, чтобы перейти к коду числа.
        movb %dl, out2(%esi) 	# Копируем содержимое %dl в буфер по нужному смещению

        cmpw $0, %ax            # Дошли до нуля? (В %ax пусто?)
        je ToStr2_out     	# Да, заканчиваем преобразование

        decl %esi               # Нет, уменьшаем %esi на 1
        jmp ToStr2_begin     	# и переходим в начало цикла

ToStr2_out:
        cmpl  $16, %esi          # В %esi 16?
        je stop_to_string2     # Да, выходим

        movb out2(%esi), %al 	# Копируем байт по адресу  out(%esi) в %al
        movb $0, out2(%esi)  	# Записываем 0 по адресу out(%esi)
        movb %al, out2(%edi) 	# Записываем значение %al по адресу out(%edi)
        inc %esi                # Увеличиваем %esi на 1
        inc %edi                # Увеличиваем %edi на 1
        jmp ToStr2_out    	# Переходим в начало цикла

stop_to_string2:
	movb $0,out2(%edi)
	Write out2
	Puts ""
	movw $'',out2
	jmp input
.end

