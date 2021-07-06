rx386: dist/disk.img

clean:
	rm dist/*.*

dist/disk.img: dist/bootsect.bin dist/boot.sys dist/kernel.elf dist/user.elf
	dd if=/dev/zero of=dist/disk.tmp bs=512 count=2880
	mkfs.fat dist/disk.tmp
	dd if=dist/bootsect.bin of=dist/disk.tmp conv=notrunc
	mcopy -vi dist/disk.tmp dist/boot.sys ::
	mattrib -i dist/disk.tmp -a +rs ::boot.sys
	mcopy -vi dist/disk.tmp dist/kernel.elf ::
	mattrib -i dist/disk.tmp -a +rs ::kernel.elf
	mcopy -vi dist/disk.tmp dist/user.elf ::
	mattrib -i dist/disk.tmp -a +rs ::user.elf
	mv dist/disk.tmp dist/disk.img

dist/bootsect.bin: src/boot/bootsect.asm
	nasm src/boot/bootsect.asm -f bin -i src/include/ -o dist/bootsect.bin

dist/boot.sys: src/boot/bootsys.asm src/include/config.inc src/include/defs.inc src/include/elf.inc
	nasm src/boot/bootsys.asm -f bin -i src/include/ -o dist/boot.sys

dist/kernel.elf: src/kernel/kernel.asm src/include/config.inc src/include/defs.inc
	nasm src/kernel/kernel.asm -f elf -i src/include/ -o dist/kernel.elf
	strip --strip-unneeded dist/kernel.elf

dist/user.elf: src/user/user.asm  src/include/config.inc src/include/defs.inc
	nasm src/user/user.asm -f elf -i src/include/ -o dist/user.elf
	strip --strip-unneeded dist/user.elf