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

section .text

USER_START:
  mov esp, StackA.top
  jmp Main

          db 0
Signature db CR,LF,'RX/386 USER SERVICES ',__UTC_DATE__,' ',__UTC_TIME__,CR,LF
Copyright db 'Copyright (c) 2021, Ruud Koot <inbox@ruudkoot.nl>',CR,LF,0

Main:
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
  mov al, 'A'
  int SYSCALL_CONSOLEOUT
  jmp ThreadA

align 256
ThreadB:
  mov al, 'B'
  int SYSCALL_CONSOLEOUT
  jmp ThreadB

align 256
ThreadC:
  mov al, 'C'
  int SYSCALL_CONSOLEOUT
  jmp ThreadC

align 256
ThreadD:
  mov al, 'D'
  int SYSCALL_CONSOLEOUT
  jmp ThreadD

section .data

db 'DATA',0

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