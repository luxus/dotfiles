{ config, pkgs, lib, ... }:

let
  name = "luxus";
  uid = config.ids.uids.${name};
  user = config.users.users.${name};
  homeManager = config.home-manager.users.${name};
  homeDirectory = "/home/${name}";

  groupNameIfPresent = name: lib.optional
    (config.users.groups ? ${name})
    config.users.groups.${name}.name;
in
{
  imports = [
    # ./syncthing
  ];

  users.users.${name} = {
    inherit uid;
    # passwordFile = config.sops.secrets."user-password/${name}".path;
    password = "luxus";

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
    groupNameIfPresent "tss" ++
    groupNameIfPresent "nix-access-tokens" ++
    groupNameIfPresent "nixbuild" ++
    groupNameIfPresent "telegram-send" ++
    groupNameIfPresent "plugdev";

    openssh.authorizedKeys.keyFiles = [
      ./ssh/authorized-keys/luxus.pub
    ];
  };

  sops.secrets."user-password/${name}" = {
    neededForUsers = true;
    sopsFile = config.sops.secretsDir + /common.yaml;
  };

  environment.global-persistence.user.users = [ name ];
  home-manager.users.${name} = { suites, ... }: {
    imports = suites.full;
    passthrough.systemConfig = config;
    home.global-persistence = {
      enable = true;
      home = homeDirectory;
    };

    home.file.".ssh/config".source = pkgs.substituteAll {
      src = ./ssh/config;
      inherit uid;
    };

    programs.git = {
      userName = "luxus";
      userEmail = "luxuspur@gmail.com";
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
}
