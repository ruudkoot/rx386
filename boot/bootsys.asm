;
; BOOT.SYS
;

[bits 16]
[cpu 8086]
[org 0x0600]

  jmp 0000:Main

          db 0
Signature db 'RX/386 BOOT LOADER ',__UTC_DATE__,' ',__UTC_TIME__,13,10
Copyright db 'Copyright (c) 2021, Ruud Koot',13,10,0

Main:
.setup_registers:
  cli
  cld
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  xor sp, sp
.setup_interrupt_vectors:
  mov word [Int00Off], Interrupt00
  mov [Int00Seg], ax
  mov word [Int01Off], Interrupt01
  mov [Int01Seg], ax
  mov word [Int02Off], Interrupt02
  mov [Int02Seg], ax
  mov word [Int03Off], Interrupt03
  mov [Int03Seg], ax
  mov word [Int04Off], Interrupt04
  mov [Int04Seg], ax
  ; mov word [Int05Off], Interrupt05
  ; mov [Int05Seg], ax
  mov word [Int06Off], Interrupt06
  mov [Int06Seg], ax
  mov word [Int07Off], Interrupt07
  mov [Int07Seg], ax
  sti
.print_signature:
  mov si, Signature
  call PrintString
.setup_disk_parameter_block:
  call DiskInit
  call DiskPrint
.done:
  call HaltSystem

;-------------------------------------------------------------------------------
; BASIC INPUT/OUTPUT
;-------------------------------------------------------------------------------

;
; Read charater from keyboard
;
ConsoleIn:
  call NotImplemented

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

;
; Send character to printer
;
PrinterOut:
  call NotImplemented

;
; Get character from serial port
;
AuxIn:
  call NotImplemented

;
; Send character to serial port
;
AuxOut:
  call NotImplemented

;
; Read sector from disk
;
;   DX = logical sector
;   DS:BX = data buffer
;
DiskRead:
  call NotImplemented

;
; Write sector to disk
;
DiskWrite:
  call NotImplemented

;-------------------------------------------------------------------------------
; UTILITIES
;-------------------------------------------------------------------------------

;
; DiskInit
;
DiskInit:
  push ax
  mov ax, [BpbPhysicalUnit]
  mov [DiskBiosDriveNumber], ax
  mov ax, [BpbNumberOfHeads]
  mov [DiskNumberOfHeads], ax
  mov ax, [BpbSectorsPerTrack]
  mov [DiskSectorsPerTrack], ax
  mov ax, [BpbBytesPerSector]
  mov [DiskBytesPerSector], ax
  pop ax
  ret

;
; DiskPrint
;
DiskPrint:
  push si
  push word [DiskBytesPerSector]
  push word [DiskSectorsPerTrack]
  push word [DiskNumberOfHeads]
  push word [DiskBiosDriveNumber]
  mov si, MessageDiskParameters
  call PrintFormatted
  add sp, 8
  pop si
  ret

;
; HaltSystem
;
HaltSystem:
  mov si, MessageSystemHalted
  call PrintString
.next:
  jmp .next

;
; Not imlemented
;
NotImplemented:
  mov si, MessageNotImplemented
  call PrintString
  call HaltSystem

;
; PrintDecimal
;
;   AX = number
;
PrintDecimal:
  push ax
  push cx
  push dx
  xor dx, dx
  mov cx, 10000
  div cx
  or al, al
  jz .digit4
  add al, '0'
  call ConsoleOut
.digit4:
  xor ax, ax
  xchg ax, dx
  mov cx, 1000
  div cx
  or al, al
  jz .digit3
  add al, '0'
  call ConsoleOut
.digit3:
  xor ax, ax
  xchg ax, dx
  mov cx, 100
  div cx
  or al, al
  jz .digit2
  add al, '0'
  call ConsoleOut
.digit2:
  xor ax, ax
  xchg ax, dx
  mov cx, 10
  div cx
  or al, al
  jz .digit1
  add al, '0'
  call ConsoleOut
.digit1:
  xchg ax, dx
  add al, '0'
  call ConsoleOut
  pop dx
  pop cx
  pop ax
  ret

;
; PrintHex
;
;   AX = number
;
PrintHex:
  push ax
  push cx
  push dx
  push bx
  mov bx, HexDigits
  xor dx, dx
  mov cx, 0x1000
  div cx
  xlat
  call ConsoleOut
  xor ax, ax
  xchg ax, dx
  mov cx, 0x100
  div cx
  xlat
  call ConsoleOut
  xor ax, ax
  xchg ax, dx
  mov cx, 0x10
  div cx
  xlat
  call ConsoleOut
  xchg ax, dx
  xlat
  call ConsoleOut
  pop bx
  pop dx
  pop cx
  pop ax
  ret

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

;
; PrintFormatted
;
PrintFormatted:
  push bp
  mov bp, sp
  add bp, 2
  push ax
  push cx
  push dx
  push bx
  push si
  push di
.next:
  mov al, [si]
  inc si
  or al, al
  jz .break
  cmp al, '%'
  jnz .printchar
  mov al, [si]
  inc si
  add bp, 2
.testd:
  cmp al, 'd'
  jnz .testh
  mov ax, [bp]
  call PrintDecimal
  jmp .next
.testh:
  cmp al, 'h'
  jnz .next
  mov ax, [bp]
  call PrintHex
  jmp .next
.printchar:
  call ConsoleOut
  jmp .next
