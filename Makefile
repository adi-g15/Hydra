GNUEFI = gnu-efi
LD = ld
CC = gcc

CFLAGS = -ffreestanding -fshort-wchar
LDFLAGS = -T Kernel/kernel.ld -static -Bsymbolic -nostdlib

SRCDIR := src
BOOTEFI := $(GNUEFI)/x86_64/bootloader/main.efi

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

SRC = $(call rwildcard,Kernel,*.c)
OBJS = $(patsubst Kernel/%.c, Build/binaries/%.o, $(SRC))
DIRS = $(wildcard Kernel/*)

bootloader:
	@-cd gnu-efi;make bootloader -s

kernel: $(OBJS) link

Build/binaries/%.o: Kernel/%.c
	@-mkdir -p $(@D)
	@-$(CC) $(CFLAGS) -c $^ -o $@

link:
	@-$(LD) $(LDFLAGS) -o Build/kernel.elf $(OBJS)

iso:
	@-dd if=/dev/zero of=Build/Hydra.iso bs=512 count=93750 > /dev/null 2>&1
	@-mformat -i Build/Hydra.iso -f 1440 ::
	@-mmd -i Build/Hydra.iso ::/EFI
	@-mmd -i Build/Hydra.iso ::/EFI/BOOT
	@-mcopy -i Build/Hydra.iso $(BOOTEFI) ::/EFI/BOOT
	@-mcopy -i Build/Hydra.iso Build/startup.nsh ::
	@-mcopy -i Build/Hydra.iso Build/kernel.elf ::
	@-mcopy -i Build/Hydra.iso Build/font.psf ::

run:
#	qemu-system-x86_64 -drive file=$(BUILDDIR)/$(OSNAME).img -m 256M -cpu qemu64 -drive if=pflash,format=raw,unit=0,file="$(OVMFDIR)/OVMF_CODE-pure-efi.fd",readonly=on -drive if=pflash,format=raw,unit=1,file="$(OVMFDIR)/OVMF_VARS-pure-efi.fd" -net none
	@-cmd.exe /C qemu-system-x86_64 -drive file=Build/Hydra.iso,format=raw -m 512M -cpu qemu64 -drive if=pflash,format=raw,unit=0,file=Build/OVMF/OVMF_CODE-pure-efi.fd,readonly=on -drive if=pflash,format=raw,unit=1,file=Build/OVMF/OVMF_VARS-pure-efi.fd -net none -boot order=d