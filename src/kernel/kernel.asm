;
; KERNEL.ELF
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

KERNEL_START:
  cli
  jmp Main

          db 0
Signature db CR,LF,'RX/386 KERNEL ',__UTC_DATE__,' ',__UTC_TIME__,CR,LF
Copyright db 'Copyright (c) 2021, Ruud Koot <inbox@ruudkoot.nl>',CR,LF,0

Main:
.prologue:
  mov eax, SELECTOR_DATA0
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov esp, KernelStack.top
  call GdtShuffle
  call IdtShuffle
  lgdt [GDTR]
  lidt [IDTR]
  mov eax, SELECTOR_TSS | 3
  ltr ax
  jmp SELECTOR_CODE0:.body
.body:
  mov esi, Signature
  call PrintString
.patch_tcbs:
  mov eax, cr3
  add eax, PAGE_SIZE ; PageDirectoryBoot -> PageDirectoryUser
  mov cr3, eax
  mov [TCB.thread0+TCB_CR3], eax
  mov [TCB.thread1+TCB_CR3], eax
  mov [TCB.thread2+TCB_CR3], eax
  mov [TCB.thread3+TCB_CR3], eax
.enable_irqs:
  mov al, IRQ7 | IRQ6 | IRQ5 | IRQ4 | IRQ3 | IRQ2
  out PORT_PIC_MASTER_DATA, al
  mov al, IRQ15 | IRQ14 | IRQ13 | IRQ12 | IRQ11 | IRQ10 | IRQ9 | IRQ8
  out PORT_PIC_SLAVE_DATA, al
.enter_ring3:
  mov eax, SELECTOR_DATA3 | 3
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  push SELECTOR_DATA3 | 3
  push USER_STACK
  push EFLAGS_IF
  push SELECTOR_CODE3 | 3
  push USER_ENTRY
  iret

BusyLoop:
  jmp BusyLoop

;-------------------------------------------------------------------------------
; THREAD CONTROL BLOCKS
;-------------------------------------------------------------------------------

TCB_SIZE equ TCB.thread1 - TCB.thread0

THREAD_RUNNING  equ 1
THREAD_BLOCKED  equ 2

section .data

CurrentThread dd TCB.thread0

align 4
TCB:
.start:
.thread0:
  dd .thread1           ; NEXT
  dd 0x00000000         ; CR3
  dd USER_ENTRY         ; EIP
  dd EFLAGS_IF          ; EFLAGS
  dd 0x00000000         ; EAX
  dd 0x00000000         ; ECX
  dd 0x00000000         ; EDX
  dd 0x00000000         ; EBX
  dd 0x00000000         ; ESP
  dd 0x00000000         ; EBP
  dd 0x00000000         ; ESI
  dd 0x00000000         ; EDI
  dd SELECTOR_CODE3 | 3 ; CS
  dd SELECTOR_DATA3 | 3 ; DS
  dd SELECTOR_DATA3 | 3 ; ES
  dd SELECTOR_DATA3 | 3 ; FS
  dd SELECTOR_DATA3 | 3 ; GS
  dd SELECTOR_DATA3 | 3 ; SS
  dd THREAD_RUNNING     ; STATE
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
.thread1:
  dd .thread2           ; NEXT
  dd 0x00000000         ; CR3
  dd BusyLoop           ; EIP
  dd EFLAGS_IF          ; EFLAGS
  dd 0x00000000         ; EAX
  dd 0x00000000         ; ECX
  dd 0x00000000         ; EDX
  dd 0x00000000         ; EBX
  dd BusyLoopStack.top  ; ESP
  dd 0x00000000         ; EBP
  dd 0x00000000         ; ESI
  dd 0x00000000         ; EDI
  dd SELECTOR_CODE0 | 0 ; CS
  dd SELECTOR_DATA0 | 0 ; DS
  dd SELECTOR_DATA0 | 0 ; ES
  dd SELECTOR_DATA0 | 0 ; FS
  dd SELECTOR_DATA0 | 0 ; GS
  dd SELECTOR_DATA0 | 0 ; SS
  dd THREAD_BLOCKED     ; STATE
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
.thread2:
  dd .thread3           ; NEXT
  dd 0x00000000         ; CR3
  dd BusyLoop           ; EIP
  dd EFLAGS_IF          ; EFLAGS
  dd 0x00000000         ; EAX
  dd 0x00000000         ; ECX
  dd 0x00000000         ; EDX
  dd 0x00000000         ; EBX
  dd BusyLoopStack.top  ; ESP
  dd 0x00000000         ; EBP
  dd 0x00000000         ; ESI
  dd 0x00000000         ; EDI
  dd SELECTOR_CODE0 | 0 ; CS
  dd SELECTOR_DATA0 | 0 ; DS
  dd SELECTOR_DATA0 | 0 ; ES
  dd SELECTOR_DATA0 | 0 ; FS
  dd SELECTOR_DATA0 | 0 ; GS
  dd SELECTOR_DATA0 | 0 ; SS
  dd THREAD_BLOCKED     ; STATE
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
.thread3:
  dd .thread0           ; NEXT
  dd 0x00000000         ; CR3
  dd BusyLoop           ; EIP
  dd EFLAGS_IF          ; EFLAGS
  dd 0x00000000         ; EAX
  dd 0x00000000         ; ECX
  dd 0x00000000         ; EDX
  dd 0x00000000         ; EBX
  dd BusyLoopStack.top  ; ESP
  dd 0x00000000         ; EBP
  dd 0x00000000         ; ESI
  dd 0x00000000         ; EDI
  dd SELECTOR_CODE0 | 0 ; CS
  dd SELECTOR_DATA0 | 0 ; DS
  dd SELECTOR_DATA0 | 0 ; ES
  dd SELECTOR_DATA0 | 0 ; FS
  dd SELECTOR_DATA0 | 0 ; GS
  dd SELECTOR_DATA0 | 0 ; SS
  dd THREAD_BLOCKED     ; STATE
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
.end:

