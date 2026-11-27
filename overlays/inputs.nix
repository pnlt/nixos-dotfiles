{
  inputs,
  system,
  ...
}:
with inputs; [
  (_final: _prev: {
    home-manager = home-manager.packages.${system}.home-manager.overrideAttrs (old: {
      buildCommand =
        old.buildCommand
        + ''
          substituteInPlace $out/bin/home-manager \
            --replace-fail "    presentNews" "    :"
        '';
    });
  })
  # Flake outputs, not overlays.shared-nixpkgs: only these hit cache.numtide.com
  (_final: _prev: {llm-agents = llm-agents.packages.${system};})
  bun2nix.overlays.default
  (_final: prev: {
    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [
        (_pythonFinal: pythonPrev: {
          nanoemoji = pythonPrev.nanoemoji.overridePythonAttrs (old: {
            src = old.src.overrideAttrs (_: {
              outputHash = "sha256-FysyKC01XBnRiur5RR9fcsTxQqE8x0JJHSoe3q6JtKc=";
            });
          });
        })
      ];
  })
  (final: prev: let
    extra = nixpkgs-extra.overlays.default final prev;
  in
    builtins.removeAttrs extra ["scripts"]
    // {myScripts = extra.scripts;})
  agentic-flake.overlays.default
  (final: _prev: {
    phone = final.callPackage "${luisquin-config}/pkgs/phone" {};
    ttygate = final.callPackage "${luisquin-config}/pkgs/ttygate" {};
  })
]
