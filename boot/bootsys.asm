;
; BOOT.SYS
;

[bits 16]
[cpu 8086]
[org 0x0600]

ROOT_DIRECTORY_CLUSTER equ 1

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
  call FatInit
  call FatPrint
.detect_cpu:
  call CpuDetect
  call FpuDetect
  call CpuFpuPrint
.detect_memory:
.load_kernel:
  mov ax, ROOT_DIRECTORY_CLUSTER
  call DirectoryOpen
  mov si, FileNameKernelSys
  call DirectorySearch
  jc .kernel_sys_not_found
.enter_protected_mode:
.done:
  call HaltSystem
.kernel_sys_not_found:
  mov si, MessageKernelSysNotFound
  call PrintString
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

FatInit:
  push ax
  push cx
  push dx
  push bx
  mov bl, [BpbSectorsPerCluster]
  xor bh, bh
  mov [FatSectorsPerCluster], bx
  mov bx, [BpbReservedSectors]
  mov [FatFirstFileAllocationTableSector], bx
  mov al, [BpbNumberOfFATs]
  xor ah, ah
  mov cx, [BpbSectorsPerFAT]
  mul cx
  add bx, ax
  mov [FatFirstRootDirectorySector], bx
  mov ax, [BpbRootDirectoryEntries]
  mov cl, 5
  shl ax, cl
  mov cx, [DiskBytesPerSector]
  xor dx, dx
  div cx
  add bx, ax
  mov [FatFirstDataAreaSector], bx
  pop bx
  pop dx
  pop cx
  pop ax
  ret

FatPrint:
  push si
  push word [FatFirstDataAreaSector]
  push word [FatFirstRootDirectorySector]
  push word [FatFirstFileAllocationTableSector]
  push word [FatSectorsPerCluster]
  mov si, MessageFatParameters
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
  hlt
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
  jnz .tests
  mov ax, [bp]
  call PrintHex
  jmp .next
.tests:
  cmp al, 's'
  jnz .next
  mov di, [bp]
  xchg si, di
  call PrintString
  xchg si, di
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

;
; FatClusterToSector
;
FatClusterToSector:
  push dx
  cmp ax, 1
  je .is_root_directory
  mov dx, [FatSectorsPerCluster]
  mul dx
  add ax, [FatFirstDataAreaSector]
  jmp .done
.is_root_directory:
  mov ax, [FatFirstRootDirectorySector]
.done:
  pop dx
  ret

;
; DirectoryOpen
;
;   AX = cluster
;
DirectoryOpen:
  call FatClusterToSector
  mov [DirectoryCurrentSector], ax
  ret

;
; DirectorySearch
;
;   SI = file name
;
DirectorySearch:
  stc
  ret

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
; CPU DETECTION
;-------------------------------------------------------------------------------

CPU_8086 equ 1
CPU_80286 equ 2
CPU_80386 equ 3
CPU_80486 equ 4

FPU_NOT_PRESENT equ 0
FPU_8087 equ 1
FPU_80287 equ 2
FPU_80387 equ 3

;
; CpuDetect - Detect the CPU
;
; Parameters:
;
;   none
;
; Returns:
;
;   AH = detected CPU
;     1 = 8088/8086/80186
;     2 = 80286
;     3 = 80386
;     4 = 80486 or higher
;   AL = reserved for subtype
;
CpuDetect:
  push dx
  push bx
  pushf
  pop bx
  cli
.test_8086_or_80286:
  ; The 8088/8086 will decrement SP before pushing it to the stack. The 80286
  ; and higher will push SP to the stack before decrementing it.
  push sp
  pop ax
  cmp ax, sp
  je .test_80286_or_80386
  mov ah, CPU_8086
  jmp .done
.test_80286_or_80386:
  ; The 80386 and higher have the IOPL bits in the FLAGS register. The 80286
  ; does not allow them to be set.
  pushf
  pop ax
  or ax, 0x3000
  push ax
  popf
  pushf
  pop ax
  test ax, 0x3000
  jnz .test_80386_or_80486
  mov ah, CPU_80286
  jmp .done
.test_80386_or_80486:
[cpu 386]
  ; The 80486 and higher have the AC (Alignment Check) bit in the EFLAGS
  ; register. The 80386 does not allow it to be set.
  pushfd
  pop ax
  and ax, 0x0fff
  pop dx
  or dx, 0x0004
  push dx
  push ax
  popfd
  pushfd
  pop ax
  pop dx
  test dx, 0x0004
  jnz .is_80486
  mov ah, CPU_80386
  jmp .done
