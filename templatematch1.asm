# Chen
# Zhenghua
# 260783959
.data
displayBuffer:  .space 0x40000 # space for 512x256 bitmap display 
space:  .space 0x40
# Question1: Before adding space, the base addresses of image and error buffers fall into the same block of the 
#            direct mapped cache because in direct mapping, the index of the block depends on the modulo of the address,
#            and the base addresses have the same modulo.
#Question2: It doesn't matter if the template buffer base address falls into the same block as the image or template
#           buffer base address in the direct mapped cache because in templateMatchFast, we don't need to loop the
#           template image inside the x,y loop.
errorBuffer:    .space 0x40000 # space to store match function
templateBuffer: .space 0x100   # space for 8x8 template
imageFileName:    .asciiz "pxlcon512x256cropgs.raw" 
templateFileName: .asciiz "template8x8gs.raw"
# struct bufferInfo { int *buffer, int width, int height, char* filename }
imageBufferInfo:    .word displayBuffer  512 128  imageFileName
errorBufferInfo:    .word errorBuffer    512 128  0
templateBufferInfo: .word templateBuffer 8   8    templateFileName

.text
main:	la $a0, imageBufferInfo
	jal loadImage
	la $a0, templateBufferInfo
	jal loadImage
	la $a0, imageBufferInfo
	la $a1, templateBufferInfo
	la $a2, errorBufferInfo
	jal matchTemplateFast        # MATCHING DONE HERE
	la $a0, errorBufferInfo
	jal findBest
	la $a0, imageBufferInfo
	move $a1, $v0
	jal highlight
	la $a0, errorBufferInfo	
	jal processError
	li $v0, 10		# exit
	syscall
	

##########################################################
# matchTemplate( bufferInfo imageBufferInfo, bufferInfo templateBufferInfo, bufferInfo errorBufferInfo )
# NOTE: struct bufferInfo { int *buffer, int width, int height, char* filename }
matchTemplate:	
	# TODO: write this function!
	addi $sp $sp -32
	sw $s0 0($sp)
	sw $s1 4($sp)
	sw $s2 8($sp)
	sw $s3 12($sp)
	sw $s4 16($sp)
	sw $s5 20($sp)
	sw $s6 24($sp)
	sw $s7 28($sp)
	lw $s0 4($a0) #imageWidth
	lw $s1 8($a0) #imageHeight
	lw $s2 ($a0) #imageBuffer
	lw $s3 ($a1) #templateBuffer
	lw $s4 ($a2) #errorBuffer
	addi $s5 $s0 -8 #imageWidth-8
	addi $s6 $s1 -8 #imageHeight-8
	add $s7 $0 $0 #store error
	add $t0 $0 $0 #y=0
	add $t1 $0 $0 #x=0
	add $t2 $0 $0 #j=0
	add $t3 $0 $0 #i=0
loop:   add $t4 $t1 $t3 #x+i
            add $t5 $t0 $t2 #y+j
            sll $t4 $t4 2 #4*(x+i)
            sll $t6 $s0 2 #4*width
            mul $t5 $t5 $t6 #(y+j)*4*width
            add $t4 $t4 $t5 #byte offset of image
            add $t4 $s2 $t4
            lbu $t4 ($t4) #load one byte of I[x+i][y+j]
            mul $t5 $t2 32 #32*j
            sll $t6 $t3 2 #4*i
            add $t5 $t6 $t5 #byte offset of template
            add $t5 $s3 $t5
            lbu $t5 ($t5) #load one byte of T[i][j]
            sub $t6 $t4 $t5
            abs $t6 $t6  #t6=abs(I[x+i][y+j]-T[i][j])
            add $s7 $s7 $t6 #accumulated error
            sll $t7 $t1 2 #4*x
            sll $t8 $s0 2 #4*width
            mul $t8 $t8 $t0 #4*y*width
            add $t8 $t7 $t8 #byte offset of errorBuffer
            add $t8 $s4 $t8
            sw $s7 ($t8) #save byte to errorBuffer[x,y]
            
            addi $t3 $t3 1 #i++
            slti $t6 $t3 8 #i loop
            bne $t6 $0 loop
            addi $t2 $t2 1#j++
            slti $t6 $t2 8#j loop
            add $t3 $0 $0#i=0
            bne $t6 $0 loop
            addi $t1 $t1 1 #x++
            slt $t6 $s5 $t1#x loop
            add $s7 $0 $0
            add $t3 $0 $0#i=0
            add $t2 $0 $0#j=0
            beq $t6 $0 loop
            addi $t0 $t0 1 #y++
            slt $t6 $s6 $t0#y loop
            add $s7 $0 $0
            add $t3 $0 $0#i=0
            add $t2 $0 $0#j=0
            add $t1 $0 $0#x=0
            beq $t6 $0 loop
            
            
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	lw $s3 12($sp)
	lw $s4 16($sp)
	lw $s5 20($sp)
	lw $s6 24($sp)
	lw $s7 28($sp)
	addi $sp $sp 32
            	
	#TODO end
	jr $ra	
