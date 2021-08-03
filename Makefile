CC=gcc
CFLAGS=-m32 -march=i386 -mtune=i386 -fno-pie -fno-asynchronous-unwind-tables -fno-stack-protector -Wall
LD=ld -m elf_i386

rx386: dist/disk.img

dist/disk.img: dist/boot/bootsect.bin dist/boot/boot.sys dist/kernel/kernel.elf dist/user/user.elf
	mkdir -p dist
	dd if=/dev/zero of=dist/disk.tmp bs=512 count=2880
	mkfs.fat dist/disk.tmp
	dd if=dist/boot/bootsect.bin of=dist/disk.tmp conv=notrunc
	mcopy -vi dist/disk.tmp dist/boot/boot.sys ::
	mattrib -i dist/disk.tmp -a +rs ::boot.sys
	mcopy -vi dist/disk.tmp dist/kernel/kernel.elf ::
	mattrib -i dist/disk.tmp -a +rs ::kernel.elf
	mcopy -vi dist/disk.tmp dist/user/user.elf ::
	mattrib -i dist/disk.tmp -a +rs ::user.elf
	mv dist/disk.tmp dist/disk.img

dist/boot/bootsect.bin: src/boot/bootsect.asm
	mkdir -p dist/boot
	nasm -f bin -i src/include/ -o dist/boot/bootsect.bin src/boot/bootsect.asm

dist/boot/boot.sys: src/boot/boot.asm src/include/config.inc src/include/defs.inc src/include/elf.inc src/include/kernel.inc
	mkdir -p dist/boot
	nasm -f bin -i src/include/ -o dist/boot/boot.sys src/boot/boot.asm

dist/kernel/kernel.elf: src/kernel/kernel.asm src/include/config.inc src/include/defs.inc src/include/kernel.inc src/kernel/schedule.inc
	mkdir -p dist/kernel
	nasm -f elf -i src/include/ -i src/kernel/ -o dist/kernel/kernel.elf src/kernel/kernel.asm
	strip --strip-unneeded dist/kernel/kernel.elf

dist/user/user.elf: dist/user/start.elf dist/user/user.o src/user/user.ld
	$(LD) -T src/user/user.ld
	strip --strip-unneeded dist/user/user.elf

dist/user/start.elf: src/user/start.asm src/include/config.inc src/include/defs.inc src/include/kernel.inc
	mkdir -p dist/user
	nasm -f elf -i src/include/ -o dist/user/start.elf src/user/start.asm

dist/user/user.o: src/user/user.c
	mkdir -p dist/user
	$(CC) -c $(CFLAGS) -o dist/user/user.o src/user/user.c

.PHONY: clean

clean:
	rm -rv dist/*
