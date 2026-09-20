{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}:

{
  programs = {
    distrobox.enable = true;

    git = {
      enable = true;
      settings = {
        core.editor = "$EDITOR";
      };
    };

    java = {
      enable = true;
      package = (lib.hiPrio pkgs.jdk25);
    };

    gpg.enable = true;

    neovim = {
      enable = true;
      withRuby = false;
      withPython3 = false;
      extraConfig = ''
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set smartindent
      '';
    };

    zoxide.enable = true;

    timidity.enable = true;
    timidity.extraConfig = ''
    #soundfont "/home/anon/Music/Roland SC-55 v3.7.sf2" order=1
    soundfont "/home/anon/Music/Arachno SoundFont - Version 1.0.sf2" order=1

    # Enable all midi effects
    opt -Ewpvsetoz

    # Don't cut sustain to save CPU
    opt --no-fast-decay

    # Pan quickly, even if it sounds bad
    opt --fast-panning

    # Set chorus and reverb by song & soundfont
    opt EFreverb=1
    opt EFchorus=1

    # Never kill voices to save CPU
    opt -k0

    # Sustain fades after three seconds (3000ms)
    opt -m3000
    '';

    info.enable = true;

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-vkcapture
        input-overlay
      ];
    };
  };

  home.packages =
    with pkgs;

    [
      # thunderbird # email
      # newsboat # rss
      qbittorrent # torrent
      vice-clipper # clip recorder

      ## Media ##
      hydrus # media management
      #clapper # video player
      fluidsynth # play midi, pulseaudio support
      qpwgraph # pipewire patchbay
      (flashplayer-standalone.override {debug = true;})
      yt-dlp # extract videos
      yewtube # watch yt
      ani-cli # anime
      streamlink # extract streams
      nicotine-plus # download music
      #stremio # watch movies and series
      #kdePackages.okular # pdf/epub
      koreader # ereader
      # tremotesf

      ## Web-browsers ##
      profile-sync-daemon
      lynx
      palemoon-bin
      ungoogled-chromium
      freetube
      flashplayer # NPAPI plugin

      ## Audio ##
      mpc # mpd client, CLI
      #ncmpcpp # ncurses mpd client
      ymuse # GUI mpd client, prob the most stable one
      audacity # audio editing GUI
      audacious # music player
      #tenacity # FLOSS audacity fork, outdated
      musescore # Music notation and composition
      #rosegarden # midi notation
      mixxx # DJ mixing
      # reaper # DAW
      (sunvox.overrideAttrs (old: {
        src = pkgs.fetchzip {
          urls = old.src.urls;
          hash  = "sha256-4GcSNu6ikAGNcPWz5ghrL78U6xrcIUqjFabs26LACRM=";
        };
      })) # modular synthetizer
      renoise # tracker DAW
      yabridge # Windows VST2 and VST3 plugins on Linux
      yabridgectl # utility to help set up and update yabridge for several directories at once
      helm # synth vst
      sfizz # SFZ jack client and LV2 plugin

      ## Graphic ##
      imagemagick
      inkscape # Vector graphics editor
      scribus # Publishing (DTP) and layout
      #xournalpp # Handwriting notetaking
      gimp3 # Image manipulation
      krita # painting
      pixelorama # pixelart
      #wow-export
      ericw-tools # for quakeworld formats (de)comp
      gmic # image processing framework
      gimp3Plugins.gmic
      krita-plugin-gmic

      ## Video ##
      #(vapoursynth.withPlugins [ ffms ])
      #vapoursynth-editor
      ffmpeg_6-full
      kdePackages.kdenlive
      #davinci-resolve

      ## Social ##
      gajim # XMPP, GUI
      #dino # XMPP, GUI
      #profanity # XMPP, CLI
      #element-desktop # Matrix, GUI
      # gomuks # Matrix, CLI
      weechat # IRC, CLI
      mumble # VoIP, GUI
      #teamspeak_client # VoIP, GUI
      #ripcord-patched # discord, GUI

      ## Network ##
      wireshark

      ## Editors ##
      onlyoffice-desktopeditors
      # sladeUnstable # doom editor
      zt-bcc # acs/bcs compiler
      acc # acs compiler
      #ultimateDoomBuilder # doom map editor
      pngout # optimize png size
      pngcrush # png optimizer
      wmctrl # for prefixing udb windows

      ## Utils ##
      firejail
      cage # wayland kiosk
      openpomodoro-cli
      libnotify
      graphviz
      gcc
      gnumake
      gdb
      valgrind
      # rr
      apitrace
      windowmaker
      mediainfo
      tigervnc
      ncdu
      jq
      pkg2zip
      xterm
      flatpak-builder
      appstream

      ## Extractors ##
      unrar
      p7zip
      zip
      unzip

      ## Git, remove, ssh ##
      gh
      # wolfssl # removed from nixpkgs because of licensing issues
      mercurial

      ## Nix ##
      steam-run
      nix-prefetch-scripts

      ## Passwords ##
      libsecret
      keepassxc
      pinentry-curses

      ## Compatibility ##
      parallel # easier parallel commands bash
      bindfs
      unionfs-fuse
      libeatmydata
      inotify-tools
      (bottles.override { removeWarningPopup = true; })
      wineWow64Packages.stagingFull
      winetricks
      cabextract
      samba
      mesa-demos
      vulkan-tools
      #python3 # check ./desktop/sway.nix
      tldr
      isd
      opencv
      sdl2-compat # for ut99
      SDL # sdl1 compat, for chaos-esque anthology
      libjpeg8.out # for chaos-esque anthology
      icu # for fruityprime
      libice # for fruityprime
      libsm # for fruityprime
      unshield # extract cab files, for the oldunreal's ut2004 installer

      ## OpenMPT ##
      coreutils
      dialog
      gnumake
      pkg-config
      gcc
      binutils
      ccache
      xterm
      winboat

      # old java & lwjgl2 e.g. minecraft 1.5 ##
      jdk8
      xrandr
      libXinerama
      libXxf86vm
      libXi
    ];
}
