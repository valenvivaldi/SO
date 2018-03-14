	.file	"1ER EJERCICIO.c"
	.globl	g
	.data
	.align 4
	.type	g, @object
	.size	g, 4
g:
	.long	3
	.globl	z
	.align 4
	.type	z, @object
	.size	z, 4
z:
	.long	4
	.section	.rodata
	.align 8
.LC0:
	.string	"x= %p x+1 =%p x+2=%p x3=%p a=%d a1=%d a2=%d"
.LC1:
	.string	"retorno %d\n"
	.text
	.globl	f
	.type	f, @function
f:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movl	%esi, -28(%rbp)
	movq	-24(%rbp), %rax
	movl	4(%rax), %eax
	movl	%eax, -12(%rbp)
	movl	-28(%rbp), %eax
	movl	%eax, -8(%rbp)
	movl	c.2289(%rip), %eax
	leal	1(%rax), %edx
	movl	%edx, c.2289(%rip)
	movl	%eax, -4(%rbp)
	movq	-24(%rbp), %rax
	leaq	16(%rax), %r8
	movq	-24(%rbp), %rax
	leaq	8(%rax), %rcx
	movq	-24(%rbp), %rax
	leaq	4(%rax), %rsi
	movl	-12(%rbp), %edi
	movq	-24(%rbp), %rax
	movl	-4(%rbp), %edx
	pushq	%rdx
	movl	-8(%rbp), %edx
	pushq	%rdx
	movl	%edi, %r9d
	movq	%rsi, %rdx
	movq	%rax, %rsi
	movl	$.LC0, %edi
	movl	$0, %eax
	call	printf
	addq	$16, %rsp
	movl	-12(%rbp), %edx
	movl	-8(%rbp), %eax
	addl	%eax, %edx
	movl	-4(%rbp), %eax
	addl	%edx, %eax
	movl	%eax, %esi
	movl	$.LC1, %edi
	movl	$0, %eax
	call	printf
	movl	-12(%rbp), %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	f, .-f
	.section	.rodata
.LC2:
	.string	"dir de a =%p dir de a[0]=%p\n"
.LC3:
	.string	"\n\n &a=%p \n  a=%p\n\n\n"
.LC4:
	.string	"r=%d %p\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB1:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$56, %rsp
	.cfi_offset 3, -24
	movq	%fs:40, %rax
	movq	%rax, -24(%rbp)
	xorl	%eax, %eax
	movl	$1, -48(%rbp)
	movl	$2, -44(%rbp)
	movl	$3, -40(%rbp)
	movl	$4, -36(%rbp)
	movl	$5, -32(%rbp)
	leaq	-48(%rbp), %rdx
	leaq	-48(%rbp), %rax
	movq	%rax, %rsi
	movl	$.LC2, %edi
	movl	$0, %eax
	call	printf
	leaq	-48(%rbp), %rdx
	leaq	-48(%rbp), %rax
	movq	%rax, %rsi
	movl	$.LC3, %edi
	movl	$0, %eax
	call	printf
	movl	-48(%rbp), %edx
	leaq	-48(%rbp), %rax
	movl	%edx, %esi
	movq	%rax, %rdi
	call	f
	movl	%eax, %ebx
	movl	g(%rip), %eax
	cltq
	movl	-48(%rbp,%rax,4), %edx
	leaq	-48(%rbp), %rax
	movl	%edx, %esi
	movq	%rax, %rdi
	call	f
	addl	%ebx, %eax
	movl	%eax, -52(%rbp)
	movl	-52(%rbp), %eax
	leaq	-52(%rbp), %rdx
	movl	%eax, %esi
	movl	$.LC4, %edi
	movl	$0, %eax
	call	printf
	movl	-52(%rbp), %eax
	movq	-24(%rbp), %rcx
	xorq	%fs:40, %rcx
	je	.L5
	call	__stack_chk_fail
.L5:
	addq	$56, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	main, .-main
	.data
	.align 4
	.type	c.2289, @object
	.size	c.2289, 4
c.2289:
	.long	5
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.9) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
