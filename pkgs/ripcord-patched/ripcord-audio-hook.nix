{ stdenv
, lib
, callPackage
, fetchurl
}:

let
  funchook = callPackage ./funchook.nix {};
in
stdenv.mkDerivation rec {
  name = "ripcord-audio-hook";
  version = "1.5.1";

  # fetchFromGitHub couldnt get the sources from any mirrors, use fetchurl for now
  src = fetchurl {
    url = "https://github.com/geniiii/ripcord-audio-hook/archive/refs/tags/v${version}.tar.gz";
    hash = "";
  };

  nativeBuildInputs = [ funchook ];

  buildPhase = ''
    gcc -shared -fPIC -o hook.so geniii*/hook.c -ldl -lfunchook
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp hook.so $out/lib
  '';

  meta = with lib; {
    description = "Fixes Ripcord's voice chat functionality";
    homepage = "https://github.com/geniiii/ripcord-audio-hook/tree/master";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