##########################################################
# matchTemplateFast( bufferInfo imageBufferInfo, bufferInfo templateBufferInfo, bufferInfo errorBufferInfo )
# NOTE: struct bufferInfo { int *buffer, int width, int height, char* filename }
matchTemplateFast:	
	
	# TODO: write this function!
	addi $sp $sp -48
	sw $s0 0($sp)
	sw $s1 4($sp)
	sw $s2 8($sp)
	sw $s3 12($sp)
	sw $s4 16($sp)
	sw $s5 20($sp)
	sw $s6 24($sp)
	sw $s7 28($sp)
	sw $a0 32($sp)
	sw $a1 36($sp)
	sw $a2 40($sp)
	sw $a3 44($sp)
	
	lw $s0 4($a0) #imageWidth
	lw $s1 8($a0) #imageHeight
	lw $s2 ($a0) #imageBuffer
	lw $s3 ($a1) #templateBuffer
	lw $s4 ($a2) #errorBuffer
	addi $s5 $s0 -8 #imageWidth-8
	addi $s6 $s1 -8 #imageHeight-8
	add $s7 $0 $0 #store error
	add $a0 $0 $0 #y=0
	add $a1 $0 $0 #x=0
	add $a2 $0 $0 #j=0
	
for1:       mul $t8 $a2 32 #32j
            add $t8 $s3 $t8 
            #T[0][j]
            lbu $t0 ($t8)
            #T[1][j]
            lbu $t1 4($t8)
            #T[2][j]
            lbu $t2 8($t8)
            #T[3][j]
            lbu $t3 12($t8)
            #T[4][j]
            lbu $t4 16($t8)
            #T[5][j]
            lbu $t5 20($t8)
            #T[6][j]
            lbu $t6 24($t8)
            #T[7][j]
            lbu $t7 28($t8)
            
