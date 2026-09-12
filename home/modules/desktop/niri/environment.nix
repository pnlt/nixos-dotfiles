{}: ''
  environment {
      CLUTTER_BACKEND "wayland"
      GDK_BACKEND "wayland,x11,*"
      GDK_DPI_SCALE "1"
      GDK_SCALE "1"
      QT_AUTO_SCREEN_SCALE_FACTOR "1"
      QT_QPA_PLATFORM "wayland;xcb"
      QT_QPA_PLATFORMTHEME "gtk3"
      QT_WAYLAND_DISABLE_WINDOWDECORATION "1"
      SDL_VIDEODRIVER "wayland"
      GSK_RENDERER "ngl"
      ELECTRON_OZONE_PLATFORM_HINT "auto"
      NIXOS_OZONE_WL "1"
      // DMS_DISABLE_MATUGEN removed with dms
  }
''
