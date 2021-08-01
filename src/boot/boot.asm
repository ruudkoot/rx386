;
; BOOT.SYS
;

;%define DEBUG_ELF_RELOC 1

%include "config.inc"
%include "defs.inc"
%include "elf.inc"
%include "kernel.inc"

cpu   8086
bits  16
org   BOOT_BASE

BOOT_START:
  jmp BOOT_SEG:Main

          db 0
Signature db CR,LF
          db 'RX/386 BOOT LOADER ',__UTC_DATE__,' ',__UTC_TIME__,CR,LF
          db 'Copyright (c) 2021, Ruud Koot <inbox@ruudkoot.nl>',CR,LF,0

Main:
.setup_registers:
  cli
  cld
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  xor sp, sp
  call NmiMask
  call InterruptSetup
  call NmiUnmask
  sti
.print_signature:
  call VideoSetup
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
  mov si, FileNameKernel
  mov bx, KERNEL_PHYS >> 4
  call FileLoad
  mov si, FileNameUser
  mov bx, USER_PHYS >> 4
  call FileLoad
[cpu 386]
  mov edx, KERNEL_PHYS
  mov ebx, KERNEL_VIRT
  mov esi, PageTable8+0
  call ElfLoad
  mov edx, USER_PHYS
  mov ebx, USER_VIRT
  mov esi, PageTable0User+1
  call ElfLoad
  xor esi, esi
  call FloppyMotorOff
.prepare_for_protected_mode:
  cli
  mov bx, 0x2820
  call A20Dump
  call A20Enable
  call A20Test
  call NmiMask
  call PicInitialize
.enter_protected_mode:
  lgdt [GDT_Register]
  mov eax, cr0
  or eax, CR0_PE
  mov cr0, eax
  jmp SELECTOR_CODE0:.in_protected_mode_32
.in_protected_mode_32:
[bits 32]
  mov ax, SELECTOR_DATA0
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov esp, BOOT_STACK
.enable_paging:
  call PageTableSetup
  mov eax, PageDirectoryBoot
  mov cr3, eax
  mov eax, cr0
  or eax, CR0_PG
  mov cr0, eax
  mov esp, KERNEL_ENTRY
  jmp SELECTOR_CODE0:KERNEL_ENTRY
[bits 16]
[cpu 8086]

;-------------------------------------------------------------------------------
; BASIC INPUT/OUTPUT
;-------------------------------------------------------------------------------

;
; VideoSetup
;
VideoSetup:
  push ax
  push bx
%if CONSOLE_ROWS > 25
  ;mov ax, BIOS_10H_SET_VIDEO_MODE | VIDEO_MODE_3
  ;int 0x10
  mov ax, BIOS_10H_LOAD_8X8_FONT
  xor bx, bx
  int 0x10
  mov ax, BIOS_10H_CURSOR_SHAPE
  mov cx, 0x0607
  int 0x10
