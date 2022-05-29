{ config, ... }:

let
  homeDirectory = "/root";
in
{
  users.users.root = {
    # using sops password file
    # passwordFile = config.sops.secrets."user-password/root".path;
    password = "luxus";
    openssh.authorizedKeys.keyFiles = [
      ../luxus/ssh/authorized-keys/luxus.pub
    ];
  };
  security.sudo.wheelNeedsPassword = false;
  environment.global-persistence.user.users = [ "root" ];
  home-manager.users.root = { suites, ... }: {
    imports = suites.base;
    passthrough.systemConfig = config;
    home.global-persistence = {
      enable = true;
      home = homeDirectory;
    };
  };

  sops.secrets."user-password/root" = {
    neededForUsers = true;
    sopsFile = config.sops.secretsDir + /common.yaml;
  };
}
