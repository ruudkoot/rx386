#define size_t int

#define NOTIFICATION_IRQ1   1
#define NOTIFICATION_IRQ2   2
#define NOTIFICATION_IRQ3   3
#define NOTIFICATION_IRQ4   4
#define NOTIFICATION_IRQ5   5
#define NOTIFICATION_IRQ6   6
#define NOTIFICATION_IRQ7   7
#define NOTIFICATION_IRQ8   8
#define NOTIFICATION_IRQ9   9
#define NOTIFICATION_IRQ10  10
#define NOTIFICATION_IRQ11  11
#define NOTIFICATION_IRQ12  12
#define NOTIFICATION_IRQ13  13
#define NOTIFICATION_IRQ14  14
#define NOTIFICATION_IRQ15  15
#define NOTIFICATION_KBDBUF 16

extern unsigned char _inb(int port);
extern void _outb(int port, unsigned char data);
extern void _syscall_yield();
extern void _syscall_consoleout(char c);
extern void _syscall_wait(int notification);
extern void _syscall_signal(int notification);
extern void _syscall_eoi(int irq);