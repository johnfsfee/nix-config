{ config, ... }:
{
  xdg.mimeApps = let
    browser = [ "palemoon-bin.desktop" ];
    archive = [ "file-roller.desktop" ];
    videoPlayer = [ "vlc.desktop" ];

    associations = {
      "inode/directory" = [ "pcmanfm.desktop" ];
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      "application/epub+zip" = [ "calibre-ebook-viewer.desktop" ];
      "application/vnd.adobe.flash.movie" = [ "flashplayer-standalone.desktop" ];
      "application/vnd.microsoft.portable-executable" = [ "wine.desktop" ];
      "application/x-ms-dos-executable" = [ "wine.desktop" ];
      "text/plain" = [ "emacsclient.desktop" ];
      "video/mp4" = videoPlayer;
      "video/mkv" = videoPlayer;
      "video/webm" = videoPlayer;
      "text/html" = browser;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/ftp" = browser;
      "x-scheme-handler/chrome" = browser;
      "x-scheme-handler/about" = browser;
      "x-scheme-handler/unknown" = browser;
      "application/x-extension-htm" = browser;
      "application/x-extension-html" = browser;
      "application/x-extension-shtml" = browser;
      "application/xhtml+xml" = browser;
      "application/x-extension-xhtml" = browser;
      "application/x-extension-xht" = browser;
      "application/zip" = archive;
    };
  in {
    enable = true;
    associations.added = associations;
    defaultApplications = associations;
  };
  xdg.mime.enable = true;
}