.break:
  pop di
  pop si
  pop bx
  pop dx
  pop cx
  pop ax
  pop bp
  ret

;-------------------------------------------------------------------------------
; DISK OPERATIONS
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; INTERRUPT HANDLERS
;-------------------------------------------------------------------------------

Interrupt00:
  push ax
  push cx
  push dx
  push bx
  push bp
  push si
  push di
  mov si, MessageDivisionByZero
  call PrintString
  call HaltSystem
  pop di
  pop si
  pop bp
  pop bx
  pop dx
  pop cx
  pop ax
  iret

Interrupt01:
  push ax
  push cx
  push dx
  push bx
  push bp
  push si
  push di
  mov si, MessageSingleStep
  call PrintString
  call HaltSystem
  pop di
  pop si
  pop bp
  pop bx
  pop dx
  pop cx
  pop ax
  iret

Interrupt02:
  push ax
  push cx
  push dx
  push bx
  push bp
  push si
  push di
  mov si, MessageNonMaskableInterrupt
  call PrintString
  call HaltSystem
  pop di
  pop si
  pop bp
  pop bx
  pop dx
  pop cx
  pop ax
  iret

Interrupt03:
  push ax
  push cx
  push dx
  push bx
  push bp
  push si
  push di
  mov si, MessageBreakPoint
  call PrintString
  call HaltSystem
  pop di
  pop si
  pop bp
  pop bx
  pop dx
  pop cx
  pop ax
  iret

Interrupt04:
  push ax
  push cx
  push dx
  push bx
  push bp
  push si
  push di
  mov si, MessageArithmeticOverflow
  call PrintString
  call HaltSystem
  pop di
  pop si
  pop bp
  pop bx
  pop dx
  pop cx
  pop ax
  iret

Interrupt06:
  push ax
  push cx
  push dx
  push bx
  push bp
  push si
  push di
  mov si, MessageUndefinedInstruction
  call PrintString
  call HaltSystem
  pop di
  pop si
  pop bp
  pop bx
  pop dx
  pop cx
  pop ax
  iret

Interrupt07:
  push ax
  push cx
  push dx
  push bx
  push bp
  push si
  push di
  mov si, MessageNoCoprocessor
  call PrintString
  call HaltSystem
  pop di
  pop si
  pop bp
  pop bx
  pop dx
  pop cx
  pop ax
  iret

InterruptReturn:
  iret

;-------------------------------------------------------------------------------
; DATA
;-------------------------------------------------------------------------------

HexDigits:
  db '0123456789ABCDEF'

;-------------------------------------------------------------------------------
; MESSAGES
;-------------------------------------------------------------------------------

MessageArithmeticOverflow:
  db 'ARITHMETIC OVERFLOW',13,10,0

MessageBreakPoint:
  db 'BREAKPOINT',13,10,0

MessageDiskParameters:
  db 'Boot device %h (%d Heads, %d Sectors/Track, %d Bytes/Sector)',13,10,0

MessageDivisionByZero:
  db 'DIVISION BY ZERO',13,10,0

MessageNonMaskableInterrupt:
  db 'NON-MASKABLE INTERRUPT',13,10,0

MessageNoCoprocessor:
  db 'NO COPROCESSOR',13,10,0

MessageNotImplemented:
  db 'OPERATION NOT IMPLEMENTED',13,10,0

MessageSingleStep:
  db 'SINGLE STEP',13,10,0

MessageSystemHalted:
  db 'SYSTEM HALTED!',13,10,0

MessageUndefinedInstruction:
  db 'UNDEFINED INSTRUCTION',13,10,0

;-------------------------------------------------------------------------------
; BLOCK STARTING SYMBOL
;-------------------------------------------------------------------------------

section .bss
  DiskBiosDriveNumber resw 1
  DiskNumberOfHeads resw 1
  DiskSectorsPerTrack resw 1
  DiskBytesPerSector resw 1

;-------------------------------------------------------------------------------
; ABSOLUTE
;-------------------------------------------------------------------------------

absolute 0x0000
  Int00Off resw 1
  Int00Seg resw 1
  Int01Off resw 1
  Int01Seg resw 1
  Int02Off resw 1
  Int02Seg resw 1
  Int03Off resw 1
  Int03Seg resw 1
  Int04Off resw 1
  Int04Seg resw 1
  Int05Off resw 1
  Int05Seg resw 1
  Int06Off resw 1
  Int06Seg resw 1
  Int07Off resw 1
  Int07Seg resw 1
  InterruptVectors resd (256-8)
  BiosDataArea resb 256
  DosCommunicationArea resb 256

absolute 0x7c00
  BpbJump                   resb 3
  BpbSystemName             resb 8
  BpbBytesPerSector         resw 1
  BpbSectorsPerCluster      resb 1
  BpbReservedSectors        resw 1
  BpbNumberOfFATs           resb 1
  BpbRootDirectoryEntries   resw 1
  BpbTotalNumberOfSectors   resw 1
  BpbMediaDescriptor        resb 1
  BpbSectorsPerFAT          resw 1
  BpbSectorsPerTrack        resw 1
  BpbNumberOfHeads          resw 1
  BpbHiddenSectors          resd 1
  BpbTotalNumberOfSectors2  resd 1
  BpbPhysicalUnit           resb 1
  BpbReserved               resb 1
  BpbMagicNumber            resb 1
  BpbVolumeSerialNumber     resd 1
  BpbVolumeLabel            resb 11
  BpbFileSystem             resb 8
; BpbBootCode
; BpbSignature