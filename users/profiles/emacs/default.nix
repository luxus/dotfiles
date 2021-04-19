{ config, pkgs, lib, ... }:
let
  emacsConfig = ./init.el;
  emacs = (pkgs.emacsWithPackagesFromUsePackage {
    config = emacsConfig;
    package = pkgs.emacs;
    alwaysEnsure = true;
  });
in
{
  home.packages = [ emacs ] ++
    (with pkgs; [
      ispell
      agda # agda mode
      sqlite # org-roam
      graphviz # org-roam
    ]);

  services.emacs = {
    enable = true;
    package = emacs;
    client.enable = true;
  };

  home.shellAliases = {
    emacs = "emacsclient --create-frame";
    vim = "emacsclient --create-frame --tty";
  };

  home.sessionVariables = {
    EDITOR = "emacsclient";
  };

  home.file.".emacs.d/init.el".source = emacsConfig;

  home.global-persistence = {
    directories = [
      ".emacs.d"
    ];
    files = [
      ".ispell_english"
    ];
  };
}