;-------------------------------------------------------------------------------
; NOTIFICATIONS
;-------------------------------------------------------------------------------

NOTIFICATION_IDLE     equ 0
NOTIFICATION_ACTIVE   equ 1
NOTIFICATION_WAITING  equ 2

section .data

NotificationState:
  dd NOTIFICATION_IDLE  ; IRQ0
  dd NOTIFICATION_IDLE  ; IRQ1
  dd NOTIFICATION_IDLE  ; IRQ2
  dd NOTIFICATION_IDLE  ; IRQ3
  dd NOTIFICATION_IDLE  ; IRQ4
  dd NOTIFICATION_IDLE  ; IRQ5
  dd NOTIFICATION_IDLE  ; IRQ6
  dd NOTIFICATION_IDLE  ; IRQ7
  dd NOTIFICATION_IDLE  ; IRQ8
  dd NOTIFICATION_IDLE  ; IRQ9
  dd NOTIFICATION_IDLE  ; IRQ10
  dd NOTIFICATION_IDLE  ; IRQ11
  dd NOTIFICATION_IDLE  ; IRQ12
  dd NOTIFICATION_IDLE  ; IRQ13
  dd NOTIFICATION_IDLE  ; IRQ14
  dd NOTIFICATION_IDLE  ; IRQ15
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE
  dd NOTIFICATION_IDLE

NotificationQueue:
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0

;-------------------------------------------------------------------------------
; TASK STATE SEGMENT
;-------------------------------------------------------------------------------

section .data

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
  dw .iopb - .start   ; IOPB offset
.iopb:
  dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
  dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
  dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
  dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
  dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
  dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
  dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
  dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
.iopb_padding:
  db 0xFF
.end:
  db 0xFF, 0xFF, 0xFF

section .bss

align 4
KernelStack:
.bottom:
  resd 1024
.top:
BusyLoopStack:
.bottom:
  resd 1024
.top:

;-------------------------------------------------------------------------------
; GLOBAL DESCRIPTOR TABLE
;-------------------------------------------------------------------------------

SELECTOR_NULL   equ GDT.selector_null  - GDT.start
SELECTOR_TSS    equ GDT.selector_tss   - GDT.start
SELECTOR_DATA0  equ GDT.selector_data0 - GDT.start
SELECTOR_CODE0  equ GDT.selector_code0 - GDT.start
SELECTOR_DATA3  equ GDT.selector_data3 - GDT.start
SELECTOR_CODE3  equ GDT.selector_code3 - GDT.start

