;
; KERNEL.SYS
;

KERNEL_BASE equ 0x80010000

%define LOW_WORD(lbl) ((lbl - KERNEL_START + KERNEL_BASE) & 0xffff)
%define HIGH_WORD(lbl) (((lbl - KERNEL_START + KERNEL_BASE) >> 16) & 0xffff)

cpu   386
bits  32
org   KERNEL_BASE

section .text

KERNEL_START:
  jmp Main

          db 0
Signature db CR,LF,'RX/386 KERNEL ',__UTC_DATE__,' ',__UTC_TIME__,CR,LF
Copyright db 'Copyright (c) 2021, Ruud Koot <inbox@ruudkoot.nl>',CR,LF,0

Main:
  mov esi, Signature
  call PrintString
  lidt [IDTR]
  jmp HaltSystem

;-------------------------------------------------------------------------------
; SEGMENTS
;-------------------------------------------------------------------------------

;SELECTOR_NULL   equ GDT.null - GDT.start
;SELECTOR_CODE0  equ GDT.code0 - GDT.start
;SELECTOR_DATA0  equ GDT.data0 - GDT.start

SELECTOR_NULL   equ 0x0000
SELECTOR_CODE0  equ 0x0008
SELECTOR_DATA0  equ 0x0010

;-------------------------------------------------------------------------------
; INTERRUPTS
;-------------------------------------------------------------------------------

section .text

; Fault
align 4
ExceptionDE:
  jmp HaltSystem

; Fault or Trap
align 4
ExceptionDB:
  jmp HaltSystem

; Interrupt
align 4
InterruptNMI:
  mov esi, MessageInterruptNMI
  call PrintString
  jmp HaltSystem

; Trap
align 4
ExceptionBP:
  jmp HaltSystem

; Trap
align 4
ExceptionOF:
  jmp HaltSystem

; Fault
align 4
ExceptionBR:
  jmp HaltSystem

; Fault
align 4
ExceptionUD:
  jmp HaltSystem

; Fault
align 4
ExceptionNM:
  jmp HaltSystem

; Abort with Error Code
align 4
ExceptionDF:
  jmp HaltSystem

; Fault
; (287 & 387 only)
align 4
ExceptionCSO:
  jmp HaltSystem

; Fault with Error Code
align 4
ExceptionTS:
  jmp HaltSystem

; Fault with Error Code
align 4
ExceptionNP:
  jmp HaltSystem

; Fault with Error Code
align 4
ExceptionSS:
  jmp HaltSystem

; Fault with Error Code
align 4
ExceptionGP:
  jmp HaltSystem

; Fault with Error Code
align 4
ExceptionPF:
  jmp HaltSystem

; Reserved
align 4
Exception0F:
  jmp HaltSystem

; Fault
align 4
ExceptionMF:
  jmp HaltSystem

; Fault with Error Code
align 4
ExceptionAC:
  jmp HaltSystem

; Abort
align 4
ExceptionMC:
  jmp HaltSystem

; Fault
align 4
ExceptionXM:
  jmp HaltSystem

; Fault
align 4
ExceptionVE:
  jmp HaltSystem

; Reserved
align 4
Exception15:
  jmp HaltSystem

; Reserved
align 4
Exception16:
  jmp HaltSystem

; Reserved
align 4
Exception17:
  jmp HaltSystem

; Reserved
align 4
Exception18:
  jmp HaltSystem

; Reserved
align 4
Exception19:
  jmp HaltSystem

; Reserved
align 4
Exception1A:
  jmp HaltSystem

; Reserved
align 4
Exception1B:
  jmp HaltSystem

; Reserved
align 4
Exception1C:
  jmp HaltSystem

; Reserved
align 4
Exception1D:
  jmp HaltSystem

; Unknown with Error Code
align 4
ExceptionSX:
  jmp HaltSystem

; Reserved
align 4
Exception1F:
  jmp HaltSystem

; Interrupt
align 4
IRQ0:
  jmp HaltSystem

; Interrupt
align 4
IRQ1:
  jmp HaltSystem

; Interrupt
align 4
IRQ2:
  jmp HaltSystem

; Interrupt
align 4
IRQ3:
  jmp HaltSystem

; Interrupt
align 4
IRQ4:
  jmp HaltSystem

; Interrupt
align 4
IRQ5:
  jmp HaltSystem

; Interrupt
align 4
IRQ6:
  jmp HaltSystem

; Interrupt
align 4
IRQ7:
  jmp HaltSystem

; Interrupt
align 4
IRQ8:
  jmp HaltSystem

; Interrupt
align 4
IRQ9:
  jmp HaltSystem

; Interrupt
align 4
IRQ10:
  jmp HaltSystem

; Interrupt
align 4
IRQ11:
  jmp HaltSystem

; Interrupt
align 4
IRQ12:
  jmp HaltSystem

; Interrupt
align 4
IRQ13:
  jmp HaltSystem

; Interrupt
align 4
IRQ14:
  jmp HaltSystem

; Interrupt
align 4
IRQ15:
  jmp HaltSystem

section .data

ID_GATETYPE_TASK32  equ 0x05
ID_GATETYPE_INTR16  equ 0x06
ID_GATETYPE_TRAP16  equ 0x07
ID_GATETYPE_INTR32  equ 0x0E
ID_GATETYPE_TRAP32  equ 0x0F
ID_STORAGE_SEGMENT  equ 0x10
ID_DPL0             equ 0x00
ID_DPL1             equ 0x20
ID_DPL2             equ 0x40
ID_DPL3             equ 0x60
ID_PRESENT          equ 0x80

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

;
; Panic
;
Panic:
  jmp HaltSystem

section .data

MessageSystemHalted:
  db 'SYSTEM HALTED!',13,10,0

;-------------------------------------------------------------------------------
; CONSOLE
;-------------------------------------------------------------------------------

NUL equ 0
BEL equ 7
BS  equ 8
HT  equ 9
LF  equ 10
VT  equ 11
FF  equ 12
CR  equ 13
ESC equ 27

CONSOLE_FRAMEBUFFER equ 0x800b8000
CONSOLE_COLS        equ 80
CONSOLE_ROWS        equ 25
CONSOLE_TABS        equ 8

PORT_CRTC_INDEX  equ 0x3d4
PORT_CRTC_DATA   equ 0x3d5

CRTC_HORIZONTAL_TOTAL         equ 0
CRTC_HORIZONTAL_DISPLAYED     equ 1
CRTC_H_SYNC_POSITION          equ 2
CRTC_SYNC_WIDTH               equ 3
CRTC_VERTICAL_TOTAL           equ 4
CRTC_V_TOTAL_ADJUST           equ 5
CRTC_VERTICAL_DISPLAYED       equ 6
CRTC_V_SYNC_POSITION          equ 7
CRTC_INTERLACE_MODE_AND_SKEW  equ 8
CRTC_MAX_SCAN_LINE_ADDRESS    equ 9
CRTC_CURSOR_START             equ 10
CRTC_CURSOR_END               equ 11
CRTC_START_ADDRESS_HIGH       equ 12
CRTC_START_ADDRESS_LOW        equ 13
CRTC_CURSOR_HIGH              equ 14
CRTC_CURSOR_LOW               equ 15
CRTC_LIGHT_PEN_HIGH           equ 16
CRTC_LIGHT_PEN_LOW            equ 17

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
.loop_exit:
  add esp, 20
  popa
  ret

section .data

HexDigits db '0123456789ABCDEF'