{ lib
, stdenv
, makeWrapper
, autoPatchelfHook
, fetchurl
# NW.js / Chromium Dependencies parsed from your ldd output
, glib
, nspr
, nss
, dbus
, atk
, cups
, expat
, libxkbcommon
, at-spi2-atk
, libX11
, libXcomposite
, libXdamage
, libXext
, libXfixes
, libXrandr
, mesa      # provides libgbm.so.1
, cairo
, pango
, udev      # systemd provides libudev.so.1
, alsa-lib  # provides libasound.so.2
, libxcb      # provides libxcb.so.1
}:

stdenv.mkDerivation rec {
  pname = "wow-export";
  version = "0.2.19";

  src = fetchurl {
    url = "https://github.com/Kruithne/wow.export/releases/download/${version}/portable-wow-export-linux-x64-${version}.tar.gz";
    # Run the build once with this fake hash to get the correct SHA256
    hash = "sha256-JggShbDg4XIYF20tUqoavRC9xRgqH6u+h5f//xnPQlk=";
  };

  buildInputs = [
    glib
    nspr
    nss
    dbus
    atk
    cups
    expat
    libxkbcommon
    at-spi2-atk
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    mesa
    cairo
    pango
    udev
    alsa-lib
    libxcb
  ];

  nativeBuildInputs = [ makeWrapper autoPatchelfHook ];

  # Required for tar.gz sources if they don't untar into a nested folder
  sourceRoot = ".";
  dontStrip = true;
  preferLocalBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib/wow-export

    # Copy everything including the subdirectories (lib, locales, src, etc)
    cp -r * $out/lib/wow-export

    # Clean up build artifacts if present
    rm -f $out/lib/wow-export/env-vars

    # Ensure main executable and crash handler are runnable
    chmod +x $out/lib/wow-export/wow.export
    chmod +x $out/lib/wow-export/chrome_crashpad_handler

    # Create the binary wrapper in system path
    makeWrapper $out/lib/wow-export/wow.export $out/bin/wow-export \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}:$out/lib/wow-export/lib"

    runHook postInstall
  '';

  postFixup = ''
    # Crucial step for Chromium runtimes: autoPatchelf needs help locating
    # the bundled internal libraries (libnw.so, libffmpeg.so) inside the /lib folder
    patchelf --set-rpath "$(patchelf --print-rpath $out/lib/wow-export/wow.export):$out/lib/wow-export/lib" $out/lib/wow-export/wow.export
  '';

  meta = with lib; {
    description = "Open-source asset exporter for World of Warcraft";
    homepage = "https://github.com/Kruithne/wow.export";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
