{ pkgs, ... }:

{
  programs = {
    mpv.enable = true;

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
      ];
    };

    zathura = {
      enable = true;
      extraConfig = ''
        map <C-n> scroll down
        map <C-p> scroll up
        map <C-v> scroll full-down
        map <A-v> scroll full-up
      '';
      options = {
        adjust-open = "width";
      };
    };
  };

  home.packages = with pkgs; [
    anki
    calibre
    element-desktop
    gimp
    goldendict
    gparted
    inkscape
    keepass
    keepassxc
    libreoffice-fresh
    meld
    mplayer
    nur.repos.linyinfeng.clash-for-windows
    nur.repos.linyinfeng.icalingua
    tdesktop
    teamspeak_client
    transmission-remote-gtk
    virt-manager
    vlc
    xournalpp
    zoom-us
    zotero
  ];

  home.global-persistence = {
    directories = [
      ".ts3client"
      ".zotero"
      ".goldendict"

      ".config/calibre"
      ".config/obs-studio"
      ".config/Element"
      ".config/unity3d" # unity3d game saves
      ".config/transmission-remote-gtk"
      ".config/icalingua"

      ".local/share/Anki2"
      ".local/share/TelegramDesktop"
      ".local/share/geary"

      "Zotero"
    ];
  };
}
