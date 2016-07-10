jr $ra           # 0x80000000
j interrupt      # 0x80000004
jr $k0           # 0x80000008 $26

main:
	lui $s1,16384         #0x40000000   0c  led   00 TH  04 TL 08 TCON
	lui $s0,16384
	addi $s0,$s0,24           #0x40000018  uart_tx  0x4000001c uart_rx  0x40000020 uart_con   #no ori

num1:
	lw $t1,8($s0)
	andi $t1,$t1,1
	beq $t1,$zero,num1
	lw $a0,4($s0)
num2:
	lw $t1,8($s0)
	andi $t1,$t1,2
	beq $t1,$zero,num2
	lw $a1,4($s0)

#	addi $a1,$zero,9
#	addi $a0,$zero,6
	andi $t0,$a0,15
	addi $a2,$t0,256
	jal Decode
	add $s4,$a2,$zero
	
	srl $t0,$a0,4
	andi $t0,$t0,15
	addi $a2,$t0,512
	jal Decode
	add $s5,$a2,$zero
	
	andi $t0,$a1,15
	addi $a2,$t0,1024
	jal Decode
	add $s6,$a2,$zero
	
	srl $t0,$a1,4
	andi $t0,$t0,15
	addi $a2,$t0,2048
	jal Decode
	add $s7,$a2,$zero     #decode
	
                              #最大公约数
	slt $t4,$a0,$a1
	beq $t4,$zero,Great
	add $t4,$a1,$zero
	sub $t5,$a1,$a0
	j Loop
Great:
	add $t4,$a0,$zero
	sub $t5,$a0,$a1
Loop:
	beq $t5,$zero,End
	sub $t6,$t4,$t5
	slt $t7,$t5,$t6
	beq $t7,$zero,Great1
	add $t4,$t6,$zero
	add $t5,$t5,$zero
	j Loop
Great1:
	add $t4,$t5,$zero
	add $t5,$t6,$zero
	j Loop
End:
	add $v0,$t4,$zero         #结果存入v0
	sw $v0,12($s1)             #led
	sw $v0,0($s0)             #uart_tx
	sw $zero,8($s0)
	add $s2,$zero,$zero
	addi $s3,$zero,4
#Timer initial
	sw $zero,8($s1)
	lui $t0,65535
	sra $t0,$t0,11    #TH    NO ori    addi &addiu are translated to lui&ori
	sw $t0,0($s1)
	lui $t1,65535
	sra $t1,$t1,16    #NO ori
	addi $t2,$zero,3
	sw $t1,4($s1)
	sw $t2,8($s1)
Loop1:
	jal Loop1
	
interrupt:
	lw $t2,8($s1)
	andi $t4,$t2,9                    #Apart from the lower 3 bits, the other bits has no meaning
	addi $sp,$sp,-4
	sw $t4,8($s1)
	sw $k0,0($sp)
	addi $s2,$s2,1
	bne $s2,$s3,display
	add $s2,$zero,$zero
display:
	beq $s2,$zero,display0
	addi $t9,$zero,1
	beq $s2,$t9,display1
	addi $t9,$zero,2
	beq $s2,$t9,display2
	addi $t9,$zero,3
	beq $s2,$t9,display3
display0:
	sw $s4,20($s1)
	lw $k0,0($sp)
	lw $t4,8($s1)
	addi $t8,$zero,2
	addi $sp,$sp,4
	or $t4,$t4,$t8                      #NO ori
	sw $t4,8($s1)
	addi $k0,$k0,-4
	jr $k0
display1:
	sw $s5,20($s1)
	lw $k0,0($sp)
	lw $t4,8($s1)
	addi $t8,$zero,2
	addi $sp,$sp,4
	or $t4,$t4,$t8                      #NO ori
	sw $t4,8($s1)
	addi $k0,$k0,-4
	jr $k0
display2:
	sw $s6,20($s1)
	lw $k0,0($sp)
	lw $t4,8($s1)
	addi $t8,$zero,2
	addi $sp,$sp,4
	or $t4,$t4,$t8                     #NO ori
	sw $t4,8($s1)
	addi $k0,$k0,-4
	jr $k0
display3:
	sw $s7,20($s1)
	lw $k0,0($sp)
	lw $t4,8($s1)
	addi $t8,$zero,2
	addi $sp,$sp,4
	or $t4,$t4,$t8                    #NO ori
	sw $t4,8($s1)
	addi $k0,$k0,-4
	jr $k0

Decode:
	andi $t8,$a2,15
	addi $t9,$zero,0
	beq  $t8,$t9,zero
	addi $t9,$zero,1
	beq  $t8,$t9,one
	addi $t9,$zero,2
	beq  $t8,$t9,two
	addi $t9,$zero,3
	beq  $t8,$t9,three
	addi $t9,$zero,4
	beq  $t8,$t9,four
	addi $t9,$zero,5
	beq  $t8,$t9,five
	addi $t9,$zero,6
	beq  $t8,$t9,six
	addi $t9,$zero,7
	beq  $t8,$t9,seven
	addi $t9,$zero,8
	beq  $t8,$t9,eight
	addi $t9,$zero,9
	beq  $t8,$t9,nine
	addi $t9,$zero,10
	beq  $t8,$t9,ten
	addi $t9,$zero,11
	beq  $t8,$t9,eleven
	addi $t9,$zero,12
	beq  $t8,$t9,twelve
	addi $t9,$zero,13
	beq  $t8,$t9,thirteen
	addi $t9,$zero,14
	beq  $t8,$t9,fourteen
	addi $t9,$zero,15
	beq  $t8,$t9,fifteen
zero:
	addi $a2,$a2,64
	jr $ra
one:
	addi $a2,$a2,120
	jr $ra
two:
	addi $a2,$a2,34
	jr $ra
three:
	addi $a2,$a2,45
	jr $ra
four:
	addi $a2,$a2,21
	jr $ra
five:
	addi $a2,$a2,13
	jr $ra
six:
	addi $a2,$a2,-4
	jr $ra
seven:
	addi $a2,$a2,113
	jr $ra
eight:
	addi $a2,$a2,-8
	jr $ra
nine:
	addi $a2,$a2,7
	jr $ra
ten:
	addi $a2,$a2,-2
	jr $ra
eleven:
	addi $a2,$a2,-8
	jr $ra
twelve:
	addi $a2,$a2,58
	jr $ra
thirteen:
	addi $a2,$a2,20
	jr $ra
fourteen:
	addi $a2,$a2,-8
	jr $ra
fifteen:
	addi $a2,$a2,-1
	jr $ra	
