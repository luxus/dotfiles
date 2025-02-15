{ config, ... }:

let
  rpcPort = 9091;
in
{
  services.transmission = {
    enable = true;
    openFirewall = true;
    credentialsFile = config.sops.secrets."transmission/credentials".path;
    settings = {
      rpc-port = rpcPort;
      rpc-bind-address = "::";
      rpc-authentication-required = true;
      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ rpcPort ];

  services.samba.shares.transmission = {
    "path" = "/var/lib/transmission/Downloads";
    "read only" = true;
    "browseable" = true;
    "comment" = "Transmission downloads";
  };
}
