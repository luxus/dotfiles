{ config, ... }:

let
  rpcPort = 9091;
in
{
  services.transmission = {
    enable = true;
    openFirewall = true;
    credentialsFile = config.age.secrets.transmission-credentials.path;
    port = rpcPort;
    settings = {
      rpc-bind-address = "::";
      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ rpcPort ];

  services.samba.shares.transmission = {
    "path" = "/var/lib/transmission/Downloads";
    "read only" = true;
    "browseable" = true;
    "comment" = "Dransmission downloads";
  };

  age.secrets.transmission-credentials.file = ../../../secrets/transmission-credentials.age;
}