%endif
  pop bx
  pop ax
  ret

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
  mov dl, [BOOT_SECTOR+BPB_PHYSICALUNIT]
  int 0x13
  jc .disk_error
  add bx, [BOOT_SECTOR+BPB_BYTESPERSECTOR]
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
  mov al, [BDA_MOTOR_SHUTOFF_COUNTER]
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
  mov ax, [BOOT_SECTOR+BPB_PHYSICALUNIT]
  mov [DiskBiosDriveNumber], ax
  mov ax, [BOOT_SECTOR+BPB_NUMBEROFHEADS]
  mov [DiskNumberOfHeads], ax
  mov ax, [BOOT_SECTOR+BPB_SECTORSPERTRACK]
  mov [DiskSectorsPerTrack], ax
  mov ax, [BOOT_SECTOR+BPB_BYTESPERSECTOR]
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
  mov bl, [BOOT_SECTOR+BPB_SECTORSPERCLUSTER]
  xor bh, bh
  mov [FatSectorsPerCluster], bx
  mov bx, [BOOT_SECTOR+BPB_RESERVEDSECTORS]
  mov [FatFirstFileAllocationTableSector], bx
  mov al, [BOOT_SECTOR+BPB_NUMBEROFFATS]
  xor ah, ah
  mov cx, [BOOT_SECTOR+BPB_SECTORSPERFAT]
  mul cx
  add bx, ax
  mov [FatFirstRootDirectorySector], bx
  mov ax, [BOOT_SECTOR+BPB_ROOTDIRECTORYENTRIES]
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
  call PrintFormatted
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
;   ES:SI = zero-terminated string
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
  mov al, [es:si]
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
;   DS:SI = zero-terminated format string
;
; Notes:
;
;   - Embedded strings (%s) point to strings in ES.
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
;   CX = total entries (currently not used)
;
DirectoryOpen:
  call FatClusterToSector
  mov [DirectoryFirstSector], ax
  ;mov [DirectoryTotalEntries], cx
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
;   CX      file name
;   SI      pointer to directory entry
;   ES:DI   target to load file to
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
  push bp
  mov bp, es
  mov ax, BOOT_SEG
  mov es, ax
  mov ax, [si+DIRECTORY_ENTRY_CLUSTER]
  push ax
  call FatClusterToSector
  push ax
  mov ax, [si+DIRECTORY_ENTRY_SIZE]
  push ax
  xor dx, dx
  mov bx, [BOOT_SECTOR+BPB_BYTESPERSECTOR]
  div bx
  or dx, dx
  jz .no_slack
  inc ax
.no_slack:
  push ax
  mov si, cx
  push si
  mov si, MessageFileInfo
  call PrintFormatted
  add sp, 2
  pop cx
  add sp, 2
  pop ax
  add sp, 2
  mov bx, di
  mov es, bp
  call DiskRead
  pop bp
  pop si
  pop bx
  pop dx
  pop cx
  pop ax
  ret

;
; FileLoad
;
; Calling Registers:
;
;   BX  segment to load to
;   SI  file name
;
FileLoad:
  push ax
  push bx
  push si
  push di
  mov cx, si
  mov ax, ROOT_DIRECTORY_CLUSTER
  call DirectoryOpen
  call DirectorySearch
  jc .file_not_found
  mov si, di
  push es
  mov es, bx
  xor di, di
  call FileRead
  pop es
  pop di
  pop si
  pop bx
  pop ax
  ret
.file_not_found:
  push si
  mov si, MessageFileNotFound
  call PrintFormatted
  pop si
  call HaltSystem

;-------------------------------------------------------------------------------
; EXECUTABLE AND LINKING FORMAT
;-------------------------------------------------------------------------------

[cpu 386]

;
; ElfLoad - Relocate ELF object and build page table
;
; Assumptions:
;
; - .text and .date are page aligned
; - relocation data follow section to be relocated
; - .bss is the last section
;
; Calling Register:
;
;   EDX   Physical Address
;   EBX   Virtual Address [UNUSED - infered from SI]
;   ESI   Page Table + U/S
;
; Local Variables:
;
;   BP-2  ELF32_E_SHSHNUM
;   BP-4  ELF32_E_SHOFF
;
ElfLoad:
.prologue:
  pushad
  push es
  mov bp, sp
  sub sp, 4
.body:
  mov eax, edx
  shr eax, 4
  mov es, ax
.elf_file_header:
  push esi
  mov ax, [es:ELF32_E_SHSTRNDX]
  push ax
  mov ax, [es:ELF32_E_SHSHNUM]
  mov [bp-2], ax
  push ax
  mov ax, [es:ELF32_E_SHENTSIZE]
  push ax
  mov eax, [es:ELF32_E_SHOFF]
  mov [bp-4], ax
  push ax
  shl eax, 16
  push ax
  mov eax, [es:ELF32_E_PHOFF]
  push ax
  shl eax, 16
  push ax
  mov eax, [es:ELF32_E_ENTRY]
  push ax
  shl eax, 16
  push ax
  mov esi, .message_e
  call PrintFormatted
  add sp, 18
  pop esi
.elf_alloc:
  mov cx, [bp-2]
  mov di, [bp-4]
  push ebp
  xor ebp, ebp
.elf_alloc_loop_start:
  call ElfAlloc
  add di, 40
  dec cx
  jz .print_sections
  jmp .elf_alloc_loop_start
