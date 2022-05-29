{ config, pkgs, lib, ... }:

let
  cfg = config.home.global-persistence;
  sysCfg = config.passthrough.systemConfig.environment.global-persistence;
in
{
  programs.nushell.enable = true;
  programs.fish.enable = true;
  programs.skim.enable = true;
  programs.zoxide.enable = true;
  home.packages = with pkgs; [
    du-dust

  ];
  home.global-persistence.directories = [
    ".local/share/zoxide"
    ".local/share/direnv"
  ];
}
