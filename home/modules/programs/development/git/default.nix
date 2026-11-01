{
  lib,
  pkgs,
  user,
  ...
}: {
  imports = [
    ./terminal.nix
    ./jujutsu.nix
    ./github.nix
    ./etc.nix
  ];

  home.packages = with pkgs; [knots git-absorb mergiraf];

  shared = {
    git = {
      enable = true;
      user = {
        name = user.fullName;
        email = user.gitEmail;
      };
    };
    lazygit.enable = true;
  };

  # mergiraf falls back to line-based merging for languages it does not parse
  programs.git.attributes = ["* merge=mergiraf"];
  programs.git.settings.merge.mergiraf = {
    name = "mergiraf";
    driver = "${lib.getExe pkgs.mergiraf} merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
  };

  programs.git.settings.hook.knots = {
    event = "pre-commit";
    command = "${lib.getExe pkgs.knots} --staged -l rust --cognitive-threshold 15 --mccabe-threshold 15 --find-duplicates";
  };
}
