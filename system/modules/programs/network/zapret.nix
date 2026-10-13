{...}: {
  services.zapret = {
    enable = true;
    configureFirewall = true;

    whitelist = [
      "steampowered.com"
      "steamcommunity.com"
      "steamstatic.com"
      "steamcontent.com"
      "steamusercontent.com"
      "steam-chat.com"
      "steamgames.com"
      "valvesoftware.com"
      "playartifact.com"
    ];

    params = [
      "--dpi-desync=multisplit"
      "--dpi-desync-split-pos=2"
    ];
  };
}
