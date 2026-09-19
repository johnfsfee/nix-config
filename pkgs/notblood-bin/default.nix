# put the game files in $XDG_CONFIG_HOME/notblood
{ lib
, stdenv
, makeWrapper
, autoPatchelfHook
, unzip
, fetchurl
, alsa-lib
, flac
, gtk2
, libvorbis
, libvpx
, libGLU
, libGL
, SDL2
, SDL2_mixer
}:

stdenv.mkDerivation rec {
  pname = "notblood";
  version = "2025-06-08-latest";

  src = fetchurl {
    url = "https://github.com/clipmove/NotBlood/releases/download/latest/notblood-linux-gcc.zip";
    hash = "sha256-GncNA/SHa1CADmucAgaG5xLvA4yvMKvxvS6spWU/aeA=";
  };

  buildInputs = [
    flac
    libvorbis
    libvpx
    SDL2
    SDL2_mixer
  ] ++ lib.optionals stdenv.isLinux [
    alsa-lib
    gtk2
    libGL
    libGLU
  ];

  nativeBuildInputs = [ makeWrapper autoPatchelfHook unzip ];
  sourceRoot = ".";
  dontStrip = "true";
  preferLocalBuild = "true";

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/notblood
    cp -r * \
      $out/lib/notblood
    rm $out/lib/notblood/env-vars
    chmod +x $out/lib/notblood/notblood
    makeWrapper $out/lib/notblood/notblood $out/bin/notblood
  '';

  postFixup = ''
    patchelf --replace-needed libvpx.so.7 libvpx.so $out/lib/notblood/notblood
    patchelf --replace-needed libFLAC.so.12 libFLAC.so \
      --set-rpath $(patchelf --print-rpath $out/lib/notblood/notblood):$out/lib/notblood \
    $out/lib/notblood/notblood
  '';

  meta = with lib; {
    description = "Enhanched port of Duke Nukem 3D for various platforms";
    homepage = "https://forums.duke4.net/topic/11826-netduke32-enhanced-duke3d-netplay";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
  };
}
