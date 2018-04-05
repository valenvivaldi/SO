;file: exit_42.asm
;compile with:
;nasm -f elf exit_42.asm
;ld -s -nostdlib -o exit_42 exit_42.o 
; try it using:
;./exit_42 ; echo $?

BITS 32
GLOBAL _start
SECTION .text
_start:
	mov eax,1 ; set syscall number 1 (exit)
	mov ebx,42 ; argument of TEXT
	int 0x80 ; do the syscall
