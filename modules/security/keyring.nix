{...}: {
  flake.modules.nixos.security = {
    # Secret Service for apps (browsers, etc.)
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;
  };

  # PAM unlocks only "login", so new secrets should land there.
  flake.modules.homeManager.desktop.home.file.".local/share/keyrings/default" = {
    text = "login\n";
    force = true;
  };
}
