extern char _inb(int port);
extern int _syscall_consoleout(char c);
extern int _syscall_waitirq(int irq);
extern int _syscall_eoi(int irq);

#define PORT_KEYB_DATA 0x060

#define KBDBUF_SIZE 100

char kbdbuf[KBDBUF_SIZE];
int kbdbuf_start;
int kbdbuf_end;

int c_thread_a() {
  char c;
  for (;;) {
    if (kbdbuf_start != kbdbuf_end) {
      c = kbdbuf[kbdbuf_start];
      _syscall_consoleout(c);
      kbdbuf_start = (kbdbuf_start + 1) % KBDBUF_SIZE;
    }
  }
}

int c_thread_b() {
  kbdbuf_start = 0;
  kbdbuf_end = 0;
  char k;
  for (;;) {
    _syscall_waitirq(1);
    k = _inb(PORT_KEYB_DATA);
    _syscall_eoi(1);
    if ((kbdbuf_end+1) % KBDBUF_SIZE != kbdbuf_start) {
      kbdbuf[kbdbuf_end+1] = k;
      kbdbuf_end = (kbdbuf_end + 1) % KBDBUF_SIZE;
    }
  }
}

int c_thread_c() {
  for (;;) {
  }
}

int c_thread_d() {
  for (;;) {
  }
}