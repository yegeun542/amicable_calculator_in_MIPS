################################################################################
#  Program:
#	amicable.asm
#
#  Description:
#       First this program prompts the user for the upper bound and lower bouund
#       of the range. Then It computes pairs of amicable numbers that fall within
#       this range
#
#  Author:
#	Yegeun Yang
#
# $s0 = start
# $s1 = end
# $s2 = pairs  $s3 = i in the for loop
# $s4 = sum in the for loop
#
# - Tested with MARS MIPS simulator Ver 4.5
# - It would take around 10 sec for the range of [1, 10000] 
# - It would take 1~2 min for the range of [1, 100000]
################################################################################

################################################################################
#   Main program
################################################################################

	.data
getStart: .asciiz "Input the start of the range: "
getEnd: .asciiz "Input the end of the range: "
nonPositiveError: .asciiz "Unable to check non-positive values\n"
exiting: .asciiz "Exiting......\n"
swapping: .asciiz "End of range < start of range -- swapping values\n"
enter: .asciiz "\n"
range: .asciiz "Range of numbers: "
minus: .asciiz " - "
total: .asciiz "Pairs of amicable numbers = "
and: .asciiz " and "
amicable: .asciiz " are amicable numbers\n"
endLine: .asciiz "------------------------------\n"

# Main body
	.text
main:
	# print getStart
	li $v0, 4
	la $a0, getStart
	syscall

	# read an integer
	li $v0, 5
	syscall
	add $s0 $v0 $zero # $s0 = start

	# non-positive check
	add $a0 $s0 $zero
	jal exitIfNonPositive

	# print getEnd
	li $v0, 4
	la $a0, getEnd
	syscall

	# read an integer
	li $v0, 5
	syscall
	add $s1 $v0 $zero # $s1 = end

	# non-positive check
	add $a0 $s1 $zero
	jal exitIfNonPositive

	# swap values if start > end
	slt $t0, $s1, $s0
	beq $t0, $zero, nonSwap

# -------------------------------------------------------
# swap: swapping values if end of range < start of range
# -------------------------------------------------------

	# print swapping
	li $v0, 4
	la $a0, swapping
	syscall
	add $t0, $s0, $zero
	add $s0, $s1, $zero
	add $s1, $t0, $zero

# ----------------------------------------------------------
# nonSwap: no swapping if the start of range > end of range
# ----------------------------------------------------------
nonSwap:
	add $s3, $s0, $zero # i = start
# -------------------------------------------------------
# finding_loop: Compute amicable pairs in a loop
# -------------------------------------------------------
# -------------------------------------------------------
# C code
#
# int pairs = 0;
# for(int i=start; i<=end; i++)
# {
#      int sum = computeProperDivSum(i);
#      if(sum>i && sum<=end && isAmicable(i, sum))
#      {
#          printf("%d and %d are amicable numbers\n", i, sum);
#          pairs++;
#      }
# }
# -------------------------------------------------------
finding_loop:
	bgt $s3, $s1, finding_loop_exit # i<=end

	add $a0, $s3, $zero #
	jal computeProperDivSum # sum = setProperDivSum(i)
	add $s4, $v0, $zero #

	ble $s4, $s3, finding_failure # if sum > i
	bgt $s4, $s1, finding_failure # if sum <= end
	add $a0, $s3, $zero # i
	add $a1, $s4, $zero # sum
	jal isAmicable
	beq $v0, $zero, finding_failure # if isAmicable(i, sum)

	# print i
	li $v0, 1
	add $a0, $s3, $zero
	syscall

	# print and
	li $v0, 4
	la $a0, and
	syscall

	# print sum
	li $v0, 1
	add $a0, $s4, $zero
	syscall

	# print amicable
	li $v0, 4
	la $a0, amicable
	syscall

	addi $s2, $s2, 1 # pairs++

