;
; KERNEL.SYS
;

[bits 32]
[cpu 386]
[org 0x80010000]

  jmp Main

          db 0
Signature db 13,10,'RX/386 KERNEL ',__UTC_DATE__,' ',__UTC_TIME__,13,10
Copyright db 'Copyright (c) 2021, Ruud Koot <inbox@ruudkoot.nl>',13,10,0

Main:
  cli
  hlt
