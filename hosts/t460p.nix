{ config, suites, lib, ... }:

let

  btrfsSubvol = device: subvol: extraConfig: lib.mkMerge [
    {
      inherit device;
      fsType = "btrfs";
      options = [ "subvol=${subvol}" "compress=zstd" ];
    }
    extraConfig
  ];

  btrfsSubvolMain = btrfsSubvol "/dev/disk/by-uuid/61c8be1d-7cb6-4a6d-bfa1-1fef8cadbe2d";

in
{
  imports =
    suites.mobileWorkstation ++
    suites.game ++
    suites.fw ++
    suites.fw-tun ++
    suites.godns ++
    suites.anbox ++
    suites.user-yinfeng;

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";
  time.timeZone = "Asia/Shanghai";

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      consoleMode = "auto";
    };
  };

  hardware.enableRedistributableFirmware = true;
  hardware.video.hidpi.enable = true;

  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia = {
  #   prime = {
  #     offload.enable = true;
  #     nvidiaBusId = "PCI:2:0:0";
  #     intelBusId = "PCI:0:2:0";
  #   };
  #   modesetting.enable = true;
  # };

  virtualisation.kvmgt = {
    enable = true;
    device = "0000:00:02.0";
    vgpus = {
      i915-GVTg_V5_4 = {
        uuid = [
          "fb70adc6-d612-4af4-bfcd-94939e5ca225"
        ];
      };
    };
  };

  powerManagement.cpuFreqGovernor = "powersave";

  services.portal = {
    host = "portal.li7g.com";
    client.enable = true;
  };
  services.godns = {
    ipv4.settings = {
      domains = [{
        domain_name = "li7g.com";
        sub_domains = [ "t460p" ];
      }];
      ip_type = "IPv4";
      ip_url = "https://myip.biturl.top";
    };
    ipv6.settings = {
      domains = [{
        domain_name = "li7g.com";
        sub_domains = [ "t460p" ];
      }];
      ip_type = "IPv6";
      ip_interface = "enp0s31f6";
    };
  };

  environment.global-persistence.enable = true;
  environment.global-persistence.root = "/persist";

  services.snapper.configs = {
    persist = {
      subvolume = "/persist";
      extraConfig = ''
        ALLOW_GROUPS="${config.users.groups.wheel.name}"
        TIMELINE_CREATE="yes"
        TIMELINE_CLEANUP="yes"
        TIMELINE_MIN_AGE="1800"
        TIMELINE_LIMIT_HOURLY="10"
        TIMELINE_LIMIT_DAILY="10"
        TIMELINE_LIMIT_WEEKLY="4"
        TIMELINE_LIMIT_MONTHLY="0"
        TIMELINE_LIMIT_YEARLY="0"
        NUMBER_CLEANUP="yes"
        NUMBER_MIN_AGE="1800"
        NUMBER_LIMIT="20"
      '';
    };
  };
  environment.shellAliases = {
    snap = "snapper -c persist";
  };

  fileSystems."/" =
    {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "defaults" "size=8G" "mode=755" ];
    };
  boot.initrd.luks.devices."crypt-root".device =
    "/dev/disk/by-uuid/65aa660c-5b99-4663-a9cb-c69e18b6b6fd";
  fileSystems."/persist" = btrfsSubvolMain "@persist" { neededForBoot = true; };
  fileSystems."/var/log" = btrfsSubvolMain "@var-log" { neededForBoot = true; };
  fileSystems."/persist/.snapshots" = btrfsSubvolMain "@snapshots" { };
  fileSystems."/nix" = btrfsSubvolMain "@nix" { neededForBoot = true; };
  fileSystems."/swap" = btrfsSubvolMain "@swap" { };
  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/8F31-70B2";
      fsType = "vfat";
    };
  # fileSystems."/windows/c" =
  #   {
  #     device = "/dev/disk/by-uuid/ECB0C2DCB0C2AD00";
  #     fsType = "ntfs";
  #     options = [ "ro" "fmask=333" "dmask=222" ];
  #   };
  swapDevices =
    [{
      device = "/swap/swapfile";
    }];
}
