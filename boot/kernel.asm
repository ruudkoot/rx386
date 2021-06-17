;
; KERNEL.SYS
;

%include "defs.inc"

KERNEL_BASE equ 0x80010000
USER_BASE   equ 0x00010000

%define LOW_WORD(lbl) \
  ((lbl - KERNEL_START + KERNEL_BASE) & 0xffff)
%define HIGH_WORD(lbl) \
  (((lbl - KERNEL_START + KERNEL_BASE) >> 16) & 0xffff)
%define LOW_BYTE_OF_HIGH_WORD(lbl) \
  (((lbl - KERNEL_START + KERNEL_BASE) >> 16) & 0xff)
%define HIGH_BYTE_OF_HIGH_WORD(lbl) \
  (((lbl - KERNEL_START + KERNEL_BASE) >> 24) & 0xff)

cpu   386
bits  32
org   KERNEL_BASE


section .text

KERNEL_START:
  cli
  jmp Main

          db 0
Signature db CR,LF,'RX/386 KERNEL ',__UTC_DATE__,' ',__UTC_TIME__,CR,LF
Copyright db 'Copyright (c) 2021, Ruud Koot <inbox@ruudkoot.nl>',CR,LF,0

Main:
.prologue:
  mov eax, SELECTOR_DATA0
  mov ds, eax
  mov es, eax
  mov fs, eax
  mov gs, eax
  mov ss, eax
  mov esp, KernelStack.top
  lgdt [GDTR]
  lidt [IDTR]
  jmp SELECTOR_CODE0:.body
.body:
  mov esi, Signature
  call PrintString
  ;call TestExceptionDE
  ;call TestExceptionDB_1
  ;call TestExceptionDB_2
  ;call TestInterruptNMI
  ;call TestExceptionGP
  ;call TestExceptionPF
.enable_irqs:
  mov al, 0xfc
  out PORT_PIC_MASTER_DATA, al
  mov al, 0xff
  out PORT_PIC_SLAVE_DATA, al
.patch_tcbs:
  mov eax, cr3
  mov [TCB.thread1+TCB_CR3], eax
  mov [TCB.thread2+TCB_CR3], eax
  mov [TCB.thread3+TCB_CR3], eax
  mov [TCB.thread4+TCB_CR3], eax
.debug:
  ;push Thread4_Stack.top
  ;push Thread4_Stack.bottom
  ;push Thread3_Stack.top
  ;push Thread3_Stack.bottom
  ;push Thread2_Stack.top
  ;push Thread2_Stack.bottom
  ;push Thread1_Stack.top
  ;push Thread1_Stack.bottom
  ;push Thread4
  ;push Thread3
  ;push Thread2
  ;push Thread1
  ;push KernelStack.top
  ;push KernelStack.bottom
  ;push esp
  ;mov esi, .message
  ;call PrintFormatted
.enter_ring3:
  mov eax, SELECTOR_TSS | 3
  ltr ax
  mov eax, SELECTOR_DATA3 | 3
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  push SELECTOR_DATA3 | 3
  push Thread1_Stack.top
  pushf
  pop eax
  or eax, EFLAGS_IF
  push eax
  push SELECTOR_CODE3 | 3
  push Thread1
  iret
.epilogue:
  jmp HaltSystem
.message:
  ;db 'ESP = %h',CR,LF
  ;db 'KernelStack.bottom = %h',CR,LF
  ;db 'KernelStack.top = %h',CR,LF
  ;db 'Thread1 = %h',CR,LF
  ;db 'Thread2 = %h',CR,LF
  ;db 'Thread3 = %h',CR,LF
  ;db 'Thread4 = %h',CR,LF
  ;db 'Thread1_Stack.bottom = %h',CR,LF
  ;db 'Thread1_Stack.top = %h',CR,LF
  ;db 'Thread2_Stack.bottom = %h',CR,LF
  ;db 'Thread2_Stack.top = %h',CR,LF
  ;db 'Thread3_Stack.bottom = %h',CR,LF
  ;db 'Thread3_Stack.top = %h',CR,LF
  ;db 'Thread4_Stack.bottom = %h',CR,LF
  ;db 'Thread4_Stack.top = %h',CR,LF
  ;db 0

;-------------------------------------------------------------------------------
; USER MODE
;-------------------------------------------------------------------------------

section .text

Thread1:
  mov al, '1'
  int SYSCALL_CONSOLEOUT
  ;mov al, 'A'
  ;int SYSCALL_CONSOLEOUT
  jmp Thread1
Thread2:
  mov al, '2'
  int SYSCALL_CONSOLEOUT
  ;mov al, 'B'
  ;int SYSCALL_CONSOLEOUT
  jmp Thread2
Thread3:
  mov al, '3'
  int SYSCALL_CONSOLEOUT
  ;mov al, 'C'
  ;int SYSCALL_CONSOLEOUT
  jmp Thread3
