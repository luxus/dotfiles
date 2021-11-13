{ config, lib, ... }:

{
  sops.defaultSopsFile = lib.mkDefault ../../secrets/main.yaml;
  sops.gnupg.sshKeyPaths = [ ];
  sops.age.sshKeyPaths = lib.mkDefault [
    (if config.environment.global-persistence.enable
    then "/persist/etc/ssh/ssh_host_ed25519_key"
    else "/etc/ssh/ssh_host_ed25519_key")
  ];
  # TODO workaround https://github.com/Mic92/sops-nix/issues/137
  sops.extendScripts.pre-sops = ''
    mkdir -p /run/secrets.d
    mount -t ramfs -o nodev,nosuid,mode=651 none /run/secrets.d
  '';
}
