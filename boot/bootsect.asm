;
; Boot sector for FAT12 floppy disks.
;

BOOTSECT_BASE equ 0x7c00

cpu   8086
bits  16
org   BOOTSECT_BASE

BOOTSECT_START:
  cli
  jmp Main0

;
; BIOS Parameter Block
;
SystemName            db 'RUUDKOOT'
BytesPerSector        dw 512
SectorsPerCluster     db 1
ReservedSectors       dw 1
NumberOfFATs          db 2
RootDirectoryEntries  dw 224
TotalNumberOfSectors  dw 2880
MediaDescriptor       db 0xf0
SectorsPerFAT         dw 9
SectorsPerTrack       dw 18
NumberOfHeads         dw 2
HiddenSectors         dd 0
TotalNumberOfSectors2 dd 0
PhysicalUnit          db 0
Reserved              db 0
MagicNumber           db 0x29
VolumeSerialNumber    dd __POSIX_TIME__
VolumeLabel           db 'RX/386 BOOT'
FileSystem            db 'FAT12   '

;
; Locate BOOT.SYS and load it into memory.
;
Main0:
  jmp 0x0000:Main1
Main1:
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x8000
  mov [PhysicalUnit], dl
  sti
Main2:
  call PrintBootMessage
  call ComputeSectorsPerCylinder
  call ComputeRootDirectorySector
  call ComputeDataAreaSector
  call LoadRootDirectorySector
  call LocateBootSys
  call BootSysClusterToSector ; FIXME: no-op
  call LoadBootSys
  jmp 0x0000:0x1000

;
; PrintBootMessage
;
PrintBootMessage:
  mov si, BootMessage
  call PrintString
  ret

;
; PrintString
;
PrintString:
.next:
  mov al, [si]
  inc si
  or al, al
  jz .break
  call PrintChar
  jmp .next
.break:
  ret

;
; PrintChar
;
PrintChar:
  mov ah, 0x0e
  mov bh, 0x00
  mov bl, 0x07
  int 0x10
  ret

;
; ComputeSectorsPerCylinder
;
ComputeSectorsPerCylinder:
  mov al, [SectorsPerTrack]
  mov ah, [NumberOfHeads]
  mul ah
  mov [SectorsPerCylinder], ax
  ret

;
; Compute the starting sector of the root directory and store in
; RootDirectorySector.
;
; Root director starts at:
;
;   SectorsPerFAT * NumberOfFATs + ReservedSectors
;
ComputeRootDirectorySector:
  mov al, [NumberOfFATs]
  mov ah, [SectorsPerFAT] ; FIXME: word
  mov dx, [ReservedSectors]
  mul ah
  add ax, dx
  mov [RootDirectorySector], ax
  ret

;
; ComputeDataAreaSector
;
ComputeDataAreaSector:
  mov bx, [BytesPerSector]
  mov cl, 5 ; 32 bytes per directory entry
  shr bx, cl
  xor dx, dx
  mov ax, [RootDirectoryEntries]
  div bx
  add ax, [RootDirectorySector]
  mov [DataAreaSector], ax
  ret

;
; Load the first sector of the root directory into the sector buffer.
;
LoadRootDirectorySector:
  mov ax, [RootDirectorySector]
  mov bx, SectorBuffer
  call LoadSector
  ret

;
; Load sector into sector buffer
;
; Inputs:
;   AX = sector number
;   ES:BX = buffer
;
LoadSector:
  push ax
  push cx
  push dx
  push bx
  push bp
  push si
  push di
  xor dx, dx
  div word [SectorsPerCylinder]
  mov ch, al
  mov ax, dx
  xor dx, dx
  div word [SectorsPerTrack]
  mov cl, dl
  inc cl
  mov dh, al
  mov dl, [PhysicalUnit]
  mov ax, 0x0201
  int 0x13
  jc FatalError
  pop di
  pop si
  pop bp
  pop bx
  pop dx
  pop cx
  pop ax
  ret

;
; Locate BOOT.SYS
;
LocateBootSys:
  mov si, SectorBuffer
  mov di, BootFile
  mov cx, 11
  repe cmpsb
  jnz FatalError
  mov ax, [SectorBuffer+0x1a]
  mov [BootSysCluster], ax
  mov ax, [SectorBuffer+0x1c]
  mov dx, [SectorBuffer+0x1e]
  div word [BytesPerSector]
  or dx, dx
  jz .noremainder
  inc ax
.noremainder:
  mov [BootSysSize], ax
  ret

;
; BootSysClusterToSector
;
BootSysClusterToSector:
  ret

;
; LoadBootSys
;
LoadBootSys:
  mov ax, [DataAreaSector]
  mov bx, 0x1000
  mov cx, [BootSysSize]
.next:
  call LoadSector
  inc ax
  add bx, [BytesPerSector]
  dec cx
  jz .break
  jmp .next
.break:
  ret

;
; InfiniteLoop
;
InfiniteLoop:
  jmp InfiniteLoop

;
; FatalError
;
FatalError:
  mov si, ErrorMessage
  call PrintString
  jmp InfiniteLoop

; Data
ErrorMessage db 'ERROR!', 0
BootMessage db 'Starting RX/386...', 13, 10, 0
BootFile db 'BOOT    SYS'

; Signature
times 510-($-$$) db 0
dw 0xaa55

;
; Uninitialized data
;
absolute 0x7000
  SectorBuffer resb 512
absolute 0x7800
  SectorsPerCylinder resw 1
  RootDirectorySector resw 1
  DataAreaSector resw 1
  BootSysCluster resw 1
  BootSysSize resw 1
  BootSysMemory resw 1
