{ config, lib, pkgs, ... }:

lib.mkIf config.home.graphical {
  programs = {
    mpv.enable = true;
  };

  home.packages = with pkgs; [
    # anki
    _1password-gui
    # TODO python3Packages.apsw broken
    # https://github.com/NixOS/nixpkgs/issues/167626
    # calibre
    element-desktop
    # gimp
    # gnuradio
    # goldendict
    gparted
    # inkscape
    # keepassxc
    # libreoffice-fresh
    lollypop
    meld
    mplayer
    brave
    obsidian
    # nur.repos.linyinfeng.clash-for-windows
    # nur.repos.linyinfeng.icalingua-plus-plus
    # picard
    tdesktop
    # transmission-remote-gtk
    virt-manager
    xournalpp
  ];

  home.global-persistence = {
    directories = [
      # ".goldendict"

      # ".config/Bitwarden"
      ".config/Element"
      # ".config/icalingua"
      # ".config/unity3d" # unity3d game saves
      # ".config/transmission-remote-gtk"
      # ".local/share/Anki2"
      ".local/share/TelegramDesktop"
      # ".local/share/geary"
      # "Zotero"
    ];
  };
}
