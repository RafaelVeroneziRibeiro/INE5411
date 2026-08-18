# Arquivo: main.asm
# Autores: Rafael Veronezi Ribeiro e Gabriel Baggio
# Descrição: Módulo de inicialização e ponto de entrada (entry point) do sistema.
#            Sua única responsabilidade é invocar as rotinas de configuração
#            dos periféricos simulados e gerenciar o fluxo contínuo de execução

.text
.globl main

main:
	jal init_tabela	# inicializa a tabela com os valores do teclado
	jal logica_init	# inicializa as variáveis globais da FSM e zera o display

loop:
	jal logica_tick # Executa um ciclo básico de avaliação lógica 
	j loop