section .text

;
; GdtShuffle - Reorder bytes in GDT
;
;   7654 3210 --> 3672 1054
;
align 4
GdtShuffle:
  pusha
  mov esi, GDT.start
  mov edi, GDT.end
  jmp .loop_check
.loop_start:
  mov ebx, [esi]
  mov ecx, [esi+4]
  mov eax, ebx
  shl eax, 16 ; 10..
  mov edx, ecx
  and edx, 0x0000ffff
  or eax, edx ; ..54
  mov [esi], eax
  mov eax, ecx
  and eax, 0x00ff0000 ; .6..
  mov edx, ecx
  shr edx, 16
  and edx, 0x0000ff00
  or eax, edx ; ..7.
  mov edx, ebx
  and edx, 0xff000000
  or eax, edx ; 3...
  mov edx, ebx
  shr edx, 16
  and edx, 0x000000ff
  or eax, edx ; ...2
  mov [esi+4], eax
  add esi, 8
.loop_check:
  cmp esi, edi
  jl .loop_start
.epilogue:
  popa
  ret

section .data

align 8
GDT:
.start:
.selector_null:
  dd 0x00000000
  dd 0x00000 \
      | SD_NOTPRESENT
.selector_tss:
  dd TSS
  dd (TSS.end - TSS.start - 1) \
      | SD_SIZE_16BIT | SD_GRANULARITY_BYTE \
      | SD_TYPE_TSS_32 | SD_DPL3 | SD_PRESENT
.selector_data0:
  dd 0x00000000
  dd 0xfffff \
      | SD_SIZE_32BIT | SD_GRANULARITY_PAGE \
      | SD_TYPE_DATA | SD_DATA_WRITABLE | SD_DPL0 | SD_PRESENT
.selector_code0:
  dd 0x00000000
  dd 0xfffff \
      | SD_SIZE_32BIT | SD_GRANULARITY_PAGE \
      | SD_TYPE_CODE | SD_CODE_READABLE | SD_DPL0 | SD_PRESENT
.selector_data3:
  dd 0x00000000
  dd 0xfffff \
      | SD_SIZE_32BIT | SD_GRANULARITY_PAGE \
      | SD_TYPE_DATA | SD_DATA_WRITABLE | SD_DPL3 | SD_PRESENT
.selector_code3:
  dd 0x00000000
  dd 0xfffff \
      | SD_SIZE_32BIT | SD_GRANULARITY_PAGE \
      | SD_TYPE_CODE | SD_CODE_READABLE | SD_DPL3 | SD_PRESENT
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

;
; IdtShuffle - Reorder bytes in IDT
;
;   7643 3210 --> 3276 4310
;
align 4
IdtShuffle:
  pusha
  mov esi, IDT.start
  mov edi, IDT.end
  jmp .loop_check
.loop_start:
  mov ebx, [esi]
  mov ecx, [esi+4]
  mov eax, ebx
  and eax, 0x0000ffff
  mov edx, ecx
  shl edx, 16
  or eax, edx
  mov [esi], eax
  mov eax, ebx
  and eax, 0xffff0000
  mov edx, ecx
  shr edx, 16
  or eax, edx
  mov [esi+4], eax
  add esi, 8
.loop_check:
  cmp esi, edi
  jl .loop_start
.epilogue:
  popa
  ret

section .data

