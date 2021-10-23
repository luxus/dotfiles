{
  description = "A highly structured configuration database.";

  nixConfig.extra-experimental-features = "nix-command flakes ca-references";
  nixConfig.extra-substituters = "https://nrdxp.cachix.org https://nix-community.cachix.org";
  nixConfig.extra-trusted-public-keys = "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";

  inputs =
    {
      nixos.url = "github:nixos/nixpkgs/nixos-unstable";
      latest.url = "github:nixos/nixpkgs/master";

      digga.url = "github:divnix/digga";
      digga.inputs.nixpkgs.follows = "nixos";
      digga.inputs.nixlib.follows = "nixos";
      digga.inputs.latest.follows = "latest";

      bud.url = "github:divnix/bud";
      bud.inputs.nixpkgs.follows = "nixos";
      bud.inputs.devshell.follows = "digga/devshell";

      home.url = "github:nix-community/home-manager";
      home.inputs.nixpkgs.follows = "nixos";

      darwin.url = "github:LnL7/nix-darwin";
      darwin.inputs.nixpkgs.follows = "latest";

      deploy.follows = "digga/deploy";

      agenix.url = "github:ryantm/agenix";
      agenix.inputs.nixpkgs.follows = "latest";
      sops-nix.url = "github:Mic92/sops-nix";
      sops-nix.inputs.nixpkgs.follows = "nixos";

      nvfetcher.url = "github:berberman/nvfetcher";
      nvfetcher.inputs.nixpkgs.follows = "latest";
      nvfetcher.inputs.flake-compat.follows = "digga/deploy/flake-compat";
      nvfetcher.inputs.flake-utils.follows = "digga/flake-utils-plus/flake-utils";

      naersk.url = "github:nmattia/naersk";
      naersk.inputs.nixpkgs.follows = "latest";

      nixos-hardware.url = "github:nixos/nixos-hardware";

      # MAIN: more inputs follows
      digga.inputs.home-manager.follows = "home";
      bud.inputs.beautysh.follows = "beautysh";
      beautysh.url = "github:lovesegfault/beautysh";
      beautysh.inputs.flake-utils.follows = "digga/flake-utils";
      beautysh.inputs.nixpkgs.follows = "nixos";

      # MAIN
      nur.url = "github:nix-community/nur";
      impermanence.url = "github:nix-community/impermanence";
      emacs-overlay.url = "github:nix-community/emacs-overlay";
      emacs-webkit.url = "github:akirakyle/emacs-webkit";
      emacs-webkit.flake = false;
      linyinfeng.url = "github:linyinfeng/nur-packages";
      linyinfeng.inputs.flake-utils-plus.follows = "digga/flake-utils-plus";
      linyinfeng.inputs.nixpkgs.follows = "nixos";
      nixos-cn.url = "github:nixos-cn/flakes";
      nixos-cn.inputs.nixpkgs.follows = "nixos";
      nixos-cn.inputs.flake-utils.follows = "digga/flake-utils";

      flake-compat.follows = "digga/deploy/flake-compat";

      # anbox-patch = { url = "https://tar.li7g.com/https/github.com/nixos/nixpkgs/pull/125600.patch.tar"; flake = false; };
      # TODO remove after issue <https://github.com/NixOS/nixpkgs/issues/141728> solved
      tracker-fix.url = "github:nixos/nixpkgs/e4ef597edfd8a0ba5f12362932fc9b1dd01a0aef";
    };

  outputs =
    { self
    , digga
    , bud
    , nixos
    , home
    , nixos-hardware
    , nur
    , agenix
    , nvfetcher
    , deploy
    , ...
    } @ inputs:
    digga.lib.mkFlake
      {
        inherit self inputs;

        # MAIN: patch the channel nixos
        # TODO: waiting for better patch supports
        # imports = [
        #   {
        #     # IFD workaround
        #     supportedSystems = [ "x86_64-linux" ];
        #     channels.nixos = {
        #       options.patches = nixos.lib.mkOption {
        #         type = with nixos.lib.types; listOf path;
        #       };
        #       config = {
        #         patches = [
        #           inputs.anbox-patch
        #         ];
        #       };
        #     };
        #   }
        # ];

        channelsConfig = { allowUnfree = true; };

        channels = {
          nixos = {
            imports = [ (digga.lib.importOverlays ./overlays) ];
            overlays = [
              digga.overlays.patchedNix
              nur.overlay
              agenix.overlay
              nvfetcher.overlay
              deploy.overlay
              ./pkgs/default.nix

              # MAIN
              inputs.sops-nix.overlay
              inputs.nixos-cn.overlay
              inputs.linyinfeng.overlays.singleRepoNur
              inputs.emacs-overlay.overlay
            ];
          };
          latest = { };
          # MAIN
          tracker-fix = { };
        };

        lib = import ./lib { lib = digga.lib // nixos.lib; };

        sharedOverlays = [
          (final: prev: {
            __dontExport = true;
            lib = prev.lib.extend (lfinal: lprev: {
              our = self.lib;
            });
          })
        ];

        nixos = {
          hostDefaults = {
            system = "x86_64-linux";
            channelName = "nixos";
            imports = [ (digga.lib.importExportableModules ./modules) ];
            modules = [
              { lib.our = self.lib; }
              digga.nixosModules.bootstrapIso
              digga.nixosModules.nixConfig
              home.nixosModules.home-manager
              agenix.nixosModules.age
              bud.nixosModules.bud

              # MAIN
              inputs.sops-nix.nixosModules.sops
              inputs.impermanence.nixosModules.impermanence
              "${inputs.nixos-cn}/modules/sops/template"
              "${inputs.nixos-cn}/modules/sops/extend-scripts.nix"
              inputs.linyinfeng.nixosModules.vlmcsd
              inputs.linyinfeng.nixosModules.tprofile
              inputs.linyinfeng.nixosModules.telegram-send
              inputs.linyinfeng.nixosModules.commit-notifier
              inputs.linyinfeng.nixosModules.dot-tar
            ];
          };

          imports = [ (digga.lib.importHosts ./hosts) ];
          hosts = {
            /* set host specific properties here */
            NixOS = {
              # MAIN
              tests = [
                digga.lib.allProfilesTest
              ];
            };

            # MAIN
            t460p = {
              system = "x86_64-linux";
              modules = with nixos-hardware.nixosModules; [
                common-pc
                common-cpu-intel
                common-pc-ssd
                lenovo-thinkpad-t460s
              ];
            };
            xps8930 = {
              system = "x86_64-linux";
              modules = with nixos-hardware.nixosModules; [
                common-pc
                common-cpu-intel
                common-pc-ssd
              ];
            };
            x200s = {
              system = "x86_64-linux";
            };
            portal = {
              system = "x86_64-linux";
            };
          };
          importables = rec {
            profiles = digga.lib.rakeLeaves ./profiles // {
              users = digga.lib.rakeLeaves ./users;
            };
            suites = with profiles; rec {
              # MAIN
              foundation = [ global-persistence security.polkit services.gc services.openssh ];
              base = [ core foundation users.root ];

              audit = [ security.audit ];
              network = (with networking; [ resolved tailscale ]) ++ (with security; [ fail2ban firewall ]);
              networkManager = (with networking; [ network-manager ]);
              multimedia = (with graphical; [ gnome kde sway fonts i18n ]) ++ (with services; [ pipewire ]);
              development = (with profiles.development; [ shells latex ]) ++ (with services; [ adb gnupg ]);
              multimediaDev = multimedia ++ development ++ (with profiles.development; [ ides ]);
              virtualization = with profiles.virtualization; [ podman libvirt wine ];
              wireless = with services; [ bluetooth ];
              phone = with services; [ kde-connect ];
              printing = [ services.printing ];
              campus = with networking; [ campus-network ];
              ci-agent = with services; [ hercules-ci-agent ];
              acme = [ services.acme ];
              telegram-send = [ programs.telegram-send ];
              notify-failure = [ services.notify-failure ];

              fw = with networking; [ fw-proxy ];
              nixbuild = [ nix.nixbuild ];
              game = with graphical.game; [ steam minecraft ];
              chia = [ services.chia ];
              transmission = [ services.transmission ];
              samba = [ services.samba ];
              godns = [ services.godns ];
              # anbox = [ profiles.virtualization.anbox ]; # TODO: broken
              waydroid = [ profiles.virtualization.waydroid ];

              workstation = base ++ multimediaDev ++ virtualization ++ network ++ networkManager ++ wireless ++ phone ++ telegram-send ++ notify-failure ++ printing;
              mobileWorkstation = workstation ++ campus ++ [ laptop ];
              desktopWorkstation = workstation;
              server = base ++ audit ++ network;
              homeServer = server ++ networkManager ++ godns ++ (with services; [ teamspeak vlmcsd ]);

              user-yinfeng = [ users.yinfeng ];
            };
          };
        };

        home = {
          imports = [ (digga.lib.importExportableModules ./users/modules) ];
          modules = [
            # MAIN
            (builtins.toPath "${inputs.impermanence}/home-manager.nix")
          ];
          importables = rec {
            profiles = digga.lib.rakeLeaves ./users/profiles;
            suites = with profiles; rec {
              # MAIN
              base = [ direnv git git-extra shells ];
              multimedia = [ gnome sway desktop-applications chromium firefox rime fonts mime ];
              development = [ profiles.development emacs tools asciinema tex ];
              virtualization = [ ];
              multimediaDev = multimedia ++ [ xdg-dirs ] ++ development ++ [ vscode ];
              synchronize = [ onedrive digital-paper roaming ];

              full = base ++ multimediaDev ++ virtualization ++ synchronize;
            };
          };
          users = {
            nixos = { suites, ... }: { imports = suites.base; };
          }; # digga.lib.importers.rakeLeaves ./users/hm;
        };

        devshell = ./shell;

        homeConfigurations = digga.lib.mkHomeConfigurations self.nixosConfigurations;

        deploy.nodes = digga.lib.mkDeployNodes
          # MAIN
          (removeAttrs self.nixosConfigurations [ "NixOS" "bootstrap" ])
          {
            portal.hostname = "portal.ts.li7g.com";
            x200s.hostname = "x200s.ts.li7g.com";
            t460p.hostname = "t460p.ts.li7g.com";
            xps8930.hostname = "xps8930.ts.li7g.com";
          };
        deploy.sshUser = "root";

        defaultTemplate = self.templates.bud;
        templates.bud.path = ./.;
        templates.bud.description = "bud template";
        # MAIN
        templates.project.path = ./templates/project;
        templates.project.description = "simple project template";

        # MAIN
        outputsBuilder = channels:
          let
            system = channels.nixos.system;
            inherit (nixos) lib;
          in
          {
            checks = lib.foldl lib.recursiveUpdate { }
              (lib.mapAttrsToList
                (host: cfg:
                  lib.optionalAttrs (cfg.pkgs.system == system)
                    { "toplevel-${host}" = cfg.config.system.build.toplevel; })
                self.nixosConfigurations);
          };

      }
    //
    {
      budModules = { devos = import ./bud; };
    }
  ;
}