for2:       add $t8 $a0 $a2 #y+j
            mul $t8 $t8 $s0 #width*(y+j)
            sll $t8 $t8 2 #4*width*(y+j)
            sll $t9 $a1 2 #4x
            add $t8 $t8 $t9 #4x+4*width*(y+j)
            add $t8 $s2 $t8 #I[x][y+j]
            lbu $t9 ($t8)
            sub $t9 $t9 $t0
            abs $t9 $t9
            add $s7 $s7 $t9
            #I[x+1][y+j]
            lbu $t9 4($t8)
            sub $t9 $t9 $t1
            abs $t9 $t9
            add $s7 $s7 $t9
            #I[x+2][y+j]
            lbu $t9 8($t8)
            sub $t9 $t9 $t2
            abs $t9 $t9
            add $s7 $s7 $t9
            #I[x+3][y+j]
            lbu $t9 12($t8)
            sub $t9 $t9 $t3
            abs $t9 $t9
            add $s7 $s7 $t9
            #I[x+4][y+j]
            lbu $t9 16($t8)
            sub $t9 $t9 $t4
            abs $t9 $t9
            add $s7 $s7 $t9
            #I[x+5][y+j]
            lbu $t9 20($t8)
            sub $t9 $t9 $t5
            abs $t9 $t9
            add $s7 $s7 $t9
            #I[x+6][y+j]
            lbu $t9 24($t8)
            sub $t9 $t9 $t6
            abs $t9 $t9
            add $s7 $s7 $t9
            #I[x+7][y+j]
            lbu $t9 28($t8)
            sub $t9 $t9 $t7
            abs $t9 $t9
            add $s7 $s7 $t9
            sll $t8 $a1 2 #4x
            mul $t9 $s0 $a0
            sll $t9 $t9 2 #4*width*y
            add $t9 $t8 $t9
            add $t9 $s4 $t9 #SAD[x][y]
            lw $a3 ($t9)
            add $s7 $a3 $s7
            sw $s7 ($t9)
            
            addi $a1 $a1 1 #x++
            slt $t9 $s5 $a1 #width-8 < x
            add $s7 $0 $0
            beq $t9 $0 for2
            addi $a0 $a0 1 #y++
            slt $t9 $s6 $a0 #height-8 < y
            add $a1 $0 $0
            add $s7 $0 $0
            beq $t9 $0 for2
            addi $a2 $a2 1 #j++
            slti $t9 $a2 8 #j < 8
            add $a0 $0 $0
            add $a1 $0 $0
            bne $t9 $0 for1
                      

	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	lw $s3 12($sp)
	lw $s4 16($sp)
	lw $s5 20($sp)
	lw $s6 24($sp)
	lw $s7 28($sp)
	lw $a0 32($sp)
	lw $a1 36($sp)
	lw $a2 40($sp)
	lw $a3 44($sp)
	addi $sp $sp 48
            #TODO:end
	jr $ra	
	
	
	
###############################################################
# loadImage( bufferInfo* imageBufferInfo )
# NOTE: struct bufferInfo { int *buffer, int width, int height, char* filename }
loadImage:	lw $a3, 0($a0)  # int* buffer
		lw $a1, 4($a0)  # int width
		lw $a2, 8($a0)  # int height
		lw $a0, 12($a0) # char* filename
		mul $t0, $a1, $a2 # words to read (width x height) in a2
		sll $t0, $t0, 2	  # multiply by 4 to get bytes to read
		li $a1, 0     # flags (0: read, 1: write)
		li $a2, 0     # mode (unused)
		li $v0, 13    # open file, $a0 is null-terminated string of file name
		syscall
		move $a0, $v0     # file descriptor (negative if error) as argument for read
  		move $a1, $a3     # address of buffer to which to write
		move $a2, $t0	  # number of bytes to read
		li  $v0, 14       # system call for read from file
		syscall           # read from file
        		# $v0 contains number of characters read (0 if end-of-file, negative if error).
        		# We'll assume that we do not need to be checking for errors!
		# Note, the bitmap display doesn't update properly on load, 
		# so let's go touch each memory address to refresh it!
		move $t0, $a3	   # start address
		add $t1, $a3, $a2  # end address
loadloop:	lw $t2, ($t0)
		sw $t2, ($t0)
		addi $t0, $t0, 4
		bne $t0, $t1, loadloop
		jr $ra
		
		
#####################################################
# (offset, score) = findBest( bufferInfo errorBuffer )
# Returns the address offset and score of the best match in the error Buffer
findBest:	lw $t0, 0($a0)     # load error buffer start address	
		lw $t2, 4($a0)	   # load width
		lw $t3, 8($a0)	   # load height
		addi $t3, $t3, -7  # height less 8 template lines minus one
		mul $t1, $t2, $t3
		sll $t1, $t1, 2    # error buffer size in bytes	
		add $t1, $t0, $t1  # error buffer end address
		li $v0, 0		# address of best match	
		li $v1, 0xffffffff 	# score of best match	
		lw $a1, 4($a0)    # load width
        		addi $a1, $a1, -7 # initialize column count to 7 less than width to account for template
