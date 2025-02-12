{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    policies = {
      AppAutoUpdate = false;
      PasswordManagerEnabled = false;
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      BlockAboutConfig = true;
      DisableFirefoxAccounts = true;
      DisablePocket = true;
      DisplayBookmarksToolbar = "always";
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
        SiteSettings = true;
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
      NewTabPage = true;
      Homepage = {
        URL = "https://x.com/i/grok?focus=1";
        StartPage = "homepage";
      };
      ShowHomeButton = true;
      PDFjs = {
        Enabled = true;
        EnablePermissions = false;
      };
      Cookies = {
        Behavior = "reject-tracker-and-partition-foreign";
        BehaviorPrivateBrowsing = "reject";
        Locked = true;
      };
      DNSOverHTTPS = {
        Enabled = true;
        Locked = true;
        Fallback = false;
        ProviderURL = "https://security.cloudflare-dns.com/dns-query";
        # ProviderURL = "https://dns.adguard-dns.com/dns-query";
      };
      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
        Strict = true;
        Locked = true;
      };
      HardwareAcceleration = true;
    };
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = {
          "browser.search.defaultenginename" = "Grok";
          "general.smoothScroll" = false;
          "network.dns.echconfig.enabled" = true;
          "network.dns.http3_echconfig.enabled" = true;
          # "network.trr.mode" = 0;
          "security.ssl.require_safe_negotiation" = true;
          "dom.security.https_only_mode" = true;
          "beacon.enabled" = false;
          "browser.cache.disk.enable" = false;
          "browser.send_pings" = false;
          "dom.battery.enabled" = false;
          # "media.video_stats.enabled" = false;
          "media.ffmpeg.vaapi.enabled" = true;
          "media.av1.enabled" = false;
          "layers.acceleration.force-enabled" = true;
          "media.hardware-video-decoding.enabled" = true;
          "media.hardware-video-decoding.force-enabled" = true;
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
          "widget.windows.window_occlusion_tracking.enabled" = false;
        };
        search = {
          force = true;
          default = "Grok";
          order = [
            "Grok"
            "Startpage"
            "DuckDuckGo"
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
            "Noogle" = {
              urls = [
                {
                  template = "https://noogle.dev/q";
                  params = [
                    {
                      name = "term";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              iconUpdateURL = "https://noogle.dev/favicon.png";
              definedAliases = [ "@ng" ];
            };
            "Google Scholar" = {
              urls = [
                {
                  template = "https://scholar.google.nl/scholar?hl=en&as_sdt=0%2C5&btnG=";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              iconUpdateURL = "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Google_Scholar_logo.svg/240px-Google_Scholar_logo.svg.png";
              definedAliases = [ "@scholar" ];
            };
            "DuckDuckGo" = {
              urls = [
                {
                  template = "https://duckduckgo.com/?k1=-1&kaj=m&kay=b&kak=-1&kax=-1&kaq=-1&kap=-1&kao=-1&kau=-1&kpsb=-1&k5=1&kbe=3";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              iconUpdateURL = "http://upload.wikimedia.org/wikipedia/en/thumb/8/88/DuckDuckGo_logo.svg/150px-DuckDuckGo_logo.svg.png";
              definedAliases = [ "@ddg" ];
            };
            "Startpage" = {
              urls = [
                {
                  template = "https://eu.startpage.com/sp/search?abp=1&t=device&lui=english&sc=7d5BTBrXwV4z20&cat=web&abd=1&prfe=606e69a3d1cd4bdd507a8e5476a35a4498fe3cd0a17fc5ed0de87781f749f832b44cd31e76ecec146f0935b469dc061ccd2b8371d84e33d494a73e5309a33126d6678c95ccb8a29d0b1629401e";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              iconUpdateURL = "https://eu.startpage.com/sp/cdn/images/privacy-please-av-icon.svg";
              definedAliases = [ "@sp" ];
            };
            "Grok" = {
              urls = [
                {
                  template = "https://x.com/i/grok";
                  params = [
                    {
                      name = "focus";
                      value = "1";
                    }
                    {
                      name = "text";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              iconUpdateURL = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/XAI-Logo.svg/150px-XAI-Logo.svg.png";
              definedAliases = [ "@grok" ];
            };
          };
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          privacy-badger
          vimium
          ublock-origin
          bitwarden
          sponsorblock
          floccus
          leechblock-ng
          grammarly
        ];
      };
    };
  };
}
