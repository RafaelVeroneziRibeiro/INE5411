# ============================================================
#  DIAGRAMA DE ESTADOS — MICRO-ONDAS
# ============================================================
#
#  Estados:
#    IDLE      : esperando entrada do usuario
#    RUNNING   : contagem regressiva ativa
#    PAUSED    : contagem pausada (B pressionado)
#    DOOR_OPEN : porta aberta (C pressionado)
#    DONE      : tempo chegou a 00 (pisca 3x)
#
# ============================================================
#
#              digita 0-9
#   +--------+-----------> (atualiza display)
#   |  IDLE  |<-----------+
#   +--------+            |
#       |                 | DONE (fim da animacao)
#       | A (tempo>0      |
#       |  e porta fecha) |
#       v                 |
#   +---------+     +------+
#   | RUNNING |---->| DONE |
#   +---------+     +------+
#       |  ^
#     B |  | A (porta fechada, tempo>0)
#       v  |
#   +--------+
#   | PAUSED |
#   +--------+
#       |
#       | B (segundo clique)
#       v
#     IDLE (zera tempo)
#============================================================
#  Transicoes por C (sensor de porta) — de qualquer estado:
#
#   RUNNING  --[C: abre porta]--> DOOR_OPEN  (para aquecimento,
#                                             congela tempo,
#                                             exibe "OP")
#   PAUSED   --[C: abre porta]--> DOOR_OPEN  (idem)
#   IDLE     --[C: abre porta]--> DOOR_OPEN  (exibe "OP")
#
#   DOOR_OPEN --[C: fecha porta]--> estado anterior
#                                   (restaura display)
#
#  Bloqueio: tecla A ignorada enquanto em DOOR_OPEN
#
# ============================================================

# Estados:
#   0 = IDLE
#   1 = RUNNING
#   2 = PAUSED
#   3 = DOOR_OPEN
#   4 = DONE


.data
	estado:          .word 0
	estado_anterior: .word 0
	tempo:           .word 0

.text
.globl logica_init
.globl logica_tick	
	
					
# zerar as variaveis e mostrar 00 na tela				
logica_init:
	sw $zero, estado
	sw $zero, estado_anterior
	sw $zero, tempo
	
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal mostrar_00
	
	lw $ra, 0($sp)
	addiu $sp, $sp,  4
	
	jr $ra
	
	
#  loop principal: lê tecla, despacha pra handler correto, 
# e se RUNNING verifica se passou 1s pra decrementar	
logica_tick:
	addiu $sp, $sp, -8
	sw    $ra, 0($sp)
	sw    $s0, 4($sp)
	
	
	jal ler_teclado
	
	
	move $s0, $v0		# s0 tem o valor retornado de ler_teclado		
				# 0...9 os digitos, 10-A, 11-B, 12-C, -1-nenhuma
				
	
	li $t0, 10
	beq $t0, $s0, tecla_A
	
	li $t0, 11
	beq $t0, $s0, tecla_B
	
	li $t0, 12
	beq $t0, $s0, tecla_C
	
	bltz $s0, nenhuma_tecla
	beq $s0, 255, nenhuma_tecla
	blt $s0, 10, tecla_digito
	
	j fim_teclado
	
	
nenhuma_tecla:
	j fim_teclado


# preciso ver primeiro se nao é estado door_open (3) pq nao pode
# preciso ver tambem se ja nao esta rodando (1)
# preciso ver se o tempo for 0, aí ele só pula pro fim
# se estiver ok preciso colocar o estado em 1 e chamar timer_reset (salva o tempo atual)

tecla_A:
### verificacoes
	lw $t0, estado
	li $t1, 3
	beq $t0, $t1, lt_fim
	
	li $t1, 1
	beq $t0, $t1, lt_fim
	
	lw $t0, tempo
	beq $zero, $t0, lt_fim
### logica
	li $t0, 1
	sw $t0, estado
	
	
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal timer_reset
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	j lt_fim


# se estiver em funcionamento(1), 1 clique pausa a contagem(2)
# se ja estiver pausado(2), 1 clique zera o tempo (0)
# se a porta estiver aberta (3), 1 clique deve zerar tambem, mas manter a porta aberta 

