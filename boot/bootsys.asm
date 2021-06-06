;
; BOOT.SYS
;

[bits 16]
[cpu 8086]
[org 0x1000]

ROOT_DIRECTORY_CLUSTER  equ 1

DIRECTORY_ENTRY_NAME    equ 0x00
DIRECTORY_ENTRY_EXT     equ 0x08
DIRECTORY_ENTRY_ATTR    equ 0x0c
DIRECTORY_ENTRY_TIME    equ 0x16
DIRECTORY_ENTRY_DATE    equ 0x18
DIRECTORY_ENTRY_CLUSTER equ 0x1a
DIRECTORY_ENTRY_SIZE    equ 0x1c

  jmp 0000:Main

          db 0
Signature db 13,10,'RX/386 BOOT LOADER ',__UTC_DATE__,' ',__UTC_TIME__,13,10
Copyright db 'Copyright (c) 2021, Ruud Koot <inbox@ruudkoot.nl>',13,10,0

Main:
.setup_registers:
  cli
  cld
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  xor sp, sp
  call InterruptSetup
  sti
.print_signature:
  mov si, Signature
  call PrintString
.detect_cpu:
  call CpuDetect
  call FpuDetect
  call CpuFpuPrint
.detect_memory:
  call MemoryDetect
  call MemoryPrint
.setup_disk_parameter_block:
  call DiskInit
  call DiskPrint
  call FatInit
  call FatPrint
.load_kernel:
  call KernelLoad
  call FloppyMotorOff
.enter_protected_mode:
  cli
  call NmiMask
  mov bx, 0x2820
  call A20Dump
  call PicInitialize
  mov ax, 0x1000
  mov ds, ax
  mov es, ax
  mov ss, ax
  xor sp, sp
  jmp 0x1000:0x0000
.done:
  call HaltSystem

;-------------------------------------------------------------------------------
; BASIC INPUT/OUTPUT
;-------------------------------------------------------------------------------

;
; Read charater from keyboard
;
ConsoleIn:
  mov ax, __LINE__
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
  mov ax, __LINE__
  call NotImplemented

;
; Get character from serial port
;
AuxIn:
  mov ax, __LINE__
  call NotImplemented

;
; Send character to serial port
;
AuxOut:
  mov ax, __LINE__
  call NotImplemented

;
; DiskRead - Read sector from disk
;
; Calling Registers:
;
;   AX = logical sector
;   CX = number of sectors
;   ES:BX = data buffer
;
; Return Registers:
;
;
;
DiskRead:
  push ax
  push cx
  push dx
  push bx
  push si
  push di
  mov si, ax
  mov di, cx
.loop_start:
  mov ax, si
  mov cx, di
  or cx, cx
  jz .loop_done
  call DiskSectorToCHS
  ; xor ax, ax
  ; mov al, cl
  ; push ax
  ; mov al, dh
  ; push ax
  ; mov al, ch
  ; push ax
  ; mov al, dl
  ; push ax
  ; mov si, MessageDebugDiskRead
  ; call PrintFormatted
  ; add sp, 8
  mov ax, 0x0201
  mov dl, [BpbPhysicalUnit]
  int 0x13
  jc .disk_error
  add bx, [BpbBytesPerSector]
  inc si
  dec di
  jmp .loop_start
.loop_done:
  pop di
  pop si
  pop bx
  pop dx
  pop cx
  pop ax
  ret
.disk_error:
  mov si, MessageDiskError
  call PrintString
  call HaltSystem

;
; Write sector to disk
;
DiskWrite:
  mov ax, __LINE__
  call NotImplemented

;
; FloppyMotorOff - Wait for BIOS to turn off floppy motors
;
FloppyMotorOff:
  push ax
  push si
  mov si, MessageFloppyMotorWait
  call PrintString
.loop_start:
  mov al, [BiosDataArea+BDA_MOTOR_SHUTOFF_COUNTER]
  or al, al
  jz .loop_done
  hlt
  jmp .loop_start