align 8
IDT:
.start:
.exception_de:
  dd ExceptionDE
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_db:
  dd ExceptionDB
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.interrupt_nmi:
  dd InterruptNMI
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_bp:
  dd ExceptionBP
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_of:
  dd ExceptionOF
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_br:
  dd ExceptionBR
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_ud:
  dd ExceptionUD
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_nm:
  dd ExceptionNM
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_df:
  dd ExceptionDF
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_cso:
  dd ExceptionCSO
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_ts:
  dd ExceptionTS
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_np:
  dd ExceptionNP
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_ss:
  dd ExceptionSS
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_gp:
  dd ExceptionGP
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_pf:
  dd ExceptionPF
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_0f:
  dd Exception0F
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_mf:
  dd ExceptionMF
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_ac:
  dd ExceptionAC
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_mc:
  dd ExceptionMC
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_xm:
  dd ExceptionXM
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_ve:
  dd ExceptionVE
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_15:
  dd Exception15
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_16:
  dd Exception16
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_17:
  dd Exception17
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_18:
  dd Exception18
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_19:
  dd Exception19
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_1a:
  dd Exception1A
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_1b:
  dd Exception1B
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_1c:
  dd Exception1C
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_1d:
  dd Exception1D
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_sx:
  dd ExceptionSX
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.exception_1f:
  dd Exception1F
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq0:
  dd IRQ0_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq1:
  dd IRQ1_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq2:
  dd IRQ2_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq3:
  dd IRQ3_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq4:
  dd IRQ4_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq5:
  dd IRQ5_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq6:
  dd IRQ6_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq7:
  dd IRQ7_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq8:
  dd IRQ8_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq9:
  dd IRQ9_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq10:
  dd IRQ10_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq11:
  dd IRQ11_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq12:
  dd IRQ12_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq13:
  dd IRQ13_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq14:
  dd IRQ14_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.irq15:
  dd IRQ15_Handler
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL0 | ID_PRESENT
.syscall_console_out:
  dd SysCall_ConsoleOut
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL3 | ID_PRESENT
.syscall_settcb:
  dd SysCall_SetTCB
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL3 | ID_PRESENT
.syscall_setiopb:
  dd SysCall_SetIOPB
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL3 | ID_PRESENT
.syscall_wait:
  dd SysCall_Wait
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL3 | ID_PRESENT
.syscall_eoi:
  dd SysCall_EOI
  dd SELECTOR_CODE0 | ID_GATETYPE_INTR32 | ID_DPL3 | ID_PRESENT
.end:

IDTR:
.limit:
  dw (IDT.end - IDT.start - 1)
.base:
  dd IDT

;-------------------------------------------------------------------------------
; EXCEPTION HANDLERS
;-------------------------------------------------------------------------------

NO_ERROR_CODE equ 0xDEADC0DE

%macro EXCEPTION_PROLOGUE_NO_ERROR_CODE 0
  push NO_ERROR_CODE
  pusha
  xor eax, eax
  mov ax, ds
  push eax
  mov ax, es
  push eax
  mov ax, fs
  push eax
  mov ax, gs
  push eax
  mov eax, SELECTOR_DATA0
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ebp, esp
%endmacro

%macro EXCEPTION_PROLOGUE_HAS_ERROR_CODE 0
  pusha
  xor eax, eax
  mov ax, ds
  push eax
  mov ax, es
  push eax
  mov ax, fs
  push eax
  mov ax, gs
  push eax
  mov eax, SELECTOR_DATA0
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ebp, esp
%endmacro

%macro EXCEPTION_EPILOGUE 0
  pop gs
  pop fs
  pop es
  pop ds
  popa
  add esp, 4
  iret
%endmacro

section .text

; Fault
align 4
ExceptionDE:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageExceptionDE
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Fault or Trap
align 4
ExceptionDB:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageExceptionDB
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Interrupt
align 4
InterruptNMI:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageInterruptNMI
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Trap
align 4
ExceptionBP:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageExceptionBP
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Trap
align 4
ExceptionOF:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageExceptionOF
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Fault
align 4
ExceptionBR:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageExceptionBR
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Fault
align 4
ExceptionUD:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageExceptionUD
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Fault
align 4
ExceptionNM:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageExceptionNM
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Abort with Error Code
align 4
ExceptionDF:
  EXCEPTION_PROLOGUE_HAS_ERROR_CODE
.body:
  mov esi, MessageExceptionDF
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Fault
; (287 & 387 only)
align 4
ExceptionCSO:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageExceptionCSO
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Fault with Error Code
align 4
ExceptionTS:
  EXCEPTION_PROLOGUE_HAS_ERROR_CODE
.body:
  mov esi, MessageExceptionTS
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Fault with Error Code
align 4
ExceptionNP:
  EXCEPTION_PROLOGUE_HAS_ERROR_CODE
