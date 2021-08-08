#define FDC_STATUS_REGISTER_A               0x3F0
#define FDC_STATUI_REGISTER_B               0x3F1
#define FDC_DIGITAL_OUTPUT_REGISTER         0x3F2
#define FDC_TAPE_DRIVE_REGISTER             0x3F3
#define FDC_MAIN_STATUS_REGISTER            0x3F4
#define FDC_DATARATE_SELECT_REGISTER        0x3F4
#define FDC_DATA_FIFO                       0x3F5
#define FDC_DIGITAL_INPUT_REGISTER          0x3F7
#define FDC_CONFIGURATION_CONTROL_REGISTER  0x3F7

#define FDC_DOR_DRIVESELECT_A               0x00
#define FDC_DOR_DRIVESELECT_B               0x01
#define FDC_DOR_DRIVESELECT_C               0x02
#define FDC_DOR_DRIVESELECT_D               0x03
#define FDC_DOR_ENABLE                      0x04
#define FDC_DOR_DMA                         0x08
#define FDC_DOR_MOTORENABLE_A               0x10
#define FDC_DOR_MOTORENABLE_B               0x20
#define FDC_DOR_MOTORENABLE_C               0x40
#define FDC_DOR_MOTORENABLE_D               0x80

#define FDC_DRIVE_A                         0
#define FDC_DRIVE_B                         1
#define FDC_DRIVE_C                         2
#define FDC_DRIVE_D                         3

typedef struct fdc_chs_t {
  int c;
  int h;
  int s;
} fdc_chs_t;

int fdc_chs_to_lba(int c, int h, int s);
fdc_chs_t fdc_lba_to_chs(int lba);
void fdc_dma_setup();
void fdc_enable(int drive);
void fdc_disble();
void fdc_commandbyte(unsigned char cb);
void fdc_readsector(int d, int c, int h, int s);