{pkgs, ...}: ''
  config-notification {
      disable-failed
  }

  hotkey-overlay {
      skip-at-startup
  }
  xwayland-satellite {
      path "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
  }

  workspace "main"
  workspace "dev"
  workspace "hub"

  screenshot-path null
''
