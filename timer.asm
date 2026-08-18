# Arquivo: timer.asm
# Autores: Rafael Veronezi Ribeiro e Gabriel Baggio
# Descrição: Gerenciador de tempo (Timer) do sistema.
#            Utiliza a chamada de sistema (syscall 30) para obter o tempo
#            do SO em milissegundos. Permite checar a passagem do tempo
#            de forma assíncrona/não-bloqueante através do cálculo de "delta".
#
# Funções Principais:
# - timer_reset: Salva o tempo atual do sistema como ponto de partida.
# - passou_1s: Retorna 1 se passou 1000ms desde o último tick, 0 caso contrário.

.data
	# armazena a marcação de tempo (em ms) do último evento validado
	ultimo_tick: .word 0

.text
.globl timer_reset, passou_1s


	timer_reset:

		li $v0,30
		syscall

		la $t0,ultimo_tick

		sw $a0,0($t0)

		jr $ra

#Função: passou_1s
# Descrição: Calcula a diferença (Tempo Atual - Último Tick).
#            Se a diferença atingir o limiar de 1 segundo (1000 ms), atualiza
#            a referência e sinaliza positivamente.
# Retorno: $v0 = 1 (passou 1s) | $v0 = 0 (ainda não passou 1s)

	passou_1s:

		li $v0,30
		syscall

		move $t1,$a0 # $t1 = Tempo Atual (em ms)

		la $t0,ultimo_tick
	
		lw $t2,0($t0)

		subu $t3,$t1,$t2

		li $t4,1000

		blt $t3,$t4,nao_passou # Se Delta < 1000ms, vai para 'nao_passou'

		# Se passou de 1000ms, atualiza a marcação de tempo para o próximo ciclo
		sw $t1,0($t0)

		li $v0,1 # retorna verdadeiro (1)

		jr $ra

	nao_passou:

		move $v0,$zero

		jr $ra
