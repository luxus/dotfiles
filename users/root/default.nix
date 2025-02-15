{ config, ... }:

let
  homeDirectory = "/root";
in
{
  users.users.root = {
    passwordFile = config.sops.secrets."user-password/root".path;
    openssh.authorizedKeys.keyFiles = [
      ../yinfeng/ssh/authorized-keys/pgp.pub
    ];
  };

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