.loop_done:
  pop si
  pop ax
  ret

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
; DiskSectorToCHS
;
; Calling Registers:
;
;   AX = linear sector
;
; Return Registers:
;
;   CH = track number
;   CL = sector number
;   DH = head number
;
DiskSectorToCHS:
  push ax
  push dx
  push bx
  mov cx, ax
  mov ax, [DiskSectorsPerTrack]
  mov dx, [DiskNumberOfHeads]
  mul dx
  mov bx, ax
  mov ax, cx
  xor dx, dx
  div bx
  mov ch, al
  mov cl, 6
  shl ah, cl
  mov cl, ah
  mov ax, dx
  xor dx, dx
  mov bx, [DiskSectorsPerTrack]
  div bx
  mov dh, al
  inc dl
  or cl, dl
  pop bx
  pop ax
  mov dl, al
  pop ax
  ret

;
; FatInit
;
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

;
; FatPrint
;
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
  cli
  hlt
  jmp .next

;
; Not imlemented
;
NotImplemented:
  push ax
  mov si, MessageNotImplemented
  call PrintFormatted
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
  push bx
  xor bx, bx
  xor dx, dx
  mov cx, 10000
  div cx
  or al, al
  jz .digit4
  inc bx
  add al, '0'
  call ConsoleOut
.digit4:
  xor ax, ax
  xchg ax, dx
  mov cx, 1000
  div cx
  or bx, bx
  jnz .digit4p
  or al, al
  jz .digit3
.digit4p:
  inc bx
  add al, '0'
  call ConsoleOut
.digit3:
  xor ax, ax
  xchg ax, dx
  mov cx, 100
  div cx
  or bx, bx
  jnz .digit3p
  or al, al
  jz .digit2
.digit3p:
  inc bx
  add al, '0'
  call ConsoleOut
.digit2:
  xor ax, ax
  xchg ax, dx
  mov cx, 10
  div cx
  or bx, bx
  jnz .digit2p
  or al, al
  jz .digit1
.digit2p:
  add al, '0'
  call ConsoleOut
.digit1:
  xchg ax, dx
  add al, '0'
  call ConsoleOut
  pop bx
  pop dx
  pop cx
  pop ax
  ret

;
; PrintByte
;
;   AL = number
;
PrintByte:
  push ax
  push cx
  push dx
  push bx
  mov bx, HexDigits
  xor dx, dx
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
.testb:
  cmp al, 'b'
  jnz .testd
  mov ax, [bp]
  call PrintByte
  jmp .next
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
  sub ax, 2
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
;   CX = total entries
;
DirectoryOpen:
  call FatClusterToSector
  mov [DirectoryFirstSector], ax
  mov [DirectoryTotalEntries], cx
  ret

;
; DirectorySearch
;
; Calling Registers:
;
;   SI = file name
;
; Return Registers:
;
;   CF clear if found, set if not found
;   DI = pointer to directory entry in sector buffer
;
; To do:
;
;   - Only searches first sector
;
DirectorySearch:
  push ax
  push cx
  push dx
  push bx
  mov ax, [DirectoryFirstSector]
  mov [DirectoryCurrentSector], ax
  mov word [DirectoryCurrentEntry], 0
  mov bx, SectorBufferDirectory
  mov cx, 1
  call DiskRead
  mov cx, 16
  mov dx, si
.entry_loop_start:
  push cx
  cld
  mov cx, 11
  mov si, dx
  mov di, bx
  repe cmpsb
  jne .entry_mismatch
.entry_match:
  mov di, bx
  clc
  add sp, 2
  jmp .epilogue
.entry_mismatch:
  pop cx
  add bx, 32
  loop .entry_loop_start
.file_not_found:
  stc
.epilogue:
  mov si, dx
  pop bx
  pop dx
  pop cx
  pop ax
  ret

