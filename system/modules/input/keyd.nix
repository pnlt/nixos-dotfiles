{...}: {
  services.keyd = {
    enable = true;

    keyboards = {
      default = {
        # Grabbing Lotus's uinput device would reorder its backspaces against real keys
        ids = ["*" "-1234:5678"];

        settings = {
          main = {
            capslock = "layer(control)";
          };

          control = {
            "[" = "esc";
          };
        };
      };
    };
  };

  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';
}
