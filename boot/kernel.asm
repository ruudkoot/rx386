;
; KERNEL.SYS
;

[bits 16]
[cpu 8086]
[org 0x0000]

ROOT_DIRECTORY_CLUSTER equ 1

  jmp Main

          db 0
Signature db 'RX/386 KERNEL ',__UTC_DATE__,' ',__UTC_TIME__,13,10
Copyright db 'Copyright (c) 2021, Ruud Koot',13,10,0

Main:
  mov si, Signature
  call PrintString
  call HaltSystem

;-------------------------------------------------------------------------------
; BASIC INPUT/OUTPUT
;-------------------------------------------------------------------------------

;
; Send character to screen
;
;   AL = character
;
ConsoleOut:
  push ax
  push bx
  mov ah, 0x0e
  mov bx, 0x0007
  int 0x10
  pop bx
  pop ax
  ret

;-------------------------------------------------------------------------------
; UTILITIES
;-------------------------------------------------------------------------------

;
; HaltSystem
;
HaltSystem:
  mov si, MessageSystemHalted
  call PrintString
.next:
  hlt
  jmp .next

;
; PrintString
;
;   DS:SI = zero-terminated string
;
PrintString:
  push ax
  push cx
  push dx
  push bx
  push bp
  push si
  push di
.next:
  mov al, [si]
  inc si
  or al, al
  jz .break
  call ConsoleOut
  jmp .next
.break:
  pop di
  pop si
  pop bp
  pop bx
  pop dx
  pop cx
  pop ax
  ret

;-------------------------------------------------------------------------------
; MESSAGES
;-------------------------------------------------------------------------------

MessageSystemHalted:
  db 'SYSTEM HALTED!',13,10,0