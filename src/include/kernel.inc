BOOT_SEG            equ 0x0000
BOOT_BASE           equ 0x00001000
BOOT_STACK          equ 0x00010000

KERNEL_PHYS         equ 0x00010000
KERNEL_VIRT         equ 0x80000000
KERNEL_ENTRY        equ 0x80001000

USER_PHYS           equ 0x00020000
USER_VIRT           equ 0x00000000
USER_ENTRY          equ 0x00001000
USER_STACK          equ 0x00003000

SYSCALL_CONSOLEOUT  equ 0x30

TCB_NEXT            equ 0
TCB_CR3             equ 4
TCB_EIP             equ 8
TCB_EFLAGS          equ 12
TCB_EAX             equ 16
TCB_ECX             equ 20
TCB_EDX             equ 24
TCB_EBX             equ 28
TCB_ESP             equ 32
TCB_EBP             equ 36
TCB_ESI             equ 40
TCB_EDI             equ 44
TCB_CS              equ 48
TCB_DS              equ 52
TCB_ES              equ 56
TCB_FS              equ 60
TCB_GS              equ 64
TCB_SS              equ 68