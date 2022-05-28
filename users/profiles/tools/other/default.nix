{ pkgs, ... }:

{
  programs = {
    tmux.enable = true;
    htop.enable = true;
    bat = {
      enable = true;
      config = {
        theme = "GitHub";
      };
    };
    jq.enable = true;
  };
    # Magical shell history
  programs.atuin.enable = true;
  programs.atuin.settings = {
    auto_sync = true;
    sync_frequency = "30m";
    search_mode = "fuzzy"; # 'prefix' | 'fulltext' | 'fuzzy'
    filter_mode = "global"; # 'global' | 'host' | 'session' | 'directory'
  };

  programs.exa.enable = true;
  programs.exa.enableAliases = true;
  programs.less.enable = true;

  programs.man.enable = true;
  # N.B. This can slow down builds, but enables more manpage integrations
  # across various tools. See the home-manager manual for more info.
  programs.man.generateCaches = lib.mkDefault true;

  programs.pazi.enable = true;
  programs.watson.enable = true;
  programs.lf.enable = true;

  home.packages = with pkgs; [
    ffmpeg
    github-cli
    imagemagick
    minio-client
    p7zip
    speedread
    trash-cli
    unar
    unrar
    unzip
    wl-clipboard
  ];

  home.global-persistence.directories = [
    ".config/gh" # github-cli
  ];
}
