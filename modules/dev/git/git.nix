{config, ...}: let
  inherit (config.meta) user;
in {
  flake.modules.homeManager.git = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [knots git-absorb];

    shared = {
      git = {
        enable = true;
        policyOwners = ["pnlt"];
        user = {
          name = user.fullName;
          email = user.gitEmail;
        };
      };
      lazygit.enable = true;
    };

    programs.git.lfs.enable = true;

    # mergiraf falls back to line-based merging for languages it does not parse
    programs.mergiraf = {
      enable = true;
      enableGitIntegration = true;
    };

    # the mergiraf module sets diff3
    programs.git.settings.merge.conflictStyle = lib.mkForce "zdiff3";

    programs.git.settings.hook.knots = {
      event = "pre-commit";
      command = "${lib.getExe pkgs.knots} --staged -l rust --cognitive-threshold 15 --mccabe-threshold 15 --find-duplicates";
    };
  };
}
