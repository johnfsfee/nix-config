{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "zennode";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "Doom-Utils";
    repo = pname;
    rev = version;
    hash = "sha256-ddTomF4XtOrfQ8XjQlZ8z5oeuEBmb8WdRXZllQFMfog=";
  };

  hardeningDisable = [ "format" ];

  buildPhase = ''
  runHook preBuild
  cd ZenNode
  make
  runHook postBuild
  '';

  installPhase = ''
  runHook preInstall
  mkdir -p $out/{share,bin}
  cp {ZenNode,bspdiff,bspinfo,compare} $out/share
  ln -s $out/share/{ZenNode,bspdiff,bspinfo} $out/bin
  ln -s $out/share/compare $out/bin/bspcompare
  runHook postInstall
  '';

  meta = {
    homepage = "http://www.mrousseau.org/programs/ZenNode/";
    description = "Doom node builder";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
}
