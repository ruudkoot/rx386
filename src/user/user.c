#define size_t int

extern unsigned char _inb(int port);
extern int _syscall_consoleout(char c);
extern int _syscall_waitirq(int irq);
extern int _syscall_eoi(int irq);

int getchar();
int putchar(int c);
int printf(const char * format, ...);
int readline(char * buf, size_t len);

#define PORT_KEYB_DATA 0x060

#define KBDBUF_SIZE 100

unsigned char kbdbuf[KBDBUF_SIZE];
unsigned int kbdbuf_start = 0;
unsigned int kbdbuf_end = 0;
int kbd_decode(unsigned char k);

#define CMDLINE_SIZE 100

int c_thread_a() {
  char cmdline[CMDLINE_SIZE];
  for(;;) {
    printf("\n\x14 ");
    readline(cmdline, CMDLINE_SIZE);
    printf(cmdline);
  }
}

int c_thread_b() {
  unsigned char k;
  for (;;) {
    _syscall_waitirq(1);
    k = _inb(PORT_KEYB_DATA);
    _syscall_eoi(1);
    if ((kbdbuf_end+1) % KBDBUF_SIZE != kbdbuf_start) {
      kbdbuf[kbdbuf_end] = k;
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

// keyboard

char key_normal[] = "..1234567890-=\b?"
                    "qwertyuiop[]\n?as"
                    "dfghjkl;'`??zxcv"
                    "bnm,./??? ??????"
                    "????????????????"
                    "????????????????"
                    "????????????????"
                    "????????????????";
char key_shift[] =  "..!@#$%^&*()_+??"
                    "QWERTYUIOP{}??AS"
                    "DFGHJKL:\"~??ZXCV"
                    "BNM<>???? ??????"
                    "????????????????"
                    "????????????????"
                    "????????????????"
                    "????????????????";

#define SCANCODE_SHIFT_LEFT   42
#define SCANCODE_SHIFT_RIGHT  54

int kbd_decode(unsigned char k) {
  static int shift = 0;
  switch (k & 0x7F) {
    case SCANCODE_SHIFT_LEFT:
    case SCANCODE_SHIFT_RIGHT:
      shift = !(k & 0x80);
      return 0;
    default:
      if (k & 0x80) return 0;
      return shift ? key_shift[k] : key_normal[k];
  }
}

// stdio

int getchar() {
  unsigned char c = 0;
  while (!c) {
    while (kbdbuf_start == kbdbuf_end); // FIXME: notification
    c = kbd_decode(kbdbuf[kbdbuf_start]);
    kbdbuf_start = (kbdbuf_start + 1) % KBDBUF_SIZE;
  }
  putchar(c);
  return c;
}

int putchar(int c) {
  switch (c) {
    case '\b':
      _syscall_consoleout('\b');
      _syscall_consoleout(' ');
      _syscall_consoleout('\b');
      break;
    case '\n':
      _syscall_consoleout('\n');
      _syscall_consoleout('\r');
      break;
    default:
      _syscall_consoleout(c);
  }
  return c;
}

int printf(const char * format, ...) {
  int i = 0;
  while (*format) {
    putchar(*format);
    format++;
    i++;
  }
  return i;
}

int readline(char * buf, size_t len) {
  int i = 0;
  char c;
  while (i < len) {
    c = getchar();
    switch (c) {
      case '\b':
        if (i > 0) {
          buf--;
          i--;
        }
        break;
      case '\n':
        goto break_loop;
      default:
        *buf++ = c;
        i++;
    }
  }
break_loop:
  *buf++ = '\0';
  return i;
}