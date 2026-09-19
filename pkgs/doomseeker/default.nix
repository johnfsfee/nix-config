{ lib, stdenv, cmake, fetchFromBitbucket, wrapQtAppsHook, pkg-config, qtbase, qttools, qtmultimedia, zlib, bzip2, xxd }:

stdenv.mkDerivation {
  pname = "doomseeker";
  version = "1.5.0";

  src = fetchFromBitbucket {
    owner = "Doomseeker";
    repo = "doomseeker";
    rev = "f8ef3769c5cd1504a7378c015a76adce11f8448e";
    hash = "sha256-TdM0GNJMwu3U9IlEueNjAUVsUr4NilQZePxets18gEQ=";
  };

  patches = [ ./dont_update_gitinfo.patch ./add_gitinfo.patch ./fix_paths.patch ];

  nativeBuildInputs = [ wrapQtAppsHook cmake qttools pkg-config xxd ];
  buildInputs = [ qtbase qtmultimedia zlib bzip2 ];

  hardeningDisable = lib.optional stdenv.isDarwin "format";

  postInstall = ''
    mv $out/bin/* $out/lib/doomseeker/
    ln -s $out/lib/doomseeker/doomseeker $out/bin/
  '';

  meta = with lib; {
    homepage = "http://doomseeker.drdteam.org/";
    description = "Multiplayer server browser for many Doom source ports";
    license = licenses.gpl2;
    platforms = platforms.unix;
    maintainers = [ maintainers.MP2E ];
  };
}
