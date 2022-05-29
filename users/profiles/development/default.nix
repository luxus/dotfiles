{ pkgs, ... }:

{
  home.global-persistence.directories = [
    ".rustup"
    ".cargo"
    ".cabal"
    ".wrangler"

    "Source"
    "Local"
  ];
  home.sessionPath = [ "$HOME/.local/bin" ];
  home.packages = with pkgs; [
    neovim-nightly
    # neovim-unwrapped

    ##: LunarVim dependencies {{
    #: core
    lua53Packages.luacheck
    cargo
    fd
    ripgrep
    gcc
    unzip

    #: nodejs
    nodePackages.neovim
    tree-sitter

    ## === Formatters ===

    treefmt # One CLI to format the code tree
    #nix
    statix
    deadnix
    alejandra
    #: python
    # (python311.withPackages (ps: [ ps.setuptools  ]))
    # black ps.isort
    poetry
    pyright

    #: }}
  ];
}
