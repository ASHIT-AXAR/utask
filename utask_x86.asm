	.file	"utask.c"
	.text
.globl utask_init
	.type	utask_init, @function
utask_init:
	pushl	%ebp
	xorl	%eax, %eax
	movl	%esp, %ebp
.L2:
	imull	$40, %eax, %edx
	incl	%eax
	cmpl	$10, %eax
	movl	$0, tasks(%edx)
	jne	.L2
	popl	%ebp
	ret
	.size	utask_init, .-utask_init
.globl utask_sleep
	.type	utask_sleep, @function
utask_sleep:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	movl	12(%ebp), %edx
	movl	$0, 8(%eax)
	movl	%edx, 16(%eax)
	movl	$3, (%eax)
	popl	%ebp
	ret
	.size	utask_sleep, .-utask_sleep
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	""
	.text
.globl utask_add
	.type	utask_add, @function
utask_add:
	movl	utask_free_slots, %ecx
	xorl	%eax, %eax
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%edi
	pushl	%esi
	testl	%ecx, %ecx
	pushl	%ebx
	movl	utask_free_tid, %ebx
	je	.L6
	imull	$40, %ebx, %edx
	movl	8(%ebp), %edi
	incl	%ebx
	incl	utask_last_used
	decl	%ecx
	movl	%ebx, utask_free_tid
	leal	tasks(%edx), %eax
	movl	$2, tasks(%edx)
	movl	%edi, tasks+20(%edx)
	movl	$0, tasks+4(%edx)
	movl	$0, tasks+28(%edx)
	movl	$.LC0, tasks+36(%edx)
	movl	utask_last_tid, %edx
	movl	$0, 16(%eax)
	movl	%ecx, utask_free_slots
	movl	%edx, 32(%eax)
	incl	%edx
	movl	%edx, utask_last_tid
.L6:
	popl	%ebx
	popl	%esi
	popl	%edi
	popl	%ebp
	ret
	.size	utask_add, .-utask_add
.globl utask_add_name
	.type	utask_add_name, @function
utask_add_name:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	8(%ebp)
	call	utask_add
	popl	%edx
	testl	%eax, %eax
	je	.L9
	movl	12(%ebp), %edx
	movl	%edx, 36(%eax)
.L9:
	leave
	ret
	.size	utask_add_name, .-utask_add_name
.globl utask_check_sleep
	.type	utask_check_sleep, @function
utask_check_sleep:
	pushl	%ebp
	orl	$-1, %eax
	movl	%esp, %ebp
	xorl	%ecx, %ecx
	pushl	%esi
	movl	$tasks, %edx
	pushl	%ebx
	movl	utask_last_used, %ebx
.L13:
	movl	(%edx), %esi
	cmpl	$2, %esi
	je	.L14
	movl	(%edx), %esi
	cmpl	$2, %esi
	jbe	.L12
	movl	16(%edx), %esi
	cmpl	%eax, %esi
	jae	.L12
	movl	16(%edx), %eax
.L12:
	incl	%ecx
	addl	$40, %edx
	cmpl	%ebx, %ecx
	jbe	.L13
	jmp	.L11
.L14:
	xorl	%eax, %eax
.L11:
	popl	%ebx
	popl	%esi
	popl	%ebp
	ret
	.size	utask_check_sleep, .-utask_check_sleep
.globl utask_schedule
	.type	utask_schedule, @function
utask_schedule:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%edi
	xorl	%edi, %edi
	pushl	%esi
	xorl	%esi, %esi
	pushl	%ebx
	movl	$tasks, %ebx
	subl	$12, %esp
	jmp	.L17
.L24:
	movl	(%ebx), %eax
	cmpl	$5, %eax
	ja	.L18
	jmp	*.L23(,%eax,4)
	.section	.rodata
	.align 4
	.align 4
.L23:
	.long	.L19
	.long	.L19
	.long	.L20
	.long	.L19
	.long	.L21
	.long	.L22
	.text
.L20:
	subl	$12, %esp
	pushl	%ebx
	call	*20(%ebx)
	addl	$16, %esp
	jmp	.L18
.L21:
	movl	8(%ebx), %eax
	movl	(%eax), %edx
	movl	12(%ebx), %eax
	cmpl	%eax, %edx
	sete	%al
	jmp	.L26
.L22:
	movl	8(%ebx), %eax
	movl	(%eax), %edx
	movl	12(%ebx), %eax
	cmpl	%eax, %edx
	setne	%al
.L26:
	movzbl	%al, %eax
	movl	%eax, %edi
.L18:
	testl	%edi, %edi
	je	.L19
	subl	$12, %esp
	pushl	%ebx
	movl	$2, (%ebx)
	call	*20(%ebx)
	addl	$16, %esp
.L19:
	incl	%esi
	addl	$40, %ebx
.L17:
	cmpl	utask_last_used, %esi
	jbe	.L24
	cmpl	$0, utask_put_mcu_to_sleep
	je	.L16
	call	utask_check_sleep
	subl	$12, %esp
	pushl	%eax
	call	*utask_put_mcu_to_sleep
	addl	$16, %esp
.L16:
	leal	-12(%ebp), %esp
	popl	%ebx
	popl	%esi
	popl	%edi
	popl	%ebp
	ret
	.size	utask_schedule, .-utask_schedule
.globl utask_sleep_process
	.type	utask_sleep_process, @function
utask_sleep_process:
	pushl	%ebp
	xorl	%eax, %eax
	movl	%esp, %ebp
	pushl	%esi
	pushl	%ebx
	movl	utask_last_used, %ebx
	jmp	.L28
