{ pkgs, ... }:

let
  x11Doomseeker = pkgs.writeShellScriptBin "doomseeker" ''
    #!/usr/bin/env sh
    env LC_ALL=C QT_QPA_PLATFORM=xcb ${pkgs.doomseeker}/bin/doomseeker $@
  '';

  retroarchWithCores = (
    pkgs.retroarch.withCores (
      cores: with cores; [
        genesis-plus-gx # sega genesis
        snes9x # snes
        swanstation # psx
        mupen64plus # n64
        mgba # gba
      ]
    )
  );
in
{
  xdg.desktopEntries.zan-protocol = {
    name = "zan-protocol-handler";
    exec = "doomseeker --connect %u";
    terminal = false;
    type = "Application";
    categories = [ "Application" ];
    mimeType = [ "x-scheme-handler/zan" ];
  };
  xdg.desktopEntries.qw-protocol = {
    name = "qw-protocol-handler";
    exec = "/home/anon/.local/bin/nquake +connect %u";
    terminal = false;
    type = "Application";
    categories = [ "Application" ];
    mimeType = [ "x-scheme-handler/qw" ];
  };

  home.packages = with pkgs; [
    vkbasalt-cli # post shader
    vkbasalt # post shader
    # sunshine # for game streaming
    heroic
    # https://github.com/NixOS/nixpkgs/issues/271483
    pkgsi686Linux.gperftools
    protonup-qt
    protontricks
    retroarchWithCores
    (lib.hiPrio dolphin-emu)
    ppsspp-sdl-wayland # psp
    flycast # dreamcast
    melonds # for some multiplayer
    # mednaffe # GTK mednafen frontend. Runs: NEC PC Engine (TurboGrafx-16), PC-FX, Sega Saturn, Nintendo Virtual Boy
    # np2kai # pc-9801
    vvvvvv
    x11Doomseeker
    qzdl
    (lib.hiPrio zandronum-bin)
    zandronum-alpha-bin
    zandronum-3_3-260112-1855-bin
    q-zandronum-bin
    notblood-bin
    #odamex
    uzdoom # gzdoom replacement
    dsda-doom
    dsda-launcher
    chocolate-doom
    dosbox
    #xonotic-sdl # use autobuild instead
    quake3e
    # ete # etlegacy
  ];

  programs.mangohud.enable = true;
  programs.mangohud.enableSessionWide = false;
}
