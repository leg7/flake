#!/bin/sh

nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko -f /home/nixos/flake/#testing
nix-shell -p sbctl --run 'sbctl create-keys'
mkdir -p /mnt/persistent/etc/secureboot
cp -r /etc/secureboot /mnt/persistent/etc/secureboot
cp -r /etc/secureboot /mnt/etc/
nixos-install --no-root-passwd --flake /home/nixos/flake#testing --cores 0 --root /mnt
