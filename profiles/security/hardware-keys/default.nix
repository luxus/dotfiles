{ pkgs, ... }:

{
  # canokey
  # services.udev.packages = [
  #   # pkgs.nur.repos.linyinfeng.canokey-udev-rules
  # ];

  # services.pcscd = {
  #   enable = true;
  #   plugins = with pkgs; [
  #     ccid
  #   ];
  # };

  # hardware.gpgSmartcards.enable = true;

  # environment.systemPackages = with pkgs; [
  #   yubikey-manager-qt
  #   yubikey-manager
  #   pcsctools
  # ];

  # disabled
  # security.pam.u2f = {
  #   enable = false;
  #   cue = true;
  # };
  # environment.global-persistence.user.directories = [
  #   ".config/Yubico"
  # ];
}