.L31:
	imull	$40, %eax, %edx
	movl	tasks(%edx), %esi
	leal	tasks(%edx), %ecx
	cmpl	$2, %esi
	jbe	.L29
	movl	tasks+16(%edx), %esi
	testl	%esi, %esi
	je	.L30
	movl	tasks+16(%edx), %edx
	decl	%edx
	movl	%edx, 16(%ecx)
	jmp	.L29
.L30:
	movl	$2, tasks(%edx)
.L29:
	incl	%eax
.L28:
	cmpl	%ebx, %eax
	jbe	.L31
	popl	%ebx
	popl	%esi
	popl	%ebp
	ret
	.size	utask_sleep_process, .-utask_sleep_process
.globl utask_exit
	.type	utask_exit, @function
utask_exit:
	pushl	%ebp
	movl	$10, %edx
	movl	%esp, %ebp
	xorl	%ecx, %ecx
	movl	8(%ebp), %eax
	incl	utask_free_slots
	pushl	%ebx
	movl	$10, utask_free_tid
	movl	$0, (%eax)
	xorl	%eax, %eax
.L35:
	imull	$40, %eax, %ebx
	movl	tasks(%ebx), %ebx
	testl	%ebx, %ebx
	jne	.L33
	cmpl	%eax, %edx
	cmova	%eax, %edx
	jmp	.L34
.L33:
	movl	%eax, %ecx
.L34:
	incl	%eax
	cmpl	$10, %eax
	jne	.L35
	popl	%ebx
	movl	%edx, utask_free_tid
	movl	%ecx, utask_last_used
	popl	%ebp
	ret
	.size	utask_exit, .-utask_exit
.globl utask_wait_eq
	.type	utask_wait_eq, @function
utask_wait_eq:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	movl	12(%ebp), %edx
	movl	%edx, 8(%eax)
	movl	20(%ebp), %edx
	movl	%edx, 16(%eax)
	movl	16(%ebp), %edx
	movl	$4, (%eax)
	movl	%edx, 12(%eax)
	popl	%ebp
	ret
	.size	utask_wait_eq, .-utask_wait_eq
.globl utask_wait_neq
	.type	utask_wait_neq, @function
utask_wait_neq:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	movl	12(%ebp), %edx
	movl	%edx, 8(%eax)
	movl	20(%ebp), %edx
	movl	%edx, 16(%eax)
	movl	16(%ebp), %edx
	movl	$5, (%eax)
	movl	%edx, 12(%eax)
	popl	%ebp
	ret
	.size	utask_wait_neq, .-utask_wait_neq
.globl utask_suspend
	.type	utask_suspend, @function
utask_suspend:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	movl	$1, (%eax)
	popl	%ebp
	ret
	.size	utask_suspend, .-utask_suspend
.globl utask_resume
	.type	utask_resume, @function
utask_resume:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	movl	$2, (%eax)
	movl	$0, 16(%eax)
	popl	%ebp
	ret
	.size	utask_resume, .-utask_resume
.globl utask_get_free_slots
	.type	utask_get_free_slots, @function
utask_get_free_slots:
	pushl	%ebp
	movl	utask_free_slots, %eax
	movl	%esp, %ebp
	popl	%ebp
	ret
	.size	utask_get_free_slots, .-utask_get_free_slots
.globl utask_get_task_cnt
	.type	utask_get_task_cnt, @function
utask_get_task_cnt:
	pushl	%ebp
	movl	utask_last_used, %ecx
	xorl	%eax, %eax
	movl	%esp, %ebp
	xorl	%edx, %edx
	pushl	%edi
	movl	8(%ebp), %edi
	pushl	%esi
	pushl	%ebx
	jmp	.L43
.L45:
	imull	$40, %edx, %esi
	xorl	%ebx, %ebx
	cmpl	%edi, tasks+20(%esi)
	sete	%bl
	incl	%edx
	movl	%ebx, %esi
	addl	%esi, %eax
.L43:
	cmpl	%ecx, %edx
	jne	.L45
	popl	%ebx
	popl	%esi
	popl	%edi
	popl	%ebp
	ret
	.size	utask_get_task_cnt, .-utask_get_task_cnt
.globl utask_get_by_tid
	.type	utask_get_by_tid, @function
utask_get_by_tid:
	pushl	%ebp
	movl	utask_last_used, %ecx
	xorl	%edx, %edx
	movl	%esp, %ebp
	pushl	%ebx
	movl	8(%ebp), %ebx
	jmp	.L47
.L50:
	imull	$40, %edx, %eax
	cmpl	%ebx, tasks+32(%eax)
	jne	.L48
	addl	$tasks, %eax
	jmp	.L49
.L48:
	incl	%edx
.L47:
	cmpl	%ecx, %edx
	jb	.L50
	xorl	%eax, %eax
.L49:
	popl	%ebx
	popl	%ebp
	ret
	.size	utask_get_by_tid, .-utask_get_by_tid
.globl utask_put_mcu_to_sleep
	.bss
	.align 4
	.type	utask_put_mcu_to_sleep, @object
	.size	utask_put_mcu_to_sleep, 4
utask_put_mcu_to_sleep:
	.zero	4
	.local	tasks
	.comm	tasks,400,4
	.local	utask_last_used
	.comm	utask_last_used,4,4
	.data
	.align 4
	.type	utask_free_slots, @object
	.size	utask_free_slots, 4
utask_free_slots:
	.long	10
	.local	utask_free_tid
	.comm	utask_free_tid,4,4
	.local	utask_last_tid
	.comm	utask_last_tid,4,4
	.ident	"GCC: (Ubuntu/Linaro 4.5.2-8ubuntu4) 4.5.2"
	.section	.note.GNU-stack,"",@progbits
