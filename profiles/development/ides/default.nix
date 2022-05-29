#{ pkgs, ... }:
{
  # persistence directories for neovim
  environment.global-persistence.user.directories = [
    ".local/bin"
    ".config/lvim"
    ".config/nvim"
    ".local/share/nvim"
    ".local/share/lunarvim"
  ];
}