.print_sections:
  push word [SymbolTable+28]
  push word [SymbolTable+30]
  push word [SymbolTable+24]
  push word [SymbolTable+26]
  push word [SymbolTable+20]
  push word [SymbolTable+22]
  push word [SymbolTable+16]
  push word [SymbolTable+18]
  push word [SymbolTable+12]
  push word [SymbolTable+14]
  push word [SymbolTable+8]
  push word [SymbolTable+10]
  push word [SymbolTable+4]
  push word [SymbolTable+6]
  push word [SymbolTable]
  push word [SymbolTable+2]
  mov esi, .message_s
  call PrintFormatted
  add sp, 32
.elf_reloc:
  pop ebp
  mov cx, [bp-2]
  mov di, [bp-4]
  push ebp
  xor ebp, ebp
  dec ebp
.elf_reloc_loop_start:
  call ElfReloc
  add di, 40
  dec cx
  jz .epilogue
  jmp .elf_reloc_loop_start
.epilogue:
  pop ebp
  add sp, 4
  pop es
  popad
  ret
.message_e:
  db 'ELF32_E_ENTRY     = %h%hh',CR,LF
  db 'ELF32_E_PHOFF     = %h%hh',CR,LF
  db 'ELF32_E_SHOFF     = %h%hh',CR,LF
  db 'ELF32_E_SHENTSIZE = %d',CR,LF
  db 'ELF32_E_SHSHNUM   = %d',CR,LF
  db 'ELF32_E_SHSTRNDX  = %d',CR,LF
  db 0
.message_s:
  db '       PSYS      VIRT',CR,LF
  db 'STACK: %h%h  %h%h',CR,LF
  db 'TEXT : %h%h  %h%h',CR,LF
  db 'DATA : %h%h  %h%h',CR,LF
  db 'BSS  : %h%h  %h%h',CR,LF
  db 0

;
; ElfAlloc - Setup page table using ELF sections
;
; Calling Register:
;
;    SI   Page Table + U/S
;   EDX   Physical Address
;   EBX   Virtual Address
;   EBP   SectionTable index
;
ElfAlloc:
.prologue:
  push eax
  push ecx
  push edx
.print:
  push si
  push word [es:di+ELF32_SH_SIZE]
  push word [es:di+ELF32_SH_OFFSET]
  push word [es:di+ELF32_SH_ADDR]
  push word [es:di+ELF32_SH_ADDR+2]
  push word [es:di+ELF32_SH_LINK]
  push word [es:di+ELF32_SH_INFO]
  push word [es:di+ELF32_SH_FLAGS]
  push word [es:di+ELF32_SH_TYPE]
  mov si, .message_sh
  call PrintFormatted
  add sp, 16
  pop si
.dispatch:
  mov eax, [es:di+ELF32_SH_TYPE]
  cmp eax, ELF32_SHT_NULL
  je .map_stack
  cmp eax, ELF32_SHT_PROGBITS
  je .map_pages
  cmp eax, ELF32_SHT_NOBITS
  je .map_pages
  cmp eax, ELF32_SHT_REL
  je .epilogue
  cmp eax, ELF32_SHT_SYMTAB
  je .epilogue
  cmp eax, ELF32_SHT_STRTAB
  je .epilogue
.allocation_error:
  mov si, .message_error
  call PrintFormatted
  call HaltSystem
.map_stack:
  inc word [es:di+ELF32_SH_SIZE]
.map_pages:
  add edx, [es:di+ELF32_SH_OFFSET]
  mov [SymbolTable+8*ebp], edx
  mov [SymbolTable+8*ebp+4], ebx
  mov [es:di+ELF32_SH_ADDR], ebx
  inc ebp
  mov ecx, [es:di+ELF32_SH_SIZE]
  test ecx, 0x00000fff
  jz .map_pages_2
  add ecx, 0x00001000
.map_pages_2:
  shr ecx, 12
  or ecx, ecx
  jmp .map_pages_loop_check
.map_pages_loop_start:
  ; debug message
  push si
  push si
  mov eax, ebx
  push ax
  mov eax, ebx
  shr eax, 16
  push ax
  mov eax, edx
  push ax
  mov eax, edx
  shr eax, 16
  push ax
  mov si, .message_pt_progbits
  call PrintFormatted
  add sp, 10
  pop si
  ; map pages
  mov eax, edx
  test si, 0x0001
  jz .supervisor
