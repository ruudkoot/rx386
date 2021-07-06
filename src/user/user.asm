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
  jmp Main

          db 0
Signature db CR,LF,'RX/386 USER SERVICES ',__UTC_DATE__,' ',__UTC_TIME__,CR,LF
Copyright db 'Copyright (c) 2021, Ruud Koot <inbox@ruudkoot.nl>',CR,LF,0

Main:
  jmp Main

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

DummyData db 'DUMMY',0

section .bss

Stack resd 1024
