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
DEL                         equ 127

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
; PAGE TABLE
;-------------------------------------------------------------------------------

PAGE_SIZE                   equ 4096

PAGE_PRESENT                equ 0x001
PAGE_RW                     equ 0x002
PAGE_USER                   equ 0x004
PAGE_WRITETHROUGH           equ 0x008
PAGE_CACHEDISABLED          equ 0x010
PAGE_ACCESSED               equ 0x020
PAGE_DIRTY                  equ 0x040
PAGE_LARGE                  equ 0x080
PAGE_GLOBAL                 equ 0x100
PAGE_AVAIL0                 equ 0x200
PAGE_AVAIL1                 equ 0x400
PAGE_AVAIL2                 equ 0x800

;-------------------------------------------------------------------------------
; I/O DELAY
;-------------------------------------------------------------------------------

PORT_DELAY                  equ 0xED

;
; IO_DELAY
;
;   I/O access in the ISA range (000h - 3FFh) should take 1 microsecond and can
;   be used to generate short delays before accessing devices.
;
%define IO_DELAY            out PORT_DELAY, al

;-------------------------------------------------------------------------------
; DIRECT MEMORY ACCESS CONTROLLER (8237A)
;-------------------------------------------------------------------------------

PORT_DMA_1_ADDRESS_0        equ 0x000
PORT_DMA_1_COUNT_0          equ 0x001
PORT_DMA_1_ADDRESS_1        equ 0x002
PORT_DMA_1_COUNT_1          equ 0x003
PORT_DMA_1_ADDRESS_2        equ 0x004
PORT_DMA_1_COUNT_2          equ 0x005
PORT_DMA_1_ADDRESS_3        equ 0x006
PORT_DMA_1_COUNT_3          equ 0x007
PORT_DMA_1_STATUS           equ 0x008 ; (R)
PORT_DMA_1_COMMAND          equ 0x008 ; (W)
PORT_DMA_1_REQUEST          equ 0x009 ; (W)
PORT_DMA_1_CHANNEL_MASK     equ 0x00A ; (W)
PORT_DMA_1_MODE             equ 0x00B ; (W)
PORT_DMA_1_BUFFER           equ 0x00D ; (R)
PORT_DMA_1_MASK             equ 0x00F ; (W)

PORT_DMA_2_ADDRESS_0        equ 0x0C0
PORT_DMA_2_COUNT_0          equ 0x0C1
PORT_DMA_2_ADDRESS_1        equ 0x0C2
PORT_DMA_2_COUNT_1          equ 0x0C3
PORT_DMA_2_ADDRESS_2        equ 0x0C4
PORT_DMA_2_COUNT_2          equ 0x0C5
PORT_DMA_2_ADDRESS_3        equ 0x0C6
PORT_DMA_2_COUNT_3          equ 0x0C7
PORT_DMA_2_STATUS           equ 0x0D0 ; (R)
PORT_DMA_2_COMMAND          equ 0x0D0 ; (W)
PORT_DMA_2_REQUEST          equ 0x0D2 ; (W)
PORT_DMA_2_CHANNEL_MASK     equ 0x0D4 ; (W)
PORT_DMA_2_MODE             equ 0x0D6 ; (W)
PORT_DMA_2_BUFFER           equ 0x0DA ; (R)
PORT_DMA_2_MASK             equ 0x0DE ; (W)

PORT_DMA_PAGE_0             equ 0x087
PORT_DMA_PAGE_1             equ 0x083
PORT_DMA_PAGE_2             equ 0x081
PORT_DMA_PAGE_3             equ 0x082
PORT_DMA_PAGE_4             equ 0x08F
PORT_DMA_PAGE_5             equ 0x08B
PORT_DMA_PAGE_6             equ 0x089
PORT_DMA_PAGE_7             equ 0x08A

;-------------------------------------------------------------------------------
; PROGRAMMABLE INTERRUPT CONTROLLER (8259A)
;-------------------------------------------------------------------------------

PORT_PIC_MASTER_CMD         equ 0x020
PORT_PIC_MASTER_DATA        equ 0x021
PORT_PIC_SLAVE_CMD          equ 0x0a0
PORT_PIC_SLAVE_DATA         equ 0x0a1

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
; PROGRAMMABLE INTERVAL TIMER (828253/8254)
;-------------------------------------------------------------------------------

PORT_PIT_1_COUNTER0         equ 0x040 ; (RW)
PORT_PIT_1_COUNTER1         equ 0x041 ; (RW)
PORT_PIT_1_COUNTER2         equ 0x042 ; (RW)
PORT_PIT_1_CONTROL          equ 0x043 ; (W)

PORT_PIT_2_COUNTER0         equ 0x048 ; (RW)
PORT_PIT_2_COUNTER1         equ 0x049 ; (RW)
PORT_PIT_2_COUNTER2         equ 0x04A ; (RW)
PORT_PIT_2_CONTROL          equ 0x04B ; (W)

;-------------------------------------------------------------------------------
; KEYBOARD CONTROLLER (8042)
;-------------------------------------------------------------------------------

PORT_KEYB_DATA              equ 0x060
PORT_KEYB_CONTROL           equ 0x064

;-------------------------------------------------------------------------------
; REAL-TIME CLOCK & NON-MASKABLE INTERRUPTS
;-------------------------------------------------------------------------------

PORT_RTC_INDEX              equ 0x070
PORT_RTC_DATA               equ 0x071

PORT_SYSTEM_CONTROL_A       equ 0x092
PORT_SYSTEM_CONTROL_B       equ 0x061

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
; INTERRUPT VECTOR TABLE
;-------------------------------------------------------------------------------

