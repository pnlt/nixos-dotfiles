{
  # Secret Service for apps (browsers, etc.)
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
}
