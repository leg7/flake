# A profile with most (vanilla) hardening options enabled by default,
# potentially at the cost of stability, features and performance.
#
# This profile enables options that are known to affect system
# stability. If you experience any stability issues when using the
# profile, try disabling it. If you report an issue and use this
# profile, always mention that you do.
#
# I took this profile and modified it to suit my flake

{ config, lib, pkgs, ... }:

with lib;

{
  nix.settings.allowed-users = [ "@users" ];

  environment.memoryAllocator.provider = mkDefault "graphene-hardened";

  security = {
    lockKernelModules = true;
    protectKernelImage = true;
    forcePageTableIsolation = true;

    # This is required by podman to run containers in rootless mode.
    unprivilegedUsernsClone = config.virtualisation.containers.enable;

    virtualisation.flushL1DataCache = "always";

    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };

    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [ { persist = true; keepEnv = true; groups = ["wheel"]; } ];
    };

    # Required to run chrome
    chromiumSuidSandbox.enable = true;
  };

  # disable coredump that could be exploited later
  # and also slow down the system when something crashes
  systemd.coredump.enable = false;

  # enable antivirus clamav and
  # keep the signatures' database updated
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  programs.firejail.enable = true;

  boot = {
    kernelPackages = mkDefault pkgs.linuxPackages_hardened;

    kernelParams = [
      # Slab/slub sanity checks, redzoning, and poisoning
      "slub_debug=FZP"

      # Overwrite free'd memory
      "page_poison=1"

      # Enable page allocator randomization
      "page_alloc.shuffle=1"
    ];

    blacklistedKernelModules = [
      # Obscure network protocols
      "ax25"
      "netrom"
      "rose"

      # Old or rare or insufficiently audited filesystems
      "adfs"
      "affs"
      "bfs"
      "befs"
      "cramfs"
      "efs"
      "erofs"
      "exofs"
      "freevxfs"
      "hfs"
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
      "ufs"
    ];

    kernel.sysctl = {
      # Restrict ptrace() usage to processes with a pre-defined relationship
      # (e.g., parent/child)
      "kernel.yama.ptrace_scope" = mkOverride 500 1;

      # Hide kptrs even for processes with CAP_SYSLOG
      "kernel.kptr_restrict" = mkOverride 500 2;

      # Disable bpf() JIT (to eliminate spray attacks)
      "net.core.bpf_jit_enable" = false;

      # Disable ftrace debugging
      "kernel.ftrace_enabled" = false;

      # Enable strict reverse path filtering (that is, do not attempt to route
      # packets that "obviously" do not belong to the iface's network; dropped
      # packets are logged as martians).
      "net.ipv4.conf.all.log_martians" = true;
      "net.ipv4.conf.all.rp_filter" = "1";
      "net.ipv4.conf.default.log_martians" = true;
      "net.ipv4.conf.default.rp_filter" = "1";

      # Ignore broadcast ICMP (mitigate SMURF)
      "net.ipv4.icmp_echo_ignore_broadcasts" = true;

      # Ignore incoming ICMP redirects (note: default is needed to ensure that the
      # setting is applied to interfaces added after the sysctls are set)
      "net.ipv4.conf.all.accept_redirects" = false;
      "net.ipv4.conf.all.secure_redirects" = false;
      "net.ipv4.conf.default.accept_redirects" = false;
      "net.ipv4.conf.default.secure_redirects" = false;
      "net.ipv6.conf.all.accept_redirects" = false;
      "net.ipv6.conf.default.accept_redirects" = false;

      # Ignore outgoing ICMP redirects (this is ipv4 only)
      "net.ipv4.conf.all.send_redirects" = false;
      "net.ipv4.conf.default.send_redirects" = false;
    };
  };

  networking = {
    # I haven't reseached IPv6 security & privacy implications so I disable it
    enableIPv6 = false;

    firewall.enable = true;
    firewall.allowedTCPPorts = [];
    firewall.allowedUDPPorts = [];
  };
}