.user:
  dec si
  or eax, PAGE_PRESENT | PAGE_RW | PAGE_USER
  mov [si], eax
  add si, 5
  jmp .continue
.supervisor:
  or eax, PAGE_PRESENT | PAGE_RW
  mov [si], eax
  add si, 4
.continue:
  add ebx, PAGE_SIZE
  add edx, PAGE_SIZE
  dec ecx
.map_pages_loop_check:
  jz .epilogue
  jmp .map_pages_loop_start
.epilogue:
  pop edx
  pop ecx
  pop eax
  ret
.message_sh:
  db 'TYPE=%h FLAGS=%h INFO=%h LINK=%h ADDR=%h%h OFFSET=%h SIZE=%h',CR,LF,0
.message_pt_progbits:
  db 'PHYS:%h%h @ VIRT:%h%h / PT:%h',CR,LF,0
.message_error:
  db 'ALLOCATION ERROR!',CR,LF,0

;
; ElfReloc - Apply relocations
;
; Calling Registers:
;
;   EBP   SectionTable index
;
ElfReloc:
.prologue:
  push eax
  push ecx
  push edx
  push ebx
.print:
  push si
  push word [es:di+ELF32_SH_SIZE]
  push word [es:di+ELF32_SH_OFFSET]
  push word [es:di+ELF32_SH_ADDR]
  push word [es:di+ELF32_SH_ADDR+2]
  push word [es:di+ELF32_SH_LINK]
  push word [es:di+ELF32_SH_INFO]
  push word [es:di+ELF32_SH_FLAGS]
  push word [es:di+ELF32_SH_TYPE]
  mov si, .message_sh
  call PrintFormatted
  add sp, 16
  pop si
.dispatch:
  mov eax, [es:di+ELF32_SH_TYPE]
  cmp eax, ELF32_SHT_NULL
  je .next_section
  cmp eax, ELF32_SHT_PROGBITS
  je .next_section
  cmp eax, ELF32_SHT_NOBITS
  je .next_section
  cmp eax, ELF32_SHT_REL
  je .relocate
  cmp eax, ELF32_SHT_SYMTAB
  je .epilogue
  cmp eax, ELF32_SHT_STRTAB
  je .epilogue
.relocation_error:
  mov si, .message_error
  call PrintFormatted
  call HaltSystem
.next_section:
  inc ebp
  jmp .epilogue
.relocate:
  xor edx, edx
  mov eax, [es:di+ELF32_SH_SIZE]
  mov ecx, [es:di+ELF32_SH_ENTSIZE]
  div ecx
  mov ecx, eax
  jmp .relocate_loop_check
.relocate_loop_start:
  mov ebx, [es:di+ELF32_SH_OFFSET]
  mov eax, [es:di+ELF32_SH_ENTSIZE]
  mul ecx
  add ebx, eax
  push si
  push word [es:bx+4] ; INFO
  push word [es:bx] ; OFFSET
  mov si, .message_r
  ;call PrintFormatted
  add sp, 4
  pop si
  mov eax, [es:bx] ; OFFSET
  mov edx, [es:bx+4] ; INFO
  call ElfRelocSymbol
.relocate_loop_check:
  sub ecx, 1
  jc .epilogue
  jmp .relocate_loop_start
.epilogue:
  pop ebx
  pop edx
  pop ecx
  pop eax
  ret
.message_sh:
  db 'TYPE=%h FLAGS=%h INFO=%h LINK=%h ADDR=%h%h OFFSET=%h SIZE=%h',CR,LF,0
.message_r:
  db 'RELOC: OFFSET=%h INFO=%h',CR,LF,0
.message_error:
  db 'RELOCATION ERROR!',CR,LF,0

;
; ElfRelocSymbol
;
; Calling Registers:
;
;   EAX   OFFSET (P)
;   EDX   INFO
;   EBP   SectionTabel index
;
ElfRelocSymbol:
.prologue:
  pushad
