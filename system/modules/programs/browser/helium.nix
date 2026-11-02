{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.helium.nixosModules.default
  ];

  programs.helium = {
    enable = true;

    # makeBinaryWrapper passes the NIXOS_OZONE_WL expansion as a literal URL;
    # wrapQtAppsHook is unused (dontWrapQtApps)
    package =
      (pkgs.callPackage "${inputs.helium}/helium.nix" {
        wrapGAppsHook3 = pkgs.wrapGAppsHook3.override {makeWrapper = pkgs.makeShellWrapper;};
      })
      .overrideAttrs (old: {
        nativeBuildInputs = lib.remove pkgs.qt6.wrapQtAppsHook old.nativeBuildInputs;
      });

    flags = [
      "--enable-zero-copy"
      "--ignore-gpu-blocklist"
      # Chromium honours only the last --enable-features, keep them in one
      "--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoEncoder,ParallelDownloading"
      "--extension-mime-request-handling=always-prompt-for-install"
    ];

    policies = {
      "BackgroundModeEnabled" = false;
      "BrowserSignin" = 0;
      "SyncDisabled" = true;
      "DefaultBrowserSettingEnabled" = false;
      "HighEfficiencyModeEnabled" = true;

      "SpellcheckEnabled" = true;
      "SpellcheckLanguage" = [
        "en-US"
      ];

      "PasswordManagerEnabled" = false;
      "PasswordLeakDetectionEnabled" = false;

      "DefaultSearchProviderEnabled" = true;
      "DefaultSearchProviderName" = "Google";
      "DefaultSearchProviderSearchURL" = "https://www.google.com/search?q={searchTerms}";

      "AutofillAddressEnabled" = false;
      "AutofillCreditCardEnabled" = false;

      "RestoreOnStartup" = 5;

      "BrowsingDataLifetime" = [
        {
          "data_types" = [
            "browsing_history"
          ];
          "time_to_live_in_hours" = 1;
        }
        {
          "data_types" = [
            "password_signin"
            "autofill"
          ];
          "time_to_live_in_hours" = 1;
        }
      ];

      "SafeBrowsingProtectionLevel" = 1;
      "DefaultPopupsSetting" = 2;

      "BlockThirdPartyCookies" = true;
      "DefaultCookiesSetting" = 4;

      "DnsOverHttpsMode" = "secure";
      "DnsOverHttpsTemplates" = "https://cloudflare-dns.com/dns-query";

      "ExtensionInstallForcelist" = [
        "ficfmibkjjnpogdcfhfokmihanoldbfe"
        "dffbjiomnajbmlhjelpipfldgkijdemn"
        "ldpochfccmkkmhdbclfhpagapcfdljkj"
        "mefhakmgclhhfbdadeojlkbllmecialg"
      ];

      "ManagedBookmarks" = [
        {
          "toplevel_name" = "Absent friends";
        }
        {
          "name" = "ESC Configurator";
          "url" = "esc-configurator.com";
        }
        {
          "name" = "EdgeTX Buddy";
          "url" = "buddy.edgetx.org";
        }
        {
          "name" = "Betaflight Configurator";
          "url" = "app.betaflight.com";
        }
      ];
    };
  };
}
