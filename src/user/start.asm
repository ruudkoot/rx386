;
; USER.ELF
;

%include "config.inc"
%include "defs.inc"
%include "kernel.inc"

cpu   386
bits  32

section .text   progbits  alloc   exec    nowrite   align=4096
section .data   progbits  alloc   noexec  write     align=4096
section .bss    nobits    alloc   noexec  write     align=4096

extern c_thread_a
extern c_thread_b
extern c_thread_c
extern c_thread_d

section .text

global _USER_START

_USER_START:
  mov esp, StackA.top
  jmp Main

          db 0
Signature db CR,LF,'RX/386 USER ',__UTC_DATE__,' ',__UTC_TIME__,CR,LF
Copyright db 'Copyright (c) 2021, Ruud Koot <inbox@ruudkoot.nl>',CR,LF,0

Main:
.signature:
  mov esi, Signature
  call PrintString
.set_iopb:
  mov eax, 3
  mov edx, 0xFFFFFF00 ; 0x60 - 0x67
  int SYSCALL_SETIOPB
.start_threads:
  mov eax, 1
  mov ecx, ThreadB
  mov ebx, StackB.top
  int SYSCALL_SETTCB
  mov eax, 2
  mov ecx, ThreadC
  mov ebx, StackC.top
  int SYSCALL_SETTCB
  mov eax, 3
  mov ecx, ThreadD
  mov ebx, StackD.top
  int SYSCALL_SETTCB
  jmp ThreadA

align 256
ThreadA:
  call c_thread_a
.halt:
  jmp .halt

align 256
ThreadB:
  call c_thread_b
.halt:
  jmp .halt

align 256
ThreadC:
  call c_thread_c
.halt:
  jmp .halt

align 256
ThreadD:
  call c_thread_d
.halt:
  jmp .halt

section .bss

align 4
StackA:
.bottom:
  resd 1024
.top:
StackB:
.bottom:
  resd 1024
.top:
StackC:
.bottom:
  resd 1024
.top:
StackD:
.bottom:
  resd 1024
.top:

;-------------------------------------------------------------------------------
; STANDARD I/O
;-------------------------------------------------------------------------------

section .text

;
; PrintString
;
;   ESI = zero-terminated string
;
PrintString:
  pusha
.loop_start:
  mov al, [esi]
  inc esi
  or al, al
  jz .loop_exit
  int SYSCALL_CONSOLEOUT
  jmp .loop_start
.loop_exit:
  popa
  ret

;-------------------------------------------------------------------------------
; USER.C
;-------------------------------------------------------------------------------

section .text

global _inb
global _syscall_consoleout
global _syscall_waitirq
global _syscall_eoi

_inb:
  xor eax, eax
  mov edx, [esp+4]
  in al, dx
  ret

_syscall_consoleout:
  mov eax, [esp+4]
  int SYSCALL_CONSOLEOUT
  ret

_syscall_waitirq:
  mov ecx, [esp+4]
  int SYSCALL_WAITIRQ
  ret

_syscall_eoi:
  mov eax, [esp+4]
  int SYSCALL_EOI
  ret
