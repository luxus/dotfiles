{ pkgs, config, suites, lib, modulesPath, ... }:
let

  btrfsSubvol = device: subvol: extraConfig: lib.mkMerge [
    {
      inherit device;
      fsType = "btrfs";
      options = [ "subvol=${subvol}" "compress=zstd" ];
    }
    extraConfig
  ];

  btrfsSubvolMain = btrfsSubvol "/dev/disk/by-uuid/c0e72722-18c2-4250-9034-676287478998";
in
{
  imports =
    suites.server ++
    suites.monitoring ++
    suites.telegram-send ++
    suites.auto-upgrade ++
    suites.notify-failure ++ [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

  config = lib.mkMerge [
    {
      i18n.defaultLocale = "en_US.UTF-8";
      console.keyMap = "us";
      time.timeZone = "Asia/Shanghai";

      boot.loader.grub = {
        enable = true;
        version = 2;
        device = "/dev/vda";
      };
      boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
      boot.kernelModules = [ "kvm-amd" ];

      boot.tmpOnTmpfs = true;
      services.fstrim.enable = true;
      environment.global-persistence.enable = true;
      environment.global-persistence.root = "/persist";
      environment.global-persistence.directories = [
        "/var/lib/private"
      ];

      environment.systemPackages = with pkgs; [
        tmux
      ];

      services.commit-notifier = {
        enable = true;
        cron = "0 */5 * * * *";
        tokenFile = config.sops.secrets."telegram-bot/commit-notifier".path;
      };
      systemd.services.commit-notifier.serviceConfig.Restart = "on-failure";
      sops.secrets."telegram-bot/commit-notifier" = { };

      services.notify-failure.services = [
        "commit-notifier"
      ];

      fileSystems."/" =
        {
          device = "tmpfs";
          fsType = "tmpfs";
          options = [ "defaults" "size=2G" "mode=755" ];
        };
      fileSystems."/persist" = btrfsSubvolMain "@persist" { neededForBoot = true; };
      fileSystems."/var/log" = btrfsSubvolMain "@var-log" { neededForBoot = true; };
      fileSystems."/nix" = btrfsSubvolMain "@nix" { neededForBoot = true; };
      fileSystems."/swap" = btrfsSubvolMain "@swap" { };
      fileSystems."/boot" =
        {
          device = "/dev/disk/by-uuid/f8d738d7-a2be-448f-a521-2b2a408d2572";
          fsType = "ext4";
        };
      swapDevices =
        [{
          device = "/swap/swapfile";
        }];
    }

    {
      networking = lib.mkIf (!config.system.is-vm) {
        useNetworkd = true;
        interfaces.ens3.useDHCP = true;
      };
      # TODO not working
      # environment.etc."systemd/network/50-ens3-ipv6.network".source = config.sops.templates."ens3-ipv6.network".path;
      sops.secrets."portal/ipv6-address" = { };
      sops.templates."ens3-ipv6.network".content = ''
        [Match]
        Name=ens3

        [Network]
        Address=${config.sops.placeholder."portal/ipv6-address"}
      '';
    }
  ];
}
