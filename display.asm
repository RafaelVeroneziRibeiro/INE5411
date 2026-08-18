# Arquivo: display.asm
# Autores: Rafael Veronezi Ribeiro e Gabriel Baggio
# Descrição: Controle dos displays de 7 segmentos.
#            Responsável por converter valores numéricos em padrões de bits
#            para acender os LEDs corretos na interface gráfica do simulador.
#
# Funções Principais:
# - mostrar_numero: Recebe um valor (0-99), separa dezenas e unidades, e exibe.
# - mostrar_OP: Exibe a string "OP" (Open) indicando porta aberta.
# - apagar_display: Zera os registradores, desligando todos os LEDs.

.globl mostrar_digitos, mostrar_numero, mostrar_OP, mostrar_00, apagar_display

.data

	segmentos:

		.byte 0x3F      #0
		.byte 0x06      #1
		.byte 0x5B      #2
		.byte 0x4F      #3
		.byte 0x66      #4
		.byte 0x6D      #5
		.byte 0x7D      #6
		.byte 0x07      #7
		.byte 0x7F      #8
		.byte 0x6F      #9


.text

	mostrar_digitos:

		la $t0,segmentos
		
		# Busca o padrão de bits para a dezena
		addu $t1,$t0,$a0
		lbu $t2,0($t1)
		
		# Busca o padrão de bits para a unidade
		addu $t1,$t0,$a1
		lbu $t3,0($t1)

		# Escreve nos endereços de Memória Mapeada dos displays
		li $t4,0xFFFF0011
		sb $t2,0($t4)

		li $t4,0xFFFF0010
		sb $t3,0($t4)

		jr $ra

# Função: mostrar_numero
# Descrição: Recebe um número completo (0-99) e extrai a dezena e a unidade
#            usando divisão inteira por 10.
# Parâmetros: $a0 = Número a ser exibido

	mostrar_numero:
		addiu $sp, $sp, -4
		sw $ra, 0($sp)

		li $t0,10
		
		# Decomposição Matemática:
		# Divide o número por 10. O quociente será a dezena e o resto será
		# a unidade.
		

		div $a0,$t0

		mflo $a0
		mfhi $a1

		jal mostrar_digitos # Chama a rotina de hardware passando os dígitos
		
		lw $ra, 0($sp)
		addiu $sp, $sp, 4
			
		jr $ra

	# Função: mostrar_OP
	# Descrição: Rotina hardcoded para exibir o alerta "OP" (Open) no display.
	mostrar_OP:

		li $t0,0xFFFF0011
		li $t1,0x3F
		sb $t1,0($t0)

		li $t0,0xFFFF0010
		li $t1,0x73
		sb $t1,0($t0)

		jr $ra
	
	# Função: mostrar_00
	# Descrição: Rotina auxiliar rápida para zerar visualmente o display.
	mostrar_00:
		addiu $sp, $sp, -4
		sw $ra, 0($sp)

		li $a0,0
		li $a1,0

		jal mostrar_digitos
		
		
		lw $ra, 0($sp)
		addiu $sp, $sp, 4
		
		jr $ra

	# Função: apagar_display
	# Descrição: Desliga todos os segmentos enviando o valor 0 (zero lógico) 
	#            para os endereços dos dois displays.
	apagar_display:
	
		li $t0,0xFFFF0011
		sb $zero,0($t0)

		li $t0,0xFFFF0010
		sb $zero,0($t0)

		jr $ra