[cpu 8086]
.is_80486:
  mov ah, CPU_80486
.done:
  xor al, al
  push bx
  popf
  pop bx
  pop dx
  ret

;
; FpuDetect
;
;   DX = detected FPU
;
FpuDetect:
  push ax
.test_present_or_not_present_1:
  ; Presence of an FPU can be detected by attemting to write the FPU Status
  ; Word to memory and checking if it is valid.
  fninit
  mov word [FpuScratch], 0x55aa
  fnstsw [FpuScratch]
  cmp byte [FpuScratch], 0
  je .test_present_or_not_present_2
  mov dh, FPU_NOT_PRESENT
  jmp .done
.test_present_or_not_present_2:
  ; Presence of an FPU can be detected by attemting to write the FPU Control
  ; Word to memory and checking if it is valid.
  fnstcw [FpuScratch]
  mov ax, [FpuScratch]
  and ax, 0x103f
  cmp ax, 0x003f
  je .test_8087_or_80287
  mov dh, FPU_NOT_PRESENT
  jmp .done
.test_8087_or_80287:
  ; We can disable interrupts on the 8087 but not on the 80287 and higher.
  and word [FpuScratch], 0xff7f
  fldcw [FpuScratch]
  fdisi
  fstcw [FpuScratch]
  test word [FpuScratch], 0x0080
  jz .test_80287_or_80387
  mov dh, FPU_8087
  jmp .done
.test_80287_or_80387:
  ; The 80287 considers positive and negative infinity to be equal. The 80387
  ; and higher do not.
  finit
  fld1
  fldz
  fdiv
  fld st0
  fchs
  fcompp
  fstsw [FpuScratch]
  mov ax, [FpuScratch]
  sahf
  jne .is_80387_or_higher
  mov dh, FPU_80287
  jmp .done
.is_80387_or_higher:
  mov dh, FPU_80387
.done:
  xor dl, dl
  pop ax
  ret

;
; CpuFpuPrint
;
;   AX = output of CpuDetect
;   DX = output of FpuDetect
;
CpuFpuPrint:
  push bx
  push si
  xor bh, bh
  mov bl, dh
  shl bx, 1
  mov si, [FpuList+bx]
  push si
  mov bl, ah
  shl bx, 1
  mov si, [CpuList+bx]
  push si
  mov si, MessageCpuFpu
  call PrintFormatted
  add sp, 4
  pop si
  pop bx
  ret

;-------------------------------------------------------------------------------
; DATA
;-------------------------------------------------------------------------------

CpuList:
  dw 0, MessageCpu8086, MessageCpu80286, MessageCpu80386, MessageCpu80486

FpuList:
  dw MessageFpuNotPresent, MessageFpu8087, MessageFpu80287, MessageFpu80387

FileNameKernelSys:
  db 'KERNEL  SYS'

HexDigits:
  db '0123456789ABCDEF'

;-------------------------------------------------------------------------------
; MESSAGES
;-------------------------------------------------------------------------------

MessageArithmeticOverflow:
  db 'ARITHMETIC OVERFLOW',13,10,0

MessageBreakPoint:
  db 'BREAKPOINT',13,10,0

MessageCpu8086:
  db '8088/8086/80186',0

MessageCpu80286:
  db '80286',0

MessageCpu80386:
  db '80386',0

MessageCpu80486:
  db '80486 (or higher)',0

MessageCpuFpu:
  db 'CPU: %s    FPU: %s',13,10,0

MessageFpuNotPresent:
  db 'Not present',0

MessageFpu8087:
  db '8087',0

MessageFpu80287:
  db '80287',0

MessageFpu80387:
  db '80387 (or higher)',0

MessageDiskParameters:
  db 'Boot device %h (%d Heads, %d Sectors/Track, %d Bytes/Sector)',13,10,0

MessageDivisionByZero:
  db 'DIVISION BY ZERO',13,10,0

MessageFatParameters:
  db '%d Sectors/Cluster, FAT @ %d, Root Directory @ %d, Data Area @ %d',13,10,0

MessageKernelSysNotFound:
  db "KERNEL.SYS not found.",13,10,0

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
  FpuScratch resw 1
  DiskBiosDriveNumber resw 1
  DiskNumberOfHeads resw 1
  DiskSectorsPerTrack resw 1
  DiskBytesPerSector resw 1
  FatSectorsPerCluster resw 1
  FatFirstFileAllocationTableSector resw 1
  FatFirstRootDirectorySector resw 1
  FatFirstDataAreaSector resw 1
  DirectoryCurrentSector resw 1
  FileCurrentSector resw 1

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