{ config, pkgs, suites, lib, ... }:

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

  windowsCMountPoint = "/media/windows/c";

in
{
  imports =
    suites.mobileWorkstation ++
    suites.game ++
    suites.fw ++
    suites.godns ++
    suites.waydroid ++
    suites.nixbuild ++
    suites.user-yinfeng;

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";
  time.timeZone = "Asia/Shanghai";

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      efiSupport = true;
      mirroredBoots = [
        {
          efiBootloaderId = "GRUB";
          path = "/boot";
          devices = [ "nodev" ];
          efiSysMountPoint = "/boot";
        }
      ];
      font = "${pkgs.iosevka}/share/fonts/truetype/iosevka-regular.ttf";
      fontSize = 32;
      useOSProber = true;
    };
  };
  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPatches = [
  #   {
  #     name = "waydroid";
  #     patch = null;
  #     extraConfig = ''
  #       ASHMEM y
  #       ANDROID y
  #       ANDROID_BINDER_IPC y
  #       ANDROID_BINDERFS n
  #       ANDROID_BINDER_DEVICES "binder,hwbinder,vndbinder"
  #     '';
  #   }
  # ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.enableRedistributableFirmware = true;
  hardware.video.hidpi.enable = true;
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "stream-hidpi";
      desktopName = "Steam (HiDPI)";
      exec = "env GDK_SCALE=2 steam %U";
      categories = "Network;FileTransfer;Game;";
      icon = "steam";
    })
  ];

  services.thermald.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  boot.blacklistedKernelModules = [ "nouveau" ];

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

  services.xserver.desktopManager.gnome.enable = true;
  # specialisation = {
  #   kde.configuration = {
  #     boot.loader.grub.configurationName = "(specialisation - KDE)";

  #     services.xserver.desktopManager = {
  #       gnome.enable = lib.mkForce false;
  #       plasma5.enable = true;
  #     };
  #   };

  #   nvidia.configuration = {
  #     boot.loader.grub.configurationName = "(specialisation - NVIDIA)";

  #     services.xserver.videoDrivers = [ "nvidia" ];
  #     hardware.nvidia = {
  #       prime = {
  #         offload.enable = true;
  #         nvidiaBusId = "PCI:2:0:0";
  #         intelBusId = "PCI:0:2:0";
  #       };
  #       modesetting.enable = true;
  #     };
  #   };
  # };

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
      ip_interface = "enp0s31f6";
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

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "xps8930.ts.li7g.com";
      sshUser = "yinfeng";
      systems = [ "x86_64-linux" "i686-linux" ];
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      maxJobs = 4;
    }
  ];
  programs.ssh.extraConfig = ''
    Host xps8930.ts.li7g.com
      IdentityFile ${config.sops.secrets."yinfeng/id-ed25519".path}
  '';
  services.openssh.knownHosts = {
    xps8930 = {
      hostNames = [ "xps8930.ts.li7g.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRWO0HmTkgNBLLyvK3DodO4va2H54gHeRjhj5wSuxBq";
    };
  };

  fonts.fontconfig.localConf = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <dir>${windowsCMountPoint}/Windows/Fonts</dir>
    </fontconfig>
  '';

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
  fileSystems.${windowsCMountPoint} =
    {
      device = "/dev/disk/by-uuid/ECB0C2DCB0C2AD00";
      fsType = "ntfs";
      options = [ "ro" "fmask=333" "dmask=222" ];
    };
  swapDevices =
    [{
      device = "/swap/swapfile";
    }];
}
