# AUTHOR: Igor '@m8dotpie' Alentev
# Description:
# Space Invaders from ITP Course
# Ported from C language to MIPS Assembly

# FIELD PROPERTIES:
# HEIGHT: 23 (Including terminators)
# LENGTH: 43 

.data 
	cls: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
	intro: .asciiz "Welcome to MIPS version of Space Invaders!\nHave a nice game!\n"
	field: .asciiz "\n|                                        |\n|      M M M M M M M M M M M M M M M     |\n|                                        |\n|      M M M M M M M M M M M M M M M     |\n|                                        |\n|      M M M M M M M M M M M M M M M     |\n|                                        |\n|      M M M M M M M M M M M M M M M     |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                    A                   |\n"
	new_field: .asciiz "|                                        |\n|      M M M M M M M M M M M M M M M     |\n|                                        |\n|      M M M M M M M M M M M M M M M     |\n|                                        |\n|      M M M M M M M M M M M M M M M     |\n|                                        |\n|      M M M M M M M M M M M M M M M     |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                                        |\n|                    A                   |\n"
	space: .byte ' '
	player_laser: .byte '^'
	player_address: .word 0x1001043f
	player: .byte 'A'
        enemy: .byte 'M'
	enemy_laser: .byte 'U'
        enemy_direction: .byte 0
        score_text: .asciiz "Your current score: "
        victory_text: .asciiz "Congratulations! You won!\nYour score: "
        loose_text: .asciiz "Bad news! You lost!\nYour score: "
        score: .word 0
        laser_text: .asciiz "\nLaser status: "
        laser_status1: .asciiz "LASER READY"
        laser_status2: .asciiz "cooldown"
        laser_status: .word 0
	
.text

main:
        jal clear_scr
	li $v0, 4
	la $a0, intro
	syscall

	li $a0, 3000
	jal sleep

	li $t0, 1

	gameLoop:
		jal clear_scr
        
		beq $t0, $zero, exit
        
		li $a0, 0
		jal sleep
    
		li $v0, 4
                la $a0, score_text
                syscall

                lw $a0, score
                li $v0, 1
                syscall

                lw $t1, laser_status
                la $a0, laser_text
                li $v0, 4
                syscall

                la $a0, laser_status1
                ble $t1, 1, gl_continue 

                unready:
                        la $a0, laser_status2

                gl_continue:
                        syscall
                addi $t1, $t1, -1
                sw $t1, laser_status

                li $v0, 4
		la $a0, field
		syscall
        
		addi $sp, $sp, -4
		sw $t0, 0($sp)
        
                jal handle_player_shots
		jal handle_player
                jal handle_enemy_shots
                jal handle_enemy
                jal enemy_shoot
        
		lw $t0, 0($sp)
		addi $sp, $sp, 4
        
                j gameLoop
		
	exit:
		li $v0, 10
		syscall

victory:
        jal clear_scr

        la $a0, victory_text
        li $v0, 4
        syscall

        lw $a0, score
        li $v0, 1
        syscall

        li $a0, 3000
        jal sleep

        li $v0, 10
        syscall

loose:
        jal clear_scr

        la $a0, loose_text
        li $v0, 4
        syscall

        lw $a0, score
        li $v0, 1
        syscall

        li $a0, 3000
        jal sleep

        li $v0, 10
        syscall

enemy_shoot:
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        lw $ra, 0($sp)
        addi $sp, $sp, 4

handle_player_shots:
        la $t1, field
        addi $t7, $t1, 989
        hps_iterate:
                bge $t1, $t7, hps_iterate_exit 

                lb $t0, 0($t1)
                beq $t0, '^', hps_laser

                addi $t1, $t1, 1
                bge $t1, $t7, hps_iterate_exit 
                j hps_iterate

                hps_laser:

                        lb $t2, space
                        lb $t3, -43($t1)
                        lb $t4, player_laser
                        sb $t2, 0($t1)

                        bne $t3, 'M', hps_not_shot
                        lw $t5, score
                        addi $t5, $t5, 50
                        sw $t5, score
                        sb $t2, -43($t1)
                        j hps_iterate

                        hps_not_shot:
                                sb $t4, -43($t1)
                                j hps_iterate
                                

                hps_iterate_exit:
                        jr $ra

handle_enemy_shots:
        jr $ra

