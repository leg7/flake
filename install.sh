#!/bin/sh
# $1 can either be --secureboot, --grub or --legacy
[ -z "$1" ] && exit

diskGood()
{
	disks="$(lsblk --raw | grep disk | awk '{print $1}')"

	for d in $disks; do
		[ "$1" = "$d" ] && return 0
	done

	return 1
}

readDisk()
{
	disk=""

	until diskGood "$disk"; do
		lsblk >&2
		read -p "What disk are you installing your system on? (ex: sda): " disk
	done

	echo "/dev/$disk"
}

disk=$(readDisk)

if echo "$disk" | grep -q nvme; then
	efiPartition="$disk"p1
	sysPartition="$disk"p2
else
	efiPartition="$disk"1
	sysPartition="$disk"2
fi

fs()
{
    # LVM
    pvcreate /dev/mapper/cryptLvm
    vgcreate pool /dev/mapper/cryptLvm

    size="$(awk 'NR==1 {print $2 * 1.5 / 1024 / 1024}' /proc/meminfo)" # 1.5x the total ram
    lvcreate -L "$size"G -n swap pool
    lvcreate -l 100%FREE -n nix pool

    # Make filesystems
    mkfs.fat -n ESP -F32 "$efiPartition"
    mkfs.f2fs -l nix -O extra_attr,inode_checksum,sb_checksum,compression /dev/pool/nix
    mkswap /dev/pool/swap
    swapon /dev/pool/swap

    # Mount
    mount -m -t tmpfs none /mnt
    mount -m -o compress_algorithm=zstd,compress_chksum,atgc,gc_merge,lazytime /dev/pool/nix /mnt/nix
    mount -m "$efiPartition" /mnt/boot
    mkdir -p /mnt/nix/persistent/etc/ # for impermanence to work
}

# Partition disks
parted "$disk" mklabel gpt
parted "$disk" mkpart primary fat32 0% 512MiB set 1 esp on
parted "$disk" mkpart primary 512MiB 100%

if [ "$1" = "secureboot" ]; then
    # Encrypt disk (you might need to adjust the memory needed)
    cryptsetup luksFormat --type luks2 -i 5000 --pbkdf argon2id --pbkdf-memory 4000000 --hash sha512 "$sysPartition"
    cryptsetup open "$sysPartition" cryptLvm
    cryptsetup config "$sysPartition" --label cryptLvm

    fs

    nix-shell -p sbctl --run 'sbctl create-keys'
    cp -r /etc/secureboot /mnt/nix/persistent/etc/secureboot
    cp -r /etc/secureboot /mnt/etc/
elif [ "$1" = "grub" ]; then
    cryptsetup luksFormat --type luks1 -i 5000 --hash sha512 "$sysPartition"
    dd if=/dev/urandom of=./keyfile.bin bs=1024 count=4
    cryptsetup luksAddKey "$sysPartition" keyfile.bin
    cryptsetup open "$sysPartition" cryptLvm -d keyfile.bin

    fs

    # Move the key
    mkdir -p /mnt/nix/persistent/etc/secrets/initrd/
    mkdir -p /mnt/etc/secrets/initrd/
    cp keyfile.bin /mnt/etc/secrets/initrd/
    cp keyfile.bin /mnt/nix/persistent/etc/secrets/initrd/
    chmod 000 /mnt/nix/persistent/etc/secrets/initrd/keyfile.bin
fi

nixos-generate-config --root /mnt
alias nins='sudo nixos-install --no-root-passwd --flake /mnt/etc/nixos/#eleum --cores 0 --root /mnt'
