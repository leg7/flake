#!/bin/sh

if [ "$1" = "secureboot" ]; then
	nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko -f /home/nixos/flake/#"$2"
	nix-shell -p sbctl --run 'sbctl create-keys'
	mkdir -p /mnt/persistent/etc/secureboot
	cp -r /etc/secureboot /mnt/persistent/etc/
	cp -r /etc/secureboot /mnt/etc/
	nixos-install --no-root-passwd --flake /home/nixos/flake#"$2" --cores 0 --root /mnt
elif [ "$1" = "rpi4-firmware" ]; then
	cd /mnt/boot || exit
	nix-shell -p wget --run 'wget https://github.com/pftf/RPi4/releases/download/v1.37/RPi4_UEFI_Firmware_v1.37.zip'
	unzip RPi4_UEFI_Firmware_v1.37.zip
	rm README.md RPi4_UEFI_Firmware_v1.37.zip
else
	nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko -f /home/nixos/flake/#"$1"
	nixos-install --no-root-passwd --flake /home/nixos/flake#"$1" --cores 0 --root /mnt --accept-flake-config
fi
