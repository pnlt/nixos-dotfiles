{config, ...}: let
  inherit (config.meta) user;
in {
  flake.modules.nixos.security.services.tripwire = {
    enable = true;
    user = user.alias;
    decoys = [
      ".git-credentials"
      ".ssh/aws_prod.pem"
      ".electrum/wallets/default_wallet"
      ".config/solana/id.json"
      ".config/BraveSoftware/Brave-Browser/Local State"
      ".config/BraveSoftware/Brave-Browser/Default/Login Data"
      ".config/BraveSoftware/Brave-Browser/Default/Cookies"
      ".config/microsoft-edge/Default/Login Data"
    ];
  };
}