# -----------------------------------------------------------------------------
# finding_failure: Increment the loop count to compute next amicable pairs
# -----------------------------------------------------------------------------
finding_failure:
	addi $s3, $s3, 1 # i++
	j finding_loop

# -----------------------------------------------------------------------
# finding_loop_exit: Print out statement if all amicable pairs are found
# -----------------------------------------------------------------------
finding_loop_exit:
	# print enter
	li $v0, 4
	la $a0, enter
	syscall

	# print range
	li $v0, 4
	la $a0, range
	syscall

	# print start
	add $a0, $s0, $zero
	li $v0, 1
	syscall

	# print minus
	li $v0, 4
	la $a0, minus
	syscall

	# print end
	add $a0, $s1, $zero
	li $v0, 1
	syscall

	# print enter
	li $v0, 4
	la $a0, enter
	syscall

	# print total
	li $v0, 4
	la $a0, total
	syscall

	# print pairs
	add $a0, $s2, $zero
	li $v0, 1
	syscall

	# print enter
	li $v0, 4
	la $a0, enter
	syscall

	# print endLine
	li $v0, 4
	la $a0, endLine
	syscall

	# exit -- main
	li $v0, 10
	syscall

# -------------------------------------------------------------
# exitIfNonPositive: Check if the given number is non-positive number
# -------------------------------------------------------------
exitIfNonPositive:
	slti $t0, $a0, 1
	bne $t0, $zero, exitIfNonPositive_true
	jr $ra

# ------------------------------------------------------------------------------
# exitIfNonPositive_true:Print out error statement and exit if the given number is non-positive
# -------------------------------------------------------------------------------
exitIfNonPositive_true:
	# print nonPositiveError
	li $v0, 4
	la $a0, nonPositiveError
	syscall

	# print exiting
	li $v0, 4
	la $a0, exiting
	syscall

	# exit -- exitIfNonPositive
	li $v0, 10
	syscall

# ---------------------------------------------------------------
# computeProperDivSum: Compute sum of proper divisors of given number
# ---------------------------------------------------------------
# ---------------------------------------------------------------
#C code
#
#int computeProperDivSum(int num)
#{
#    int n=num;
#    int r=1;
#
#    // even factors
#    if(n%2==0)
#    {
#        int p = leastPower(2, n);
#        r *= p-1;
#        n /= p/2;
#    }
#
#    // odd factors. we can save some time
#    // if we use prime number memoization here
#    for(int i=3; i*i<=n; i+=2)
#    {
#        int p = leastPower(i, n);
#        r *= (p-1)/(i-1);
#        n /= p/i;
#    }
#
#    // n is 1 or prime number
#    if(1<n)
#        r *= 1+n;
#
#    return r-num;
#}
# ---------------------------------------------------------------
computeProperDivSum: # $t0 -> n $t1 -> r
	addi $sp, $sp, -4
	sw $ra, 0($sp) # return -> stack
	addi $sp, $sp, -4
	sw $a0, 0($sp) # num -> stack
	add $t0, $a0, $zero # n = num
	addi $t1, $zero, 1 # r = 1
	addi $t2, $zero, 2 # $t2 = 2
	rem $t3, $t0, $t2 # $t3 = n % 2
	bne $t3, $zero, even_false
	add $a0, $t2, $zero
	add $a1, $t0, $zero
	jal leastPower
	add $t2, $v0, $zero # $t2 -> p
	addi $t3, $t2, -1 # $t3 -> p-1
	mul $t1, $t1, $t3 # r *= (p-1)
	addi $t3, $zero, 2 # $t3 = 2
	div $t3, $t2, $t3 # $t3 = p / 2
	div $t0, $t0, $t3 # n /= p/2

# ---------------------------------------------------------------
# even_false: if a given number does not have even factors
# ---------------------------------------------------------------
even_false:
	addi $t2, $zero, 3 # i = 3;