Thread4:
  mov al, '4'
  int SYSCALL_CONSOLEOUT
  ;mov al, 'D'
  ;int SYSCALL_CONSOLEOUT
  jmp Thread4

section .bss

align 4
Thread1_Stack:
.bottom:
  resd 256
.top:
Thread2_Stack:
.bottom:
  resd 256
.top:
Thread3_Stack:
.bottom:
  resd 256
.top:
Thread4_Stack:
.bottom:
  resd 256
.top:

;-------------------------------------------------------------------------------
; THREAD CONTROL BLOCKS
;-------------------------------------------------------------------------------

TCB_NEXT    equ 0
TCB_CR3     equ 4
TCB_EIP     equ 8
TCB_EFLAGS  equ 12
TCB_EAX     equ 16
TCB_ECX     equ 20
TCB_EDX     equ 24
TCB_EBX     equ 28
TCB_ESP     equ 32
TCB_EBP     equ 36
TCB_ESI     equ 40
TCB_EDI     equ 44
TCB_CS      equ 48
TCB_DS      equ 52
TCB_ES      equ 56
TCB_FS      equ 60
TCB_GS      equ 64
TCB_SS      equ 68

section .data

CurrentThread dd TCB.thread1

align 4
TCB:
.start:
.thread1:
  dd .thread2           ; NEXT
  dd 0x00000000         ; CR3
  dd Thread1            ; EIP
  dd EFLAGS_IF          ; EFLAGS
  dd 0x00000000         ; EAX
  dd 0x00000000         ; ECX
  dd 0x00000000         ; EDX
  dd 0x00000000         ; EBX
  dd Thread1_Stack.top  ; ESP
  dd 0x00000000         ; EBP
  dd 0x00000000         ; ESI
  dd 0x00000000         ; EDI
  dd SELECTOR_CODE3 | 3 ; CS
  dd SELECTOR_DATA3 | 3 ; DS
  dd SELECTOR_DATA3 | 3 ; ES
  dd SELECTOR_DATA3 | 3 ; FS
  dd SELECTOR_DATA3 | 3 ; GS
  dd SELECTOR_DATA3 | 3 ; SS
.thread2:
  dd .thread3           ; NEXT
  dd 0x00000000         ; CR3
  dd Thread2            ; EIP
  dd EFLAGS_IF          ; EFLAGS
  dd 0x00000000         ; EAX
  dd 0x00000000         ; ECX
  dd 0x00000000         ; EDX
  dd 0x00000000         ; EBX
  dd Thread2_Stack.top  ; ESP
  dd 0x00000000         ; EBP
  dd 0x00000000         ; ESI
  dd 0x00000000         ; EDI
  dd SELECTOR_CODE3 | 3 ; CS
  dd SELECTOR_DATA3 | 3 ; DS
  dd SELECTOR_DATA3 | 3 ; ES
  dd SELECTOR_DATA3 | 3 ; FS
  dd SELECTOR_DATA3 | 3 ; GS
  dd SELECTOR_DATA3 | 3 ; SS
.thread3:
  dd .thread4           ; NEXT
  dd 0x00000000         ; CR3
  dd Thread3            ; EIP
  dd EFLAGS_IF          ; EFLAGS
  dd 0x00000000         ; EAX
  dd 0x00000000         ; ECX
  dd 0x00000000         ; EDX
  dd 0x00000000         ; EBX
  dd Thread3_Stack.top  ; ESP
  dd 0x00000000         ; EBP
  dd 0x00000000         ; ESI
  dd 0x00000000         ; EDI
  dd SELECTOR_CODE3 | 3 ; CS
  dd SELECTOR_DATA3 | 3 ; DS
  dd SELECTOR_DATA3 | 3 ; ES
  dd SELECTOR_DATA3 | 3 ; FS
  dd SELECTOR_DATA3 | 3 ; GS
  dd SELECTOR_DATA3 | 3 ; SS
.thread4:
  dd .thread1           ; NEXT
  dd 0x00000000         ; CR3
  dd Thread4            ; EIP
  dd EFLAGS_IF          ; EFLAGS
  dd 0x00000000         ; EAX
  dd 0x00000000         ; ECX
  dd 0x00000000         ; EDX
  dd 0x00000000         ; EBX
  dd Thread4_Stack.top  ; ESP
  dd 0x00000000         ; EBP
  dd 0x00000000         ; ESI
  dd 0x00000000         ; EDI
  dd SELECTOR_CODE3 | 3 ; CS
  dd SELECTOR_DATA3 | 3 ; DS
  dd SELECTOR_DATA3 | 3 ; ES
  dd SELECTOR_DATA3 | 3 ; FS
  dd SELECTOR_DATA3 | 3 ; GS
  dd SELECTOR_DATA3 | 3 ; SS
