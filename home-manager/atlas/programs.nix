{ config, pkgs, lib, specialArgs, ... }:

{
  programs = {
    git = {
      enable = true;
      extraConfig = {
        core.editor = "nvim";
      };
    };

    gpg.enable = true;

    neovim = {
      enable = true;
      extraConfig = ''
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set smartindent
      '';
    };
  };

  home.packages = with pkgs;
  [
    betterbird # email
    newsboat # rss

    ## Media ##
    vlc
    timidity # play midi
    flashplayer-standalone
    yt-dlp # extract videos
    streamlink # extract streams
    nicotine-plus # download music
    calibre # e-book library manager and reader

    ## Web-browsers ##
    lynx
    sse2-palemoon-bin
    qutebrowser
    flashplayer

    ## Audio ##
    mpc-cli # mpd client, CLI
    #ncmpcpp # ncurses mpd client
    ymuse # GUI mpd client, prob the most stable one

    ## Graphic ##
    imagemagick
    inkscape # Vector graphics editor
    scribus # Publishing (DTP) and layout
    xournalpp # Handwriting notetaking
    gimp # Image manipulation
    gmic # image processing framework
    gimpPlugins.gmic

    ## Video ##
    (vapoursynth.withPlugins [ffms])
    vapoursynth-editor
    ffmpeg_6-full
    olive-editor

    ## Social ##
    #profanity # XMPP, CLI
    # gomuks # Matrix, CLI
    weechat # IRC, CLI
    mumble # VoIP, GUI
    #teamspeak_client # VoIP, GUI
    #ripcord-patched # discord, GUI

    ## Network ##
    wireshark

    ## Editors ##
    geogebra6
    onlyoffice-bin

    ## Utils ##
    graphviz
    gcc
    gnumake
    gdb
    valgrind
    rr
    apitrace
    windowmaker
    mediainfo
    tigervnc
    ncdu
    jq
    pkg2zip
    xterm
    gnome-clocks
    mediamtx

    ## Extractors ##
    unrar
    p7zip
    zip
    unzip

    ## Git, remove, ssh ##
    gh
    wolfssl
    mercurial

    ## Nix ##
    steam-run
    nix-prefetch-scripts

    ## Passwords ##
    libsecret
    keepassxc
    pinentry-curses

    ## Compatibility ##
    bottles
    wineWowPackages.stagingFull
    #wine-nine
    winetricks
    samba
    mesa-demos
    jdk21
  ];
}
