{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  makeWrapper,
  kdePackages,
  udev,
  wayland,
  wayland-protocols,
  libdrm,
  mesa,
  python3,
  quickshell,
  wl-clipboard,
  cliphist,
  wireplumber,
  pipewire,
  pulseaudio,
  cava,
  psmisc,
  brightnessctl,
  power-profiles-daemon,
  bluez,
  networkmanager,
}:
# Upstream's default.nix, over a pinned fetch instead of `./.`
let
  runtimeDeps = lib.makeBinPath [
    quickshell
    wl-clipboard
    cliphist
    wireplumber
    pipewire
    pulseaudio
    cava
    psmisc
    brightnessctl
    power-profiles-daemon
    bluez
    networkmanager
    python3
  ];
in
  stdenv.mkDerivation {
    pname = "tide-island";
    version = "1.1.4-unstable-2026-11-03";

    src = fetchFromGitHub {
      owner = "Bimbok";
      repo = "Tide-island-extended";
      rev = "f493bce4a6d5cf81416b0fad4d5d49c6b06116ab";
      hash = "sha256-NzyzlwYFApor9DUCXIkhkogX563OWRkfj0M5IFcfgi0=";
    };

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
      makeWrapper
      kdePackages.wrapQtAppsHook
    ];

    buildInputs = [
      kdePackages.qtbase
      kdePackages.qtdeclarative
      kdePackages.qt5compat
      kdePackages.qtwayland
      kdePackages.qtshadertools
      kdePackages.qtsvg
      udev
      wayland
      wayland-protocols
      libdrm
      mesa
      python3
    ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DTIDE_ISLAND_WITH_NIRI=ON"
    ];

    qtWrapperArgs = ["--prefix PATH : ${runtimeDeps}"];

    postInstall = let
      qmlImportPaths = "$out/lib/qt6/qml:${kdePackages.qtdeclarative}/lib/qt-6/qml:${kdePackages.qt5compat}/lib/qt-6/qml";
    in ''
      wrapProgram $out/bin/tide-island \
        --prefix PATH : "${runtimeDeps}" \
        --prefix QML_IMPORT_PATH : "${qmlImportPaths}" \
        --prefix QML2_IMPORT_PATH : "${qmlImportPaths}"
    '';

    meta = {
      description = "Dynamic Island desktop shell for Hyprland and niri";
      homepage = "https://github.com/Bimbok/Tide-island-extended";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
      mainProgram = "tide-island";
    };
  }
