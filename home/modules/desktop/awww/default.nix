{pkgs, ...}: {
  services.awww.enable = true;

  home.packages = [
    (pkgs.writeShellScriptBin "wallpaper-next" ''
      set -euo pipefail
      dir="${./wallpapers}"
      current=$(awww query 2>/dev/null | awk '{print $NF}' | xargs -r basename || true)
      mapfile -t files < <(find "$dir" -type f | sort)
      if [ "''${#files[@]}" -eq 0 ]; then
        echo "no wallpapers in $dir" >&2
        exit 1
      fi
      next="''${files[0]}"
      for i in "''${!files[@]}"; do
        if [[ "$(basename "''${files[$i]}")" == "$current" ]]; then
          next="''${files[$(( (i + 1) % ''${#files[@]} ))]}"
          break
        fi
      done
      awww img "$next"
    '')
  ];
}
