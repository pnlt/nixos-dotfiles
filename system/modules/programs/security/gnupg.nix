{pkgs, ...}: {
  programs.gnupg.agent = {
    enable = true;
    # Falls back to a curses prompt when there is no graphical session.
    pinentryPackage = pkgs.pinentry-gnome3;

    settings = {
      default-cache-ttl = 60 * 30;
      max-cache-ttl = 60 * 40;
    };
  };

  environment.interactiveShellInit = ''
    if [ -t 0 ]; then
      export GPG_TTY="$(tty)"
      gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true
    fi

    gpg_unlock() {
      printf 'test' | gpg --clearsign >/dev/null
    }

    gpg_forget() {
      gpgconf --kill gpg-agent
    }
  '';
}
