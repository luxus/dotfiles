{ pkgs, ... }:

{
  services.udev.packages = [
    pkgs.nur.repos.linyinfeng.canokey-udev-rules
  ];

  services.pcscd = {
    enable = true;
    plugins = with pkgs; [
      ccid
    ];
  };

  hardware.gpgSmartcards.enable = true;

  environment.systemPackages = with pkgs; [
    pcsctools
  ];
}
