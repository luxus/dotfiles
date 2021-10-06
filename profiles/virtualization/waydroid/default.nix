{ pkgs, ... }:

let
  waydroid = "${pkgs.waydroid}/bin/waydroid";
in
{
  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  environment.systemPackages = [ pkgs.waydroid ];
  systemd.services.waydroid-container = {
    description = "Waydroid Container";
    serviceConfig = {
      ExecStart = "${waydroid} container start";
      ExecStop = "${waydroid} container stop";
      ExecStopPost = "${waydroid} session stop";
    };
    path = [
      pkgs.util-linux # mount, umount
      pkgs.which
      pkgs.kmod # modprobe
      pkgs.iproute2
      pkgs.iptables
      pkgs.glibc # getent
    ];
    wantedBy = [ "multi-user.target" ];
  };
  environment.etc."gbinder.d/anbox.conf".source = "${pkgs.waydroid}/share/waydroid/gbinder.d/anbox.conf";
  environment.etc."gbinder.d/api-level.conf".text = ''
    [General]
    ApiLevel = 29
  '';
  networking.firewall.trustedInterfaces = [ "waydroid0" ];
  environment.global-persistence = {
    user.directories = [
      ".local/share/waydroid"
    ];
    directories = [
      "/var/lib/waydroid"
      "/var/lib/lxc/rootfs"
    ];
  };
}
