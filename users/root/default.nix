{ config, lib, ... }:

{
  users.users.root = {
    hashedPassword = "$6$Mo8boJowSi3G$FjdpZQNoUoFCdzKWXT94obLCUU4OrMMf8oN7ogxzGq4/zeqHIfnP/svKYLKzQ36qGwLpuV5mW87qcit43smOJ/";
    # passwordFile = config.age.secrets.user-root-password.path;
    openssh.authorizedKeys.keyFiles = [
      ../yinfeng/ssh/id_ed25519.pub
    ];
  };

  age.secrets.user-root-password.file = ../../secrets/user-root-password.age;
}