tecla_B:
	lw $t0, estado
	li $t1, 1
	beq $t0, $t1, tecla_b_pause
	
	li $t1, 2
	beq $t0, $t1, tecla_b_zerar
	
	li $t1, 3
	beq $t0, $t1, tecla_b_op
	
	j tecla_b_zerar
	
tecla_b_zerar:
	sw $zero, estado
	sw $zero, tempo
	
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal mostrar_00

	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	j lt_fim	

tecla_b_pause:
	li $t0, 2
	sw $t0, estado
	j lt_fim

tecla_b_op:	
	sw $zero, estado_anterior
	sw $zero, tempo
	
	#addiu $sp, $sp, -4
	#sw $ra, 0($sp)
	#jal mostrar_00
	#lw $ra, 0($sp)
	#addiu $sp, $sp, 4
	
	j lt_fim


# clicou --> abre porta (3)
# já está em 3 (aberto) --> estado_anterior

tecla_C:
	lw $t0, estado
	li $t1, 3
	beq $t0, $t1, tecla_C_fechar
	
	sw $t0, estado_anterior
	li $t1, 3
	sw $t1, estado
	
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	jal mostrar_OP
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	j lt_fim
	
tecla_C_fechar:
	lw $t0, estado_anterior
	li $t1, 1
	beq $t0, $t1, estado_anterior_op_running
	
	sw $t0, estado
	
tecla_C_fechar_continue:

	lw $a0, tempo
	
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	
	###
	jal timer_reset
	
	lw $a0, tempo
	###
	jal mostrar_numero
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	j lt_fim

estado_anterior_op_running:
	li $t1, 2
	sw $t1, estado
	
	j tecla_C_fechar_continue

# se o estado for != de IDLE(0) ele deve ir para o fim
# salvar o tempo atual, dividir por 10, o resto será a unidade
# multiplica o resto por 10, virou a nova dezena
# soma o novo digito digitado
# salva o novo tempo
# ex ==> tempo tava em 58, foi digitado 3, divide por 10 vai dar 5 resto 8
# pega a unidade (8), multiplica por 10 e soma com o que foi digitado ==> 83
# novo tempo = 83, o mesmo vale para 00 trivialmente
tecla_digito:
	# só prossegue se o estado for IDLE
	lw $t0, estado
	bnez $t0, lt_fim
	
	lw $t1, tempo
	li $t2, 10
	
	div $t1, $t2
	mfhi $t3		# unidade atual vira a nova dezena
	mul $t3, $t3, $t2
	add $t3, $t3, $s0	# o dígito ta em s0
	sw $t3, tempo
	move $a0, $t3
	
	
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	jal mostrar_numero
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	j lt_fim
	

fim_teclado:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	jal passou_1s
	lw $ra, 0($sp)
	addiu $sp, $sp, 4 
	beq $v0, $zero, lt_fim 
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	jal logica_decrementa
	lw $ra, 0($sp)
	addiu $sp, $sp, 4

lt_fim:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addiu $sp, $sp, 8
	jr $ra
	
	
###################################################################################

# -1 no tempo e chama mostrar numero com o tempo atualizado, 
# deve verificar tambem se o tempo nao chegou em 0 pra fazer o devido encaminhamento

logica_decrementa:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, estado
	li $t1, 1
	bne $t0, $t1, ld_fim
	
	lw $t0, tempo
	addiu $t0, $t0, -1
	sw $t0, tempo
	move $a0, $t0
	
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	jal mostrar_numero
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	lw $t0, tempo		# precisamos recarregar o tempo, o jal de mostrar_numero não mantém a informação
	bgtz $t0, ld_fim
	
	# chegou a zero --> done
	li $t0, 4
	sw $t0, estado
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	jal logica_done
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
ld_fim:
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	jr $ra
	
# piscar 00 3 vezes e voltar pra IDLE
logica_done:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $s2, 3
	
ld_loop:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	jal mostrar_00
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jal esperar_500ms
	
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	jal apagar_display
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jal esperar_500ms
	
	addiu $s2, $s2, -1
	bgtz $s2, ld_loop
	
	sw $zero, estado
	sw $zero, tempo
	jal mostrar_00
	

	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra
	
esperar_500ms:

	li $v0, 30
	syscall
	move $t0, $a0
	
await_loop:
	li $v0, 30
	syscall
	subu $t1, $a0, $t0
	li $t2, 500
	blt $t1, $t2, await_loop
	jr $ra
	

					
