{ config, lib, ... }:

let
  cfg = config.services.portal;
in
{
  options.services.portal = {
    host = lib.mkOption {
      type = with lib.types; str;
    };
    alterId = lib.mkOption {
      type = with lib.types; int;
      default = 0;
    };
    logLevel = lib.mkOption {
      type = with lib.types; str;
      default = "info";
    };
    path = lib.mkOption {
      type = with lib.types; str;
      default = "/ray";
    };
    client = {
      enable = lib.mkOption {
        type = with lib.types; bool;
        default = false;
      };
      port = lib.mkOption {
        type = with lib.types; int;
        default = 1080;
      };
      extraV2rayConfig = lib.mkOption {
        type = with lib.types; attrs;
        default = { };
      };
    };
    server = {
      enable = lib.mkOption {
        type = with lib.types; bool;
        default = false;
      };
      internalPort = lib.mkOption {
        type = with lib.types; int;
        default = 1080;
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (with cfg; server.enable || client.enable) {
      sops.secrets.portal-client-id = { };
      services.v2ray = {
        enable = true;
        configFile = config.sops.templates.portal-v2ray.path;
      };
      systemd.services.v2ray = {
        environment = {
          "v2ray.vmess.aead.forced" = "true";
        };
        restartTriggers = [
          config.sops.secrets.portal-client-id.sopsFile
          config.sops.templates.portal-v2ray.file
        ];
      };
    })
    (lib.mkIf cfg.server.enable {
      services.caddy = {
        enable = true;
        config = ''
          ${cfg.host} {
            log {
              output stdout
            }
            @v2ray {
              path ${cfg.path}
              header Connection *Upgrade*
              header Upgrade websocket
            }
            handle @v2ray {
              reverse_proxy localhost:${toString cfg.server.internalPort}
            }
            handle {
              respond "hello, world"
            }
          }
        '';
      };
      networking.firewall = {
        allowedTCPPorts = [ 80 443 ];
      };

      sops.templates.portal-v2ray.content = builtins.toJSON {
        log.loglevel = cfg.logLevel;
        inbounds = [
          {
            port = cfg.server.internalPort;
            protocol = "vmess";
            settings = {
              clients = [
                {
                  id = config.sops.placeholder.portal-client-id;
                  inherit (cfg) alterId;
                }
              ];
              disableInsecureEncryption = true;
            };
            streamSettings = {
              network = "ws";
              wsSettings = {
                inherit (cfg) path;
              };
            };
          }
        ];
        outbounds = [
          {
            protocol = "freedom";
          }
        ];
      };
    })
    (lib.mkIf cfg.client.enable {
      sops.templates.portal-v2ray.content =
        let
          basicConfig = {
            inbounds = [
              {
                port = cfg.client.port;
                listen = "127.0.0.1";
                protocol = "socks";
                settings = {
                  auth = "noauth";
                  udp = true;
                };
              }
            ];
            outbounds = [
              {
                protocol = "vmess";
                settings = {
                  vnext = [
                    {
                      address = cfg.host;
                      port = 443;
                      users = [
                        {
                          id = config.sops.placeholder.portal-client-id;
                          inherit (cfg) alterId;
                        }
                      ];
                    }
                  ];
                };
                streamSettings = {
                  network = "ws";
                  security = "tls";
                  wsSettings = {
                    path = cfg.path;
                  };
                };
                mux = {
                  enabled = false;
                  # mux as much as possible
                  concurrency = 1024;
                };
              }
            ];
          };
        in
        builtins.toJSON (lib.recursiveUpdate basicConfig cfg.client.extraV2rayConfig);
    })
  ];
}
