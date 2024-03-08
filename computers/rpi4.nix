{ lib, ... }: {
  imports = [
    ./modules/systems/server.nix
    ./modules/mainDisk.nix
  ];

  mainDisk.name = "/dev/sda";

  users.users.user.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD1hBrP/Yz8Up3BblRkl4MwKN0tBb2iqEZCd/GnNpf+Y/X59BCP+ZfzKSfMMXxHJ+EtRGPLV8CzFezvFtyaaaNH7AKpjhCZ+XSq0jLZavp9SZgyryX3Abonwz7UFUAPECMsKbaKde6GIuvxb0CiMlEQz5ispLVjvd2OGZFjT+CqQgvCckQXPM7C8KwacWB3v0A8JlUhMM2RBn59acyxDcX+HNhlqcAZni3ivllQsZUk1wLXHtoF3aeIdtdCpHGrfd9yM4gOIZ/kGcrMnnYnQSfgZPV3vacczg0h/wfcpAhIa573NrUes+EWdYp2yZYD0xUL9pOmYLhwMjIB9E3qZd3ENqW+3j/Wj+oD97ClyyLohq2SxhFXofVvG3254kaPykXz0Enx3m7nG5vbE+HRO7Jw56a1kaHJlnCpl3PryPi+Rw9Esj7l7f2kVYXVdEPmk3/jtjzIFlqfCP2npasl5H8a/bA3EDdWOV2gawdUZffdjUhtLYCSObUbkC1zlLkL7q0= user@eleum"
  ];

  system.stateVersion = "23.11";
  time.timeZone = "Europe/Paris";
  nixpkgs.config.allowUnfree = true;

  hardware.enableAllFirmware = true;
  networking.hostName = "majula";

  services = {
    fstrim.enable = true;
    fwupd.enable = true;
  };
}

