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
  llm-agents.overlays.shared-nixpkgs
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
]
