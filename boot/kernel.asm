;
; KERNEL.SYS
;

[bits 32]
[cpu 386]
[org 0x80010000]

section .text

  jmp Main

          db 0
Signature db 13,10,'RX/386 KERNEL ',__UTC_DATE__,' ',__UTC_TIME__,13,10
Copyright db 'Copyright (c) 2021, Ruud Koot <inbox@ruudkoot.nl>',13,10,0

Main:
  mov esi, Signature
  call PrintString
  cli
  hlt

;-------------------------------------------------------------------------------
; CONSOLE
;-------------------------------------------------------------------------------

CONSOLE_FRAMEBUFFER equ 0x800b8000
CONSOLE_COLS        equ 80
CONSOLE_ROWS        equ 25

section .text

;
; Send character to screen
;
;   AL = character
;
ConsoleOut:
  pusha
  mov bl, al
  mov eax, [ConsoleCursorRow]
  mov ecx, CONSOLE_COLS
  mul ecx
  add eax, [ConsoleCursorCol]
  mov [CONSOLE_FRAMEBUFFER+2*eax], bl
  inc dword [ConsoleCursorCol]
  popa
  ret

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
  call ConsoleOut
  jmp .loop_start
.loop_exit:
  popa
  ret

section .data

ConsoleCursorCol dd 0
ConsoleCursorRow dd 24