.body:
  mov esi, MessageExceptionNP
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Fault with Error Code
align 4
ExceptionSS:
  EXCEPTION_PROLOGUE_HAS_ERROR_CODE
.body:
  mov esi, MessageExceptionSS
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Fault with Error Code
align 4
ExceptionGP:
  EXCEPTION_PROLOGUE_HAS_ERROR_CODE
.body:
  mov esi, MessageExceptionGP
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Fault with Error Code
align 4
ExceptionPF:
  EXCEPTION_PROLOGUE_HAS_ERROR_CODE
.body:
  mov esi, MessageExceptionPF
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Reserved
align 4
Exception0F:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageException0F
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Fault
align 4
ExceptionMF:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageExceptionMF
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Fault with Error Code
align 4
ExceptionAC:
  EXCEPTION_PROLOGUE_HAS_ERROR_CODE
.body:
  mov esi, MessageExceptionAC
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Abort
align 4
ExceptionMC:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageExceptionMC
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Fault
align 4
ExceptionXM:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageExceptionXM
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Fault
align 4
ExceptionVE:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageExceptionVE
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Reserved
align 4
Exception15:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageException15
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Reserved
align 4
Exception16:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageException16
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Reserved
align 4
Exception17:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageException17
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Reserved
align 4
Exception18:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageException18
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Reserved
align 4
Exception19:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageException19
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Reserved
align 4
Exception1A:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageException1A
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Reserved
align 4
Exception1B:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageException1B
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Reserved
align 4
Exception1C:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageException1C
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Reserved
align 4
Exception1D:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageException1D
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Unknown with Error Code
align 4
ExceptionSX:
  EXCEPTION_PROLOGUE_HAS_ERROR_CODE
.body:
  mov esi, MessageExceptionSX
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

; Reserved
align 4
Exception1F:
  EXCEPTION_PROLOGUE_NO_ERROR_CODE
.body:
  mov esi, MessageException1F
  jmp Panic
.epilogue:
  EXCEPTION_EPILOGUE

section .data

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
; SCHEDULING
;-------------------------------------------------------------------------------

%macro SCHEDULER_PROLOGUE 0
  pusha
  xor eax, eax
  mov ax, ds
  push eax
  mov ax, es
  push eax
  mov ax, fs
  push eax
  mov ax, gs
  push eax
  mov eax, SELECTOR_DATA0
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ebp, esp
%endmacro

%macro SCHEDULER_SAVESTATE 0
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
  mov eax, [ebp+12]
  mov [ebx+TCB_DS], eax
  mov eax, [ebp+8]
  mov [ebx+TCB_ES], eax
  mov eax, [ebp+4]
  mov [ebx+TCB_FS], eax
  mov eax, [ebp+0]
  mov [ebx+TCB_GS], eax
  mov eax, [ebp+44]
  mov [ebx+TCB_EAX], eax
  mov eax, [ebp+40]
  mov [ebx+TCB_ECX], eax
  mov eax, [ebp+36]
  mov [ebx+TCB_EDX], eax
  mov eax, [ebp+32]
  mov [ebx+TCB_EBX], eax
  mov eax, [ebp+24]
  mov [ebx+TCB_EBP], eax
  mov eax, [ebp+20]
  mov [ebx+TCB_ESI], eax
  mov eax, [ebp+16]
  mov [ebx+TCB_EDI], eax
%endmacro

%macro SCHEDULER_SELECTTHREAD 1
  mov [CurrentThread], %1
  mov dword [%1+TCB_STATE], THREAD_RUNNING
%endmacro

%macro SCHEDULER_NEXTTHREAD 0
  %%next_thread:
    mov ebx, [ebx+TCB_NEXT]
    mov eax, [ebx+TCB_STATE]
    cmp eax, THREAD_RUNNING
    jne %%next_thread
    mov [CurrentThread], ebx
%endmacro

