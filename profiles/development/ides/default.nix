{ pkgs, ... }:

{
  # persistence directories for neovim
  environment.global-persistence.user.directories = [
    ".config/lvim"
    ".config/nvim"
    ".local/share/nvim"
    ".local/share/lunarvim"
  ];
}
