{user, ...}: {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      settings = {
        inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "lotus";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "lotus";
        };
        # Empty lists drop fcitx5's defaults: Ctrl+Space is Zed's terminal toggle,
        # a lone Left Shift tap switches IM. Hyprland's Mod+Shift+Space toggles instead.
        globalOptions = {
          "Hotkey/TriggerKeys" = {};
          "Hotkey/AltTriggerKeys" = {};
          "Hotkey/EnumerateForwardKeys" = {};
          "Hotkey/EnumerateBackwardKeys" = {};
          "Hotkey/EnumerateGroupForwardKeys" = {};
          "Hotkey/EnumerateGroupBackwardKeys" = {};
        };
      };
    };
  };

  services.fcitx5-lotus = {
    enable = true;
    users = [user.alias];
  };

  users.users.uinput_proxy.extraGroups = ["uinput"];
}
