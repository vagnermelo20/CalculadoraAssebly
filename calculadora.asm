# ------------------------------------------------------------------
# AUTOR: Vagner Montenegro de Melo
# DATA: 01/12 - 21:46
# DATA: 01/12 - 22:23
# PROJETO: Calculadora Programador Didática - Infra de Hardware
# ------------------------------------------------------------------

.data
    menu_msg:       .asciiz "\n\n--- MENU ---\n1 - Base 10 para Base 2 (Binario)\n2 - Base 10 para Base 8 (Octal)\n3 - Base 10 para Base 16 (Hex)\n4 - Base 10 para BCD\n5 - Base 10 para 16 bits com Sinal (Comp. 2)\n0 - Sair\nEscolha: "
    msg_input:      .asciiz "\nDigite o numero Decimal (Inteiro): "
    msg_result:     .asciiz "\nResultado Final: "
    
    msg_step:       .asciiz "\nPasso: "
    msg_div:        .asciiz " / "
    msg_eq:         .asciiz " = "
    msg_rest:       .asciiz " [Resto: "
    msg_close:      .asciiz "]"
    msg_bcd_step:   .asciiz "\nDigito Decimal: "
    msg_bcd_arrow:  .asciiz " -> Em Binario (4 bits): "
    
.text
.globl main

main:
    li $v0, 4
    la $a0, menu_msg
    syscall

    li $v0, 5
    syscall
    move $s0, $v0

    beq $s0, 0, exit
    beq $s0, 1, case_bin
    beq $s0, 2, case_oct
    beq $s0, 3, case_hex
    beq $s0, 4, case_bcd
    beq $s0, 5, case_signed
    
    j main

# ---------------------------------------------------------
# A) BASE 10 PARA BASE 2 (BINARIO)
# ---------------------------------------------------------
case_bin:
    li $v0, 4
    la $a0, msg_input
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    
    li $t1, 2
    li $t3, 0
    
loop_bin:
    div $t0, $t1
    mflo $t4
    mfhi $t5
    
    jal print_step_math

    subu $sp, $sp, 4
    sw $t5, ($sp)
    addi $t3, $t3, 1

    move $t0, $t4
    bgt $t0, 0, loop_bin

    j print_stack_result

# ---------------------------------------------------------
# B) BASE 10 PARA BASE 8 (OCTAL)
# ---------------------------------------------------------
case_oct:
    li $v0, 4
    la $a0, msg_input
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    
    li $t1, 8
    li $t3, 0
    
loop_oct:
    div $t0, $t1
    mflo $t4
    mfhi $t5
    
    jal print_step_math

    subu $sp, $sp, 4
    sw $t5, ($sp)
    addi $t3, $t3, 1

    move $t0, $t4
    bgt $t0, 0, loop_oct

    j print_stack_result

# ---------------------------------------------------------
# C) BASE 10 PARA BASE 16 (HEXADECIMAL)
# ---------------------------------------------------------
case_hex:
    li $v0, 4
    la $a0, msg_input
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    
    li $t1, 16
    li $t3, 0
    
loop_hex:
    div $t0, $t1
    mflo $t4
    mfhi $t5
    
    jal print_step_math

    subu $sp, $sp, 4
    sw $t5, ($sp)
    addi $t3, $t3, 1

    move $t0, $t4
    bgt $t0, 0, loop_hex

    li $v0, 4
    la $a0, msg_result
    syscall

pop_hex_loop:
    beq $t3, 0, return_main
    lw $t5, ($sp)
    addu $sp, $sp, 4
    
    blt $t5, 10, print_num_hex
    addi $t5, $t5, 55
    li $v0, 11
    move $a0, $t5
    syscall
    j decr_hex_count

print_num_hex:
    li $v0, 1
    move $a0, $t5
    syscall

decr_hex_count:
    subi $t3, $t3, 1
    j pop_hex_loop

# ---------------------------------------------------------
# D) CODIGO BCD (Binary Coded Decimal)
# ---------------------------------------------------------
case_bcd:
    li $v0, 4
    la $a0, msg_input
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    
    li $t1, 10
    li $t3, 0
    
loop_split_digits:
    div $t0, $t1
    mflo $t0
    mfhi $t5
    
    subu $sp, $sp, 4
    sw $t5, ($sp)
    addi $t3, $t3, 1
    
    bgt $t0, 0, loop_split_digits
    
    li $v0, 4
    la $a0, msg_result
    syscall

pop_bcd_loop:
    beq $t3, 0, return_main
    lw $t5, ($sp)
    addu $sp, $sp, 4
    
    li $v0, 4
    la $a0, msg_bcd_step
    syscall
    li $v0, 1
    move $a0, $t5
    syscall
    li $v0, 4
    la $a0, msg_bcd_arrow
    syscall
    
    andi $t6, $t5, 8
    srl $a0, $t6, 3
    li $v0, 1
    syscall

    andi $t6, $t5, 4
    srl $a0, $t6, 2
    li $v0, 1
    syscall

    andi $t6, $t5, 2
    srl $a0, $t6, 1
    li $v0, 1
    syscall

    andi $t6, $t5, 1
    move $a0, $t6
    li $v0, 1
    syscall
    
    subi $t3, $t3, 1
    j pop_bcd_loop

# ---------------------------------------------------------
# QUESTÃO 2 - BASE 10 PARA 16 BITS COM SINAL (COMPLEMENTO A 2)
# ---------------------------------------------------------
case_signed:
    li $v0, 4
    la $a0, msg_input
    syscall
    li $v0, 5
    syscall
    move $t0, $v0

    li $v0, 4
    la $a0, msg_result
    syscall

    li $t1, 15
loop_print_bits:
    blt $t1, 0, return_main
    
    li $t2, 1
    sllv $t2, $t2, $t1
    and $t3, $t0, $t2
    
    bnez $t3, print_one
    
    li $a0, 0
    li $v0, 1
    syscall
    j next_bit

print_one:
    li $a0, 1
    li $v0, 1
    syscall

next_bit:
    subi $t1, $t1, 1
    j loop_print_bits

# ---------------------------------------------------------
# FUNCOES AUXILIARES
# ---------------------------------------------------------
print_step_math:
    li $v0, 4
    la $a0, msg_step
    syscall
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, msg_div
    syscall
    li $v0, 1
    move $a0, $t1
    syscall
    li $v0, 4
    la $a0, msg_eq
    syscall
    li $v0, 1
    move $a0, $t4
    syscall
    li $v0, 4
    la $a0, msg_rest
    syscall
    li $v0, 1
    move $a0, $t5
    syscall
    li $v0, 4
    la $a0, msg_close
    syscall
    jr $ra

print_stack_result:
    li $v0, 4
    la $a0, msg_result
    syscall
pop_loop:
    beq $t3, 0, return_main
    lw $a0, ($sp)
    addu $sp, $sp, 4
    li $v0, 1
    syscall
    subi $t3, $t3, 1
    j pop_loop

return_main:
    j main

exit:
    li $v0, 10
    syscall