.body:
  xor ebx, ebx
  mov bl, dh
  xchg ebx, ebp
  mov esi, [SymbolTable+8*ebx]
  xchg ebx, ebp
  mov edi, [SymbolTable+8*ebx+4] ; S
  add esi, eax
  mov ecx, [es:si] ; A (ES:SI ~ ESI)
  mov ebx, ecx
  cmp dl, ELF32_R_386_NONE
  je .r_386_none
  cmp dl, ELF32_R_386_32
  je .r_386_32
  cmp dl, ELF32_R_386_PC32
  je .r_386_pc32
  jmp .error
.r_386_none:
  jmp .epilogue
.r_386_32:
  add ecx, edi
  mov [es:si], ecx ; S + A (ES:SI ~ ESI)
%ifdef DEBUG_ELF_RELOC
  push dx
  push ax
  mov eax, ecx
  push ax
  shr eax, 16
  push ax
  mov eax, ebx
  push ax,
  shr eax, 16
  push ax
  mov eax, edi
  push ax
  shr eax, 16
  push ax
  mov si, .message_r_386_32
  call PrintFormatted
  add sp, 16
%endif
  jmp .epilogue
.r_386_pc32:
  add ecx, edi
  sub ecx, eax
  mov [es:si], ecx ; S + A - P (ES:SI ~ ESI)
%ifdef DEBUG_ELF_RELOC
  mov esi, eax ; (P)
  push dx
  push ax
  mov eax, ecx
  push ax
  shr eax, 16
  push ax
  mov eax, esi ; (P)
  push ax
  shr eax, 16
  push ax
  mov eax, ebx
  push ax,
  shr eax, 16
  push ax
  mov eax, edi
  push ax
  shr eax, 16
  push ax
  mov si, .message_r_386_pc32
  call PrintFormatted
  add sp, 20
%endif
  jmp .epilogue
.epilogue:
  popad
  ret
.error:
  mov si, .message_error
  call PrintFormatted
  call HaltSystem
%ifdef DEBUG_ELF_RELOC
.message_r_386_32:
  db 'R_386_32  : (S)%h%h + (A)%h%h               = %h%h @ (P)%h [%h]',CR,LF,0
.message_r_386_pc32:
  db 'R_386_PC32: (S)%h%h + (A)%h%h - (P)%h%h = %h%h @ (P)%h [%h]',CR,LF,0
%endif
.message_error:
  db 'ElfRelocSymbol error',CR,LF,0

[cpu 8086]

section .bss

; Symbol table holding .stack, .text, .data, .bss symbols.
; FIXME: Use .symtab section.
SymbolTable resd 8

;-------------------------------------------------------------------------------
; INTERRUPT HANDLERS
;-------------------------------------------------------------------------------

section .text

