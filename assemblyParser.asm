.data:
	endl: .asciiz "\n"

	instructionCountQuery: .asciiz "\nPodaj liczbe instrukcji (1-5): \n"
	badInstructionCountMessage: .asciiz "\nNieprawidlowa liczba instrukcji. \n"
	instructionQuery: .asciiz "\nPodaj instrukcje: \n"
	badInstructionMessage: .asciiz "\nNieprawidlowa instrukcja \n"
	memAlocatedMessage: .asciiz "\nPamiec zaalokowana na stosie: \n"
	lineBreak: .asciiz "--------------------------------------------"
	
	finishText: .asciiz "AppFinished"
	
	addInstr: .asciiz "ADD"
	addiInstr: .asciiz "ADDI"
	jInstr: .asciiz "J"
	noopInstr: .asciiz "NOOP"
	multInstr: .asciiz "MULT"
	jrInstr: .asciiz "JR"
	jalInstr: .asciiz "JAL"
	
	inputStr: .space 51
.text:
	#s0 - remaining instruction count
	#s1 - total instructions on stack
	#s2 - string count in current instruction
	#s3 - string table for current instruction
	#s4 - address of first instruction word
	#s5 - memory allocated on stack
	main:
		getInstructionCount:
			li $v0, 4
			la $a0, instructionCountQuery
			syscall
			
			li $v0, 5
			syscall
			
			blez $v0, wrongInstrCount
			bgt $v0, 5, wrongInstrCount
			j finishGetInstruction
			
			wrongInstrCount:
			li $v0, 4
			la $a0, badInstructionCountMessage
			syscall
			j getInstructionCount
			
			
			finishGetInstruction:
			move $s0, $v0
		
		getInstruction:
			li $v0, 4
			la $a0, instructionQuery
			syscall
		
			li $v0, 9
			li $a0, 51
			syscall
			move $t0, $v0
		
			li $v0, 8
			move $a0, $t0
			li $a1, 51
			syscall
			
			move $a0, $t0
			jal SplitString
			move $s2, $v0
			move $s3, $v1
			
			j processInstruction
		
	processInstruction:
		blez $s2, invalidInstruction
		lw $s4, ($s3)
		
		move $a0, $s4
		la $a1, addInstr
		jal textEqual
		beq $v0, 1, handleAdd
		
		move $a0, $s4
		la $a1, addiInstr
		jal textEqual
		beq $v0, 1, handleAddI
		
		move $a0, $s4
		la $a1, jInstr
		jal textEqual
		beq $v0, 1, handleJ
		
		move $a0, $s4
		la $a1, noopInstr
		jal textEqual
		beq $v0, 1, handleNOOP
		
		move $a0, $s4
		la $a1, multInstr
		jal textEqual
		beq $v0, 1, handleMult
		
		move $a0, $s4
		la $a1, jrInstr
		jal textEqual
		beq $v0, 1, handleJR
		
		move $a0, $s4
		la $a1, jalInstr
		jal textEqual
		beq $v0, 1, handleJAL
		
		j invalidInstruction
		
	invalidInstruction:
		li $v0, 4
		la $a0, badInstructionMessage
		syscall
		j getInstruction
		
	putInstructionOnStack:
		addi $t0, $s2, -1 #t0 - array index
		mul $t0, $t0, 4
		add $t0, $t0, $s3
		add $s5, $s5, $s2
		
		move $t2, $s2
		
		putInstructionLoop:
			blez $t2, putLB
			lw $t1, ($t0) #Address of null terminated string
			addi $sp, $sp, -4
			sw $t1, ($sp)
			addi $t2, $t2, -1
			addi $t0, $t0, -4
			j putInstructionLoop
			
		putLB:
			la $t0, lineBreak
			addi $sp, $sp, -4
			sw $t0, ($sp)
			add $s5, $s5, 1
			
			j getInstructionAgain
		
	getInstructionAgain:
		addi $s0, $s0, -1
		beqz $s0, finishProgram
		j getInstruction
		
	finishProgram:
		move $t0, $s5 #Remaining steps
		
		mul $t1, $t0, 4
		li $v0, 4
		la $a0, memAlocatedMessage
		syscall
		li $v0, 1
		move $a0, $t1
		syscall
		li $v0, 4
		la $a0, endl
		syscall
		syscall
		
		printStack:
			beqz $t0, exit
		
			lw $a0, ($sp)
			li $v0, 4
			syscall
			
			la $a0, endl
			li $v0, 4
			syscall
			
			addi $sp, $sp, 4
			addi $t0, $t0, -1
			j printStack
	
		exit:
		li $v0, 10
		syscall
		
		
		
	handleAdd:
		bne $s2, 4, invalidInstruction
		
		lw $a0, 4($s3)
		jal IsRegister
		beqz $v0, invalidInstruction
		
		lw $a0, 8($s3)
		jal IsRegister
		beqz $v0, invalidInstruction
		
		lw $a0, 12($s3)
		jal IsRegister
		beqz $v0, invalidInstruction
		
		j putInstructionOnStack
		
	
	handleAddI:
		bne $s2, 4, invalidInstruction
		
		lw $a0, 4($s3)
		jal IsRegister
		beqz $v0, invalidInstruction
		
		lw $a0, 8($s3)
		jal IsRegister
		beqz $v0, invalidInstruction
		
		lw $a0, 12($s3)
		jal IsImmediate
		beqz $v0, invalidInstruction
		
		j putInstructionOnStack
		
		
	handleJ:
		bne $s2, 2, invalidInstruction
		
		lw $a0, 4($s3)
		jal IsLabel
		beqz $v0, invalidInstruction
		
		j putInstructionOnStack
		
		
	handleNOOP:
		bne $s2, 1, invalidInstruction
		
		j putInstructionOnStack
		
	handleMult:
		bne $s2, 3, invalidInstruction
		
		lw $a0, 4($s3)
		jal IsRegister
		beqz $v0, invalidInstruction
		
		lw $a0, 8($s3)
		jal IsRegister
		beqz $v0, invalidInstruction
		
		j putInstructionOnStack
		
	handleJR:
		bne $s2, 2, invalidInstruction
		
		lw $a0, 4($s3)
		jal IsRegister
		beqz $v0, invalidInstruction
		
		j putInstructionOnStack
		
	handleJAL:
		bne $s2, 2, invalidInstruction
		
		lw $a0, 4($s3)
		jal IsLabel
		beqz $v0, invalidInstruction
		
		j putInstructionOnStack
		
		
		
		
		
		
		
	textEqual:
		#a0 - address of first null terminated text
		#a1 - address of second null terminated text
		#v0 - true or false
		
		checkCharacter:
		 	li $t0, 0
		 	li $t1, 0
			lb $t0, ($a0)
			lb $t1, ($a1)
			bne $t0, $t1, returnTextNotEqual
			beq $t0, 0, returnTextEqual
			addi $a0, $a0, 1
			addi $a1, $a1, 1
			j checkCharacter
			
		returnTextNotEqual:
			li $v0, 0
			jr $ra
			
		returnTextEqual:
			li $v0, 1
			jr $ra
		
		
	IsImmediate:
		#a0 - address of null terminated string
		#v0 - boolean is immediate
		addi $sp, $sp, -4
		sw $ra, ($sp)
		
		lb $t0, ($a0)
		
		checkMinusSign:
		bne $t0, 45, checkPlusSign
		addi $a0, $a0, 1
		
		checkPlusSign:
		bne $t0, 43, checkIsNumber
		addi $a0, $a0, 1
		
		checkIsNumber:
			lb $t0, ($a0)
			beqz $t0, ReturnIsImmediate
			
			blt $t0, 48, ReturnIsNotImmediate
			bgt $t0, 57, ReturnIsNotImmediate
			
			addi $a0, $a0, 1
			j checkIsNumber
			
		
		ReturnIsImmediate:
			lw $t0, ($sp)
			addi $sp, $sp, 4
			li $v0, 1
			jr $t0
			
		ReturnIsNotImmediate:
			lw $t0, ($sp)
			addi $sp, $sp, 4
			li $v0, 0
			jr $t0
		
	IsLabel:
		addi $sp, $sp, -4
		sw $ra, ($sp)
		#a0 - address of null terminated string
		#v0 - boolean is a label
		checkIsCharacter:
			lb $t0, ($a0)
			beqz $t0, ReturnIsLabel
			
			sge $t1, $t0, 65
			sle $t2, $t0, 90
			sge $t3, $t0, 97
			sle $t4, $t0, 122
			
			and $t1, $t1, $t2
			and $t3, $t3, $t4
			or $t1, $t1, $t3
			beqz $t1, ReturnIsNotLabel
			
			addi $a0, $a0, 1
			j checkIsCharacter
			
		ReturnIsLabel:
			lw $t0, ($sp)
			addi $sp, $sp, 4
			li $v0, 1
			jr $t0
			
		ReturnIsNotLabel:
			lw $t0, ($sp)
			addi $sp, $sp, 4
			li $v0, 0
			jr $t0
		
	IsRegister:
		#a0 - address of null terminated string
		#v0 - boolean is a register
		addi $sp, $sp, -4
		sw $ra, ($sp)
		
		lb $t0, 0($a0)
		lb $t1, 1($a0)
		lb $t2, 2($a0)
		lb $t3, 3($a0)
		bne $t0, 36, ReturnIsNotRegister
		
		beqz $t2, checkSingleDigitRegister
		beqz $t3, checkDoubleDigitRegister
		j ReturnIsNotRegister
		
		checkDoubleDigitRegister:
		blt $t1, 49, ReturnIsNotRegister
		bgt $t1, 51, ReturnIsNotRegister
		blt $t2, 48, ReturnIsNotRegister
		bgt $t2, 57, ReturnIsNotRegister
		
		bne $t1, 51, ReturnIsRegister # first digit is less than 3
		bgt $t2, 49, ReturnIsNotRegister # number is more than 32
		j ReturnIsRegister
		
		checkSingleDigitRegister:
		blt $t1, 48, ReturnIsNotRegister
		bgt $t1, 57, ReturnIsNotRegister
		j ReturnIsRegister
		
		ReturnIsRegister:
			lw $t0, ($sp)
			addi $sp, $sp, 4
			li $v0, 1
			jr $t0
			
		ReturnIsNotRegister:
			lw $t0, ($sp)
			addi $sp, $sp, 4
			li $v0, 0
			jr $t0
		
		
	SplitString:
		#turns single string into array of null terminated words
		#a0 - address of null terminated string
		#v0 - number of words
		#v1 - table of word pointers 
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		move $t0, $a0 #current character address
		li $t1, 0 #is last character part of word
		li $t2, 0 # number of words
		li $t3, 32 #pretend last character was whitespace
		
		move $t7, $a0 #original location of the string
		
		countWords:
			lb $t3, ($t0)
			beqz $t3, stackToArray
			
			seq $t4, $t3, 32 # $t4 - character is whitespace
			seq $t5, $t3, 10
			or $t4, $t4, $t5
			seq $t5, $t3, 44
			or $t4, $t4, $t5
			
			# if whitespace
			seq $t5, $t4, 0   # t5 - character is text
			and $t1, $t5, $t1 # set t1 to 0  
			mul $t3, $t3, $t5
			sb $t3, ($t0)
			add $t0, $t0, $t4 # increment string addres by 1 byte
			beq $t4, 1, countWords # then jump back to loop
			
			# Character is not whitespace
			seq $t5, $t1, 0       # t5 - last character was whitespace
		
			beqz $t5, skipStack
			add $t2, $t2, 1
			addi $sp, $sp, -4
			sw $t0, ($sp)
			
			skipStack:
			addi $t0, $t0, 1
			li $t1, 1
			j countWords
		
		# t0 - start of the array
		# t1 - current array pointer
		# t2 - remaining words
		stackToArray:
			li $v0, 9
			mul $a0, $t2, 4
			syscall #allocate array
				
			move $t0, $v0 
			move $v0, $t2 
			move $v1, $t0 # save to final result
			
			mul $t1, $t2, 4
			add $t1, $t1, $t0 # move pointer to the end of array
			addi $t1, $t1, -4
			
			stackToArrayLoop:
				beqz $t2, return
				
				lw $t4, ($sp)
				sw $t4, ($t1)
				addi $t1, $t1, -4
				addi $sp, $sp, 4
				
				addi $t2, $t2, -1
				j stackToArrayLoop
		
		return:
			lw $ra, 0($sp)
        	addi $sp, $sp, 4
        	jr $ra
		
	TestBooleanFunctions:
		li $v0, 8
		la $a0, inputStr
		li $a1, 10
		syscall
		
		la $a0, inputStr
		jal IsImmediate
		move $a0, $v0
		li $v0, 1
		syscall
		
		li $v0, 4
		la $a0, endl
		syscall
		
		j TestBooleanFunctions
		
	TestSplitString:
		li $v0, 8
		la $a0, inputStr
		li $a1, 51
		syscall
		
		la $a0, inputStr
		jal SplitString
		move $t0, $v0
		move $t1, $v1
		
		printStrings:
			beqz $t0, endTest
			
			li $v0, 4
			lw $a0, ($t1)
			syscall
			
			li $v0, 4
			la $a0, endl
			syscall
			
			addi $t1, $t1, 4
			addi $t0, $t0, -1
			j printStrings
			
		endTest:
		li $v0, 4
		la $a0, endl
		syscall
		
		j TestSplitString