;
; FileRead
;
; Calling Registers:
;
;   SI = pointer to directory entry
;   ES:DI = target to load file to
;
; To do:
;
;   - Support non-contiguous files
;
FileRead:
  push ax
  push cx
  push dx
  push bx
  push si
  mov ax, [si+DIRECTORY_ENTRY_CLUSTER]
  push ax
  call FatClusterToSector
  push ax
  mov ax, [si+DIRECTORY_ENTRY_SIZE]
  push ax
  xor dx, dx
  mov bx, [BpbBytesPerSector]
  div bx
  or dx, dx
  jz .no_slack
  inc ax
.no_slack:
  push ax
  mov si, MessageKernelSysFile
  call PrintFormatted
  pop cx
  add sp, 2
  pop ax
  add sp, 2
  mov bx, di
  call DiskRead
  pop si
  pop bx
  pop dx
  pop cx
  pop ax
  ret

;-------------------------------------------------------------------------------
; ENTER KERNEL
;-------------------------------------------------------------------------------

;
; KernelLoad
;
KernelLoad:
  push ax
  push si
  push di
  mov ax, ROOT_DIRECTORY_CLUSTER
  call DirectoryOpen
  mov si, FileNameKernelSys
  call DirectorySearch
  jc .kernel_sys_not_found
  mov si, di
  mov ax, 0x1000
  push es
  mov es, ax
  xor di, di
  call FileRead
  pop es
  pop di
  pop si
  pop ax
  ret
.kernel_sys_not_found:
  mov si, MessageKernelSysNotFound
  call PrintString
  call HaltSystem

;-------------------------------------------------------------------------------
; INTERRUPT HANDLERS
;-------------------------------------------------------------------------------

PORT_SYSTEM_CONTROL_A equ 0x92
PORT_SYSTEM_CONTROL_B equ 0x61

InterruptSetup:
  push ax
  mov word [Int00Off], Interrupt00
  mov [Int00Seg], ax
  mov word [Int01Off], Interrupt01
  mov [Int01Seg], ax
  ; FIXME: mask NMI
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
  mov [Int20Seg], ax
  mov word [Int20Off], Interrupt20
  mov [Int21Seg], ax
  mov word [Int21Off], Interrupt21
  mov [Int22Seg], ax
  mov word [Int22Off], InterruptReturn
  mov [Int23Seg], ax
  mov word [Int23Off], InterruptReturn
  mov [Int24Seg], ax
  mov word [Int24Off], InterruptReturn
  mov [Int25Seg], ax
  mov word [Int25Off], InterruptReturn
  mov [Int26Seg], ax
  mov word [Int26Off], InterruptReturn
  mov [Int27Seg], ax
  mov word [Int27Off], InterruptReturn
  mov [Int28Seg], ax
  mov word [Int28Off], InterruptReturn
  mov [Int29Seg], ax
  mov word [Int29Off], InterruptReturn
  mov [Int2ASeg], ax
  mov word [Int2AOff], InterruptReturn
  mov [Int2BSeg], ax
  mov word [Int2BOff], InterruptReturn
  mov [Int2CSeg], ax
  mov word [Int2COff], InterruptReturn
  mov [Int2DSeg], ax
  mov word [Int2DOff], InterruptReturn
  mov [Int2ESeg], ax
  mov word [Int2EOff], InterruptReturn
  mov [Int2FSeg], ax
  mov word [Int2FOff], InterruptReturn
  pop ax
  ret

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
  xor ah, ah
  in al, PORT_SYSTEM_CONTROL_B
  push ax
  in al, PORT_SYSTEM_CONTROL_A
  push ax
  mov si, MessageNonMaskableInterrupt
  call PrintFormatted
  add sp, 4
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

Interrupt20:
  push ax
  ;push ds
  ;xor ax, ax
  ;mov ds, ax
  ;mov si, .message
  ;call PrintString
  ;call PicDump
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
  ;pop ds
  pop ax
  iret
.message:
  db '[TICK]',0

Interrupt21:
  push ax
  push ds
  xor ax, ax
  mov ds, ax
  mov si, .message
  call PrintString
;  call PicDump
  in al, PORT_KEYB_DATA