InterruptSetup:
  push ax
  mov word [IV_OFFSET(0x00)], Interrupt00
  mov [IV_SEGMENT(0x00)], ax
  mov word [IV_OFFSET(0x01)], Interrupt01
  mov [IV_SEGMENT(0x01)], ax
  mov word [IV_OFFSET(0x02)], Interrupt02
  mov [IV_SEGMENT(0x02)], ax
  mov word [IV_OFFSET(0x03)], Interrupt03
  mov [IV_SEGMENT(0x03)], ax
  mov word [IV_OFFSET(0x04)], Interrupt04
  mov [IV_SEGMENT(0x04)], ax
  ; mov word [IV_OFFSET(0x05)], Interrupt05
  ; mov [IV_SEGMENT(0x05)], ax
  mov word [IV_OFFSET(0x06)], Interrupt06
  mov [IV_SEGMENT(0x06)], ax
  mov word [IV_OFFSET(0x07)], Interrupt07
  mov [IV_SEGMENT(0x07)], ax
  mov word [IV_OFFSET(0x20)], Interrupt20
  mov [IV_SEGMENT(0x20)], ax
  mov word [IV_OFFSET(0x21)], Interrupt21
  mov [IV_SEGMENT(0x21)], ax
  mov word [IV_OFFSET(0x22)], InterruptReturn
  mov [IV_SEGMENT(0x22)], ax
  mov word [IV_OFFSET(0x23)], InterruptReturn
  mov [IV_SEGMENT(0x23)], ax
  mov word [IV_OFFSET(0x24)], InterruptReturn
  mov [IV_SEGMENT(0x24)], ax
  mov word [IV_OFFSET(0x25)], InterruptReturn
  mov [IV_SEGMENT(0x25)], ax
  mov word [IV_OFFSET(0x26)], InterruptReturn
  mov [IV_SEGMENT(0x26)], ax
  mov word [IV_OFFSET(0x27)], InterruptReturn
  mov [IV_SEGMENT(0x27)], ax
  mov word [IV_OFFSET(0x28)], InterruptReturn
  mov [IV_SEGMENT(0x28)], ax
  mov word [IV_OFFSET(0x29)], InterruptReturn
  mov [IV_SEGMENT(0x29)], ax
  mov word [IV_OFFSET(0x2A)], InterruptReturn
  mov [IV_SEGMENT(0x2A)], ax
  mov word [IV_OFFSET(0x2B)], InterruptReturn
  mov [IV_SEGMENT(0x2B)], ax
  mov word [IV_OFFSET(0x2C)], InterruptReturn
  mov [IV_SEGMENT(0x2C)], ax
  mov word [IV_OFFSET(0x2D)], InterruptReturn
  mov [IV_SEGMENT(0x2D)], ax
  mov word [IV_OFFSET(0x2E)], InterruptReturn
  mov [IV_SEGMENT(0x2E)], ax
  mov word [IV_OFFSET(0x2F)], InterruptReturn
  mov [IV_SEGMENT(0x2F)], ax
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
  in al, PORT_SYSTEM_CONTROL_A
  push ax
  in al, PORT_SYSTEM_CONTROL_B
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

CPU_8086        equ 1
CPU_80286       equ 2
CPU_80386       equ 3
CPU_80486       equ 4

FPU_NOT_PRESENT equ 0
FPU_8087        equ 1
FPU_80287       equ 2
FPU_80387       equ 3

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

;
; NmiMask
;
NmiMask:
  push ax
  pushf
  cli
  mov al, 0x80
  out PORT_RTC_INDEX, al
  IO_DELAY
  in al, PORT_RTC_DATA
  popf
  pop ax
  ret

;
; NmiUnmask
;
NmiUnmask:
  push ax
  pushf
  cli
  mov al, 0x00
  out PORT_RTC_INDEX, al
  IO_DELAY
  in al, PORT_RTC_DATA
  popf
  pop ax
  ret

;-------------------------------------------------------------------------------
; A20 GATE
;-------------------------------------------------------------------------------

;
; A20Dump
;
A20Dump:
  push ax
  push bx
  push si
  mov ax, BIOS_15H_QUERY_A20_SUPPORT
  int 0x15
  jc .query_a20_support_not_supported
  push bx
  mov si, .message_query_a20_support
  call PrintFormatted
  add sp, 2
  pop si
  pop bx
  pop ax
  ret
.query_a20_support_not_supported:
  mov al, ah
  xor ah, ah
  push ax
  mov si, .message_query_a20_support_not_supported
  call PrintString
  call HaltSystem
.message_query_a20_support:
  db 'A20: BX = %h',CR,LF,0
.message_query_a20_support_not_supported:
  db 'A20: could not query BIOS for A20 support (AH = %b)',CR,LF,0

;
; A20Disable
;
A20Disable:
  push ax
  in al, PORT_SYSTEM_CONTROL_A
  and al, 0xfd
  out PORT_SYSTEM_CONTROL_A, al
  pop ax
  ret

;
; A20Enable
;
A20Enable:
  push ax
  in al, PORT_SYSTEM_CONTROL_A
  or al, 0x02
  out PORT_SYSTEM_CONTROL_A, al
  pop ax
  ret

;
; A20Test
;
A20Test:
  push ax
  push si
  push es
  mov ax, 0xffff
  mov es, ax
  mov al, 0xaa
  mov ah, 0x55
  mov [0x0600], al
  mov [es:0x0610], ah
  mov al, [0x0600]
  mov ah, [es:0x0610]
  cmp al, ah
  jnz .different