# ---------------------------------------------------------------
# odd_loop: Compute for odd factors
# ---------------------------------------------------------------
odd_loop: # $t2 -> i
	mul $t3, $t2, $t2 # $t3 = i * i
	bgt $t3, $t0, odd_loop_exit # i*i <= n

	add $a0, $t2, $zero
	add $a1, $t0, $zero
	jal leastPower
	add $t3, $v0, $zero # $t3 = p
	addi $t4, $t3, -1 # $t4 = p-1
	addi $t5, $t2, -1 # $t5 = i-1
	div $t6, $t4, $t5 # $t6 = (p-1) / (i-1)
	mul $t1, $t1, $t6 # r = r * (p-1)/(i-1)
	div $t3, $t3, $t2 # $t3 = p/i
	div $t0, $t0, $t3

	addi $t2, $t2, 2 # i+=2
	j odd_loop

odd_loop_exit:

	slti $t2, $t0, 2
	bne $t2, $zero, prime_false
	addi $t2, $t0, 1 # $t2 = n+1
	mul $t1, $t1, $t2 # r *= 1+n

# ---------------------------------------------------------------
# prime_false: if final n is 1 ( if(1<n) in C code )
# ---------------------------------------------------------------
prime_false:
	lw $t2, 0($sp) # num <- stack
	addi $sp, $sp, 4
	sub $v0, $t1, $t2 # return r - num
	lw $ra, 0($sp) # return <- stack
	addi $sp, $sp, 4
	jr $ra

# ---------------------------------------------------
# leastPower: Find the least power of a that does not divide x
# ---------------------------------------------------
# ---------------------------------------------------
#C code
#
#int leastPower(int a, int x)
#{
#    int b=a;
#    while(isFactor(b, x))
#        b*=a;
#    return b;
#}
# ---------------------------------------------------
leastPower: # $t3 up
	addi $sp, $sp, -4
	sw $ra, 0($sp) # return -> stack

	add $t3, $a0, $zero # $t3 <- b
	add $t4, $a0, $zero # $t4 <- a

leastPower_loop:
	add $a0, $t3, $zero # isFactor $a0 <- b
	jal isFactor
	beq $v0, $zero, leastPower_exit
	mul $t3, $t3, $t4 # b *= a
	j leastPower_loop

leastPower_exit:
	lw $ra, 0($sp) # return <- stack
	addi $sp, $sp, 4
	add $v0, $t3, $zero # return b
	jr $ra

# -----------------------------------------------------
# isFactor: Check if divisor is the factor of dividend
# -----------------------------------------------------
# -----------------------------------------------------
#C code
#
#int isFactor(int divisor, int dividend)
#{
#    return dividend % divisor == 0;
#}
# -----------------------------------------------------
isFactor: # $t5 up
	rem $t5, $a1, $a0 # return dividend % divisor
	beq $t5, $zero, isFactor_true
	add $v0, $zero, $zero
	jr $ra # if rem == 0, return 1

isFactor_true:
	addi $v0, $zero, 1
	jr $ra # if rem != 0, return 0

# ------------------------------------------------------------
# isAmicable: Check if sum of proper divisors of given sum is equal to given num
# ------------------------------------------------------------
# ------------------------------------------------------------
#C code
#
#int isAmicable(int num, int sum)
#{
#    int secondSum = computeProperDivSum(sum);
#    return secondSum==num;
#}
# ------------------------------------------------------------
isAmicable:
	addi $sp, $sp, -4
	sw $ra, 0($sp) # return -> stack
	addi $sp, $sp, -4
	sw $a0, 0($sp) # num -> stack

	add $a0, $a1, $zero
	jal computeProperDivSum
	add $t0, $v0, $zero
	lw $t1, 0($sp) # num <- stack
	addi $sp, $sp, 4
	bne $t0, $t1, amicable_false
	addi $v0, $zero, 1
	j amicable_exit

amicable_false:
	add $v0, $zero, $zero

amicable_exit:
	lw $ra, 0($sp) # return <- stack
	addi $sp, $sp, 4
	jr $ra
