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

extern c_entry

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
  call c_entry
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
  mov al, 'A'
  ;int SYSCALL_CONSOLEOUT
  jmp ThreadA

  section .text

align 256
ThreadB:
  mov al, '['
  ;int SYSCALL_CONSOLEOUT
  mov ecx, 1
  int SYSCALL_WAITIRQ
  mov al, '*'
  ;int SYSCALL_CONSOLEOUT
  in al, PORT_KEYB_DATA
  mov ecx, 1
  int SYSCALL_EOI
  int SYSCALL_CONSOLEOUT
  mov al, ']'
  ;int SYSCALL_CONSOLEOUT
  jmp ThreadB

align 256
ThreadC:
  mov al, 'C'
  ;int SYSCALL_CONSOLEOUT
  jmp ThreadC

align 256
ThreadD:
  mov eax, [StateD]
  or eax, eax
  jnz .halt
  inc eax
  mov [StateD], eax
  mov al, 'D'
  ;int SYSCALL_CONSOLEOUT
  mov eax, [StateD]
  or eax, eax
  jz .halt
  dec eax
  mov [StateD], eax
  mov al, 'd'
  ;int SYSCALL_CONSOLEOUT
  jmp ThreadD
.halt:
  mov al, 'X'
  int SYSCALL_CONSOLEOUT
  jmp .halt

section .data

StateD dd 0
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

;-------------------------------------------------------------------------------
; STANDARD I/O
;-------------------------------------------------------------------------------

PRINTF_FLAG_LEFTJUSTIFY equ 1
PRINTF_FLAG_FORCESIGN   equ 2
PRINTF_FLAG_PADSIGN     equ 4
PRINTF_FLAG_BASEPREFIX  equ 8
PRINTF_FLAG_LEFTPADZERO equ 16

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

;
; PrintFormatted
;
;   ESI = zero-terminated string
;
; State machine:
;
;   0 = normal characted
;   1 = in format specifier
;
PrintFormatted:
  pusha
  mov ebp, esp
  sub esp, 20
  mov dword [ebp], 0    ; STATE
  mov dword [ebp-4], 0  ; FLAGS
  mov dword [ebp-8], 0  ; WIDTH
  mov dword [ebp-12], 0 ; PRECISION
  mov dword [ebp-16], 0 ; PARAM
.loop_start:
  mov al, [esi]
  inc esi
  or al, al
  jz .loop_exit
  mov ebx, [ebp] ; STATE
  or ebx, ebx
  jnz .in_format_specifier
  cmp al, '%'
  jz .is_format_specifier
.print_literal:
  int SYSCALL_CONSOLEOUT
  jmp .loop_start
.is_format_specifier:
  inc dword [ebp] ; STATE
  jmp .loop_start
.in_format_specifier:
  mov dword [ebp], 0 ; STATE
  cmp al, '%'
  jz .print_literal
  cmp al, 'h'
  jz .print_h
  cmp al, 's'
  jz .print_s
  jmp .loop_start
.print_h:
  mov ebx, [ebp-16] ; PARAM
  inc dword [ebp-16]
  mov edx, [ebp+4*ebx+36]
  mov ebx, HexDigits
  mov cl, 28
.print_h_loop_start:
  mov eax, edx
  shr eax, cl
  and al, 0xf
  xlat
  int SYSCALL_CONSOLEOUT
  sub cl, 4
  jc .loop_start
  jmp .print_h_loop_start
.print_s:
  push esi
  mov ebx, [ebp-16] ; PARAM
  inc dword [ebp-16]
  mov esi, [ebp+4*ebx+36]
  call PrintString
  pop esi
  jmp .loop_start
.loop_exit:
  add esp, 20
  popa
  ret

section .data

HexDigits db '0123456789ABCDEF'

;-------------------------------------------------------------------------------
; USER.C
;-------------------------------------------------------------------------------

section .text

global _consoleout

_consoleout:
  pusha
  mov ebp, esp
  mov eax, [ebp+36]
  int SYSCALL_CONSOLEOUT
  popa
  ret