.end:

;-------------------------------------------------------------------------------
; TASK STATE SEGMENT
;-------------------------------------------------------------------------------

section .text ; FIXME: .data (but relocation errors)

align 4
TSS:
.start:
  dw 0                ; LINK
  dw 0                ; reserved
  dd KernelStack.top  ; ESP0
  dw SELECTOR_DATA0   ; SS0
  dw 0                ; reserved
  dd 0                ; ESP1
  dw 0                ; SS1
  dw 0                ; reserved
  dd 0                ; ESP2
  dw 0                ; SS2
  dw 0                ; reserved
  dd 0                ; CR3
  dd 0                ; EIP
  dd 0                ; EFLAGS
  dd 0                ; EAX
  dd 0                ; ECX
  dd 0                ; EDX
  dd 0                ; EBX
  dd 0                ; ESP
  dd 0                ; EBP
  dd 0                ; ESI
  dd 0                ; EDI
  dw 0                ; ES
  dw 0                ; reserved
  dw 0                ; CS
  dw 0                ; reserved
  dw 0                ; SS
  dw 0                ; reserved
  dw 0                ; DS
  dw 0                ; reserved
  dw 0                ; FS
  dw 0                ; reserved
  dw 0                ; GS
  dw 0                ; reserved
  dw 0                ; LDTR
  dw 0                ; reserved
  dw 0                ; reserved / trap
  dw 0                ; IOPB offset
.end:

section .bss

align 4
KernelStack:
.bottom:
  resd 1024
.top:

;-------------------------------------------------------------------------------
; SEGMENT DESCRIPTOR TABLE
;-------------------------------------------------------------------------------

SELECTOR_NULL         equ GDT.selector_null  - GDT.start
SELECTOR_TSS          equ GDT.selector_tss   - GDT.start
SELECTOR_DATA0        equ GDT.selector_data0 - GDT.start
SELECTOR_CODE0        equ GDT.selector_code0 - GDT.start
SELECTOR_DATA3        equ GDT.selector_data3 - GDT.start
SELECTOR_CODE3        equ GDT.selector_code3 - GDT.start

section .data

align 8
GDT:
.start:
.selector_null:
  dw 0x0000
  dw 0x0000
  db 0x00
  db SD_NOTPRESENT
  db 0x00
  db 0x00
.selector_tss:
  dw TSS.end - TSS.start ; FIXME: -1?
  dw LOW_WORD(TSS)
  db LOW_BYTE_OF_HIGH_WORD(TSS)
  db SD_TYPE_TSS_32 | SD_DPL3 | SD_PRESENT
  db 0x00 | SD_SIZE_16BIT | SD_GRANULARITY_BYTE
  db HIGH_BYTE_OF_HIGH_WORD(TSS)
.selector_data0:
  dw 0xffff
  dw 0x0000
  db 0x00
  db SD_TYPE_DATA | SD_DATA_WRITABLE | SD_DPL0 | SD_PRESENT
  db 0x0f | SD_SIZE_32BIT | SD_GRANULARITY_PAGE
  db 0x00
.selector_code0:
  dw 0xffff
  dw 0x0000
  db 0x00
  db SD_TYPE_CODE | SD_CODE_READABLE | SD_DPL0 | SD_PRESENT
  db 0x0f | SD_SIZE_32BIT | SD_GRANULARITY_PAGE
  db 0x00
.selector_data3:
  dw 0xffff
  dw 0x0000
  db 0x00
  db SD_TYPE_DATA | SD_DATA_WRITABLE | SD_DPL3 | SD_PRESENT
  db 0x0f | SD_SIZE_32BIT | SD_GRANULARITY_PAGE
  db 0x00
.selector_code3:
  dw 0xffff
  dw 0x0000
  db 0x00
  db SD_TYPE_CODE | SD_CODE_READABLE | SD_DPL3 | SD_PRESENT
  db 0x0f | SD_SIZE_32BIT | SD_GRANULARITY_PAGE
  db 0x00
.end:

GDTR:
.limit:
  dw (GDT.end - GDT.start - 1)
.base:
  dd GDT

;-------------------------------------------------------------------------------
; INTERRUPT DESCRIPTOR TABLE
;-------------------------------------------------------------------------------

section .text

; Fault
align 4
ExceptionDE:
  cli
  pusha
.body:
  mov esi, MessageExceptionDE
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Fault or Trap
align 4
ExceptionDB:
  cli
  pusha
.body:
  mov esi, MessageExceptionDB
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Interrupt
align 4
InterruptNMI:
  cli
  pusha
.body:
  mov esi, MessageInterruptNMI
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Trap
align 4
ExceptionBP:
  cli
  pusha
