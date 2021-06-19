%ifndef DEFS_INC
%define DEFS_INC

;-------------------------------------------------------------------------------
; ASCII
;-------------------------------------------------------------------------------

NUL                         equ 0
BEL                         equ 7
BS                          equ 8
HT                          equ 9
LF                          equ 10
VT                          equ 11
FF                          equ 12
CR                          equ 13
ESC                         equ 27

;-------------------------------------------------------------------------------
; EFLAGS
;-------------------------------------------------------------------------------

EFLAGS_CF                   equ 0x00000001
EFLAGS_PF                   equ 0x00000004
EFLAGS_AF                   equ 0x00000010
EFLASG_ZF                   equ 0x00000040
EFLAGS_SF                   equ 0x00000080
EFLAGS_TF                   equ 0x00000100
EFLAGS_IF                   equ 0x00000200
EFLAGS_DF                   equ 0x00000400
EFLAGS_OF                   equ 0x00000800
EFLAGS_IOPL                 equ 0x00003000
EFLAGS_NT                   equ 0x00004000
EFLAGS_RF                   equ 0x00010000
EFLAGS_VM                   equ 0x00020000
EFLAGS_AC                   equ 0x00040000
EFLAGS_VIF                  equ 0x00080000
EFLAGS_VIP                  equ 0x00100000
EFLAGS_ID                   equ 0x00200000

;-------------------------------------------------------------------------------
; CONTROL REGISTERS
;-------------------------------------------------------------------------------

CR0_PE                      equ 0x00000001  ; Protected Mode Enable
CR0_MP                      equ 0x00000002  ; Monitor co-processor
CR0_EM                      equ 0x00000004  ; Emulation
CR0_TS                      equ 0x00000008  ; Task Switched
CR0_ET                      equ 0x00000010  ; Extension Type
CR0_NE                      equ 0x00000020  ; Numeric Error
CR0_WP                      equ 0x00010000  ; Write Protect
CR0_AM                      equ 0x00040000  ; Alignment Mask
CR0_NW                      equ 0x20000000  ; No Write-Through
CR0_CD                      equ 0x40000000  ; Cache Disable
CR0_PG                      equ 0x80000000  ; Paging

CR4_VME                     equ 0x00000001  ; V86 Mode Extensions
CR4_PVI                     equ 0x00000002  ; PM Virtual Interrupts
CR4_TSD                     equ 0x00000004  ; Time Stamp Disable
CR4_DE                      equ 0x00000008  ; Debuggin Extensions
CR4_PSE                     equ 0x00000010  ; Page Size Extension
CR4_PAE                     equ 0x00000020  ; Physical Address Extension
CR4_MCE                     equ 0x00000040  ; Machine Check Exception
CR4_PGE                     equ 0x00000080  ; Page Global Enabled
CR4_PCE                     equ 0x00000100  ; Performance Counter Enable
CR4_OSFXSR                  equ 0x00000200  ; OS-support for FXSAVE
CR4_OSXMMEXCEPT             equ 0x00000400  ; OS-support for XMM Excpt.
CR4_UMIP                    equ 0x00000800  ; User Mode Instruction Prevention
CR4_LA57                    equ 0x00001000  ; 5-Level Paging
CR4_VMXE                    equ 0x00002000  ; Intel VT-x Virtualizaion
CR4_SMXE                    equ 0x00004000  ; Trusted Execution Technology
CR4_FSGSBASE                equ 0x00010000  ; Enable RD/WRFS/GSBASE Instruction
CR4_PCIDE                   equ 0x00020000  ; Process Context ID Enable
CR4_OSXSAVE                 equ 0x00040000  ; XSAVE Enable
CR4_SMEP                    equ 0x00100000  ; Supervisor Mode Execution Protect.
CR4_SMAP                    equ 0x00200000  ; Supervisor Mode Access Prevention
CR4_PKE                     equ 0x00400000  ; Protection Key Enable

;-------------------------------------------------------------------------------
; SEGEMENT DESCRIPTORS
;-------------------------------------------------------------------------------

SD_SIZE_16BIT               equ 0x00000000
SD_SIZE_32BIT               equ 0x00400000
SD_GRANULARITY_BYTE         equ 0x00000000
SD_GRANULARITY_PAGE         equ 0x00800000

SD_TYPE_LDT                 equ 0x00000000
SD_TYPE_TSS_16              equ 0x01000000
SD_TYPE_TSS_32              equ 0x09000000
SD_TYPE_DATA                equ 0x10000000
SD_TYPE_CODE                equ 0x18000000
SD_TSS_BUSY                 equ 0x02000000
SD_CODE_DATA_ACCESSED       equ 0x01000000
SD_DATA_WRITABLE            equ 0x02000000
SD_DATA_GROWDOWN            equ 0x04000000
SD_CODE_READABLE            equ 0x02000000
SD_CODE_CONFORMING          equ 0x04000000
SD_DPL0                     equ 0x00000000
SD_DPL1                     equ 0x20000000
SD_DPL2                     equ 0x40000000
SD_DPL3                     equ 0x60000000
SD_NOTPRESENT               equ 0x00000000
SD_PRESENT                  equ 0x80000000

;-------------------------------------------------------------------------------
; INTERRUPT DESCRIPTORS
;-------------------------------------------------------------------------------

