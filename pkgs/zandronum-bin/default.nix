{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, makeWrapper
, callPackage
, soundfont-fluid
, SDL_compat
, libGL
, libopus
, glew
, bzip2
, zlib
, libjpeg
, fluidsynth
, fmodex
, openssl
, gtk2
, game-music-emu
}:

let
  fmod = fmodex; # fmodex is on nixpkgs now
  sqlite = callPackage ./sqlite.nix { };
  clientLibPath = lib.makeLibraryPath [ fluidsynth fmod ];
  olibjpeg = (libjpeg.override { enableJpeg8 = true; });

in
stdenv.mkDerivation rec {
  pname = "zandronum-bin";
  version = "3.2.1";

  src = fetchurl {
    url = "https://zandronum.com/downloads/zandronum3.2.1-linux-x86_64.tar.bz2";
    hash = "sha256-n0uT7ZmrFdJAbml+KgbZVuuAjJrC5T5irp8a/7U8hsA=";
  };

  # Work around the "unpacker appears to have produced no directories"
  # case that happens when the archive doesn't have a subdirectory.
  setSourceRoot = "sourceRoot=`pwd`";

  # I have no idea why would SDL and libjpeg be needed for the server part!
  # But they are.
  # RE: libjpeg idk, but SDL provides many low-level OS abstractions other than just video and audio, timing is probably the notable one
  buildInputs = [ openssl bzip2 zlib SDL_compat olibjpeg sqlite game-music-emu libGL libopus glew fmod fluidsynth gtk2 ];

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/zandronum
    cp * \
       $out/lib/zandronum
    rm $out/lib/zandronum/env-vars
    ln -sr -f ${fmod}/lib/libfmodex-4.44.64.so $out/lib/zandronum/libfmodex64-4.44.64.so

    makeWrapper $out/lib/zandronum/zandronum-server $out/bin/zandronum-server-bin
    makeWrapper $out/lib/zandronum/zandronum $out/bin/zandronum-bin
    wrapProgram $out/bin/zandronum-server-bin \
      --set LC_ALL "C"
    wrapProgram $out/bin/zandronum-bin \
      --set LC_ALL "C"
  '';

  postFixup = ''
    patchelf --replace-needed libjpeg.so.8 libjpeg.so \
      --set-rpath $(patchelf --print-rpath $out/lib/zandronum/zandronum):$out/lib/zandronum:${clientLibPath} \
      $out/lib/zandronum/{zandronum,zandronum-server}
  '';

  passthru = {
    inherit fmod sqlite;
  };

  meta = with lib; {
    homepage = "https://zandronum.com/";
    description = "Multiplayer oriented port, based off Skulltag, for Doom and Doom II by id Software";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux;
  };
}
