{ config, ... }:
{
  xdg.mimeApps =
    let
      browser = [ "chromium-browser.desktop" ];
      archive = [ "file-roller.desktop" ];
      videoPlayer = [ "mpv.desktop" ];
      #videoPlayer = [ "com.github.rafostar.Clapper.desktop" ];
      visualEditor = [ "emacs-client.desktop" ];

      associations = {
        "inode/directory" = [ "pcmanfm.desktop" ];
        "application/pdf" = [ "koreader.desktop" ];
        "application/epub+zip" = [ "calibre-ebook-viewer.desktop" ];
        "application/vnd.adobe.flash.movie" = [ "flashplayer-standalone.desktop" ];
        "application/vnd.microsoft.portable-executable" = [ "wine.desktop" ];
        "application/x-ms-dos-executable" = [ "wine.desktop" ];
        "text/plain" = visualEditor;
        "video/mp4" = videoPlayer;
        "video/mkv" = videoPlayer;
        "video/x-matroska" = videoPlayer;
        "video/webm" = videoPlayer;
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/ftp" = browser;
        "x-scheme-handler/chrome" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;
        "x-scheme-handler/magnet" = [ "org.qbittorrent.qBittorrent.desktop" ];
        # for doomseeker to open zan://
        "x-scheme-handler/zan" = [ "zan-protocol.desktop" ];
        # for ezquake to open qw://
        "x-scheme-handler/qw" = [ "qw-protocol.desktop" ];
        # for org files
        "x-scheme-handler/org-protocol" = [ "org-protocol.desktop" ];
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/x-extension-shtml" = browser;
        "application/xhtml+xml" = browser;
        "application/x-extension-xhtml" = browser;
        "application/x-extension-xht" = browser;
        "application/zip" = archive;
      };
    in
    {
      enable = true;
      associations.added = associations;
      defaultApplications = associations;
    };
  xdg.mime.enable = true;
}
