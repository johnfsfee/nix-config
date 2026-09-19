final: prev:

with final;
{
  profile-sync-daemon = callPackage ./profile-sync-daemon {};

  sse2-palemoon-bin = callPackage ./sse2-palemoon-bin {};

  epyrus-bin = callPackage ./epyrus-bin {};

  beebeep-bin = qt5.callPackage ./beebeep-bin {};

  cleanflash = callPackage ./mozilla-plugins/flashplayer/cleanflash.nix {};

    dino = callPackage ./dino {
    inherit (gst_all_1)
      gstreamer
      gst-plugins-base
      gst-plugins-bad
      gst-vaapi
      ;
    gst-plugins-good = gst_all_1.gst-plugins-good.override { gtkSupport = true; };
  };

  doomseeker = qt5.callPackage ./doomseeker {};

  dsda-doom = callPackage ./dsda-doom {};

  deutex = callPackage ./odamex/deutex.nix {};

  ete = callPackage ./etlegacy {};

  etlegacy-assets = callPackage ./etlegacy/assets.nix {};

  flashplayer = callPackage ./mozilla-plugins/flashplayer {};

  flashplayer-standalone = callPackage ./mozilla-plugins/flashplayer/standalone.nix {};

  flashplayer-standalone-debugger = callPackage ./mozilla-plugins/flashplayer/standalone.nix {
    debug = true;
  };

  funchook = callPackage ./ripcord-patched/funchook.nix {};

  gajim = prev.gajim.overrideAttrs (old: {
        propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [
                prev.gsound
        ];
  });

  ripcord-patched = qt5.callPackage ./ripcord-patched {};

  ripcord-audio-hook = callPackage ./ripcord-patched/ripcord-audio-hook.nix {};

  ripcord-patcher = callPackage ./ripcord-patched/ripcord-patcher.nix {};

  ultimateDoomBuilder = callPackage ./ultimateDoomBuilder {};

  vvvvvv = callPackage ./vvvvvv {};

  notblood-bin = callPackage ./notblood-bin {};

  odamex = callPackage ./odamex {};
  odamex-unstable = callPackage ./odamex/unstable.nix {};

  pkg2zip = callPackage ./pkg2zip {};

  quake3e = callPackage ./quake3e {};

  sm64ex-coop = callPackage ./sm64ex/coop.nix {};

  q-zandronum-bin = callPackage ./q-zandronum-bin {};

  vice-clipper = final.callPackage ./vice-clipper {};

  wl-screenrec = callPackage ./wl-screenrec {};

  wow-export = callPackage ./wow-export {};

  zandronum-bin = callPackage ./zandronum-bin {};

  zandronum-alpha-bin = callPackage ./zandronum-bin/alpha.nix {};

  zandronum-3_3-260112-1855-bin = callPackage ./zandronum-bin/alpha3_3-260112-1855.nix {};

  zennode = callPackage ./ultimateDoomBuilder/zennode.nix {};

  zt-bcc = callPackage ./ultimateDoomBuilder/zt-bcc.nix {};
}
