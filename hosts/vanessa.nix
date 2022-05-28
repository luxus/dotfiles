{ config, pkgs, lib, suites, profiles, ... }:

let

  btrfsSubvol = device: subvol: extraConfig: lib.mkMerge [
    {
      inherit device;
      fsType = "btrfs";
      options = [ "subvol=${subvol}" "compress=zstd" ];
    }
    extraConfig
  ];

  btrfsSubvolMain = btrfsSubvol "/dev/disk/by-uuid/a5a16dd1-f62f-4175-9144-fd2cd8383643";
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
      # services.godns
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
  services.thermald.enable = true;
  services.fwupd.enable = true;

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
  services.hercules-ci-agent.settings = {
    concurrentTasks = 2;
  };

  environment.global-persistence.enable = true;
  environment.global-persistence.root = "/persist";
  boot.kernelModules = [ "kvm-intel" "wl" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sr_mod" "uas" ];
  boot.initrd.luks.forceLuksSupportInInitrd = true;
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.initrd.kernelModules = [ "tpm" "tpm_tis" "tpm_crb" ];
  # boot.initrd.preLVMCommands = ''
  #   waitDevice /dev/disk/by-uuid/29bb6dbb-7348-42a0-a9e9-6e7daa89d32e
  #   ${pkgs.clevis}/bin/clevis luks unlock -d /dev/disk/by-uuid/29bb6dbb-7348-42a0-a9e9-6e7daa89d32e -n crypt-root
  #   waitDevice /dev/disk/by-uuid/0f9a546e-f458-46d9-88a4-4f6b157579ea
  #   ${pkgs.clevis}/bin/clevis luks unlock -d /dev/disk/by-uuid/0f9a546e-f458-46d9-88a4-4f6b157579ea -n crypt-data
  # '';
 # fileSystems."/" = {
 #   device = "none";
 #   fsType = "tmpfs";
 #   options = [ "defaults" "size=5G" "mode=755" ];
 # };
  #fileSystems."/" =
   # { device = "/dev/disk/by-uuid/a5a16dd1-f62f-4175-9144-fd2cd8383643";
   #   fsType = "btrfs";
   #   options = [ "subvol=root" ];
   # };
  #fileSystems."/" = btrfsSubvolMain "@root" { };
  #fileSystems."/nix" = btrfsSubvolMain "@nix" { neededForBoot = true; };
  #fileSystems."/persist" = btrfsSubvolMain "@persist" { neededForBoot = true; };
  #fileSystems."/var/log" = btrfsSubvolMain "@var-log" { neededForBoot = true; };
     fileSystems."/" =
    { device = "/dev/disk/by-uuid/a5a16dd1-f62f-4175-9144-fd2cd8383643";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };
  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/a5a16dd1-f62f-4175-9144-fd2cd8383643";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  boot.initrd.luks.devices."enc".device = "/dev/disk/by-uuid/2c913cfd-aa74-4629-b8a0-0a0a080e1f19";

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/a5a16dd1-f62f-4175-9144-fd2cd8383643";
      fsType = "btrfs";
      options = [ "subvol=persist" ];
      neededForBoot = true;
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/a5a16dd1-f62f-4175-9144-fd2cd8383643";
      fsType = "btrfs";
      options = [ "subvol=var-log" ];
      neededForBoot = true;
    };
fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/61B1-2C06";
      fsType = "vfat";
    };
  swapDevices = [{
    device = "/dev/disk/by-uuid/fa4fe315-136c-47d2-9ecb-726d4901ae75";
  }];
}
