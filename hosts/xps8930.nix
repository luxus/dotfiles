{ config, lib, suites, ... }:

let

  btrfsSubvol = device: subvol: extraConfig: lib.mkMerge [
    {
      inherit device;
      fsType = "btrfs";
      options = [ "subvol=${subvol}" "compress=zstd" ];
    }
    extraConfig
  ];

  btrfsSubvolMain = btrfsSubvol "/dev/disk/by-uuid/3d22521e-0f64-4a64-ad29-40dcabda13a2";
  btrfsSubvolMobile = btrfsSubvol "/dev/disk/by-uuid/7eb0cf99-d5ea-4bb0-97fa-bbea23308f71";

in
{
  imports =
    suites.desktopWorkstation ++
    suites.campus ++
    suites.fw ++
    suites.godns ++
    suites.ci-agent ++
    suites.transmission ++
    suites.samba ++
    suites.user-yinfeng;

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";
  time.timeZone = "Asia/Shanghai";

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
  };

  hardware.enableRedistributableFirmware = true;

  powerManagement.cpuFreqGovernor = "performance";

  networking.firewall.allowedTCPPorts = [ 80 ];
  services.godns = {
    ipv4.settings = {
      domains = [{
        domain_name = "li7g.com";
        sub_domains = [ "xps8930" ];
      }];
      ip_type = "IPv4";
      ip_interface = "enp4s0";
    };
    ipv6.settings = {
      domains = [{
        domain_name = "li7g.com";
        sub_domains = [ "xps8930" ];
      }];
      ip_type = "IPv6";
      ip_interface = "enp4s0";
    };
  };
  services.hercules-ci-agent.settings = {
    concurrentTasks = 2;
  };
  services.github-runner = {
    enable = true;
    url = "https://github.com/linyinfeng/dotfiles";
    tokenFile = config.age.secrets.dotfiles-runner-token.path;
  };
  systemd.services.github-runner.environment = config.networking.fw-proxy.environment;
  age.secrets.dotfiles-runner-token.file = config.age.secrets-directory + /dotfiles-runner-token.age;
  nix.gc.options = lib.mkForce ''
    --delete-older-than 14d
  '';

  environment.global-persistence.enable = true;
  environment.global-persistence.root = "/persist";

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "uas" "sd_mod" "sr_mod" ];
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "defaults" "size=16G" "mode=755" ];
  };
  boot.initrd.luks.devices."crypt-root" = {
    device = "/dev/disk/by-uuid/29bb6dbb-7348-42a0-a9e9-6e7daa89d32e";
    allowDiscards = true;
  };
  boot.initrd.luks.devices."crypt-mobile" = {
    device = "/dev/disk/by-uuid/b456f27c-b0a1-4b1e-8f2b-91f1826ae51c";
  };
  fileSystems."/nix" = btrfsSubvolMain "@nix" { neededForBoot = true; };
  fileSystems."/persist" = btrfsSubvolMain "@persist" { neededForBoot = true; };
  fileSystems."/var/log" = btrfsSubvolMain "@var-log" { neededForBoot = true; };
  fileSystems."/swap" = btrfsSubvolMain "@swap" { };
  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/74C9-BFBC";
      fsType = "vfat";
    };
  fileSystems."/var/lib/transmission" = btrfsSubvolMobile "@bittorrent" { };
  fileSystems."/data" =
    {
      device = "/dev/disk/by-uuid/6c4a47ea-492e-4855-8157-180e74904b73";
      fsType = "ext4";
    };
  swapDevices = [{
    device = "/swap/swapfile";
  }];
}
