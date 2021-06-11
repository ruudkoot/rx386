;
; KERNEL.SYS
;

[bits 32]
[cpu 386]
[org 0x80010000]

section .text

  jmp Main

          db 0
Signature db CR,LF,'RX/386 KERNEL ',__UTC_DATE__,' ',__UTC_TIME__,CR,LF
Copyright db 'Copyright (c) 2021, Ruud Koot <inbox@ruudkoot.nl>',CR,LF,0

Main:
  mov esi, Signature
  call PrintString
  cli
  hlt

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

ConsoleCursorCol  dd 0
ConsoleCursorRow  dd 24
ConsoleAttr       dd 0x07