%define IV_OFFSET(x) (4*x)
%define IV_SEGMENT(x) (4*x+2)

;-------------------------------------------------------------------------------
; BIOS DATA AREA
;-------------------------------------------------------------------------------

BDA_PORT_COM1               equ 0x00400
BDA_PORT_COM2               equ 0x00402
BDA_PORT_COM3               equ 0x00403
BDA_PORT_COM4               equ 0x00404
BDA_PORT_LPT1               equ 0x00408
BDA_PORT_LPT2               equ 0x0040A
BDA_PORT_LPT3               equ 0x0040C
BDA_PORT_LPT4               equ 0x0040E ; PC/XT
BDA_EBDA_SEGMENT            equ 0x0040E ; PS/2
BDA_EQUIPMENT_WORD          equ 0x00410
BDA_INFRARED_KB_ERRORS      equ 0x00412 ; PCjr
BDA_MEMORY_SIZE             equ 0x00413
BDA_PS2_BIOS_CONTROL_FLAGS  equ 0x00416
BDA_KB_FLAGS                equ 0x00417
BDA_KB_BUFFER_HEAD          equ 0x0041A
BDA_KB_BUFFER_TAIL          equ 0x0041C
BDA_KB_BUFFER               equ 0x0041E
BDA_DRIVE_RECALIBRATION     equ 0x0043E
BDA_DRIVE_MOTOR_STATUS      equ 0x0043F
BDA_MOTOR_SHUTOFF_COUNTER   equ 0x00440
BDA_PORT_CRTC               equ 0x00463

;-------------------------------------------------------------------------------
; DOS COMMUNICATION AREA
;-------------------------------------------------------------------------------

DCA_PRINT_SCREEN_STATUS     equ 0x00500

;-------------------------------------------------------------------------------
; LOADALL (80286)
;-------------------------------------------------------------------------------

LOADALL_MSW                 equ 0x00806
LOADALL_TR                  equ 0x00816
LOADALL_FLAGS               equ 0x00818
LOADALL_IP                  equ 0x0081A
LOADALL_LDT                 equ 0x0081C
LOADALL_DS                  equ 0x0081E
LOADALL_SS                  equ 0x00820
LOADALL_CS                  equ 0x00822
LOADALL_ES                  equ 0x00824
LOADALL_DI                  equ 0x00826
LOADALL_SI                  equ 0x00828
LOADALL_BP                  equ 0x0082A
LOADALL_SP                  equ 0x0082C
LOADALL_BX                  equ 0x0082E
LOADALL_DX                  equ 0x00830
LOADALL_CX                  equ 0x00832
LOADALL_AX                  equ 0x00834
LOADALL_ES_DESCRIPTOR       equ 0x00836
LOADALL_CS_DESCRIPTOR       equ 0x0083C
LOADALL_SS_DESCRIPTOR       equ 0x00842
LOADALL_GDTR                equ 0x0084E
LOADALL_LDT_DESCRIPTOR      equ 0x00854
LOADALL_IDTR                equ 0x0085A
LOADALL_TSS_DESCRIPTOR      equ 0x00860

;-------------------------------------------------------------------------------
; BIOS PARAMTER BLOCK
;-------------------------------------------------------------------------------

BOOT_SECTOR                 equ 0x07C00

BPB_JUMP                    equ 0x000
BPB_SYSTEMNAME              equ 0x003
BPB_BYTESPERSECTOR          equ 0x00B
BPB_SECTORSPERCLUSTER       equ 0x00D
BPB_RESERVEDSECTORS         equ 0x00E
BPB_NUMBEROFFATS            equ 0x010
BPB_ROOTDIRECTORYENTRIES    equ 0x011
BPB_TOTALNUMBEROFSECTORS    equ 0x013
BPB_MEDIADESCRIPTOR         equ 0x015
BPB_SECTORSPERFAT           equ 0x016
BPB_SECTORSPERTRACK         equ 0x018
BPB_NUMBEROFHEADS           equ 0x01A
BPB_HIDDENSECTORS           equ 0x01C
BPB_TOTALNUMBEROFSECTORS2   equ 0x020
BPB_PHYSICALUNIT            equ 0x024
BPB_RESERVED                equ 0x025
BPB_MAGICNUMBER             equ 0x026
BPB_VOLUMESERIALNUMBER      equ 0x027
BPB_VOLUMELABEL             equ 0x02B
BPB_FILESYSTEM              equ 0x036
BPB_BOOTCODE                equ 0x03E
BPB_SIGNATURE               equ 0x1FE

;-------------------------------------------------------------------------------
; BIOS
;-------------------------------------------------------------------------------

BIOS_10H_SET_VIDEO_MODE     equ 0x0000
BIOS_10H_LOAD_8X8_FONT      equ 0x1112

VIDEO_MODE_3                equ 0x0003


BIOS_15H_DISABLE_A20        equ 0x2400
BIOS_15H_ENABLE_A20         equ 0x2401
BIOS_15H_A20_STATUS         equ 0x2402
BIOS_15H_QUERY_A20_SUPPORT  equ 0x2403

;-------------------------------------------------------------------------------
; FILE ALLOCATION TABLE
;-------------------------------------------------------------------------------

ROOT_DIRECTORY_CLUSTER      equ 1

DIRECTORY_ENTRY_NAME        equ 0x00
DIRECTORY_ENTRY_EXT         equ 0x08
DIRECTORY_ENTRY_ATTR        equ 0x0c
DIRECTORY_ENTRY_TIME        equ 0x16
DIRECTORY_ENTRY_DATE        equ 0x18
DIRECTORY_ENTRY_CLUSTER     equ 0x1a
DIRECTORY_ENTRY_SIZE        equ 0x1c

%endif