ENTRY(_USER_START)
OUTPUT_FORMAT(elf32-i386)
SEARCH_DIR(dist/user)
INPUT
(
  start.elf
  user.o
)
OUTPUT(dist/user/user.elf)
SECTIONS
{
  .text(0x00001000) : ALIGN(0x1000) {
    *(.text)
  }
  .rodata : ALIGN(0x1000) {
    *(.rodata)
  }
  .data : ALIGN(0x1000) {
    *(.data)
  }
  .bss : ALIGN(0x1000) {
    *(.bss)
  }
}