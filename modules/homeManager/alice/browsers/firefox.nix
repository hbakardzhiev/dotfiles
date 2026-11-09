{
  config,
  ...
}:

{
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";

    # Declarative policies to block telemetry, studies, and data collection at the root level
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFormHistory = true;
      PasswordManagerEnabled = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      OfferToSaveLogins = false;

      # Clear everything on shutdown via enterprise policy
      SanitizeOnShutdown = {
        Cache = true;
        Cookies = true;
        History = true;
        Sessions = true;
        SiteSettings = true;
        OfflineApps = true;
        FormData = true;
        Locked = true;
      };
    };

    profiles.nuked = {
      isDefault = true;

      settings = {
        # --- TELEMETRY & DATA SHARING KILLSWITCH ---
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.server" = "";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhr.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.hybridContent.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unifiedisoptin" = false;
        "toolkit.telemetry.updatePing.enabled" = false;

        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.healthreport.service.enabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;

        "app.shield.optoutstudies.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.crashreports.unsupportedCheck.sendReport" = false;
        "breakpad.reportURL" = "";

        # --- ZERO MEMORY / NO PERSISTENCE / NUKED ON CLOSE ---

        # Always start in Private Browsing mode globally if desired,
        # or rely on strict history clearing. (Uncomment line below for permanent Permanent-Private-Mode):
        # "browser.privatebrowsing.autostart" = true;

        # Disable disk caching completely (force everything into volatile memory or drop it)
        "browser.cache.disk.enable" = false;
        "browser.cache.memory.enable" = true; # Keeps it strictly in RAM until closed
        "browser.cache.offline.enable" = false;

        # History & Session settings
        "places.history.enabled" = false;
        "browser.sessionstore.privacy_level" = 2; # Never store extra session data (form data, POST data, cookies)
        "browser.sessionstore.resume_from_crash" = false;

        # Cookies and site data handling
        "network.cookie.lifetimePolicy" = 2; # Keep cookies until Firefox closes
        "network.cookie.cookieBehavior" = 1; # Block third-party cookies

        # DOM Local Storage & IndexedDB throttling/disabling
        "dom.storage.enabled" = false; # Disables HTML5 localStorage entirely across sites

        # Safe browsing and speculative loads leak info — disable them
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.speculativeSampling.enabled" = false;
        "network.predictor.enabled" = false;
        "network.prefetch-next" = false;

        # Misc tracking vectors
        "geo.enabled" = false;
        "beacon.enabled" = false;
      };
    };
  };
}
