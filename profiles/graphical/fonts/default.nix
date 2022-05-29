{ pkgs, lib, ... }:
#TODO:fixing  the font situaation
let
  iosevka-yinfeng = pkgs.iosevka.override {
    privateBuildPlan = {
      family = "Iosevka Yinfeng";
      spacing = "fontconfig-mono";
      serifs = "slab";
      # no need to export character variants and stylistic set
      no-cv-ss = "true";
      ligations = {
        inherits = "haskell";
      };
    };
    set = "yinfeng";
  };
in
{
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "Inconsolata" "IBMPlexMono" "CascadiaCode" "SourceCodePro" "FiraCode" "Hack" "Iosevka" ]; })
  ];

  fonts.fontconfig.defaultFonts = {
    # sansSerif = lib.mkBefore [
    #   "Source Sans 3"
    #   "Source Han Sans SC"
    #   "Source Han Sans TC"
    #   "Source Han Sans HW"
    #   "Source Han Sans K"
    # ];
    # serif = lib.mkBefore [
    #   "Source Serif 4"
    #   "Source Han Serif SC"
    #   "Source Han Serif TC"
    #   "Source Han Serif HW"
    #   "Source Han Serif K"
    # ];
    # monospace = lib.mkAfter [
    #   "Iosevka Yinfeng"
    # ];
    # emoji = lib.mkBefore [
    #   "Noto Color Emoji"
    # ];
  };

  passthru = { inherit iosevka-yinfeng; };
}
