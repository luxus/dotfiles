{ config, lib, pkgs, ... }:
let
  cfg = config.networking.fw-proxy;

  clashUser = "clash";
  clashDir = "/var/lib/clash";

  scripts = pkgs.stdenvNoCC.mkDerivation rec {
    name = "fw-proxy-scripts";
    buildCommand = ''
      install -Dm644 $enableProxy    $out/bin/enable-proxy
      install -Dm644 $disableProxy   $out/bin/disable-proxy
      install -Dm755 $updateClashUrl $out/bin/update-clash-url
      install -Dm755 $updateClash    $out/bin/update-clash
    '';
    enableProxy = pkgs.substituteAll {
      src = ./enable-proxy;
      mixedPort = cfg.port.mixed;
    };
    disableProxy = pkgs.substituteAll {
      src = ./disable-proxy;
    };
    updateClashUrl = pkgs.substituteAll {
      src = ./update-clash-url.sh;
      isExecutable = true;
      inherit (pkgs.stdenvNoCC) shell;
      inherit (pkgs) coreutils curl systemd;
      yqGo = pkgs.yq-go;
      httpPort = cfg.port.http;
      socksPort = cfg.port.socks5;
      redirPort = cfg.port.redir;
      mixedPort = cfg.port.mixed;
      externalControllerPort = cfg.port.externalController;
      directory = clashDir;
    };
    updateClash = pkgs.substituteAll {
      src = ./update-clash.sh;
      isExecutable = true;
      inherit (pkgs.stdenvNoCC) shell;
      inherit updateClashUrl;
      dlerUrl = config.age.secrets.clash-dler.path;
      cnixUrl = config.age.secrets.clash-cnix.path;
    };
  };
in
with lib;
{
  options.networking.fw-proxy = {
    enable = mkOption {
      type = with types; bool;
      default = false;
    };
    port = {
      http = mkOption {
        type = with types; int;
        default = 7890;
      };
      socks5 = mkOption {
        type = with types; int;
        default = 7891;
      };
      redir = mkOption {
        type = with types; int;
        default = 7893;
      };
      mixed = mkOption {
        type = with types; int;
        default = 8899;
      };
      externalController = mkOption {
        type = with types; int;
        default = 9090;
      };
      webui = mkOption {
        type = with types; int;
        default = 7901;
      };
    };
    environment = mkOption {
      type = with types; attrsOf str;
      description = ''
        Proxy environment.
      '';
    };
    stringEnvironment = mkOption {
      type = with types; listOf str;
      description = ''
        Proxy environment in strings.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    networking.fw-proxy.environment =
      let
        proxyUrl = "http://localhost:${toString cfg.port.mixed}/";
      in
      {
        HTTP_PROXY = proxyUrl;
        HTTPS_PROXY = proxyUrl;
        http_proxy = proxyUrl;
        https_proxy = proxyUrl;
      };
    networking.fw-proxy.stringEnvironment = map
      (key:
        let value = lib.getAttr key cfg.environment;
        in "${key}=${value}"
      )
      (lib.attrNames cfg.environment);

    users.users.${clashUser} = {
      isSystemUser = true;
    };
    # TODO: network is not available in vm-test
    systemd.services.clash-premium = lib.mkIf (!config.system.is-vm-test) {
      description = "A rule based proxy in GO";
      serviceConfig = {
        Type = "exec";
        User = "clash";
        Group = "nogroup";
        Restart = "on-abort";
        ExecStart = ''
          ${pkgs.nur.repos.linyinfeng.clash-premium}/bin/clash-premium -d "${clashDir}"
        '';
      };
      wantedBy = [ "multi-user.target" ];
    };
    environment.global-persistence.directories = [ clashDir ];
    system.activationScripts.fixClashDirectoryPremission = ''
      mkdir -p "${clashDir}"
      chown "${clashUser}" "${clashDir}"
    '';
    environment.systemPackages = [
      scripts
    ];
    virtualisation.oci-containers.containers.yacd = {
      image = "haishanh/yacd";
      ports = [
        "${toString cfg.port.webui}:80"
      ];
    };
    age.secrets = {
      clash-dler.file = config.age.secrets-directory + /clash-dler.age;
      clash-cnix.file = config.age.secrets-directory + /clash-cnix.age;
    };

    programs.proxychains = {
      enable = true;
      chain.type = "strict";
      proxies = {
        clash = {
          enable = true;
          type = "socks5";
          host = "127.0.0.1";
          port = cfg.port.mixed;
        };
      };
    };

    security.sudo.extraConfig = ''
      Defaults env_keep += "HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY NO_PROXY"
      Defaults env_keep += "http_proxy https_proxy ftp_proxy all_proxy no_proxy"
    '';
  };
}
