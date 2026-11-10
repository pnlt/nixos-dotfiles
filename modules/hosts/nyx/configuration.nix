{config, ...}: let
  inherit (config.meta) host nix;
in {
  flake.modules.nixos.nyx = {pkgs, ...}: {
    networking.hostName = host.name;

    time.timeZone = host.timeZone;
    i18n.defaultLocale = host.i18nLocale;
    documentation.enable = false;

    environment.systemPackages = with pkgs; [
      vim
      pavucontrol
      swaylock
      networkmanagerapplet
    ];

    system = {
      activationScripts = {
        banner.text = ''
          if [ ! -f /run/nixos-banner-shown ]; then
            echo '    .              +   .                .   . .     .  .'
            echo '                    .                    .       .     *'
            echo '    .       *                        . . . .  .   .  + .'
            echo '              (You Are Here)            .   .  +  . . .'
            echo '  .                 |             .  .   .    .    . .'
            echo '                    |           .     .     . +.    +  .'
            echo '                    ↓            .       .   . .'
            echo '         . .       . * <- (chimera).    * . . .  .  +   .'
            echo '            +        ° <- (nyx)  *   .   .      +'
            echo '<==[{         ?             .       . +  .+. .'
            echo '    .                      .     . + .  . .     .      .'
            echo '            .      .    .     . .   . . .        ! /'
            echo '        *             .    . .  +    .  .       - O -  ←- (rose)'
            echo '            .     .    .  +   . .  *  .        . / |'
            echo '                . + .  .  .  .. +  .'
            echo '  .  +   .  .  .  *   .  *  . +..  .            *'
            echo '  .      .   . .   .   .   . .  +   .    .            +'
            echo

            touch /run/nixos-banner-shown
          fi
        '';
      };

      nixos.tags = ["yay"];

      inherit (nix) stateVersion;

      autoUpgrade.enable = false;
    };
  };
}
