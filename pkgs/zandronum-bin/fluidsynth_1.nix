{ stdenv, lib, fetchFromGitHub, pkg-config, cmake
, alsa-lib, glib, libjack2, libsndfile, libpulseaudio
}:

stdenv.mkDerivation  {
  name = "fluidsynth-1";
  version = "1.1.11";

  src = fetchFromGitHub {
    owner = "FluidSynth";
    repo = "fluidsynth";
    rev = "v1.1.11";
    sha256 = "0n75jq3xgq46hfmjkaaxz3gic77shs4fzajq40c8gk043i84xbdh";
  };

  patches = [
    ./fluidsynth_remove_g_thread_init.patch
  ];

  postPatch = ''
    # Existing GLib fixes
    substituteInPlace src/utils/fluid_sys.h \
      --replace-warn "GStaticMutex" "GMutex" \
      --replace-warn "G_STATIC_MUTEX_INIT" "{ 0 }" \
      --replace-warn "g_static_mutex_free" "g_mutex_clear" \
      --replace-warn "g_static_mutex_lock" "g_mutex_lock" \
      --replace-warn "g_static_mutex_unlock" "g_mutex_unlock"

    # JACK driver: static mutex initializer is illegal with modern GLib
    substituteInPlace src/drivers/fluid_jack.c \
      --replace-warn \
        "static fluid_mutex_t last_client_mutex = G_STATIC_MUTEX_INIT;" \
        "static fluid_mutex_t last_client_mutex;"

    # Fix ancient CMake requirement
    substituteInPlace CMakeLists.txt \
      --replace-warn "cmake_minimum_required ( VERSION 3.0.2 )" \
                     "cmake_minimum_required(VERSION 3.5)"
  '';

  nativeBuildInputs = [ pkg-config cmake ];

  buildInputs = [ glib libsndfile libpulseaudio libjack2 ]
    ++ lib.optionals stdenv.isLinux [ alsa-lib ];

  cmakeFlags = [ "-Denable-framework=off" ];

  postFixup = ''
    patchelf --set-rpath "$out/lib" \
      $out/bin/fluidsynth
  '';

  meta = with lib; {
    description = "Real-time software synthesizer based on the SoundFont 2 specifications";
    homepage    = "https://www.fluidsynth.org";
    license     = licenses.lgpl21Plus;
    maintainers = with maintainers; [ goibhniu lovek323 ];
    platforms   = platforms.unix;
  };
}
