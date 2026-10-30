{...}: [
  (
    _self: super: {
      waybar = super.waybar.overrideAttrs (_oldAttrs: let
        libcavaVersion = "0.10.7";
        libcavaSrc = super.fetchFromGitHub {
          owner = "LukashonakV";
          repo = "cava";
          rev = libcavaVersion;
          hash = "sha256-zkyj1vBzHtoypX4Bxdh1Vmwh967DKKxN751v79hzmgQ=";
        };
      in {
        src = super.fetchFromGitHub {
          owner = "Alexays";
          repo = "Waybar";
          rev = "05945748dccce28bf96d26d8f64a9e69a8dd49ba";
          hash = "sha256-51R3mIt8cLNvh/X5qe9vOqeJCj0U9KRyemVE5y+OhiU=";
        };

        postUnpack = ''
          pushd "$sourceRoot"
          cp -R --no-preserve=mode,ownership ${libcavaSrc} subprojects/cava-${libcavaVersion}
          patchShebangs .
          popd
        '';

        doCheck = false;
        mesonFlags =
          map
          (flag:
            if flag == "-Dtests=enabled"
            then "-Dtests=disabled"
            else flag)
          (_oldAttrs.mesonFlags or []);
      });
    }
  )
  (_final: prev: {
    bat = prev.bat.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./patches/bat/idempotent-cache-build.patch
        ];
    });
  })
  (final: _prev: {
    rtk = final.llm-agents.rtk.overrideAttrs (_oldAttrs: {
      postInstall = ''
        mkdir -p $out/share/rtk/hooks
        cp -r hooks/* $out/share/rtk/hooks/
      '';
    });
  })
  (_final: prev: rec {
    codex = prev.llm-agents.codex.overrideAttrs (old: let
      devServerInstruction = "When building a site or app that needs a dev server to run properly, you start the local dev server after implementation and give the user the URL so they can try it. If there's already a server on that port, you use another one. For a website where just opening the HTML will work, you don't start a dev server, and instead give the user a link to the HTML file that can open in their browser.\\n\\n";
    in {
      patches =
        (old.patches or [])
        ++ [
          ./patches/codex/recursive-project-trust.patch
          ./patches/codex/git-remote-show-no-fetch.patch
          ./patches/codex/curated-plugins-disable-sync.patch
          ./patches/codex/presentation-card.patch
          ./patches/codex/terminal-terminfo-dirs.patch
          ./patches/codex/custom-input-bar.patch
          ./patches/codex/disable-cloud-tasks.patch
          ./patches/codex/default-bypass-hook-trust.patch
          ./patches/codex/disable-update-advice.patch
          ./patches/codex/session-only-directory-trust.patch
          ./patches/codex/disable-config-toml-writes.patch
          ./patches/codex/default-yolo.patch
          ./patches/codex/status-line-short-cwd.patch
          ./patches/codex/status-line-effective-reasoning.patch
          ./patches/codex/unload-unsubscribed-threads.patch
          ./patches/codex/rename-name-alias.patch
          ./patches/codex/thread-title-on-composer-rail.patch
          ./patches/codex/default-no-daemon.patch
        ];

      postPatch =
        (old.postPatch or "")
        + ''
          substituteInPlace models-manager/models.json \
            --replace-fail ${prev.lib.escapeShellArg devServerInstruction} ""
        '';
    });

    ccstatusline = prev.llm-agents.ccstatusline.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./patches/ccstatusline/responsive-width-profiles.patch
        ];

      # Upstream installs only the entry point straight out of $src, which both
      # steps over the patched copy and drops the chunks it imports
      # (dist/ccstatusline-*.js, hooks-*.js, index-*.js ...).
      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib $out/bin
        cp -r dist $out/lib/ccstatusline
        chmod +x $out/lib/ccstatusline/ccstatusline.js
        patchShebangs $out/lib/ccstatusline/ccstatusline.js
        ln -s $out/lib/ccstatusline/ccstatusline.js $out/bin/ccstatusline
        runHook postInstall
      '';
    });

    freebuff = prev.callPackage ../pkgs/third-party/freebuff {};

    llm-agents = prev.llm-agents // {inherit codex ccstatusline freebuff;};
  })
  (_final: prev: {
    mako = prev.mako.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./patches/mako/notification-metadata.patch
          ./patches/mako/restore-history-by-id.patch
          ./patches/mako/history-actions-and-removal.patch
        ];
    });
  })
  (_final: prev: {
    lazygit = prev.lazygit.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./patches/lazygit/hide-personal-authors.patch
          ./patches/lazygit/shift-delete-in-text-inputs.patch
          ./patches/lazygit/submodules-dashboard.patch
          ./patches/lazygit/show-worktree-path.patch
        ];
    });
  })
  (_final: prev: {
    browsers = prev.browsers.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./patches/browsers/zen-linux-app.patch
          ./patches/browsers/larger-picker-window.patch
          ./patches/browsers/fix-url-argument-injection.patch
        ];
    });
  })
  (_final: prev: {
    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [
        (_pythonFinal: pythonPrev: {
          libtmux = pythonPrev.libtmux.overridePythonAttrs (old: {
            patches =
              (old.patches or [])
              ++ [
                ./patches/libtmux/pin-attached-server-socket.patch
              ];
          });
        })
      ];
  })
  (_final: prev: {
    # herdr 0.9.4's vendored libghostty-vt hard-requires Zig 0.16, but
    # llm-agents' shared-nixpkgs overlay builds it with this flake's default
    # `zig`, which nixos-unstable moved to 0.17. Drop the override once herdr
    # accepts 0.17 (or llm-agents pins it upstream).
    #  Backports ghostty-org/ghostty#14832; drop once herdr vendors past
    #  ghostty bcfe5775.
    herdr = prev.llm-agents.herdr.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./patches/herdr/larger-sidebar-toggle-hit-area.patch
          ./patches/herdr/freebuff-agent-session.patch
          ./patches/herdr/stage-agent-resume-command.patch
          ./patches/herdr/claude-resume-skip-permissions.patch
          ./patches/herdr/default-bg-follows-child-ownership.patch
          ./patches/herdr/drop-kitty-images-in-erased-history.patch
        ];
    });
  })
  (_final: prev: {
    gnome-keyring = prev.gnome-keyring.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./patches/gnome-keyring/open-session-missing-session-error.patch
          ./patches/gnome-keyring/create-client-record-on-demand.patch
        ];
    });
  })
  (_final: prev: {
    linear-tui = prev.linear-tui.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./patches/linear-tui/terminal-image-rendering.patch
          ./patches/linear-tui/issue-table-layout.patch
          ./patches/linear-tui/issue-table-status-icons.patch
        ];
    });
  })
  (_final: prev: {
    vicinae = prev.vicinae.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./patches/vicinae/write-clipboard-through-data-control-when-focused.patch
        ];
    });
  })
]