.same:
  mov si, .message_a20_disabled
  call PrintString
  call HaltSystem
.different:
  mov si, .message_a20_enabled
  call PrintString
.epilogue:
  pop es
  pop si
  pop ax
  ret
.message_a20_enabled:
  db "A20 is enabled",CR,LF,0
.message_a20_disabled:
  db "A20 is disabled",CR,LF,0

;-------------------------------------------------------------------------------
; PROGRAMMABLE INTERRUPT CONTROLLER (8259A)
;-------------------------------------------------------------------------------

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
  IO_DELAY
.icw2:
  mov al, bl
  test al, 0x07
  jnz .invalid_base
  out PORT_PIC_MASTER_DATA, al
  mov al, bh
  and al, 0x07
  jnz .invalid_base
  out PORT_PIC_SLAVE_DATA, al
  IO_DELAY
.icw3:
  mov al, PIC_ICW3_MASTER_IRQ2
  out PORT_PIC_MASTER_DATA, al
  mov al, PIC_ICW3_SLAVE_IRQ2
  out PORT_PIC_SLAVE_DATA, al
  IO_DELAY
.icw4:
  mov al, PIC_ICW4_8086_MODE | PIC_ICW4_MANUAL_EOI
  out PORT_PIC_MASTER_DATA, al
  out PORT_PIC_SLAVE_DATA, al
  IO_DELAY
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
  db 'PIC STATUS [M] IRR=%b ISR=%b IMR=%b [S] IRR=%b ISR=%b IMR=%b',CR,LF,0

;-------------------------------------------------------------------------------
; PAGING
;-------------------------------------------------------------------------------

[cpu 386]
[bits 32]

;
; PageTableSetup
;
PageTableSetup:
  pusha
.page_directory:
  xor eax, eax
  mov ecx, 1024
.page_directory_loop:
  mov [PageDirectoryBoot+4*ecx-4], eax
  loop .page_directory_loop
.page_directory_fill:
  mov eax, PageTable0Boot
  or eax, PAGE_PRESENT | PAGE_RW
  mov [PageDirectoryBoot+0x000], eax
  mov eax, PageTable0User
  or eax, PAGE_PRESENT | PAGE_RW | PAGE_USER
  mov [PageDirectoryUser+0x000], eax
  mov eax, PageTable8
  or eax, PAGE_PRESENT | PAGE_RW
  mov [PageDirectoryBoot+0x800], eax
  mov [PageDirectoryUser+0x800], eax
  mov eax, PageTableC
  or eax, PAGE_PRESENT | PAGE_RW
  mov [PageDirectoryBoot+0xC00], eax
  mov [PageDirectoryUser+0xC00], eax
.page_table:
  mov eax, 0x003ff000 | PAGE_PRESENT | PAGE_RW
  mov ecx, 1024
.page_table_loop:
  mov [PageTable0Boot+4*ecx-4], eax
  mov [PageTableC+4*ecx-4], eax
  sub eax, 0x00001000
  loop .page_table_loop
.epilogue:
  popa
  ret

[bits 16]
[cpu 8086]

;-------------------------------------------------------------------------------
; DATA
;-------------------------------------------------------------------------------

CpuList:
  dw 0, MessageCpu8086, MessageCpu80286, MessageCpu80386, MessageCpu80486

FpuList:
  dw MessageFpuNotPresent, MessageFpu8087, MessageFpu80287, MessageFpu80387

FileNameKernel:
  db 'KERNEL  ELF',0

FileNameUser:
  db 'USER    ELF',0

HexDigits:
  db '0123456789ABCDEF'

;-------------------------------------------------------------------------------
; DESCRIPTOR TABLES
;-------------------------------------------------------------------------------

SELECTOR_NULL       equ GDT.null        - GDT.start
SELECTOR_NOTPRESENT equ GDT.notpresent  - GDT.start
SELECTOR_DATA0      equ GDT.data0       - GDT.start
SELECTOR_CODE0      equ GDT.code0       - GDT.start

align 8
GDT:
.start:
.null:
  dd 0
  dd 0
.notpresent:
  dd 0
  dd 0
.data0:
  dw 0xffff
  dw 0
  db 0
  db 10010010b
  db 11001111b
  db 0
