{
  lib,
  self,
  inputs,
  withSystem,
  ...
}:
let
  username = "daksh";
  description = "daksh";
in
{
  flake-file.inputs.nix-alien = {
    url = lib.mkDefault "github:thiagokokada/nix-alien";
    inputs.nixpkgs.follows = lib.mkDefault "nixpkgs";
  };

  flake.modules.nixos."users-${username}" = {
    users.users.${username} = {
      isNormalUser = true;
      inherit description;
      extraGroups = [
        "adbusers"
        "audio"
        "kvm"
        "libvirtd"
        "networkmanager"
        "wheel"
        "wireshark"
      ];
    };

    common.flake = "/home/${username}/.dotfiles";

    networking' = {
      allowPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      openssh = {
        enable = true;
        ports = [ 54321 ];
        endlessh.port = 22;
        settings.AllowUsers = [ username ];
      };
      openvpn.enable = true;
      # wireshark.enable = true;
    };

    media = {
      routing.enable = true;
      bluetooth.enable = true;
      optimizations.enable = true;
      streaming.server = {
        enable = true;
        autostart = false;
      };
    };
    hardware.bluetooth.settings.Policy.AutoEnable = false;

    containers'.enable = true;

    virtualisation = {
      containers.storage.settings = {
        storage.driver = "btrfs";
      };
      podman.defaultNetwork.settings = {
        dns_enabled = true;
      };
    };

    virtualisation' = {
      qemu = {
        enable = true;
        runAsRoot = true;
        manager.enable = true;
      };
      # waydroid.enable = true;
    };

    desktop.niri.enable = true;

    # packaging = {
    #   flatpak.enable = true;
    #   appimage.enable = true;
    # };

    gaming = {
      steam.enable = true;
      gamescope.enable = true;
      gamemode.enable = true;
    };

    # programs.gpu-screen-recorder.enable = true;
  };

  flake.homeConfigurations."${username}@zeus" = withSystem "x86_64-linux" (
    { pkgs, ... }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        self.modules.homeManager.options-desktop
        self.modules.homeManager.options-terminal
        self.modules.homeManager.options-browsers
        self.modules.homeManager.options-editors
        self.modules.homeManager.options-media
        self.modules.homeManager."users-${username}"
        {
          home.stateVersion = "25.11";

          nixpkgs.config.allowUnfree = true;
        }
      ];
    }
  );

  flake.modules.homeManager."users-${username}" =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        inputs.nix-alien.overlays.default
      ];

      home = {
        inherit username;
        homeDirectory = "/home/${username}";
        packages = builtins.attrValues {
          inherit (pkgs)
            # aseprite
            bibata-cursors
            # bottles
            duckdb
            ffmpeg
            # krita
            nix-alien
            nix-output-monitor
            nix-prefetch-github
            pear-desktop
            # pika-backup
            qbittorrent
            trash-cli
            wl-mirror
            playerctl
            ;
          inherit (pkgs.kdePackages) dolphin gwenview okular;
        };
        # file.".julia/config/startup.jl".source = ../scripts/julia/startup.jl;
      };

      desktop = {
        niri.dms.enable = true;
        labwc.dms.enable = true;
      };

      terminal.common.enable = true;

      browsers = {
        helium.enable = true;
        librewolf.enable = true;
      };

      editors = {
        doom-emacs.enable = true;
        zed-editor.enable = true;
      };

      # media.daw.enable = true;

      # packaging.flatpak.enableEssentials = true;

      programs = {
        # distrobox.enable = true;

        # terminal.common.enable -> git.enable
        git = {
          settings = {
            user = {
              name = "h4shcore";
              email = "97403914+h4shcore@users.noreply.github.com";
            };
            url = {
              "git@github.com:".insteadOf = "gh:";
              "git@gitlab.com:".insteadOf = "gl:";
              "git@codeberg.org:".insteadOf = "cb:";
              "git@github.com:h4shcore/".insteadOf = "me@gh:";
              "git@codeberg.org:h4shcore/".insteadOf = "me@cb:";
            };
          };
          # signing = {
          #   format = "ssh";
          #   signByDefault = true;
          #   key = "~/.ssh/id_ed25519.pub";
          # };
        };

        ghostty = {
          enable = true;
          settings = {
            command = "fish";
            shell-integration = "fish";
            window-decoration = "none";
            window-padding-x = 10;
            window-padding-y = "0,0";
            font-family = "Maple Mono NF";
            font-size = 14;
            font-feature = "-calt,-zero,-cv02,+cv01,+cv61";
            config-file = "./themes/dankcolors";
            app-notifications = "no-clipboard-copy,no-config-reload";
          };
        };

        # terminal.common.enable -> helix.enable
        helix.defaultEditor = true;

        home-manager.enable = true;

        # terminal.common.enable -> jujutsu.enable
        jujutsu.settings = {
          user = {
            name = "h4shcore ";
            email = "h4shcoren@proton.me";
          };
          # signing = {
          #   backend = "ssh";
          #   behavior = "own";
          #   key = "~/.ssh/id_ed25519.pub";
          # };
        };

        mpv.enable = true;

        nushell.enable = true;

        nix-search-tv.enable = true;

        # obs-studio = {
        #   enable = true;
        #   plugins = [
        #     pkgs.obs-studio-plugins.obs-pipewire-audio-capture
        #     pkgs.obs-studio-plugins.obs-vkcapture
        #   ];
        # };

        # onlyoffice.enable = true;

        thunderbird.enable = true;

        vesktop.enable = true;
      };

      services = {
        # easyeffects.enable = true;

        # kdeconnect.enable = true;
      };
    };
}
