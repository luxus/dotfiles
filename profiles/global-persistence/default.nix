{ ... }:

{
  environment.global-persistence = {
    directories = [
      "/etc/nixos"
      "/var/lib/systemd/coredump"
      "/var/db/sudo/lectured"
    ];
    etcFiles = [
      # systemd machine-id
      "/etc/machine-id"
    ];
  };
}
