{pkgs, ...}: {
  # Run unpatched prebuilt binaries (Android SDK, npm/pip native modules, Electron)
  services.envfs.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      acl
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      attr
      bzip2
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      fuse3
      gdk-pixbuf
      glib
      gtk3
      icu
      libdrm
      libGL
      libglvnd
      libnotify
      libpulseaudio
      libsodium
      libssh
      libunwind
      libusb1
      libuuid
      libx11
      libxcb
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxkbcommon
      libxkbfile
      libxrandr
      libxrender
      libxscrnsaver
      libxshmfence
      libxtst
      mesa
      nspr
      nss
      pango
      pipewire
      stdenv.cc.cc
      util-linux
      vulkan-loader
      zlib
      zstd
    ];
  };
}