.body:
  mov esi, MessageExceptionBP
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Trap
align 4
ExceptionOF:
  cli
  pusha
.body:
  mov esi, MessageExceptionOF
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Fault
align 4
ExceptionBR:
  cli
  pusha
.body:
  mov esi, MessageExceptionBR
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Fault
align 4
ExceptionUD:
  cli
  pusha
.body:
  mov esi, MessageExceptionUD
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Fault
align 4
ExceptionNM:
  cli
  pusha
.body:
  mov esi, MessageExceptionNM
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Abort with Error Code
align 4
ExceptionDF:
  cli
  pusha
.body:
  mov esi, MessageExceptionDF
  mov eax, [ebp+32] ; Error Code
  jmp Panic
.epilogue:
  popa
  add esp, 4
  iret

; Fault
; (287 & 387 only)
align 4
ExceptionCSO:
  cli
  pusha
.body:
  mov esi, MessageExceptionCSO
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Fault with Error Code
align 4
ExceptionTS:
  cli
  pusha
.body:
  mov esi, MessageExceptionTS
  mov eax, [ebp+32] ; Error Code
  jmp Panic
.epilogue:
  popa
  add esp, 4
  iret

; Fault with Error Code
align 4
ExceptionNP:
  cli
  pusha
.body:
  mov esi, MessageExceptionNP
  mov eax, [ebp+32] ; Error Code
  jmp Panic
.epilogue:
  popa
  add esp, 4
  iret

; Fault with Error Code
align 4
ExceptionSS:
  cli
  pusha
.body:
  mov esi, MessageExceptionSS
  mov eax, [ebp+32] ; Error Code
  jmp Panic
.epilogue:
  popa
  add esp, 4
  iret

; Fault with Error Code
align 4
ExceptionGP:
  cli
  pusha
.body:
  mov ebp, esp
  mov esi, MessageExceptionGP
  mov eax, [ebp+32] ; Error Code
  jmp Panic
.epilogue:
  popa
  add esp, 4
  iret

; Fault with Error Code
align 4
ExceptionPF:
  cli
  pusha
.body:
  mov esi, MessageExceptionPF
  mov eax, [ebp+32] ; Error Code
  jmp Panic
.epilogue:
  popa
  add esp, 4
  iret

; Reserved
align 4
Exception0F:
  cli
  pusha
.body:
  mov esi, MessageException0F
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Fault
align 4
ExceptionMF:
  cli
  pusha
.body:
  mov esi, MessageExceptionMF
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Fault with Error Code
align 4
ExceptionAC:
  cli
  pusha
.body:
  mov esi, MessageExceptionAC
  mov eax, [ebp+32] ; Error Code
  jmp Panic
.epilogue:
  popa
  add esp, 4
  iret

; Abort
align 4
ExceptionMC:
  cli
  pusha
.body:
  mov esi, MessageExceptionMC
  mov eax, [ebp+32] ; Error Code
  jmp Panic
.epilogue:
  popa
  iret

; Fault
align 4
ExceptionXM:
  cli
  pusha
.body:
  mov esi, MessageExceptionXM
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Fault
align 4
ExceptionVE:
  cli
  pusha
.body:
  mov esi, MessageExceptionVE
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Reserved
align 4
Exception15:
  cli
  pusha
.body:
  mov esi, MessageException15
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Reserved
align 4
Exception16:
  cli
  pusha
.body:
  mov esi, MessageException16
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Reserved
align 4
Exception17:
  cli
  pusha
.body:
  mov esi, MessageException17
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Reserved
align 4
Exception18:
  cli
  pusha
.body:
  mov esi, MessageException18
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Reserved
align 4
Exception19:
  cli
  pusha
.body:
  mov esi, MessageException19
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Reserved
align 4
Exception1A:
  cli
  pusha
.body:
  mov esi, MessageException1A
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Reserved
align 4
Exception1B:
  cli
  pusha
.body:
  mov esi, MessageException1B
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Reserved
align 4
Exception1C:
  cli
  pusha
.body:
  mov esi, MessageException1C
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Reserved
align 4
Exception1D:
  cli
  pusha
.body:
  mov esi, MessageException1D
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

; Unknown with Error Code
align 4
ExceptionSX:
  cli
  pusha
.body:
  mov esi, MessageExceptionSX
  mov eax, [ebp+32] ; Error Code
  jmp Panic
.epilogue:
  popa
  add esp, 4
  iret

; Reserved
align 4
Exception1F:
  cli
  pusha
.body:
  mov esi, MessageException1F
  xor eax, eax
  jmp Panic
.epilogue:
  popa
  iret

