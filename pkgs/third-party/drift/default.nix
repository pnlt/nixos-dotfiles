{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  mpv,
  yt-dlp,
}:
rustPlatform.buildRustPackage {
  pname = "drift";
  version = "1.3-unstable-2026-11-04";

  src = fetchFromGitHub {
    owner = "socatlolmeow";
    repo = "drift";
    rev = "50a72004e47434596a3fbbec69d4845a6653b6a4";
    hash = "sha256-NpZH2NN1Rbm+N3TJnbAHEx6jmMpcWO6mHMRSfseNjrg=";
  };

  cargoHash = "sha256-jnBK282Yc/iAOpuwIdxKkrZ/l/gfH4DolPE3WUyf+fE=";

  nativeBuildInputs = [makeWrapper];

  postInstall = ''
    # Native PipeWire output tags no process id, so hyprstfu can't map it to the window
    makeWrapper ${lib.getExe mpv} $out/libexec/drift/mpv --add-flags --ao=pulse
    wrapProgram $out/bin/drift --prefix PATH : $out/libexec/drift:${lib.makeBinPath [yt-dlp]}
  '';

  meta.mainProgram = "drift";
}
