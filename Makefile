rx386: dist/disk.img

clean:
	rm dist/*.bin
	rm dist/*.sys
	rm dist/*.img

dist/disk.img: dist/bootsect.bin dist/boot.sys dist/kernel.sys
	dd if=/dev/zero of=dist/disk.img bs=512 count=2880
	mkfs.fat dist/disk.img
	dd if=dist/bootsect.bin of=dist/disk.img conv=notrunc
	mcopy -vi dist/disk.img dist/boot.sys ::
	mattrib -i dist/disk.img -a +rs ::boot.sys
	mcopy -vi dist/disk.img dist/kernel.sys ::
	mattrib -i dist/disk.img -a +rs ::kernel.sys

dist/bootsect.bin: src/boot/bootsect.asm
	nasm src/boot/bootsect.asm -f bin -i src/include/ -o dist/bootsect.bin

dist/boot.sys: src/boot/bootsys.asm src/include/defs.inc
	nasm src/boot/bootsys.asm -f bin -i src/include/ -o dist/boot.sys

dist/kernel.sys: src/kernel/kernel.asm src/include/defs.inc
	nasm src/kernel/kernel.asm -f bin -i src/include/ -o dist/kernel.sys
