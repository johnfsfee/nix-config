{ stdenv
, lib
, callPackage
, fetchFromGitHub
, makeWrapper
, msbuild
, mono
, libGL
, libX11
, libXfixes
, gtk2-x11
, acc
, zdbsp
}:

let
  # TODO: package acs and bcs libs
  # zonebuilder and BCS compiler
  zennode = callPackage ./zennode.nix {};
  zt-bcc = callPackage ./zt-bcc.nix {};
in
stdenv.mkDerivation rec {
  pname = "UltimateDoomBuilder";
  version = "2026-01-02T15";

  src = fetchFromGitHub {
    owner = "UltimateDoomBuilder";
    repo = pname;
    rev = "aa22cd71a8cf1000a5b0f1c799dc88b3fa551e62";
    hash = "sha256-31NkZPlaxLvEMBqXIBnMW/0aeATvCk58GJb4oMHi218=";
  };

  # patches = [ ./VisplaneExplorer_fix.patch ];

  nativeBuildInputs = [
    msbuild
    makeWrapper
  ];

  buildInputs = [
    libGL
    libX11
    libXfixes
    gtk2-x11
  ];

  /*
  makeFlags = [
    "BUILDTYPE=Debug"
  ];
  */

  patchPhase = ''
    substituteInPlace Makefile \
    --replace-warn /verbosity:minimal "/verbosity:minimal /p:codepage=65001"
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/opt

    cp -r Build $out/opt/UltimateDoomBuilder

    substituteInPlace $out/opt/UltimateDoomBuilder/builder --replace-warn mono ${mono}/bin/mono
    substituteInPlace $out/opt/UltimateDoomBuilder/builder --replace-warn Builder.exe $out/opt/UltimateDoomBuilder/Builder.exe
    substituteInPlace $out/opt/UltimateDoomBuilder/Compilers/Nodebuilders/ZenNode.cfg --replace-warn ZenNode.exe ${zennode}/bin/ZenNode
    substituteInPlace $out/opt/UltimateDoomBuilder/Compilers/Nodebuilders/zdbsp.cfg --replace-warn zdbsp.exe ${zdbsp}/bin/zdbsp
    echo $out/opt/UltimateDoomBuilder/Compilers/Hexen \
    $out/opt/UltimateDoomBuilder/Compilers/ZDoom \
    $out/opt/UltimateDoomBuilder/Compilers/ZDaemon \
    $out/opt/UltimateDoomBuilder/Compilers/Zandronum \
    | xargs -n 1 cp ${acc}/bin/acc
    substituteInPlace $out/opt/UltimateDoomBuilder/Compilers/{Z*,Hexen}/acc.cfg --replace-warn acc.exe acc
    cp ${zt-bcc}/bin/zt-bcc $out/opt/UltimateDoomBuilder/Compilers/BCC
    substituteInPlace $out/opt/UltimateDoomBuilder/Compilers/BCC/bcc.cfg --replace-warn bcc.exe bcc

    wrapProgram $out/opt/UltimateDoomBuilder/builder \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ gtk2-x11 libGL libX11 ]}"

    ln -s $out/opt/UltimateDoomBuilder/builder $out/bin/builder
  '';

  meta = {
    homepage = "https://forum.zdoom.org/viewtopic.php?f=232&t=66745";
    description = "Comprehensive map editor for Doom, Heretic, Hexen and Strife based games. Works best for ZDoom-family ports while also supporting classic engines. Based on GZDoomBuilder by MaxED & Doom Builder 2 by CodeImp (see — http://doombuilder.com)";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