%macro SCHEDULER_SWITCHTASK 0
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
  mov [ebp+12], eax
  mov eax, [ebx+TCB_ES]
  mov [ebp+8], eax
  mov eax, [ebx+TCB_FS]
  mov [ebp+4], eax
  mov eax, [ebx+TCB_GS]
  mov [ebp+0], eax
  mov eax, [ebx+TCB_EAX]
  mov [ebp+44], eax
  mov eax, [ebx+TCB_ECX]
  mov [ebp+40], eax
  mov eax, [ebx+TCB_EDX]
  mov [ebp+36], eax
  mov eax, [ebx+TCB_EBX]
  mov [ebp+32], eax
  mov eax, [ebx+TCB_EBP]
  mov [ebp+24], eax
  mov eax, [ebx+TCB_ESI]
  mov [ebp+20], eax
  mov eax, [ebx+TCB_EDI]
  mov [ebp+16], eax
%endmacro

%macro SCHEDULER_EPILOGUE 0
  pop gs
  pop fs
  pop es
  pop ds
  popa
  iret
%endmacro

;-------------------------------------------------------------------------------
; INTERRUPT HANDLERS
;-------------------------------------------------------------------------------

section .text

;
; IRQ0_Handler - Programmable Interval Timer
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
IRQ0_Handler:
.prologue:
  SCHEDULER_PROLOGUE
.body:
  mov al, 0
  call DebugIRQ
  SCHEDULER_SAVESTATE
  SCHEDULER_NEXTTHREAD
  call DebugThread
  SCHEDULER_SWITCHTASK
.eoi:
  mov al, PIC_CMD_SPECIFIC_EOI | PIC_SEOI_LVL0
  out PORT_PIC_MASTER_CMD, al
  ;in al, PORT_KEYB_DATA
  ;mov al, PIC_CMD_SPECIFIC_EOI | PIC_SEOI_LVL1
  ;out PORT_PIC_MASTER_CMD, al
.epilogue:
  SCHEDULER_EPILOGUE

;
; IRQ1_Handler - Keyboard Controller
;
; Reflected back to user mode.
;
; FIXME:
;
; - Does not schedule the thread immediately.
;
align 4
IRQ1_Handler:
.prologue:
  SCHEDULER_PROLOGUE
.body:
  mov al, 1
  call DebugIRQ
  SCHEDULER_SAVESTATE
  mov ebx, [NotificationQueue+4*1]
  or ebx, ebx
  jz .no_user_handler_waiting
  xor eax, eax
  mov [NotificationQueue+4*1], eax
  mov dword [ebx+TCB_STATE], THREAD_RUNNING
  SCHEDULER_SELECTTHREAD ebx
  SCHEDULER_SWITCHTASK
.epilogue:
  SCHEDULER_EPILOGUE
.no_user_handler_waiting:
  mov eax, [NotificationState+4*1]
  or eax, eax
  jnz .double_irq
  inc eax
  mov dword [NotificationState+4*1], eax
  jmp .epilogue
.double_irq:
  mov esi, .double_irq_message
  call PrintString
  call HaltSystem
.double_irq_message:
  db 'DOUBLE IRQ1',CR,LF,0

; Interrupt
align 4
IRQ2_Handler:
  pusha
.body:
  mov al, 2
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  mov esi, .message
  call PrintString
  jmp HaltSystem
  popa
  iret
.message:
  db 'UNEXPECTED IRQ2!',CR,LF,0

; Interrupt
align 4
IRQ3_Handler:
  pusha
.body:
  mov al, 3
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  mov esi, .message
  call PrintString
  jmp HaltSystem
  popa
  iret
.message:
  db 'UNEXPECTED IRQ3!',CR,LF,0

; Interrupt
align 4
IRQ4_Handler:
  pusha
.body:
  mov al, 4
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  mov esi, .message
  call PrintString
  jmp HaltSystem
  popa
  iret
.message:
  db 'UNEXPECTED IRQ4!',CR,LF,0

; Interrupt
align 4
IRQ5_Handler:
  pusha
.body:
  mov al, 5
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  mov esi, .message
  call PrintString
  jmp HaltSystem
  popa
  iret
.message:
  db 'UNEXPECTED IRQ5!',CR,LF,0

; Interrupt
align 4
IRQ6_Handler:
  pusha
.body:
  mov al, 6
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  mov esi, .message
  call PrintString
  jmp HaltSystem
  popa
  iret
