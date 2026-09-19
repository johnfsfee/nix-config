{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    package = (pkgs.wrapFirefox (pkgs.firefox-devedition-unwrapped.override { pipewireSupport = true;}) {});
    nativeMessagingHosts = [ pkgs.tridactyl-native ];
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        tridactyl
        auto-tab-discard
        ublock-origin
        leechblock-ng
        i-dont-care-about-cookies
        unpaywall
        terms-of-service-didnt-read
        sponsorblock
        return-youtube-dislikes
        don-t-fuck-with-paste
        enhanced-h264ify
        redirector
      ];
      settings = {
        "app.update.auto" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.quitShortcut.disabled" = true;
        "extensions.update.enabled" = false;
        "extension.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "extensions.autoDisableScopes" = 0;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "pdfjs.disabled" = true;
      };
      userChrome = ''
        :root:not([customizing]) #navigator-toolbox:not(:hover):not(:focus-within) #TabsToolbar {
          visibility: collapse;
        }

        :root:not([customizing]) #navigator-toolbox:not(:hover):not(:focus-within) {
          max-height: 0;
          min-height: 0;
          height: 0;
          overflow: hidden;
          border: none !important;
        }

        :root:not([customizing]) #navigator-toolbox:not(:hover):not(:focus-within) #urlbar {
          min-height: 0 !important;
          height: 0 !important;
          overflow: hidden !important;
        }

        :root:not([customizing]) #navigator-toolbox #urlbar-container {
          --urlbar-container-height: auto !important;
        }
      '';
    };
  };
}

