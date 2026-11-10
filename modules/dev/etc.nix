{...}: {
  flake.modules.homeManager.dev = {pkgs, ...}: {
    home.packages = with pkgs; [
      license-generator
      passgen
      hyperfine # benchmarking
      rclone # cloud storages

      # Command runners
      gnumake
      just
      ngrok
      senv
      kondo # Clean up
      minify # HTML, CSS, and JavaScript minifier
      shfmt
      scc
      ast-grep
      jjui
    ];
  };
}
