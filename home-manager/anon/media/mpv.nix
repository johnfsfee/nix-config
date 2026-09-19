{ config, pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    scripts = with pkgs; [
      mpvScripts.mpris
    ];
    config = {
      screenshot-directory = "~/Pictures/mpv";

      ## VIDEO ##
      vo = "gpu-next"; # recommended
      # vo = "dmabuf-wayland"; # wont play unsupported formats
      gpu-api= "opengl"; # https://github.com/mpv-player/mpv/issues/16218
      gpu-context = "wayland";
      hwdec = "auto-safe";
      # profile = "high-quality"; # recommended
      profile = "fast";

      ## AUDIO ##
      ao = "pipewire";
      audio-channels = "auto-safe";
      # enable at your own peril
      # af = "lavfi=[dynaudnorm]";
      volume = "100";

      ## MISC ##
      script-opts = "ytdl_hook-ytdl_path=${pkgs.yt-dlp}/bin/yt-dlp";
      ytdl-format = "bestvideo[height<=?720][fps<=?30][vcodec!=?vp9]+bestaudio/best[height<=?720]";

      keep-open = "yes";

      /*
      # required so that the 2 UIs don't fight each other
      osc = "no";
      # uosc provides its own seeking/volume indicators, so you also don't need this
      osd-bar = "no";
      # uosc will draw its own window controls if you disable window border
      border = "no";
      */
    };
  };
}