;  sti
;.stop:
;  jmp .stop
  mov al, PIC_CMD_NONSPECIFIC_EOI
  out PORT_PIC_MASTER_CMD, al
  pop ds
  pop ax
  iret
.message:
  db '[KEY]',0

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
; MEMORY DETECTION
;-------------------------------------------------------------------------------

;
; MemoryDetect
;
; Calling Registers:
;
;   none
;
; Return Registers:
;
;   AX = kilobytes of conventional memory
;   DX = kilobytes of extended memory
;
MemoryDetect:
.get_extended:
  clc
  mov ah, 0x88
  int 0x15
  jc .no_extended
  mov dx, ax
  jmp .get_conventional
.no_extended:
  xor ax, ax
  xor dx, dx
.get_conventional:
  int 0x12
.done:
  ret

;
; MemoryPrint
;
; Calling Registers:
;
;   AX = kilobytes of conventional memory
;   DX = kilobytes of extended memory
;
; Return Registers:
;
;   none
;
MemoryPrint:
  push si
  mov si, MessageMemorySize
  push dx
  push ax
  call PrintFormatted
  add sp, 4
  pop si
  ret

;-------------------------------------------------------------------------------
; NON-MASKABLE INTERRUPTS
;-------------------------------------------------------------------------------

PORT_RTC_INDEX  equ 0x70
PORT_RTC_DATA   equ 0x71

;
; NmiMask
;
NmiMask:
  push ax
  mov al, 0x80
  out PORT_RTC_INDEX, al
  in al, PORT_RTC_DATA
  pop ax
  ret

;
; NmiUnmask
;
NmiUnmask:
  push ax
  mov al, 0x00
  out PORT_RTC_INDEX, al
  in al, PORT_RTC_DATA
  pop ax
  ret

;-------------------------------------------------------------------------------
; A20 GATE
;-------------------------------------------------------------------------------

A20Dump:
  ret

;-------------------------------------------------------------------------------
; PROGRAMMABLE INTERRUPT CONTROLLER (8259A)
;-------------------------------------------------------------------------------

PORT_PIC_MASTER_CMD       equ 0x20
PORT_PIC_MASTER_DATA      equ 0x21
PORT_PIC_SLAVE_CMD        equ 0xa0
PORT_PIC_SLAVE_DATA       equ 0xa1
PORT_WAIT                 equ 0x80

PIC_CMD_AEOI_ROTATE       equ 0x00
PIC_CMD_OCW3              equ 0x08
PIC_OCW3_READ_IRR         equ 0x02
PIC_OCW3_READ_ISR         equ 0x03
PIC_OCW3_POLLING_MODE     equ 0x04
PIC_OCW3_SMM_CLEAR        equ 0x40
PIC_OCW3_SMM_SET          equ 0x60
PIC_CMD_ICW1              equ 0x10
PIC_ICW1_NEED_ICW4        equ 0x01
PIC_ICW1_EDGE             equ 0x00
PIC_ICW1_LEVEL            equ 0x01
PIC_ICW1_CASCADE          equ 0x00
PIC_ICW1_SINGLE           equ 0x02
PIC_ICW3_MASTER_IRQ2      equ 0x04
PIC_ICW3_SLAVE_IRQ2       equ 0x02
PIC_ICW4_MCS85_MODE       equ 0x00
PIC_ICW4_8086_MODE        equ 0x01
PIC_ICW4_MANUAL_EOI       equ 0x00
PIC_ICW4_AUTO_EOI         equ 0x02
PIC_ICW4_MASTER_PIC       equ 0x00
PIC_ICW4_SLAVE_PIC        equ 0x04
PIC_ICW4_BUFFERED         equ 0x08
PIC_ICW4_SFNM             equ 0x10
PIC_CMD_NONSPECIFIC_EOI   equ 0x20
PIC_CMD_NOP               equ 0x40
PIC_CMD_SPECIFIC_EOI      equ 0x60
PIC_SEOI_LVL0             equ 0x00
PIC_SEOI_LVL1             equ 0x01
PIC_SEOI_LVL2             equ 0x02
PIC_SEOI_LVL3             equ 0x03
PIC_SEOI_LVL4             equ 0x04
PIC_SEOI_LVL5             equ 0x05
PIC_SEOI_LVL6             equ 0x06
PIC_SEOI_LVL7             equ 0x07
PIC_CMD_AEOI_SET_ROTATE   equ 0x80
PIC_CMD_NSEOI_ROTATE      equ 0xa0
PIC_CMD_PRIORITY          equ 0xc0
PIC_CMD_SEOI_ROTATE       equ 0xe0

