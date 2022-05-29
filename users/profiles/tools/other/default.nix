{ pkgs, lib, ... }:

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
  programs.zellij.enable = true;
  programs.mcfly.enable = true;
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
  programs.man.generateCaches = true;

  programs.pazi.enable = true;
  programs.watson.enable = true;
  programs.lf.enable = true;
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;

      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$shlvl"
        "$directory"
        "$git_branch"
        "$git_metrics"
        "$git_status"
        "$fill"
        "$nodejs"
        "$php"
        "$python"
        "$ruby"
        "$terraform"
        "$vagrant"
        "$nix_shell"
        "$cmd_duration"
        "$line_break"
        "$jobs"
        "$time"
        "$status"
        "$shell"
        "$character"
      ];

      aws = {
        symbol = " ";
      };

      character = {
        success_symbol = "❯";
        error_symbol = "[](bold red)";
        vicmd_symbol = "[❮](bold purple)";
      };

      battery = {
        full_symbol = "";
        charging_symbol = "";
        discharging_symbol = "";
      };

      conda = {
        symbol = " ";
      };

      directory = {
        style = "bg:#DA627D";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";

        read_only = " ";
      };

      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
        style = "bold dimmed white";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        conflicted = " ";
        ahead = " $count ";
        behind = " $count ";
        diverged = " ";
        untracked = " ";
        stashed = " ";
        modified = " ";
        staged = " ";
        renamed = " ";
        deleted = " ";
        style = "bold bright-white";
      };

      memory_usage = {
        symbol = " ";
      };

      nix_shell = {
        format = "[$symbol$state]($style) ";
        symbol = " ";
        pure_msg = "λ ";
        impure_msg = "⎔ ";
      };

      nodejs = {
        symbol = " ";
        version_format = "$major";
        format = "[$symbol($version )]($style)";
      };

      package = {
        symbol = " ";
      };

      php = {
        symbol = " ";
        format = "[$symbol($version )]($style)";
        version_format = "$major.$minor";
      };

      python = {
        symbol = " ";
      };

      ruby = {
        symbol = " ";
      };

      rust = {
        symbol = " ";
      };

      status = {
        disabled = false;
      };
    };
  };
  home.packages = with pkgs; [
    ffmpeg
    lazygit
    gitui

    github-cli
    p7zip
    unar
    unrar
    unzip
    wl-clipboard
    uutils-coreutils
    wtf
    bandwhich
    asciinema
    hyperfine
    lazygit
    gitui
    broot
    prettyping
    difftastic
    pandoc

  ];

  home.global-persistence.directories = [
    ".config/gh" # github-cli
  ];
}
