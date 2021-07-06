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