{ pkgs, config, ... }:

let
  tex = (pkgs.texlive.combine {
      inherit (pkgs.texlive) scheme-medium # any less than medium isn't guaranteed to work
      biber biblatex
      ## BR stuff ##
      babel-portuges abntex2 biblatex-abnt memoir enumitem fontspec lastpage
      ## emacs/org-mode ##
      dvisvgm dvipng # for preview and export as html
      circuitikz # electrical circuits
      pgfplots # normal/log plots in 2D/3D
      wrapfig amsmath ulem hyperref capt-of
      # for resume:
      geometry titlesec xcolor
      #(setq org-latex-compiler "lualatex")
      #(setq org-preview-latex-default-process 'dvisvgm)
      ;});

  emacs-overlayPkg = (pkgs.emacsWithPackagesFromUsePackage {
      # Your Emacs config file. Org mode babel files are also
      # supported.
      # NB: Config files cannot contain unicode characters, since
      #     they're being parsed in nix, which lacks unicode
      #     support.
      config = ./emacs.el;

      # Whether to include your config as a default init file.
      # If being bool, the value of config is used.
      # Its value can also be a derivation like this if you want to do some
      # substitution:
      #   defaultInitFile = pkgs.substituteAll {
      #     name = "default.el";
      #     src = ./emacs.el;
      #     inherit (config.xdg) configHome dataHome;
      #   };
      defaultInitFile = true;

      # Package is optional, defaults to pkgs.emacs
      package = pkgs.emacs30-pgtk;

      # By default emacsWithPackagesFromUsePackage will only pull in
      # packages with `:ensure`, `:ensure t` or `:ensure <package name>`.
      # Setting `alwaysEnsure` to `true` emulates `use-package-always-ensure`
      # and pulls in all use-package references not explicitly disabled via
      # `:ensure nil` or `:disabled`.
      # Note that this is NOT recommended unless you've actually set
      # `use-package-always-ensure` to `t` in your config.
      alwaysEnsure = false;

      # For Org mode babel files, by default only code blocks with
      # `:tangle yes` are considered. Setting `alwaysTangle` to `true`
      # will include all code blocks missing the `:tangle` argument,
      # defaulting it to `yes`.
      # Note that this is NOT recommended unless you have something like
      # `#+PROPERTY: header-args:emacs-lisp :tangle yes` in your config,
      # which defaults `:tangle` to `yes`.
      alwaysTangle = false;

      # Optionally provide extra packages not in the configuration file.
      extraEmacsPackages = epkgs: [
      ];

      /*
      # Optionally override derivations.
      override = final: prev: {
        weechat = prev.melpaPackages.weechat.overrideAttrs(old: {
          patches = [ ./weechat-el.patch ];
        });
      };
      */
    });
in
{
  home.packages = with pkgs; [
    emacs-overlayPkg

    nixfmt
    editorconfig-core-c
    tuntox # for crdt collab
    notmuch # email
    notmuch.emacs
    isync # for mbsync
    msmtp # for sending mail
    lieer # gmail
    tex # latex

    jansson # for emacs native json support
    ## ORG ##
    sqlite # for org-roam2
    grim # org-download-clipboard
    slurp # org-download-clipboard
    gnuplot
    pandoc # for markdown processing and markup conversions

    ## everywhere ##
    xclip
    xdotool
    xprop
    xwininfo

    ## lang servers ##
    nixd
    ccls
    rust-analyzer
    vhdl-ls
    ghdl # vhdl compiler and simulator
    gtkwave # vhdl simulation visualization
  ];

  services.emacs = {
    enable = true;

    # use services.emacs.package instead of programs.emacs.package if using emacs-overlay
    # https://github.com/nix-community/home-manager/issues/1111
    package = emacs-overlayPkg;
    client.enable = true;
    defaultEditor = true;
  };

  xdg.desktopEntries.org-protocol = {
    name = "Org-Protocol";
    exec = "emacsclient %u";
    terminal = false;
    type = "Application";
    icon = "emacs-icon";
    categories = [ "Application" ];
    mimeType = [ "x-scheme-handler/org-protocol" ];
  };

}
