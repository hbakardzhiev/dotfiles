{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    policies = {
      PasswordManagerEnabled = false;
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      BlockAboutConfig = true;
      DisableFirefoxAccounts = true;
      DisablePocket = true;
      DisplayBookmarksToolbar = "newtab";
      DisableFeedbackCommands = true;
      NetworkPrediction = true;
      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;
      SearchBar = "unified";
      TranslateEnabled = true;
      FirefoxSuggest = {
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };
      SanitizeOnShutdown = {
        Cookies = true;
        Downloads = false;
        FormData = false;
        History = false;
        Sessions = true;
        SiteSettings = false;
        Cache = true;
        OfflineApps = true;
      };
      FirefoxHome = {
        Search = true;
        SponsoredTopSites = false;
        TopSites = true;
        Highlights = true;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = true;
      };
      PDFjs = {
        Enabled = true;
        EnablePermissions = false;
      };
      Cookies = {
        Behavior = "reject-foreign";
        AcceptThirdParty = "never";
        RejectTracker = true;
      };
      DNSOverHTTPS = {
        Enabled = false;
        #   ProviderURL = "https://security.cloudflare-dns.com/dns-query";
        #   # ProviderURL = "https://dns.adguard-dns.com/dns-query";
      };
      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
        Strict = true;
      };
      HardwareAcceleration = true;
    };
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = {
          "browser.search.defaultenginename" = "Google";
          "general.smoothScroll" = false;
          "network.dns.echconfig.enabled" = true;
          "network.dns.http3_echconfig.enabled" = true;
          "network.trr.mode" = 0;
          "security.ssl.require_safe_negotiation" = true;
          "dom.security.https_only_mode" = true;
          "beacon.enabled" = false;
          "browser.cache.disk.enable" = false;
          "browser.send_pings" = false;
          "dom.battery.enabled" = false;
          "media.video_stats.enabled" = false;
          "media.ffmpeg.vaapi.enabled" = true;
          "media.peerconnection.enabled" = true;
          "network.cookie.cookieBehavior" = 1;
          "network.http.referer.spoofSource" = true;
          "gfx.webrender.all" = true;
          "gfx.webrender.compositor.force-enabled" = true;
          "hardware-video-decoding.force-enabled" = true;
          "geo.enabled" = false;
          "privacy.donottrackheader.value" = 1;
          "privacy.donottrackheader.enabled" = true;
          "browser.sessionstore.enabled" = true;
          "browser.sessionstore.resume_from_crash" = true;
          "browser.sessionstore.resume_session_once" = true;
          "browser.startup.page" = 3;
          "nglayout.initialpaint.delay" = 0;
        };
        search = {
          force = true;
          default = "Google";
          order = [
            "Google"
            "Ecosia"
          ];
          engines = {
            "Ecosia" = {
              urls = [
                {
                  template = "https://www.ecosia.org/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              iconUpdateURL = "https://theboar.org/wp-content/uploads/2020/10/1280px-Ecosia-like_logo.svg_.png";
              definedAliases = [ "@e" ];
            };
            "Ecosia Chat" = {
              urls = [
                {
                  template = "https://www.ecosia.org/chat";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              iconUpdateURL = "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/i/593d1ad9-6d46-4c66-904e-c8fb6f312619/d6rf3li-2270b709-128c-463e-a142-0c0238908053.jpg";
              definedAliases = [ "@ec" ];
            };
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "Nix Options" = {
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@no" ];
            };
            "Nix" = {
              urls = [
                {
                  template = "https://mynixos.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@nix" ];
            };
            "Odysee" = {
              urls = [
                {
                  template = "https://odysee.com/$/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              definedAliases = [ "@od" ];
            };
            "Google".metaData.alias = "@g";
            "Home-manager options" = {
              urls = [
                {
                  template = "https://home-manager-options.extranix.com/";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                    {
                      name = "release";
                      value = "master";
                    }
                  ];
                }
              ];
              iconUpdateURL = "https://home-manager-options.extranix.com/images/home-manager-option-search2.png";
              definedAliases = [ "@hm" ];
            };
          };
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          privacy-badger
          vimium
          ublock-origin
          bitwarden
          metamask
          sponsorblock
          floccus
        ];
      };
    };
  };
}