.message:
  db 'UNEXPECTED IRQ6!',CR,LF,0

; Interrupt
align 4
IRQ7_Handler:
  pusha
.body:
  mov al, 7
  call DebugIRQ
  mov al, PIC_CMD_SPECIFIC_EOI | PIC_SEOI_LVL7
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  mov esi, .message
  call PrintString
  ;jmp HaltSystem
  popa
  iret
.message:
  db '### IRQ7! ###',CR,LF,0

; Interrupt
align 4
IRQ8_Handler:
  pusha
.body:
  mov al, 8
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  mov esi, .message
  call PrintString
  jmp HaltSystem
  popa
  iret
.message:
  db 'UNEXPECTED IRQ8!',CR,LF,0

; Interrupt
align 4
IRQ9_Handler:
  pusha
.body:
  mov al, 9
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  mov esi, .message
  call PrintString
  jmp HaltSystem
  popa
  iret
.message:
  db 'UNEXPECTED IRQ9!',CR,LF,0

; Interrupt
align 4
IRQ10_Handler:
  pusha
.body:
  mov al, 10
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  mov esi, .message
  call PrintString
  jmp HaltSystem
  popa
  iret
.message:
  db 'UNEXPECTED IRQ10!',CR,LF,0

; Interrupt
align 4
IRQ11_Handler:
  pusha
.body:
  mov al, 11
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  mov esi, .message
  call PrintString
  jmp HaltSystem
  popa
  iret
.message:
  db 'UNEXPECTED IRQ11!',CR,LF,0

; Interrupt
align 4
IRQ12_Handler:
  pusha
.body:
  mov al, 12
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  mov esi, .message
  call PrintString
  jmp HaltSystem
  popa
  iret
.message:
  db 'UNEXPECTED IRQ12!',CR,LF,0

; Interrupt
align 4
IRQ13_Handler:
  pusha
.body:
  mov al, 13
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  mov esi, .message
  call PrintString
  jmp HaltSystem
  popa
  iret
.message:
  db 'UNEXPECTED IRQ13!',CR,LF,0

; Interrupt
align 4
IRQ14_Handler:
  pusha
.body:
  mov al, 14
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  mov esi, .message
  call PrintString
  jmp HaltSystem
  popa
  iret
.message:
  db 'UNEXPECTED IRQ14!',CR,LF,0

; Interrupt
align 4
IRQ15_Handler:
  pusha
.body:
  mov al, 15
  call DebugIRQ
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_SLAVE_CMD, al
  out PORT_PIC_MASTER_CMD, al
.epilogue:
  mov esi, .message
  call PrintString
  jmp HaltSystem
  popa
  iret
.message:
  db 'UNEXPECTED IRQ15!',CR,LF,0

;-------------------------------------------------------------------------------
; SYSTEM CALLS
;-------------------------------------------------------------------------------

section .text

; Syscall
align 4
SysCall_ConsoleOut:
  pusha
.body:
  call ConsoleOut
.epilogue:
  popa
  iret

; Syscall
align 4
SysCall_SetTCB:
  pusha
.body:
  mov edx, TCB_SIZE
  mul edx
  add eax, TCB
  mov [eax+TCB_EIP], ecx
  mov [eax+TCB_ESP], ebx
  mov dword [eax+TCB_CS], SELECTOR_CODE3 | 3
  mov dword [eax+TCB_DS], SELECTOR_DATA3 | 3
  mov dword [eax+TCB_ES], SELECTOR_DATA3 | 3
  mov dword [eax+TCB_FS], SELECTOR_DATA3 | 3
  mov dword [eax+TCB_GS], SELECTOR_DATA3 | 3
  mov dword [eax+TCB_SS], SELECTOR_DATA3 | 3
  mov dword [eax+TCB_STATE], THREAD_RUNNING
.epilogue:
  popa
  iret

; Syscall
align 4
SysCall_SetIOPB:
  pusha
.body:
  mov [TSS.iopb+4*eax], edx
.epilogue:
  popa
  iret

