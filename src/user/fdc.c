#include <stdlib.h>
#include "rx386.h"
#include "dma.h"
#include "fdc.h"


int printline(const char * str);

// NEC µPD765     PC
// Intel 8272A
// Intel 82072A   PC/AT
// Intel 82077A   PS/2
// Intel 82078

#define CYLINDERS_PER_DISK  80
#define HEADS_PER_CYLINDER   2
#define SECTORS_PER_TRACK   18

// FIXME: why does this not work if not initialized?
unsigned char fdc_sectorbuffer[512] = "SECTORBUFFER";

int fdc_chs_to_lba(int c, int h, int s) {
  return
    c * HEADS_PER_CYLINDER * SECTORS_PER_TRACK
      + h * SECTORS_PER_TRACK
        + s - 1;
}

fdc_chs_t fdc_lba_to_chs(int lba) {
  div_t x;
  fdc_chs_t chs;
  x = div(lba, HEADS_PER_CYLINDER * SECTORS_PER_TRACK);
  chs.c = x.quot;
  x = div(x.rem, SECTORS_PER_TRACK);
  chs.h = x.quot;
  chs.s = x.rem + 1;
  return chs;
}

#define DUMMY 0xFF

void fdc_dma_setup() {
  printline("fdc_dma_setup()\n");
  int addr = PHYS_ADDR(fdc_sectorbuffer);
  int count = 512 - 1;
  _outb(PORT_DMA_S_CHANNELMASK, DMA_CHANNELMASK_SET | DMA_CHANNELMASK_DMA2);
  _outb(PORT_DMA_S_CLEARFLIPFLOP, DUMMY);
  _outb(PORT_DMA2_ADDR, addr & 0xFF);
  _outb(PORT_DMA2_ADDR, (addr >> 8) & 0xFF);
  _outb(PORT_DMA2_PAGE, (addr >> 16) & 0xFF);
  _outb(PORT_DMA_S_CLEARFLIPFLOP, DUMMY);
  _outb(PORT_DMA2_COUNT, count & 0xFF);
  _outb(PORT_DMA2_COUNT, (count >> 8) & 0xFF);
  _outb(PORT_DMA_S_CHANNELMASK, DMA_CHANNELMASK_CLEAR | DMA_CHANNELMASK_DMA2);
}

void fdc_dma_prepare_read() {
  fdc_dma_setup();
  printline("fdc_dma_prepare_read()\n");
  _outb(PORT_DMA_S_CHANNELMASK, DMA_CHANNELMASK_SET | DMA_CHANNELMASK_DMA2);
  _outb(PORT_DMA_S_MODE, DMA_MODE_SINGLE | DMA_MODE_READ | DMA_MODE_DMA2);
  _outb(PORT_DMA_S_CHANNELMASK, DMA_CHANNELMASK_CLEAR | DMA_CHANNELMASK_DMA2);
}

void fdc_enable(int drive) {
  printline("fdc_enable()\n");
  unsigned char d;
  switch (drive) {
    case FDC_DRIVE_A:
      d = FDC_DOR_MOTORENABLE_A | FDC_DOR_DRIVESELECT_A;
      break;
    case FDC_DRIVE_B:
      d = FDC_DOR_MOTORENABLE_B | FDC_DOR_DRIVESELECT_B;
      break;
    case FDC_DRIVE_C:
      d = FDC_DOR_MOTORENABLE_C | FDC_DOR_DRIVESELECT_C;
      break;
    case FDC_DRIVE_D:
      d = FDC_DOR_MOTORENABLE_D | FDC_DOR_DRIVESELECT_D;
      break;
  }
  _outb(FDC_DIGITAL_OUTPUT_REGISTER, FDC_DOR_DMA | FDC_DOR_ENABLE | d);
}

void fdc_disable() {
  _outb(FDC_DIGITAL_OUTPUT_REGISTER, 0);
}

void fdc_commandbyte(unsigned char cb) {
  int mrq;
  for (;;) {
    mrq = _inb(FDC_MAIN_STATUS_REGISTER);
    if (mrq && 0x80 == 0x80) {
      _outb(FDC_DATA_FIFO, cb);
      return;
    }
  }
}

#define FDC_CMD_READ_SECT   0x06
#define FDC_CMD_SEEK        0x0F
#define FDC_CMD_SKIP        0x20
#define FDC_CMD_MFM         0x40
#define FDC_CMD_MULTITRACK  0x80

#define FDC_SECTORSIZE_512  0x02

#define FDC_GAP1_1440       0x1B

void fdc_readsector(int d, int c, int h, int s) {
  printline("fdc_readsector(...)\n");
  unsigned char opcode[] = {
    FDC_CMD_READ_SECT | FDC_CMD_MFM | FDC_CMD_MULTITRACK,
    (h << 2) | d,
    c,
    h,
    s,
    FDC_SECTORSIZE_512,
    SECTORS_PER_TRACK,
    FDC_GAP1_1440,
    0xFF
  };
  fdc_dma_prepare_read();
  for (int i = 0; i < 9; i++)
    fdc_commandbyte(opcode[i]);
  printline("waiting on IRQ6\n");
  _syscall_wait(NOTIFICATION_IRQ6);
  printline("received IRQ6\n");
  for (int i = 0; i < 7; i++)
    _inb(FDC_DATA_FIFO);
  printline("read results from FIFO\n");
  _syscall_eoi(NOTIFICATION_IRQ6);
  printline("EOI IRQ6\n");
  printline("[start sector buffer]\n");
  for (int i = 0; i < 512; i++)
    _syscall_consoleout(fdc_sectorbuffer[i]);
  printline("\n[end sector buffer]\n");
}