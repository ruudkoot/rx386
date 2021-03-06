BOOT_SEG            equ 0x0000
BOOT_BASE           equ 0x00001000
BOOT_STACK          equ 0x00010000

KERNEL_PHYS         equ 0x00010000
KERNEL_VIRT         equ 0x80000000
KERNEL_ENTRY        equ 0x80001000

USER_PHYS           equ 0x00020000
USER_VIRT           equ 0x00000000
USER_ENTRY          equ 0x00001000
USER_STACK          equ 0x00000000 ; FIXME

SYSCALL_CONSOLEOUT  equ 0x30
SYSCALL_SETTCB      equ 0x31
SYSCALL_SETIOPB     equ 0x32
SYSCALL_WAIT        equ 0x33
SYSCALL_SIGNAL      equ 0x34
SYSCALL_EOI         equ 0x35
SYSCALL_YIELD       equ 0x36

TCB_NEXT            equ 0
TCB_PREV            equ 4
TCB_CR3             equ 8
TCB_EIP             equ 12
TCB_EFLAGS          equ 16
TCB_EAX             equ 20
TCB_ECX             equ 24
TCB_EDX             equ 28
TCB_EBX             equ 32
TCB_ESP             equ 36
TCB_EBP             equ 40
TCB_ESI             equ 44
TCB_EDI             equ 48
TCB_CS              equ 52
TCB_DS              equ 56
TCB_ES              equ 60
TCB_FS              equ 64
TCB_GS              equ 68
TCB_SS              equ 72