.code0:
  dw 0xffff
  dw 0
  db 0
  db 10011010b
  db 11001111b
  db 0
.end:

GDT_Register:
.limit:
  dw GDT.end - GDT.start - 1
.base:
  dd GDT

;-------------------------------------------------------------------------------
; MESSAGES
;-------------------------------------------------------------------------------

MessageArithmeticOverflow:
  db 'ARITHMETIC OVERFLOW',CR,LF,0

MessageBreakPoint:
  db 'BREAKPOINT',CR,LF,0

MessageCpu8086:
  db '8088/8086/80186',0

MessageCpu80286:
  db '80286',0

MessageCpu80386:
  db '80386',0

MessageCpu80486:
  db '80486 (or higher)',0

MessageCpuFpu:
  db 'CPU: %s    FPU: %s',CR,LF,0

MessageDebugDiskRead:
  db 'DiskRead: D = %h, C = %d, H = %d, S = %d',CR,LF,0

MessageDiskError:
  db 'DISK ERROR!',CR,LF,0

MessageFpuNotPresent:
  db 'Not present',0

MessageFpu8087:
  db '8087',0

MessageFpu80287:
  db '80287',0

MessageFpu80387:
  db '80387 (or higher)',0

MessageDiskParameters:
  db 'Boot device %h (%d Heads, %d Sectors/Track, %d Bytes/Sector)',CR,LF,0

MessageDivisionByZero:
  db 'DIVISION BY ZERO',CR,LF,0

MessageFatParameters:
  db '%d Sectors/Cluster, FAT @ %d, Root Directory @ %d, Data Area @ %d',CR,LF,0

MessageFileInfo:
  db '%s: Sectors = %d, Size = %d, Sector = %d, Cluster = %d',CR,LF,0

MessageFileNotFound:
  db "%s not found.",CR,LF,0

MessageFloppyMotorWait:
  db 'Waiting for floppy motor to stop...',CR,LF,0

MessageIrqTimer:
  db 'TICK!',CR,LF,0

MessageMemorySize:
  db '%d KiB conventional memory, %d KiB extended memory',CR,LF,0

MessageNonMaskableInterrupt:
  db 'NON-MASKABLE INTERRUPT (B = %b, A = %b)',CR,LF,0

MessageNoCoprocessor:
  db 'NO COPROCESSOR',CR,LF,0

MessageNotImplemented:
  db 'OPERATION NOT IMPLEMENTED (Line = %d)',CR,LF,0

MessagePicInvalidBase:
  db 'PicInitialize: Invalid base vector (BX = %h)',CR,LF,0

MessageSingleStep:
  db 'SINGLE STEP',CR,LF,0

MessageSystemHalted:
  db 'SYSTEM HALTED!',CR,LF,0

MessageUndefinedInstruction:
  db 'UNDEFINED INSTRUCTION',CR,LF,0

;-------------------------------------------------------------------------------
; BLOCK STARTING SYMBOL
;-------------------------------------------------------------------------------

section .bss
  FpuScratch                        resw 1
  DiskBiosDriveNumber               resw 1
  DiskNumberOfHeads                 resw 1
  DiskSectorsPerTrack               resw 1
  DiskBytesPerSector                resw 1
  FatSectorsPerCluster              resw 1
  FatFirstFileAllocationTableSector resw 1
  FatFirstRootDirectorySector       resw 1
  FatFirstDataAreaSector            resw 1
  DirectoryFirstSector              resw 1
  DirectoryCurrentSector            resw 1
  ;DirectoryTotalEntries             resw 1
  DirectoryCurrentEntry             resw 1
  FileCurrentSector                 resw 1

align 4096, resb 1
  PageDirectoryBoot                 resd 1024
  PageDirectoryUser                 resd 1024
  PageTable0Boot                    resd 1024
  PageTable0User                    resd 1024
  PageTable8                        resd 1024
  PageTableC                        resd 1024

;-------------------------------------------------------------------------------
; ABSOLUTE
;-------------------------------------------------------------------------------

absolute 0x7000
  SectorBufferFAT           resb 512
  SectorBufferDirectory     resb 512
