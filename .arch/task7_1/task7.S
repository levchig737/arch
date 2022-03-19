.include "my-macro"

.extern scanf	
.extern printf

.data 
get:	.long	0
put:	.long	0

#	Форматные строки для передачи их адресов как параметров
fmti:
        .string "%ld" 	# scanf: h - 8 бит, u - беззнаковое целое 

fmtp:
	.string "%lu\n"  # printf 
	

.text        # секция команд процесора
	
.type   Fact, @function

Fact:

#       Стандартный пролог фунции

        pushl %ebp       # сохранить в стеке значение, бывшее в вызывающей
        movl  %esp, %ebp # обеспечить адресный доступ к параметрам и 
                         # локальным переменнным в стеке путем базовой 
			# адресации через ebp



	
#       тело функции
        movl 8(%ebp), %ebx  # параметр в ebx

	cmpl $1, %ebx
	je Fact1

	# Вызов Fact
	
        decl %ebx    # получение следующего параметра
	pushl %ebx
	call Fact
	addl $4, %esp   # очистка стека
	
	movl 8(%ebp), %ebx  # параметр в ebx
	imull %ebx, %eax
	
	jc Fact_err
	
	#       Стандартный эпилог функции
FactEnd:	
        movl %ebp, %esp # восстановить указатель стека
        popl %ebp       # восстановить ebp
        ret             # возврат в вызывающую
	
Fact1:
	movl $1, %eax
	jmp FactEnd
Fact_err:
	movl $0, %eax
	jmp FactEnd
.global main # точка входа - глобальная метка

main:
	nop

#	Вызовы scanf  для ввода значений 32 
#       битовых целых get и put, форматная строка fmtl        
	
	Puts "Введите число:"
        pushl $get	# 2 параметр - адрес переменной
        pushl $fmti	# 1 параметр - адрес форматной строки
	call scanf           
	addl $8, %esp   # очистка стека
	
#	получение факториала
	pushl get
	call Fact
	addl $4, %esp   # очистка стека
	movl %eax, put

	cmpl $0, %eax
	je err
#	печать суммы

        Puts "Факториал:"	
	pushl put              # 2 параметр - значение 
	pushl $fmtp          # 1 параметр - адрес форматной строки 
	call printf

	addl $8, %esp        # очистка стека

End:	
	Finish
err:
	Puts "Ошибка: число слишком большое"
	jmp End
.end
