{ config, pkgs, lib, ... }:

let
  name = "yinfeng";
  uid = (import ../uid.nix).${name};
  user = config.users.users.${name};
  homeManager = config.home-manager.users.${name};
  homeDirectory = "/home/${name}";

  groupNameIfPresent = name: lib.optional
    (config.users.groups ? ${name})
    config.users.groups.${name}.name;
in
{
  users.users.${name} = {
    uid = 1000;
    passwordFile = config.sops.secrets."user-password/${name}".path;
    isNormalUser = true;
    shell = pkgs.fish;
    home = homeDirectory;
    extraGroups = with config.users.groups; [
      users.name
      wheel.name
      keys.name
    ] ++
    groupNameIfPresent "adbusers" ++
    groupNameIfPresent "libvirtd" ++
    groupNameIfPresent "transmission" ++
    groupNameIfPresent "networkmanager" ++
    groupNameIfPresent "tss";

    openssh.authorizedKeys.keyFiles = [
      ./ssh/authorized-keys/pgp.pub
      ./ssh/authorized-keys/t460p-win.pub
    ];
  };

  sops.secrets = {
    "user-password/${name}".neededForUsers = true;
    "${name}/asciinema-token".owner = user.name;
  };

  home-manager.users.${name} = { suites, ... }: {
    imports = suites.full;

    passthrough.systemConfig = config;

    home.global-persistence.enable = true;

    home.file.".ssh/config".source = pkgs.substituteAll {
      src = ./ssh/config;
      inherit uid;
    };

    programs.git = {
      userName = "Lin Yinfeng";
      userEmail = "lin.yinfeng@outlook.com";
      # do not sign by default
      # signing.signByDefault = true;
    };
    programs.gpg.publicKeys = [
      {
        source = ./pgp/pub.asc;
        trust = "ultimate";
      }
    ];
  };

  environment.etc."nixos".source = "${homeDirectory}/Source/dotfiles";

  environment.global-persistence.directories =
    map (dir: "${homeDirectory}/${dir}")
      homeManager.home.global-persistence.directories;
}
