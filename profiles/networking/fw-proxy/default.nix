{ config, lib, ... }:

let
  cfg = config.networking.fw-proxy;
in
{
  networking.fw-proxy.enable = true;
  networking.fw-proxy.tun.enable = true;
  networking.fw-proxy.mixinConfig = {
    port = 7890;
    socks-port = 7891;
    mixed-port = 8899;
    log-level = "warning";
    external-controller = "127.0.0.1:9090";
  };

  networking.fw-proxy.auto-update = {
    enable = true;
    service = "dler";
  };

  systemd.services.nix-daemon.environment = cfg.environment;

  nix = lib.mkMerge [
    {
      settings.substituters = lib.mkOrder 900 [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      ];
    }
    (lib.mkIf (config.networking.hostName != "nuc") {
      settings.substituters = lib.mkOrder 1100 [
        "https://nuc.li7g.com/store"
      ];
      settings.trusted-public-keys = [
        "cache.li7g.com:YIVuYf8AjnOc5oncjClmtM19RaAZfOKLFFyZUpOrfqM="
      ];
    })
  ];
}
