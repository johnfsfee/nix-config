# Vice — instant-replay game clip recorder for Linux
# https://github.com/eklonofficial/Vice
#
# ⚠ NAMING: nixpkgs already ships a package called `vice` (the Commodore
# 64/128/VIC-20 emulator, pkgs/by-name/vi/vice). If you bind this derivation
# to `vice` in your overlay it will silently shadow that one. Upstream's own
# PKGBUILD in this repo hits the same collision on Arch and names its package
# `vice-clipper` for exactly that reason, so this file follows suit. Only the
# attribute name changes — the installed binaries are still `vice`/`vice-app`
# (the emulator's binaries are x64/x128/xvic/etc, so there's no clash there).
#
# Dependency list is taken from the repo itself at tag v2.10.0 (PKGBUILD,
# .SRCINFO, pyproject.toml/requirements.txt) and cross-checked with
# `grep -r shutil.which vice/` so it reflects what the code actually shells
# out to, not just what the README mentions.
#
# GUI backend: app.py explicitly probes `import PyQt6.QtWebEngineWidgets` +
# `import qtpy`, and pins QT_API=pyqt6 when that succeeds — that's the
# primary, GPU-accelerated Chromium path and it's what most of the Python
# deps below are for. If the probe fails it falls back to GTK3/WebKit2GTK
# (also used unconditionally for app.py's native crash dialog). That
# fallback path is wired up here too, but with lower confidence than the
# PyQt6 path: GI_TYPELIB_PATH is set, but full GTK app-wrapping (e.g.
# LD_LIBRARY_PATH for dlopen'd libwebkit2gtk) isn't. Shouldn't matter
# unless PyQt6 somehow fails to import.
#
# qt6.qtbase / qt6.qtwayland / the preFixup block below were added after
# a real build failure (qtPluginPrefix unset — wrapQtAppsHook needs qtbase
# in buildInputs directly; Python's `dependencies` propagation doesn't
# reach it) and cross-checked against qutebrowser's actual nixpkgs
# packaging, the closest real precedent for buildPythonApplication +
# PyQt6-WebEngine. A second real build confirmed the Python side end to
# end — wheel build, pythonRuntimeDepsCheckHook, wheel install all passed —
# but died in postInstall (see the mkdir below) before ever reaching
# fixupPhase, so the Qt wrapping fixes above are still unexercised by an
# actual build.

{ lib
, python3Packages
, fetchFromGitHub

# recording backends — see vice/recorder.py
, gpu-screen-recorder
, wf-recorder
, ffmpeg

# sharing + clipboard — see vice/share.py
, cloudflared
, wl-clipboard
, xclip

# X11 active-window / game detection — see vice/active_window.py.
# Hyprland/Sway use hyprctl/swaymsg instead, already on PATH if you're
# running those compositors, so they're deliberately not forced here.
, xdotool
, wmctrl
, xprop  # top-level now; `xorg.xprop` is a deprecated alias
, xrandr # top-level now; `xorg.xrandr` is a deprecated alias

, systemd
, gst_all_1

# primary GUI backend: PyQt6 + QtWebEngine (Chromium, GPU-accelerated)
, qt6

# fallback GUI backend: GTK3 + WebKit2GTK (best-effort, see note above)
, gtk3
, webkitgtk_4_1
}:

python3Packages.buildPythonApplication rec {
  pname = "vice-clipper";
  version = "2.10.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "eklonofficial";
    repo = "Vice";
    tag = "v${version}";
    # Placeholder — this is the normal FOD workflow, not a stub I forgot:
    # `nix build` will refuse once with the real hash in the error, paste
    # it in. Or skip the round-trip: `nix run nixpkgs#nix-prefetch-github
    # -- eklonofficial Vice --rev v${version}`.
    hash = "sha256-7+ahNY4ckW0WBqE2Kg1uxmRpY+hCc/5E5+rbMq3fbwE=";
  };

  build-system = with python3Packages; [ setuptools wheel ];

  dependencies = with python3Packages; [
    evdev
    aiohttp
    click
    tomli-w
    psutil
    pywebview

    pyqt6
    pyqt6-webengine
    qtpy

    pygobject3
  ];

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase    # defines qtPluginPrefix for wrapQtAppsHook — this was the build error
    qt6.qtwayland # native `wayland` QPA platform plugin (you're on Sway, not XWayland)
    gtk3
    webkitgtk_4_1
  ];

  # External CLI tools Vice shells out to at runtime. Not Python deps, so
  # they go on the wrapped binary's PATH instead of `dependencies`.
  makeWrapperArgs = [
    "--prefix" "PATH" ":" (lib.makeBinPath [
      gpu-screen-recorder
      wf-recorder
      ffmpeg
      cloudflared
      wl-clipboard
      xclip
      xdotool
      wmctrl
      xprop
      xrandr
      systemd
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
    ])
    "--prefix" "GI_TYPELIB_PATH" ":" (lib.makeSearchPath "lib/girepository-1.0" [
      gtk3
      webkitgtk_4_1
    ])
  ];

  # qtHostPathHook (registered by wrapQtAppsHook once qt6.qtbase is present)
  # only fills in the `qtWrapperArgs` bash array — it doesn't merge that into
  # buildPythonApplication's own `makeWrapperArgs` for you. Confirmed against
  # qutebrowser's real nixpkgs packaging rather than assumed: it does this
  # exact splice, for the exact same reason. Skipping it means the build
  # succeeds but `vice-app` fails at runtime with "could not load the Qt
  # platform plugin", since QT_PLUGIN_PATH never actually reaches the wrapper.
  preFixup = ''
    makeWrapperArgs+=(
      # drop any QT_PLUGIN_PATH inherited from outside the wrapper so it
      # can't shadow the (correct, matching-version) one qtWrapperArgs sets
      --unset QT_PLUGIN_PATH
      "''${qtWrapperArgs[@]}"
      --set QTWEBENGINE_RESOURCES_PATH "${qt6.qtwebengine}/resources"
    )
  '';

  postInstall = ''
    install -Dm644 vice.desktop $out/share/applications/vice.desktop
    install -Dm644 assets/vice.svg $out/share/icons/hicolor/scalable/apps/vice.svg

    # Grants /dev/input/event* access via systemd-logind uaccess instead of
    # the `input` group. Only takes effect once this package is in
    # services.udev.packages (see usage notes).
    install -Dm644 packaging/vice.rules $out/lib/udev/rules.d/70-vice-input.rules

    # Shipped for reference / `systemctl --user link`; the upstream unit
    # hardcodes /usr/bin/vice, which doesn't exist on NixOS. `substitute`
    # writes via a plain `> "$output"` redirect (confirmed in stdenv's
    # setup.sh) — unlike `install -D` it does NOT create the destination
    # directory itself, hence the mkdir.
    mkdir -p $out/lib/systemd/user
    substitute packaging/vice.service $out/lib/systemd/user/vice.service \
      --replace-fail /usr/bin/vice $out/bin/vice
  '';

  pythonImportsCheck = [ "vice" ];

  # The test suite wants a live compositor, evdev nodes, and network access;
  # not something the build sandbox can give it.
  doCheck = false;

  meta = {
    description = "Medal.tv-style instant-replay game clip recorder for Linux";
    homepage = "https://github.com/eklonofficial/Vice";
    changelog = "https://github.com/eklonofficial/Vice/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "vice-app";
  };
}