;
; PicReinitialize
;
; Calling Registers:
;
;   BL = master interrupt base
;   BH = slave interrupt base
;
PicInitialize:
  push ax
.icw1:
  mov al, PIC_CMD_ICW1 | PIC_ICW1_EDGE | PIC_ICW1_CASCADE | PIC_ICW1_NEED_ICW4
  out PORT_PIC_MASTER_CMD, al
  out PORT_PIC_SLAVE_CMD, al
  out PORT_WAIT, al
.icw2:
  mov al, bl
  test al, 0x07
  jnz .invalid_base
  out PORT_PIC_MASTER_DATA, al
  mov al, bh
  and al, 0x07
  jnz .invalid_base
  out PORT_PIC_SLAVE_DATA, al
  out PORT_WAIT, al
.icw3:
  mov al, PIC_ICW3_MASTER_IRQ2
  out PORT_PIC_MASTER_DATA, al
  mov al, PIC_ICW3_SLAVE_IRQ2
  out PORT_PIC_SLAVE_DATA, al
  out PORT_WAIT, al
.icw4:
  mov al, PIC_ICW4_8086_MODE | PIC_ICW4_MANUAL_EOI
  out PORT_PIC_MASTER_DATA, al
  out PORT_PIC_SLAVE_DATA, al
  out PORT_WAIT, al
.imr:
  mov al, 0xff
  out PORT_PIC_MASTER_DATA, al
  mov al, 0xff
  out PORT_PIC_SLAVE_DATA, al
.epilogue:
  pop ax
  ret
.invalid_base:
  mov si, MessagePicInvalidBase
  push bx
  call PrintFormatted
  add sp, 2
  call HaltSystem

PicDump:
  push ax
  push cx
  push dx
  push bx
  push si
  mov al, PIC_CMD_OCW3 | PIC_OCW3_READ_IRR
  out PORT_PIC_MASTER_CMD, al
  out PORT_PIC_SLAVE_CMD, al
  in al, PORT_PIC_MASTER_CMD
  mov cl, al
  in al, PORT_PIC_SLAVE_CMD
  mov dl, al
  mov al, PIC_CMD_OCW3 | PIC_OCW3_READ_ISR
  out PORT_PIC_MASTER_CMD, al
  out PORT_PIC_SLAVE_CMD, al
  in al, PORT_PIC_MASTER_CMD
  mov ch, al
  in al, PORT_PIC_SLAVE_CMD
  mov dh, al
  in al, PORT_PIC_MASTER_DATA
  mov bl, al
  in al, PORT_PIC_SLAVE_DATA
  mov bh, al
  xor ah, ah
  mov al, bh
  push ax
  mov al, dh
  push ax
  mov al, dl
  push ax
  mov al, bl
  push ax
  mov al, ch
  push ax
  mov al, cl
  push ax
  mov si, MessagePicDump
  call PrintFormatted
  add sp, 12
  pop si
  pop bx
  pop dx
  pop cx
  pop ax
  ret

MessagePicDump:
  db 'PIC STATUS [M] IRR=%b ISR=%b IMR=%b [S] IRR=%b ISR=%b IMR=%b',13,10,0

;-------------------------------------------------------------------------------
; KEYBOARD CONTROLLER (8042)
;-------------------------------------------------------------------------------

PORT_KEYB_DATA    equ 0x60
PORT_KEYB_CONTROL equ 0x64

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

