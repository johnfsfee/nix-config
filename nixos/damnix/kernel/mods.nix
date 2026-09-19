# choose driver, kernel mods, apply patches etc
{ lib, config, pkgs, inputs, ... }:

{
  boot = {

    kernelModules = [ "bfq" "zstd" /* "tcp_bbr" */ ];
    /*
    kernelPatches = [
      { name = "build_too_high_ram_usage"; patch = null; extraConfig = ''DEBUG_INFO_BTF n''; }
      { name = "intel-gfx_memleak_fix"; patch = ./Possible-regression-in-drm-i915-driver-memleak.patch; }
    ];
    */
    kernel.sysctl = lib.mkForce {
      "net.core.default_qdisc" = "fq_codel";
      # "net.ipv4.tcp_congestion_control" = "bbr";
      "vm.swappiness" = 10; # 35->10 to ensure hugepages can be allocated and stay resident
      "kernel.core_pattern" = "|/bin/false";
      # https://community.frame.work/t/wayland-lag-stuttering-since-kernel-6-11-2/59422
      "amdgpu.dcdebugmask" = "0x400";
    };
    kernelParams = [
      "nowatchdog"
      "mitigations=off"
      "intel_iommu=off"
      "resume_offset=533760"
    ];
  };

  services.udev = {
    extraRules = ''
      ACTION=="add/change", KERNEL=="sda", ATTR{bdi/read_ahead_kb}="2048"
    '';
    packages = [ pkgs.usb-blaster-udev-rules ]; # for fpga
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
    description = "Enable ZSwap, set to ZSTD and zsmalloc";
    enable = true;
    wantedBy = [ "basic.target" ];
    path = [ pkgs.bash ];
    serviceConfig = {
      ExecStart = ''${pkgs.bash}/bin/bash -c \
        "unset CDPATH; \
        cd /sys/module/zswap/parameters && \
        echo 1 > enabled && \
        echo zstd > compressor && \
        echo zsmalloc > zpool && \
        echo 60 > max_pool_percent && \
        echo 1 > shrinker_enabled && \
        echo 80 > accept_threshold_percent"
      '';
      Type = "simple";
    };
  };
}