;
; IRQ0 - Programmable Interval Timer
;
; Performs context switching.
;
; Calling Stack:
;
;   SS3
;   ESP3
;   EFLAGS
;   CS3
;   EIP
;
; To Do:
;
; - Floating-point registers
;
; Ideas:
;
; - Point ESP0 into the TCB to avoid copy from stack to TCB.
; - Handle segments more efficiently
;
align 4
IRQ0:
  cli
  push ds ; FIXME: partial write
  push es ; FIXME: partial write
  push fs ; FIXME: partial write
  push gs ; FIXME: partial write
  pusha
  mov ax, SELECTOR_DATA0
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ebp, esp
  ;mov esi, .message
  ;call PrintFormatted
  ;call HaltSystem
.body:
  mov al, 0
  call DebugIRQ
.save_state:
  mov ebx, [CurrentThread]
  mov eax, [ebp+64]
  mov [ebx+TCB_SS], eax
  mov eax, [ebp+60]
  mov [ebx+TCB_ESP], eax
  mov eax, [ebp+56]
  mov [ebx+TCB_EFLAGS], eax
  mov eax, [ebp+52]
  mov [ebx+TCB_CS], eax
  mov eax, [ebp+48]
  mov [ebx+TCB_EIP], eax
  mov eax, [ebp+44]
  mov [ebx+TCB_DS], eax
  mov eax, [ebp+40]
  mov [ebx+TCB_ES], eax
  mov eax, [ebp+36]
  mov [ebx+TCB_FS], eax
  mov eax, [ebp+32]
  mov [ebx+TCB_GS], eax
  mov eax, [ebp+28]
  mov [ebx+TCB_EAX], eax
  mov eax, [ebp+24]
  mov [ebx+TCB_ECX], eax
  mov eax, [ebp+20]
  mov [ebx+TCB_EDX], eax
  mov eax, [ebp+16]
  mov [ebx+TCB_EBX], eax
  mov eax, [ebp+8]
  mov [ebx+TCB_EBP], eax
  mov eax, [ebp+4]
  mov [ebx+TCB_ESI], eax
  mov eax, [ebp+0]
  mov [ebx+TCB_EDI], eax
.switch_task:
  mov ebx, [ebx+TCB_NEXT]
  mov [CurrentThread], ebx
  mov eax, [ebx+TCB_SS]
  mov [ebp+64], eax
  mov eax, [ebx+TCB_ESP]
  mov [ebp+60], eax
  mov eax, [ebx+TCB_EFLAGS]
  mov [ebp+56], eax
  mov eax, [ebx+TCB_CS]
  mov [ebp+52], eax
  mov eax, [ebx+TCB_EIP]
  mov [ebp+48], eax
  mov eax, [ebx+TCB_DS]
  mov [ebp+44], eax
  mov eax, [ebx+TCB_ES]
  mov [ebp+40], eax
  mov eax, [ebx+TCB_FS]
  mov [ebp+36], eax
  mov eax, [ebx+TCB_GS]
  mov [ebp+32], eax
  mov eax, [ebx+TCB_EAX]
  mov [ebp+28], eax
  mov eax, [ebx+TCB_ECX]
  mov [ebp+24], eax
  mov eax, [ebx+TCB_EDX]
  mov [ebp+20], eax
  mov eax, [ebx+TCB_EBX]
  mov [ebp+16], eax
  mov eax, [ebx+TCB_EBP]
  mov [ebp+8], eax
  mov eax, [ebx+TCB_ESI]
  mov [ebp+4], eax
  mov eax, [ebx+TCB_EDI]
  mov [ebp+0], eax
  ;mov esi, .message
  ;call PrintFormatted
  ;call HaltSystem
.eoi:
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  popa
  pop gs
  pop fs
  pop es
  pop ds
  iret
.message:
  ;db CR,LF
  ;db "IRQ0: EDI    = %h",CR,LF
  ;db "IRQ0: ESI    = %h",CR,LF
  ;db "IRQ0: EBP    = %h",CR,LF
  ;db "IRQ0: ESP    = %h",CR,LF
  ;db "IRQ0: EBX    = %h",CR,LF
  ;db "IRQ0: EDX    = %h",CR,LF
  ;db "IRQ0: ECX    = %h",CR,LF
  ;db "IRQ0: EAX    = %h",CR,LF
  ;db "IRQ0: GS     = %h",CR,LF
  ;db "IRQ0: FS     = %h",CR,LF
  ;db "IRQ0: ES     = %h",CR,LF
  ;db "IRQ0: DS     = %h",CR,LF
  ;db "IRQ0: EIP    = %h",CR,LF
  ;db "IRQ0: CS     = %h",CR,LF
  ;db "IRQ0: EFLAGS = %h",CR,LF
  ;db "IRQ0: ESP3   = %h",CR,LF
  ;db "IRQ0: SS3    = %h",CR,LF
  ;db 0


; Interrupt
align 4
IRQ1:
  cli
  pusha
.body:
  mov al, 1
  call DebugIRQ
  in al, PORT_KEYB_DATA
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  popa
  iret