;
; SysCall_Wait - Wait on a Notification
;
; Calling Registers:
;
;   ECX   Notification/IRQ#
;
; State Diagram:
;
;   IDLE -> WAITING
;   ACTIVE -> IDLE
;   WAITING -> WAITING
;
align 4
SysCall_Wait:
.prologue:
  SCHEDULER_PROLOGUE
.body:
  mov eax, [NotificationState+4*ecx]
  cmp eax, NOTIFICATION_ACTIVE
  jne .not_active
.active:
  mov eax, NOTIFICATION_IDLE
  mov dword [NotificationState+4*ecx], eax
  jmp .epilogue
.not_active:
  SCHEDULER_SAVESTATE
  mov ebx, [CurrentThread]
  mov eax, [NotificationQueue+4*ecx]
  or eax, eax
  jnz .error_double_wait
  mov [NotificationQueue+4*ecx], ebx
  mov dword [ebx+TCB_STATE], THREAD_BLOCKED
  SCHEDULER_NEXTTHREAD
  SCHEDULER_SWITCHTASK
.epilogue:
  SCHEDULER_EPILOGUE
.error_double_wait:
  mov esi, Message_DoubleWait
  call PrintString
  call HaltSystem

section .data

Message_DoubleWait:
  db 'DOUBLE WAIT',CR,LF,0

section .text

;
; SysCall_EOI
;
; Calling Registers:
;
;    CL   IRQ#
;
; FIXME:
;
; - Slave PIC
;
align 4
SysCall_EOI:
  pusha
  and cl, 0x07
  mov al, PIC_CMD_SPECIFIC_EOI
  or al, cl
  out PORT_PIC_MASTER_CMD, al
  popa
  iret

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
  push dword [ebp+16] ; EDI
  push dword [ebp+20] ; ESI
  push dword [ebp+24] ; EBP
  push dword [ebp+28] ; ESP
  push dword [ebp+32] ; EBX
  push dword [ebp+36] ; EDX
  push dword [ebp+40] ; ECX
  push dword [ebp+44] ; EAX
  push dword [ebp+0]  ; GS
  push dword [ebp+4]  ; FS
  push dword [ebp+8]  ; ES
  push dword [ebp+12] ; DS
  mov eax, cr2
  push eax
  push dword [ebp+48] ; ERROR CODE
  push dword [ebp+52] ; EIP
  push dword [ebp+56] ; CS
  push dword [ebp+60] ; EFLAGS
  push dword [ebp+64] ; ESP
  push dword [ebp+68] ; SS
  push esi
  mov esi, MessagePanic
  call PrintFormatted
  jmp HaltSystem

section .data

MessagePanic:
  db CR,LF
  db '! EXCEPTION %s',CR,LF
  db '!  SS=%h  ESP=%h             EFLAGS=%h',CR,LF
  db '!  CS=%h  EIP=%h  ERR=%h  CR2=%h',CR,LF
  db '!  DS=%h   ES=%h   FS=%h   GS=%h',CR,LF
  db '! EAX=%h  ECX=%h  EDX=%h  EBX=%h',CR,LF
  db '! ESP=%h  EBP=%h  ESI=%h  EDI=%h',CR,LF
  db 0

section .text

;
; DebugIRQ
;
; Calling Regsiters:
;
;   EBX = thread
;
DebugThread:
  pusha
  sub ebx, TCB.start
  shr ebx, 7
  add bl, 'A'
  mov [CONSOLE_FRAMEBUFFER+CONSOLE_ROWS*CONSOLE_COLS*2], bl
  popa
  ret

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
  inc byte [CONSOLE_FRAMEBUFFER+2*ebx+128+CONSOLE_ROWS*CONSOLE_COLS*2]
  popa
  ret

;-------------------------------------------------------------------------------
; CONSOLE
;-------------------------------------------------------------------------------

CONSOLE_FRAMEBUFFER equ 0xC00B8000

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
  rep movsb
  mov esi, eax
  mov ax, 0x0700 ; FIXME: ConsoleAttr
  mov ecx, CONSOLE_COLS
  mov edi, CONSOLE_FRAMEBUFFER+2*CONSOLE_COLS*(CONSOLE_ROWS-1)
  rep stosw
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
ConsoleCursorRow  dd CONSOLE_ROWS - 1
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
