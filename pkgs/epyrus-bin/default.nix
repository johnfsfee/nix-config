{ stdenv
, lib
, fetchzip
, alsa-lib
, autoPatchelfHook
, copyDesktopItems
, dbus-glib
, ffmpeg
, gtk2-x11
, gtk3
, libXt
, libpulseaudio
, makeDesktopItem
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "epyrus-bin";
  version = "2.1.2";

  src = fetchzip {
    urls = [
      "https://www.addons.epyrus.org/download/epyrus-${version}.linux-x86_64-gtk3.tar.xz"
    ];
    hash = 
      "sha256-MuYaDnerlmQ9KOHl7qvnGvSGdYUvYHSfCZ86VVJK/bs=";
  };

  preferLocalBuild = true;

  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    wrapGAppsHook
  ];

  buildInputs = [
    alsa-lib
    dbus-glib
    gtk2-x11
    libXt
    stdenv.cc.cc.lib
    gtk3
  ];

  desktopItems = [(makeDesktopItem rec {
    name = pname;
    desktopName = "Epyrus mail client";
    comment = "Companion for Palemoon";
    keywords = [
      "Internet"
      "E-mail"
    ];
    exec = "epyrus %u";
    terminal = false;
    type = "Application";
    icon = "palemoon";
    categories = [
      "Network"
    ];
    startupNotify = true;
    startupWMClass = "Epyrus";
    extraConfig = {
      X-MultipleArgs = "false";
    };
  })];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,lib/epyrus}
    cp -R * $out/lib/epyrus/
    ln -s $out/{lib/epyrus,bin}/epyrus
    for iconpath in chrome/icons/default/default{16,32,48} icons/mozicon128; do
      n=''${iconpath//[^0-9]/}
      size=$n"x"$n
      mkdir -p $out/share/icons/hicolor/$size/apps
      ln -s $out/lib/epyrus/"$iconpath".png $out/share/icons/hicolor/$size/apps/epyrus.png
    done
    # Disable built-in updater. From:
    # https://forum.palemoon.org/viewtopic.php?f=5&t=25073&p=197771#p197747
    install -Dm644 ${./zz-disableUpdater.js} $out/lib/epyrus/defaults/pref/zz-disableUpdates.js
    runHook postInstall
  '';

  dontWrapGApps = true;

  preFixup = ''
    # Make optional dependencies available
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        ffmpeg
        libpulseaudio
      ]}"
    )
    wrapGApp $out/lib/epyrus/epyrus
  '';

  meta = with lib; {
    homepage = "http://www.epyrus.org/";
    description = "An Open Source, Goanna-based e-mail client";
    license = [
      licenses.mpl20
    ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "epyrus";
    platforms = [ "x86_64-linux" ];
    hydraPlatforms = [];
  };
}