; Interrupt
align 4
IRQ2:
  cli
  pusha
.body:
  mov al, 2
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  jmp HaltSystem
  popa
  iret

; Interrupt
align 4
IRQ3:
  cli
  pusha
.body:
  mov al, 3
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  jmp HaltSystem
  popa
  iret

; Interrupt
align 4
IRQ4:
  cli
  pusha
.body:
  mov al, 4
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  jmp HaltSystem
  popa
  iret

; Interrupt
align 4
IRQ5:
  cli
  pusha
.body:
  mov al, 5
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  jmp HaltSystem
  popa
  iret

; Interrupt
align 4
IRQ6:
  cli
  pusha
.body:
  mov al, 6
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  jmp HaltSystem
  popa
  iret

; Interrupt
align 4
IRQ7:
  cli
  pusha
.body:
  mov al, 7
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  jmp HaltSystem
  popa
  iret

; Interrupt
align 4
IRQ8:
  cli
  pusha
.body:
  mov al, 8
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  jmp HaltSystem
  popa
  iret

; Interrupt
align 4
IRQ9:
  cli
  pusha
.body:
  mov al, 9
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  jmp HaltSystem
  popa
  iret

; Interrupt
align 4
IRQ10:
  cli
  pusha
.body:
  mov al, 10
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  jmp HaltSystem
  popa
  iret

; Interrupt
align 4
IRQ11:
  cli
  pusha
.body:
  mov al, 11
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  jmp HaltSystem
  popa
  iret

; Interrupt
align 4
IRQ12:
  cli
  pusha
.body:
  mov al, 12
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  jmp HaltSystem
  popa
  iret

; Interrupt
align 4
IRQ13:
  cli
  pusha
.body:
  mov al, 13
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  jmp HaltSystem
  popa
  iret

; Interrupt
align 4
IRQ14:
  cli
  pusha
.body:
  mov al, 14
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  jmp HaltSystem
  popa
  iret

; Interrupt
align 4
IRQ15:
  cli
  pusha
.body:
  mov al, 15
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  jmp HaltSystem
  popa
  iret

; Syscall
align 4
SysCall_ConsoleOut:
  cli
  pusha
.body:
  call ConsoleOut
.epilogue:
  popa
  iret

section .data

SYSCALL_CONSOLEOUT  equ (IDT.syscall_console_out - IDT.start) / 8

align 8
IDT:
.start:
.exception_de:
  dw LOW_WORD(ExceptionDE)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionDE)
.exception_db:
  dw LOW_WORD(ExceptionDB)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionDB)
.interrupt_nmi:
  dw LOW_WORD(InterruptNMI)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(InterruptNMI)
.exception_bp:
  dw LOW_WORD(ExceptionBP)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionBP)
.exception_of:
  dw LOW_WORD(ExceptionOF)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionOF)
.exception_br:
  dw LOW_WORD(ExceptionBR)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionBR)
.exception_ud:
  dw LOW_WORD(ExceptionUD)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionUD)
.exception_nm:
  dw LOW_WORD(ExceptionNM)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionNM)
.exception_df:
  dw LOW_WORD(ExceptionDF)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionDF)
.exception_cso:
  dw LOW_WORD(ExceptionCSO)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionCSO)
.exception_ts:
  dw LOW_WORD(ExceptionTS)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionTS)
.exception_np:
  dw LOW_WORD(ExceptionNP)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionNP)
.exception_ss:
  dw LOW_WORD(ExceptionSS)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionSS)
.exception_gp:
  dw LOW_WORD(ExceptionGP)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionGP)
.exception_pf:
  dw LOW_WORD(ExceptionPF)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionPF)
.exception_0f:
  dw LOW_WORD(Exception0F)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(Exception0F)
.exception_mf:
  dw LOW_WORD(ExceptionMF)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionMF)
.exception_ac:
  dw LOW_WORD(ExceptionAC)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionAC)
.exception_mc:
  dw LOW_WORD(ExceptionMC)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionMC)
.exception_xm:
  dw LOW_WORD(ExceptionXM)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionXM)
.exception_ve:
  dw LOW_WORD(ExceptionVE)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionVE)
.exception_15:
  dw LOW_WORD(Exception15)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(Exception15)
.exception_16:
  dw LOW_WORD(Exception16)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(Exception16)
.exception_17:
  dw LOW_WORD(Exception17)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(Exception17)
.exception_18:
  dw LOW_WORD(Exception18)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(Exception18)
.exception_19:
  dw LOW_WORD(Exception19)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(Exception19)
.exception_1a:
  dw LOW_WORD(Exception1A)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(Exception1A)
.exception_1b:
  dw LOW_WORD(Exception1B)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(Exception1B)