MessageDebugDiskRead:
  db 'DiskRead: D = %h, C = %d, H = %d, S = %d',13,10,0

MessageDiskError:
  db 'DISK ERROR!',13,10,0

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

MessageFloppyMotorWait:
  db 'Waiting for floppy motor to stop...',13,10,0

MessageIrqTimer:
  db 'TICK!',13,10,0

MessageKernelSysFile:
  db 'KERNEL.SYS: Sectors = %d, Size = %d, Sector = %d, Cluster = %d',13,10,0

MessageKernelSysNotFound:
  db "KERNEL.SYS not found.",13,10,0

MessageMemorySize:
  db '%d KiB conventional memory, %d KiB extended memory',13,10,0

MessageNonMaskableInterrupt:
  db 'NON-MASKABLE INTERRUPT (A = %b, B = %b)',13,10,0

MessageNoCoprocessor:
  db 'NO COPROCESSOR',13,10,0

MessageNotImplemented:
  db 'OPERATION NOT IMPLEMENTED (Line = %d)',13,10,0

MessagePicInvalidBase:
  db 'PicInitialize: Invalid base vector (BX = %h)',13,10,0

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
  DirectoryFirstSector resw 1
  DirectoryCurrentSector resw 1
  DirectoryTotalEntries resw 1
  DirectoryCurrentEntry resw 1
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
  Int08Off resw 1
  Int08Seg resw 1
  Int09Off resw 1
  Int09Seg resw 1
  Int0AOff resw 1
  Int0ASeg resw 1
  Int0BOff resw 1
  Int0BSeg resw 1
  Int0COff resw 1
  Int0CSeg resw 1
  Int0DOff resw 1
  Int0DSeg resw 1
  Int0EOff resw 1
  Int0ESeg resw 1
  Int0FOff resw 1
  Int0FSeg resw 1
  Int10Off resw 1
  Int10Seg resw 1
  Int11Off resw 1
  Int11Seg resw 1
  Int12Off resw 1
  Int12Seg resw 1
  Int13Off resw 1
  Int13Seg resw 1
  Int14Off resw 1
  Int14Seg resw 1
  Int15Off resw 1
  Int15Seg resw 1
  Int16Off resw 1
  Int16Seg resw 1
  Int17Off resw 1
  Int17Seg resw 1
  Int18Off resw 1
  Int18Seg resw 1
  Int19Off resw 1
  Int19Seg resw 1
  Int1AOff resw 1
  Int1ASeg resw 1
  Int1BOff resw 1
  Int1BSeg resw 1
  Int1COff resw 1
  Int1CSeg resw 1
  Int1DOff resw 1
  Int1DSeg resw 1
  Int1EOff resw 1
  Int1ESeg resw 1
  Int1FOff resw 1
  Int1FSeg resw 1
  Int20Off resw 1
  Int20Seg resw 1
  Int21Off resw 1
  Int21Seg resw 1
  Int22Off resw 1
  Int22Seg resw 1
  Int23Off resw 1
  Int23Seg resw 1
  Int24Off resw 1
  Int24Seg resw 1
  Int25Off resw 1
  Int25Seg resw 1
  Int26Off resw 1
  Int26Seg resw 1
  Int27Off resw 1
  Int27Seg resw 1
  Int28Off resw 1
  Int28Seg resw 1
  Int29Off resw 1
  Int29Seg resw 1
  Int2AOff resw 1
  Int2ASeg resw 1
  Int2BOff resw 1
  Int2BSeg resw 1
  Int2COff resw 1
  Int2CSeg resw 1
  Int2DOff resw 1
  Int2DSeg resw 1
  Int2EOff resw 1
  Int2ESeg resw 1
  Int2FOff resw 1
  Int2FSeg resw 1
  InterruptVectors resd (256-48)
  BiosDataArea resb 256
  DosCommunicationArea resb 256

BDA_MOTOR_SHUTOFF_COUNTER equ 0x40

absolute 0x7000
  SectorBufferFAT resb 512
  SectorBufferDirectory resb 512

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