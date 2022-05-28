{ config, pkgs, lib, suites, profiles, ... }:

let

  btrfsSubvol = device: subvol: extraConfig: lib.mkMerge [
    {
      inherit device;
      fsType = "btrfs";
      options = [ "noatime" "subvol=${subvol}" "compress=zstd" ];
    }
    extraConfig
  ];

  btrfsSubvolMain = btrfsSubvol "/dev/disk/by-uuid/443b5b30-750a-4501-85b8-6655ecd4f499";
  # btrfsSubvolData = btrfsSubvol "/dev/disk/by-uuid/fc047db2-0ba9-445a-9b84-194af545fa23";

in
{
  imports =
    suites.workstation ++
    (with profiles; [
      # nix.access-tokens
      # nix.nixbuild
      # security.tpm
      # networking.wireguard-home
      # networking.behind-fw
      # networking.fw-proxy
      services.godns
    ]) ++
    (with profiles.users; [ luxus ]);

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";
  time.timeZone = "Europe/Zurich";

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
  };
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  hardware.enableRedistributableFirmware = true;
  # services.thermald.enable = true;
  # services.fwupd.enable = true;

  services.xserver.desktopManager.gnome.enable = true;

  virtualisation.kvmgt = {
    enable = true;
    device = "0000:00:02.0";
    vgpus = {
      i915-GVTg_V5_4 = {
        uuid = [
          "15feffce-745b-4cb6-9f48-075af14cdb6f"
        ];
      };
    };
  };
  # networking.campus-network = {
  #   enable = true;
  #   auto-login.enable = true;
  # };
  # services.portal = {
  #   host = "portal.li7g.com";
  #   client.enable = true;
  # };
  services.godns = {
    ipv4.settings = {
      domains = [{
        domain_name = "furiosa.org";
        sub_domains = [ "vanessa" ];
      }];
      ip_type = "IPv4";
      ip_interface = "enp6s0";
    };
    ipv6.settings = {
      domains = [{
        domain_name = "furiosa.org";
        sub_domains = [ "vanessa" ];
      }];
      ip_type = "IPv6";
      ip_interface = "enp6s0";
    };
  };
  # services.hercules-ci-agent.settings = {
  #   concurrentTasks = 2;
  # };

  environment.global-persistence.enable = true;
  environment.global-persistence.root = "/persist";
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  # boot.initrd.luks.forceLuksSupportInInitrd = true;
  # boot.initrd.kernelModules = [ "tpm" "tpm_tis" "tpm_crb" ];
  # boot.initrd.preLVMCommands = ''
  #   waitDevice /dev/disk/by-uuid/29bb6dbb-7348-42a0-a9e9-6e7daa89d32e
  #   ${pkgs.clevis}/bin/clevis luks unlock -d /dev/disk/by-uuid/29bb6dbb-7348-42a0-a9e9-6e7daa89d32e -n crypt-root
  #   waitDevice /dev/disk/by-uuid/0f9a546e-f458-46d9-88a4-4f6b157579ea
  #   ${pkgs.clevis}/bin/clevis luks unlock -d /dev/disk/by-uuid/0f9a546e-f458-46d9-88a4-4f6b157579ea -n crypt-data
  # '';
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "defaults" "size=16G" "mode=755" ];
  };
  # fileSystems."/" = btrfsSubvolMain "@root" { };
  fileSystems."/nix" = btrfsSubvolMain "@nix" { };
  # fileSystems."/home" = btrfsSubvolMain "@home" {  };
  fileSystems."/persist" = btrfsSubvolMain "@persist" { neededForBoot = true; };
  fileSystems."/var/log" = btrfsSubvolMain "@var-log" { neededForBoot = true; };
  # fileSystems."/mnt/btr_pool" = btrfsSubvolMain "@root" { options = [ "subvolid=5" ]; };
  # fileSystems."/swap" = btrfsSubvolMain "@swap" { };
  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/86C4-06EB";
      fsType = "vfat";
    };
  # fileSystems."/media/data" = btrfsSubvolData "@data" { };
  # swapDevices = [{
  #   device = "/swap/swapfile";
  # }];
  swapDevices = [ ];
}
