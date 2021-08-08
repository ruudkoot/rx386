#define USER_PHYS 0x00020000
#define PHYS_ADDR(x) (USER_PHYS + (int)x)

#define PORT_DMA0_ADDR            0x000
#define PORT_DMA0_COUNT           0x001
#define PORT_DMA1_ADDR            0x002
#define PORT_DMA1_COUNT           0x003
#define PORT_DMA2_ADDR            0x004
#define PORT_DMA2_COUNT           0x005
#define PORT_DMA3_ADDR            0x006
#define PORT_DMA3_COUNT           0x007
#define PORT_DMA_S_STATUS         0x008 // R
#define PORT_DMA_S_COMMAND        0x008 // W
#define PORT_DMA_S_REQUEST        0x009 // W
#define PORT_DMA_S_CHANNELMASK    0x00A // W
#define PORT_DMA_S_MODE           0x00B // W
#define PORT_DMA_S_CLEARFLIPFLOP  0x00C
#define PORT_DMA_S_INTERMEDIATE   0x00D // R
#define PORT_DMA_S_MASK           0x00F // W
#define PORT_DMA2_PAGE            0x081
#define PORT_DMA3_PAGE            0x082
#define PORT_DMA1_PAGE            0x083
#define PORT_DMA0_PAGE            0x087
#define PORT_DMA6_PAGE            0x089
#define PORT_DMA7_PAGE            0x08A
#define PORT_DMA5_PAGE            0x08B
#define PORT_DMA4_PAGE            0x08F
#define PORT_DMA4_ADDR            0x0C0
#define PORT_DMA4_COUNT           0x0C2
#define PORT_DMA5_ADDR            0x0C4
#define PORT_DMA5_COUNT           0x0C6
#define PORT_DMA6_ADDR            0x0C8
#define PORT_DMA6_COUNT           0x0CA
#define PORT_DMA7_ADDR            0x0CC
#define PORT_DMA7_COUNT           0x0CE
#define PORT_DMA_M_STATUS         0x0D0 // R
#define PORT_DMA_M_COMMAND        0x0D0 // W
#define PORT_DMA_M_REQUEST        0x0D2 // W
#define PORT_DMA_M_CHANNELMASK    0x0D4 // W
#define PORT_DMA_M_MODE           0x0D6 // W
#define PORT_DMA_M_CLEARFLIPFLOP  0x0D8 // X
#define PORT_DMA_M_INTERMEDIATE   0x0DA // R
#define PORT_DMA_M_CLEARMASTER    0x0DA // X
#define PORT_DMA_M_CLEARMASK      0x0DC // X
#define PORT_DMA_M_MASK           0x0DE // W

#define DMA_STATUS_TC0            0x01
#define DMA_STATUS_TC1            0x02
#define DMA_STATUS_TC2            0x04
#define DMA_STATUS_TC3            0x08
#define DMA_STATUS_REQ0           0x10
#define DMA_STATUS_REQ1           0x20
#define DMA_STATUS_REQ2           0x40
#define DMA_STATUS_REQ3           0x80

#define DMA_CHANNELMASK_CLEAR     0x00
#define DMA_CHANNELMASK_SET       0x04
#define DMA_CHANNELMASK_DMA0      0x00
#define DMA_CHANNELMASK_DMA1      0x01
#define DMA_CHANNELMASK_DMA2      0x02
#define DMA_CHANNELMASK_DMA3      0x03

#define DMA_MODE_DMA0             0x00
#define DMA_MODE_DMA1             0x01
#define DMA_MODE_DMA2             0x02
#define DMA_MODE_DMA3             0x03
#define DMA_MODE_VERIFY           0x00
#define DMA_MODE_READ             0x04 //???
#define DMA_MODE_WRITE            0x08
#define DMA_MODE_INVALID          0x0C  // when DMA_MODE_CASCADE?
#define DMA_MODE_AUTOINIT         0x10
#define DMA_MODE_INCREMENT        0x00
#define DMA_MODE_DECREMENT        0x20
#define DMA_MODE_DEMAND           0x00
#define DMA_MODE_SINGLE           0x40
#define DMA_MODE_BLOCK            0x80
#define DMA_MODE_CASCADE          0xC0