.exception_1c:
  dw LOW_WORD(Exception1C)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(Exception1C)
.exception_1d:
  dw LOW_WORD(Exception1D)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(Exception1D)
.exception_sx:
  dw LOW_WORD(ExceptionSX)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(ExceptionSX)
.exception_1f:
  dw LOW_WORD(Exception1F)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(Exception1F)
.irq0:
  dw LOW_WORD(IRQ0)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ0)
.irq1:
  dw LOW_WORD(IRQ1)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ1)
.irq2:
  dw LOW_WORD(IRQ2)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ2)
.irq3:
  dw LOW_WORD(IRQ3)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ3)
.irq4:
  dw LOW_WORD(IRQ4)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ4)
.irq5:
  dw LOW_WORD(IRQ5)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ5)
.irq6:
  dw LOW_WORD(IRQ6)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ6)
.irq7:
  dw LOW_WORD(IRQ7)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ7)
.irq8:
  dw LOW_WORD(IRQ8)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ8)
.irq9:
  dw LOW_WORD(IRQ9)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ9)
.irq10:
  dw LOW_WORD(IRQ10)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ10)
.irq11:
  dw LOW_WORD(IRQ11)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ11)
.irq12:
  dw LOW_WORD(IRQ12)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ12)
.irq13:
  dw LOW_WORD(IRQ13)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ13)
.irq14:
  dw LOW_WORD(IRQ14)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ14)
.irq15:
  dw LOW_WORD(IRQ15)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
  dw HIGH_WORD(IRQ15)
.syscall_console_out:
  dw LOW_WORD(SysCall_ConsoleOut)
  dw SELECTOR_CODE0
  db 0
  db ID_GATETYPE_INTR32 | ID_DPL3 | ID_PRESENT
  dw HIGH_WORD(SysCall_ConsoleOut)
.end:

IDTR:
.limit:
  dw (IDT.end - IDT.start - 1)
.base:
  dd IDT

MessageExceptionDE:
  db 'Divide-by-zero Error (#DE)',0

MessageExceptionDB:
  db 'Debug (#DB)',0

MessageInterruptNMI:
  db 'Non-maskable interrupt',0

MessageExceptionBP:
  db 'Breakpoint (#BP)',0

MessageExceptionOF:
  db 'Overflow (#OF)',0

MessageExceptionBR:
  db 'Bound Range Exceeded (#BR)',0

MessageExceptionUD:
  db 'Invalid Opcode (#UD)',0

MessageExceptionNM:
  db 'Device Not Available (#NM)',0

MessageExceptionDF:
  db 'Double Fault (#DF)',0

MessageExceptionCSO:
  db 'Coprocessor Segment Overrun',0

MessageExceptionTS:
  db 'Invalid TSS (#TS)',0

MessageExceptionNP:
  db 'Segment Not Present (#NP)',0

MessageExceptionSS:
  db 'Stack-Segment Fault (#SS)',0

MessageExceptionGP:
  db 'General Protection Fault (#GP)',0

MessageExceptionPF:
  db 'Page Fault (#PF)',0

MessageException0F:
  db 'Unknown Exception (0Fh)',0

MessageExceptionMF:
  db 'x87 Floating-Point Exception (#MF)',0

MessageExceptionAC:
  db 'Alignment Check (#AC)',0

MessageExceptionMC:
  db 'Machine Check (#MC)',0

MessageExceptionXM:
  db 'SIMD Floating-Point Exception (#XM)',0

MessageExceptionVE:
  db 'Virtualization Exception (#VE)',0

; FIXME: Control Protection Exception
MessageException15:
  db 'Unknown Exception (15h)',0

MessageException16:
  db 'Unknown Exception (16h)',0

MessageException17:
  db 'Unknown Exception (17h)',0

MessageException18:
  db 'Unknown Exception (18h)',0

MessageException19:
  db 'Unknown Exception (19h)',0

MessageException1A:
  db 'Unknown Exception (1Ah)',0

MessageException1B:
  db 'Unknown Exception (1Bh)',0

MessageException1C:
  db 'Unknown Exception (1Ch)',0

MessageException1D:
  db 'Unknown Exception (1Dh)',0

MessageExceptionSX:
  db 'Security Exception (#SE)',0

MessageException1F:
  db 'Unknown Exception (1Fh)',0

;-------------------------------------------------------------------------------
; PANIC
;-------------------------------------------------------------------------------

section .text

;
; HaltSystem
;
; To do:
;
;   - Disable NMI?
;
HaltSystem:
  mov esi, MessageSystemHalted
  call PrintString
  cli
  hlt
  jmp HaltSystem

section .data

MessageSystemHalted:
  db 'SYSTEM HALTED!',13,10,0

section .text