fbLoop:		lw $t9, 0($t0)        # score
		sltu $t8, $t9, $v1    # better than best so far?
		beq $t8, $zero, notBest
		move $v0, $t0
		move $v1, $t9
notBest:		addi $a1, $a1, -1
		bne $a1, $0, fbNotEOL # Need to skip 8 pixels at the end of each line
		lw $a1, 4($a0)        # load width
        		addi $a1, $a1, -7     # column count for next line is 7 less than width
        		addi $t0, $t0, 28     # skip pointer to end of line (7 pixels x 4 bytes)
fbNotEOL:	add $t0, $t0, 4
		bne $t0, $t1, fbLoop
		lw $t0, 0($a0)     # load error buffer start address	
		sub $v0, $v0, $t0  # return the offset rather than the address
		jr $ra
		

#####################################################
# highlight( bufferInfo imageBuffer, int offset )
# Applies green mask on all pixels in an 8x8 region
# starting at the provided addr.
highlight:	lw $t0, 0($a0)     # load image buffer start address
		add $a1, $a1, $t0  # add start address to offset
		lw $t0, 4($a0) 	# width
		sll $t0, $t0, 2	
		li $a2, 0xff00 	# highlight green
		li $t9, 8	# loop over rows
highlightLoop:	lw $t3, 0($a1)		# inner loop completely unrolled	
		and $t3, $t3, $a2
		sw $t3, 0($a1)
		lw $t3, 4($a1)
		and $t3, $t3, $a2
		sw $t3, 4($a1)
		lw $t3, 8($a1)
		and $t3, $t3, $a2
		sw $t3, 8($a1)
		lw $t3, 12($a1)
		and $t3, $t3, $a2
		sw $t3, 12($a1)
		lw $t3, 16($a1)
		and $t3, $t3, $a2
		sw $t3, 16($a1)
		lw $t3, 20($a1)
		and $t3, $t3, $a2
		sw $t3, 20($a1)
		lw $t3, 24($a1)
		and $t3, $t3, $a2
		sw $t3, 24($a1)
		lw $t3, 28($a1)
		and $t3, $t3, $a2
		sw $t3, 28($a1)
		add $a1, $a1, $t0	# increment address to next row	
		add $t9, $t9, -1		# decrement row count
		bne $t9, $zero, highlightLoop
		jr $ra

######################################################
# processError( bufferInfo error )
# Remaps scores in the entire error buffer. The best score, zero, 
# will be bright green (0xff), and errors bigger than 0x4000 will
# be black.  This is done by shifting the error by 5 bits, clamping
# anything bigger than 0xff and then subtracting this from 0xff.
processError:	lw $t0, 0($a0)     # load error buffer start address
		lw $t2, 4($a0)	   # load width
		lw $t3, 8($a0)	   # load height
		addi $t3, $t3, -7  # height less 8 template lines minus one
		mul $t1, $t2, $t3
		sll $t1, $t1, 2    # error buffer size in bytes	
		add $t1, $t0, $t1  # error buffer end address
		lw $a1, 4($a0)     # load width as column counter
        		addi $a1, $a1, -7  # initialize column count to 7 less than width to account for template
pebLoop:		lw $v0, 0($t0)        # score
		srl $v0, $v0, 5       # reduce magnitude 
		slti $t2, $v0, 0x100  # clamp?
		bne  $t2, $zero, skipClamp
		li $v0, 0xff          # clamp!
skipClamp:	li $t2, 0xff	      # invert to make a score
		sub $v0, $t2, $v0
		sll $v0, $v0, 8       # shift it up into the green
		sw $v0, 0($t0)
		addi $a1, $a1, -1        # decrement column counter	
		bne $a1, $0, pebNotEOL   # Need to skip 8 pixels at the end of each line
		lw $a1, 4($a0)        # load width to reset column counter
        		addi $a1, $a1, -7     # column count for next line is 7 less than width
        		addi $t0, $t0, 28     # skip pointer to end of line (7 pixels x 4 bytes)
pebNotEOL:	add $t0, $t0, 4
		bne $t0, $t1, pebLoop
		jr $ra
