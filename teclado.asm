# Arquivo: teclado.asm
# Autores: Rafael Veronezi Ribeiro e Gabriel Baggio
# Descrição: Responsável por realizar a varredura física (polling) das linhas 
#	     e colunas, tratar repetições (debounce lógico)
#            e converter o código bruto de hardware para o valor lógico correspondente.
#
# Funções Principais:
# - init_tabela: Popula na memória a tabela de conversão (Mapeamento de Hardware -> Lógico).
# - ler_teclado: Executa a varredura, trata debounce e retorna a tecla (-1 se nenhuma).


.data 
	# guarda o ultimo codigo lido, evita que uma tecla pressionada seja retornada varias vezes
	tecla_anterior: .byte 0 
	
	# cria uma tabela de 256 bytes, todos os elementos começam com -1
	tabela: .byte -1:256
	
.text 
.globl init_tabela, ler_teclado


	init_tabela:	
	
		la $t0, tabela

    		li $t1,0
    		sb $t1,0x11($t0) # Tecla 0

    		li $t1,1
    		sb $t1,0x31($t0) # Tecla 1
	
    		li $t1,2
    		sb $t1,0x51($t0) # Tecla 2

    		li $t1,3
    		sb $t1,0x91($t0) # Tecla 3


    		li $t1,4
    		sb $t1,0x32($t0) # Tecla 4

    		li $t1,5
    		sb $t1,0x22($t0) # Tecla 5

    		li $t1,6
    		sb $t1,0x62($t0) # Tecla 6

    		li $t1,7
    		sb $t1,0x92($t0) # Tecla 7


    		li $t1,8
    		sb $t1,0x54($t0) # Tecla 8

    		li $t1,9
    		sb $t1,0x64($t0) # Tecla 9

    		li $t1,10
    		sb $t1,0x44($t0) # Tecla A

    		li $t1,11
    		sb $t1,0xC4($t0) # Tecla B



    		li $t1,12
    		sb $t1,0x98($t0) # Tecla C

    		jr $ra

# Função: ler_teclado
# Descrição: Realiza a varredura das 4 linhas do teclado para detectar qual
#            coluna foi ativada.
# Retorno: $v0 contém o valor lógico da tecla (0-12) ou -1 se nenhuma for lida.


	ler_teclado: 
	
		addiu $sp, $sp, -4		
		sw $ra, 0($sp) # salva o endereço de retorno na pilha
		
		li $t0, 0xFFFF0012 # endereço da linha
		li $t1, 0xFFFF0014 # endereço da leitura
		
		li $t2, 1
		li $t3, 4 # 4 linhas para varrer
		
	varredura:
        
        	sb $t2, 0($t0) # linha atual
        	lbu $t4, 0($t1) # le se alguma coluna foi pressionada
        	
        	bne $t4, $zero, tecla_encontrada # se != 0, uma tecla foi pressionada
        
        	# proxima linha
        	
        	sll $t2, $t2, 1
        	addiu $t3, $t3, -1
        	bgtz $t3, varredura
        
        	# nenhuma tecla
        	
        	sb $zero, 0($t0)
        	la $t5, tecla_anterior
        	sb $zero, 0($t5)    # reseta ultima tecla
        	li $v0, -1    # retorna que nenhuma foi pressionada
        
        	j finalizar_teclado

		
	tecla_encontrada: 
	
		# O hardware retorna a linha e a coluna separadas.
		# Para buscar na lookup table, combinamos os dois dados em um único byte.
		# Deslocamos a linha para o nibble superior e aplicamos OR com a coluna.	
		
		sll $t8, $t2, 4 # Desloca  alinha para o nibble superior
		or $t8, $t8, $t4 # Combina com a coluna
	
	

		la $t5, tecla_anterior		
		lbu $t6, 0($t5)
		beq $t4, $t6, tecla_repetida # se for a mesma tecla do ciclo anterior, ignora
		
		sb $t4, 0($t5) # atualiza a tecla_anterior com a nova leitura	
		move $a0, $t8
		
		jal converter # busca o valor lógico na tabela
		j finalizar_teclado
		
	tecla_repetida:
		
		li $v0, -1
		
	finalizar_teclado:
	
		lw $ra, 0($sp)
		addiu $sp, $sp, 4
		jr $ra
		
	
	converter:
	
		la $t0, tabela
		addu $t0, $t0, $a0 # soma o endereço base com o offset da tecla
		lb $v0, 0($t0) # carrega o valor convertido em $v0
		jr $ra