;
; Panic
;
; Calling Registers:
;
;   ESI = exception
;   EAX = error code
;
Panic:
  pusha
  push eax
  push esi
  mov esi, MessagePanic1
  call PrintFormatted
  add esp, 8
  popa
  jmp HaltSystem

section .data

MessagePanic1:
  db '! EXCEPTION %s    ERROR CODE %h',CR,LF,0

;
; DebugIRQ
;
; Calling Regsiters:
;
;   AL = irq
;
DebugIRQ:
  pusha
  cbw
  mov ebx, eax
  inc byte [CONSOLE_FRAMEBUFFER+2*ebx+128]
  popa
  ret

;-------------------------------------------------------------------------------
; CONSOLE
;-------------------------------------------------------------------------------

CONSOLE_FRAMEBUFFER equ 0x800b8000
CONSOLE_COLS        equ 80
CONSOLE_ROWS        equ 25
CONSOLE_TABS        equ 8

section .text

;
; Send character to screen
;
;   AL = character
;
ConsoleOut:
  pusha
  mov bl, al
  mov esi, [ConsoleCursorCol]
  mov edi, [ConsoleCursorRow]
  cmp bl, NUL
  jz .control_nul
  ;cmp bl, BEL
  ;jz .control_bel
  cmp bl, BS
  jz .control_bs
  ;cmp bl, HT
  ;jz .control_ht
  cmp bl, LF
  jz .control_lf
  ;cmp bl, VT
  ;jz .control_vt
  ;cmp bl, FF
  ;jz .control_ff
  cmp bl, CR
  jz .control_cr
  ;cmp bl, ESC
  ;jz .control_esc
  jmp .normal_char
.control_nul:
  jmp .epilogue
.control_bs:
  or esi, esi
  jnz .control_bs_dec_col
  or edi, edi
  jz .epilogue
.control_bs_dec_row:
  mov esi, CONSOLE_COLS-1
  dec edi
  jmp .update_cursor
.control_bs_dec_col:
  dec esi
  jmp .update_cursor
.control_lf:
  inc edi
  jmp .scroll_screen
.control_cr:
  xor esi, esi
  jmp .update_cursor
.normal_char:
  mov eax, CONSOLE_COLS
  mul edi
  add eax, esi
  mov [CONSOLE_FRAMEBUFFER+2*eax], bl
  inc esi
  cmp esi, CONSOLE_COLS
  jl .update_cursor
  xor esi, esi
  inc edi
.scroll_screen:
  cmp edi, CONSOLE_ROWS
  jl .update_cursor
  mov eax, esi
  mov edx, edi
  mov edi, CONSOLE_FRAMEBUFFER
  mov esi, CONSOLE_FRAMEBUFFER+2*CONSOLE_COLS
  mov ecx, 2*CONSOLE_COLS*(CONSOLE_ROWS-1)
  cld
  rep movsd
  ; FIXME: fill newline
  mov esi, eax
  mov edi, edx
  dec edi
.update_cursor:
  mov [ConsoleCursorCol], esi
  mov [ConsoleCursorRow], edi
  mov eax, CONSOLE_COLS
  mul edi
  add eax, esi
  mov ecx, eax
  mov dx, PORT_CRTC_INDEX
  mov al, CRTC_CURSOR_HIGH
  out dx, al
  mov dx, PORT_CRTC_DATA
  mov al, ch
  out dx, al
  mov dx, PORT_CRTC_INDEX
  mov al, CRTC_CURSOR_LOW
  out dx, al
  mov dx, PORT_CRTC_DATA
  mov al, cl
  out dx, al
.epilogue:
  popa
  ret

section .data

ConsoleCursorCol  dd 0
ConsoleCursorRow  dd 24
ConsoleAttr       dd 0x07

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
  call ConsoleOut
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
  call ConsoleOut
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
  call ConsoleOut
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
; TESTS
;-------------------------------------------------------------------------------

;
; TestExceptionDE - Raise Divide-by-zero Error
;
TestExceptionDE:
  pusha
  xor eax, eax
  xor edx, edx
  xor ebx, ebx
  div ebx
  popa
  ret

TestExceptionDB_1:
  pusha
  icebp
  popa
  ret

TestExceptionDB_2:
  pusha
  pushf
  pop eax
  or eax, 0x00000100
  push eax
  popf
  nop
  pushf
  pop eax
  and eax, 0xfffffeff
  push eax
  popf
  popa
  ret

;
; TestInterruptNMI - Raise a non-maskable interrupt
;
TestInterruptNMI:
  pusha
  pushf
  cli
  int 2
  popf
  popa
  ret

TestExceptionGP:
  pusha
  xor eax, eax
  mov ax, fs
  push eax
  xor eax, eax
  mov fs, ax
  xor eax, eax
  push eax
  mov [fs:0xc000000], eax
  pop eax
  pop eax
  mov fs, ax
  popa
  ret
