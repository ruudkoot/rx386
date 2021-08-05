;
; DEBUG_IRQ
;
; Calling Regsiters:
;
;   %1 = irq
;
%macro DEBUG_IRQ 1
  inc byte [CONSOLE_FRAMEBUFFER+2*%1+128+CONSOLE_ROWS*CONSOLE_COLS*2]
%endmacro

;
; DEBUG_THREAD
;
; Calling Regsiters:
;
;   %1 = thread
;
%macro DEBUG_THREAD 2
  push %1
  sub %1, TCB.start
  shr %1, 7
  add %1, 'A'
  mov [CONSOLE_FRAMEBUFFER+CONSOLE_ROWS*CONSOLE_COLS*2], %2
  pop %1
%endmacro