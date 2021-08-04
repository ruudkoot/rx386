;
; DebugIRQ
;
; Calling Regsiters:
;
;   %1 = irq
;
%macro DEBUG_IRQ 1
  inc byte [CONSOLE_FRAMEBUFFER+2*%1+128+CONSOLE_ROWS*CONSOLE_COLS*2]
%endmacro
