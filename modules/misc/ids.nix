{ ... }:

{
  ids.uids = {
    # human users
    luxus = 1000;

    # other users
    nixos = 1099;

    # service users
    # nix-access-tokens = 400; # not using
    # nixbuild = 401; # not using
    # telegram-send = 402;
  };
  ids.gids = {
    # service groups
    nix-access-tokens = 400;
    nixbuild = 401;
    telegram-send = 402;
  };
}
