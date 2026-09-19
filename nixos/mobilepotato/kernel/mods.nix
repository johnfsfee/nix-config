# choose driver, kernel mods, apply patches etc
{ lib, config, pkgs, inputs, ... }:

{
  boot = {
    kernelModules = [ "bfq" "zstd" "z3fold" "tcp_bbr" "acpi_call" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

    /*
    kernelPatches = [
      { name = "build_too_high_ram_usage"; patch = null; extraConfig = ''DEBUG_INFO_BTF n''; }
      { name = "intel-gfx_memleak_fix"; patch = ./Possible-regression-in-drm-i915-driver-memleak.patch; }
    ];
    */
    kernel.sysctl = lib.mkForce {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.ip_forward" = 1;
      "vm.swappiness" = 100;
      "kernel.core_pattern" = "|/bin/false";
    };
    kernelParams = [
      "nowatchdog"
      "mitigations=off"
      "intel_iommu=off"
      "button.lid_init_state=open"
    ];
  };

  systemd.services.sysrq = {
    description = "enable magic sysrq";
    enable = true;
    wantedBy = [ "basic.target" ];
    path = [ pkgs.bash ];
    serviceConfig = {
      ExecStart = ''${pkgs.bash}/bin/bash -c \
        'cd /proc/sys/kernel && \
        echo 64 > sysrq'
      '';
      Type = "simple";
    };
  };

  systemd.services.bfq = {
    description = "set scheduler to BFQ";
    enable = true;
    wantedBy = [ "basic.target" ];
    path = [ pkgs.bash ];
    serviceConfig = {
      ExecStart = ''${pkgs.bash}/bin/bash -c \
        'cd /sys/block/sda/queue && \
        echo bfq > scheduler'
      '';
      Type = "simple";
    };
  };

  systemd.services.zswap = {
    description = "Enable ZSwap, set to ZSTD and Z3FOLD";
    enable = true;
    wantedBy = [ "basic.target" ];
    path = [ pkgs.bash ];
    serviceConfig = {
      ExecStart = ''${pkgs.bash}/bin/bash -c \
        'cd /sys/module/zswap/parameters && \
        echo 1 > enabled && \
        echo 20 > max_pool_percent && \
        echo zstd > compressor && \
        echo z3fold > zpool'
      '';
      Type = "simple";
    };
  };
}