ID_GATETYPE_TASK32          equ 0x05000000
ID_GATETYPE_INTR16          equ 0x06000000
ID_GATETYPE_TRAP16          equ 0x07000000
ID_GATETYPE_INTR32          equ 0x0E000000
ID_GATETYPE_TRAP32          equ 0x0F000000
ID_STORAGE_SEGMENT          equ 0x10000000
ID_DPL0                     equ 0x00000000
ID_DPL1                     equ 0x20000000
ID_DPL2                     equ 0x40000000
ID_DPL3                     equ 0x60000000
ID_PRESENT                  equ 0x80000000

;-------------------------------------------------------------------------------
; I/O DELAY
;-------------------------------------------------------------------------------

PORT_WAIT                   equ 0x80

%define IO_DELAY            out PORT_WAIT, al

;-------------------------------------------------------------------------------
; PROGRAMMABLE INTERRUPT CONTROLLER (8259A)
;-------------------------------------------------------------------------------

PORT_PIC_MASTER_CMD         equ 0x20
PORT_PIC_MASTER_DATA        equ 0x21
PORT_PIC_SLAVE_CMD          equ 0xa0
PORT_PIC_SLAVE_DATA         equ 0xa1

PIC_CMD_AEOI_ROTATE         equ 0x00
PIC_CMD_OCW3                equ 0x08
PIC_OCW3_READ_IRR           equ 0x02
PIC_OCW3_READ_ISR           equ 0x03
PIC_OCW3_POLLING_MODE       equ 0x04
PIC_OCW3_SMM_CLEAR          equ 0x40
PIC_OCW3_SMM_SET            equ 0x60
PIC_CMD_ICW1                equ 0x10
PIC_ICW1_NEED_ICW4          equ 0x01
PIC_ICW1_EDGE               equ 0x00
PIC_ICW1_LEVEL              equ 0x01
PIC_ICW1_CASCADE            equ 0x00
PIC_ICW1_SINGLE             equ 0x02
PIC_ICW3_MASTER_IRQ2        equ 0x04
PIC_ICW3_SLAVE_IRQ2         equ 0x02
PIC_ICW4_MCS85_MODE         equ 0x00
PIC_ICW4_8086_MODE          equ 0x01
PIC_ICW4_MANUAL_EOI         equ 0x00
PIC_ICW4_AUTO_EOI           equ 0x02
PIC_ICW4_MASTER_PIC         equ 0x00
PIC_ICW4_SLAVE_PIC          equ 0x04
PIC_ICW4_BUFFERED           equ 0x08
PIC_ICW4_SFNM               equ 0x10
PIC_CMD_NONSPECIFIC_EOI     equ 0x20
PIC_CMD_NOP                 equ 0x40
PIC_CMD_SPECIFIC_EOI        equ 0x60
PIC_SEOI_LVL0               equ 0x00
PIC_SEOI_LVL1               equ 0x01
PIC_SEOI_LVL2               equ 0x02
PIC_SEOI_LVL3               equ 0x03
PIC_SEOI_LVL4               equ 0x04
PIC_SEOI_LVL5               equ 0x05
PIC_SEOI_LVL6               equ 0x06
PIC_SEOI_LVL7               equ 0x07
PIC_CMD_AEOI_SET_ROTATE     equ 0x80
PIC_CMD_NSEOI_ROTATE        equ 0xa0
PIC_CMD_PRIORITY            equ 0xc0
PIC_CMD_SEOI_ROTATE         equ 0xe0

;-------------------------------------------------------------------------------
; KEYBOARD CONTROLLER (8042)
;-------------------------------------------------------------------------------

PORT_KEYB_DATA              equ 0x60
PORT_KEYB_CONTROL           equ 0x64

;-------------------------------------------------------------------------------
; CRT CONTROLLER (6845)
;-------------------------------------------------------------------------------

PORT_CRTC_INDEX             equ 0x3d4
PORT_CRTC_DATA              equ 0x3d5

CRTC_HORIZONTAL_TOTAL       equ 0
CRTC_HORIZONTAL_DISPLAYED   equ 1
CRTC_H_SYNC_POSITION        equ 2
CRTC_SYNC_WIDTH             equ 3
CRTC_VERTICAL_TOTAL         equ 4
CRTC_V_TOTAL_ADJUST         equ 5
CRTC_VERTICAL_DISPLAYED     equ 6
CRTC_V_SYNC_POSITION        equ 7
CRTC_INTERLACE_MODE_N_SKEW  equ 8
CRTC_MAX_SCAN_LINE_ADDRESS  equ 9
CRTC_CURSOR_START           equ 10
CRTC_CURSOR_END             equ 11
CRTC_START_ADDRESS_HIGH     equ 12
CRTC_START_ADDRESS_LOW      equ 13
CRTC_CURSOR_HIGH            equ 14
CRTC_CURSOR_LOW             equ 15
CRTC_LIGHT_PEN_HIGH         equ 16
CRTC_LIGHT_PEN_LOW          equ 17

;-------------------------------------------------------------------------------
; REAL-TIME CLOCK & NON-MASKABLE INTERRUPTS
;-------------------------------------------------------------------------------

PORT_RTC_INDEX              equ 0x70
PORT_RTC_DATA               equ 0x71

PORT_SYSTEM_CONTROL_A       equ 0x92
PORT_SYSTEM_CONTROL_B       equ 0x61

;-------------------------------------------------------------------------------
; BIOS
;-------------------------------------------------------------------------------

BIOS_15H_DISABLE_A20        equ 0x2400
BIOS_15H_ENABLE_A20         equ 0x2401
BIOS_15H_A20_STATUS         equ 0x2402
BIOS_15H_QUERY_A20_SUPPORT  equ 0x2403

%endif