{ lib
, stdenv
, callPackage
, fetchFromGitHub
, cmake
, pkg-config
, makeWrapper
, SDL2
, SDL2_mixer
, libpng
, curl
, portmidi
, fltk14
, jsoncpp
, miniupnpc
}:

let
  deutex = callPackage ./deutex.nix {};
in
stdenv.mkDerivation rec {
  pname = "odamex-unstable";
  version = "11.0.0-2024-04-04";

  src = fetchFromGitHub {
    owner = "odamex";
    repo = "odamex";
    rev = "3c5df8c9a75da697a6a69a64cadc644a765809b2";
    hash = "sha256-mqwQ1lIMXGOZ+7RMXzMyVr4U42dU3GPzME/Zix4QFjM=";
    fetchSubmodules = true;
  };

#  patches = [
#    ./patches/${pname}-10.3.0-unbundle-fltk.patch
#  ];

  cmakeFlags = [
    "-DUSE_INTERNAL_FLTK=1"
		"-DUSE_INTERNAL_JSONCPP=1"
		"-DUSE_INTERNAL_LIBS=1"
		"-DUSE_INTERNAL_MINIUPNP=1"
		"-DBUILD_CLIENT=1"
		"-DBUILD_LAUNCHER=0" # odalaunch crashes with wxGTK31/wxGTK32
		"-DBUILD_MASTER=1"
		"-DBUILD_SERVER=1"
		"-DBUILD_OR_FAIL=1"
		"-DENABLE_PORTMIDI=1"
		"-DUSE_MINIUPNP=1"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    SDL2
    SDL2_mixer
    deutex
    libpng
    curl
    portmidi
    fltk14
    jsoncpp
    miniupnpc
  ];

  installPhase = ''
    runHook preInstall
  '' + (if stdenv.isDarwin then ''
    mkdir -p $out/{Applications,bin}
    mv odalaunch/odalaunch.app $out/Applications
    makeWrapper $out/{Applications/odalaunch.app/Contents/MacOS,bin}/odalaunch
  '' else ''
    make install
  '') + ''
    runHook postInstall
  '';

  meta = {
    homepage = "http://odamex.net/";
    description = "A client/server port for playing old-school Doom online";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.unix;
  };
}