handle_enemy:
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        lb $t0, enemy_direction
        la $t1, field
        addi $t7, $t1, 989 # MAX ADDRESS
        li $t6, 0

        beq $t0, 0, move_enemy_left
        beq $t0, 1, move_enemy_right

        j handle_enemy_exit
        
        move_enemy_left:
                li $t4, 0
                mel_iterate:
                        lb $t2, enemy
                        lb $t3, space
                        lb $t0, 0($t1)
                        
                        beq $t0, $t2, mel_enemy
        
                        addi $t1, $t1, 1

                        bge $t1, $t7, mel_iterate_exit

                        j mel_iterate

                        mel_enemy:
                                lb $s1, -1($t1)
                                beq $s1, 'A', loose
                                li $t6, 1
                                lb $t2, -1($t1)
                                beq $t2, '^', mel_got_shot
                                lb $t2, enemy
                                sb $t2, -1($t1)
                                sb $t3, 0($t1)
                                lb $t5, -2($t1)

                                beq $t5, '|', change_mel_flag
                                j mel_iterate
                                change_mel_flag:
                                        li $t4, 1
                                        j mel_iterate
                                mel_got_shot:
                                        lw $t5, score
                                        addi $t5, $t5, 50
                                        sw $t5, score
                                        lb $t2, space
                                        sb $t2, -1($t1)
                                        sb $t3, 0($t1)
                                        lb $t5, -2($t1)

                                        beq $t5, '|', change_mel_flag
                                        j mel_iterate

                        mel_iterate_exit:
                                beq $t4, 1, move_enemy_down
                                j handle_enemy_exit

        move_enemy_right:
                li $t4, 0
                mer_iterate:
                        lb $t2, enemy
                        lb $t3, space
                        lb $t0, 0($t1)
                        
                        beq $t0, $t2, mer_enemy
        
                        addi $t1, $t1, 1

                        bge $t1, $t7, mer_iterate_exit

                        j mer_iterate

                        mer_enemy:
                                lb $s1, 1($t1)
                                beq $s1, 'A', loose
                                li $t6, 1
                                lb $t2, 1($t1)
                                beq $t2, '^', mer_got_shot
                                lb $t2, enemy
                                sb $t2, 1($t1)
                                sb $t3, 0($t1)
                                lb $t5, 2($t1)

                                addi $t1, $t1, 2

                                beq $t5, '|', change_mer_flag
                                j mer_iterate
                                change_mer_flag:
                                        li $t4, 1
                                        j mer_iterate
                                mer_got_shot:
                                        lw $t5, score
                                        addi $t5, $t5, 50
                                        sw $t5, score
                                        lb $t2, space
                                        sb $t2, 1($t1)
                                        sb $t3, 0($t1)
                                        lb $t5, 2($t1)

                                        addi $t1, $t1, 2

                                        beq $t5, '|', change_mer_flag
                                        j mer_iterate
                        mer_iterate_exit:
                                beq $t4, 1, move_enemy_down
                                j handle_enemy_exit

        move_enemy_down:
                lb $t0, enemy_direction
                xori $t0, $t0, 1

                la $t1, field

                sb $t0, enemy_direction

                li $t4, 0
                med_iterate:
                        bge $t1, $t7, med_iterate_exit

                        lb $t2, enemy
                        lb $t3, space
                        lb $t0, 0($t1)
                        
                        beq $t0, $t2, med_enemy
        
                        addi $t1, $t1, 1

                        bge $t1, $t7, med_iterate_exit

                        beq $t0, '|', check_row

                        j med_iterate

                        check_row:
                                beq $t4, 1, skip_row
                                
                                li $t4, 0
                                j med_iterate

                                skip_row:
                                        li $t4, 0
                                        addi $t1, $t1, 43
                                        j med_iterate

                        j med_iterate

                        med_enemy:
                                lb $s1, 43($t1)
                                addi $s2, $t1, 43
                                li $s3, 43
                                la $s4, field
                                sub $s2, $s2, $s4
                                div $s2, $s2, $s3
                                beq $s2, 22, loose
                                beq $s1, 'A', loose
                                li $t6, 1
                                lb $t2, 43($t1)
                                beq $t2, '^', med_got_shot
                                lb $t2, enemy
                                sb $t2, 43($t1)
                                sb $t3, 0($t1)

                                addi $t1, $t1, 2

                                li $t4, 1

                                j med_iterate
                                med_got_shot:
                                        lw $t5, score
                                        addi $t5, $t5, 50
                                        sw $t5, score
                                        lb $t2, enemy
                                        sb $t2, 43($t1)
                                        sb $t3, 0($t1)

                                        addi $t1, $t1, 2

                                        li $t4, 1

                                        j med_iterate
                                

                        med_iterate_exit:
                                j handle_enemy_exit

                j handle_enemy_exit

        handle_enemy_exit:
                lw $ra, 0($sp)
                addi $sp, $sp, 4
                beq $t6, 0, victory
                jr $ra
	
handle_player:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $v0, 12
	syscall

	move $a0, $v0
	jal move_player

	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra
	
move_player:
	addi $sp, $sp, -4
	sw $ra,  0($sp)
	
	lw $t0, player_address
	lb $t1, -1($t0)
	lb $t2, 1($t0)
			
	beq $a0, 'a', move_player_left
	beq $a0, 'd', move_player_right
	beq $a0, 'm', fire
			
	j move_player_exit
			
	move_player_left:
		beq $t1, '|', move_player_exit 

		lb $t3, player
		lb $t4, space
		sb $t3, -1($t0)
		sb $t4, 0($t0)
                
		addi $t0, $t0, -1
		sw $t0, player_address
				
		j move_player_exit
				
	move_player_right:
		beq $t2, '|', move_player_exit
                
                lb $t3, player
                lb $t4, space
                sb $t3, 1($t0)
                sb $t4, 0($t0)
                
                addi $t0, $t0, 1
                sw $t0, player_address
                
                j move_player_exit
				
	fire:
                lw $t2, laser_status
                bge $t2, 1, move_player_exit
                li $t2, 2
                sw $t2, laser_status
                lw $t0, player_address
                lb $t1, player_laser
                sb $t1, -43($t0)
                j move_player_exit
	
    move_player_exit:
        sw $ra,  0($sp)
        addi $sp, $sp, 4
        jr $ra
	
clear_scr:
	la $a0, cls
	li $v0, 4
	syscall
	jr $ra

sleep:
	li $v0, 32
	syscall
	jr $ra
