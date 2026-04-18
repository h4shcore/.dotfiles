{ lib, inputs, ... }:
{
  flake-file.inputs = {
    niri-source = {
      url = lib.mkDefault "github:niri-wm/niri";
      flake = false;
    };
    niri = {
      url = lib.mkDefault "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = lib.mkDefault "nixpkgs";
      inputs.niri-unstable.follows = lib.mkDefault "niri-source";
    };
    dms = {
      url = lib.mkDefault "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = lib.mkDefault "nixpkgs";
    };
    quickshell = {
      url = lib.mkDefault "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = lib.mkDefault "nixpkgs";
    };
    xwayland-satellite = {
      url = lib.mkDefault "github:Supreeeme/xwayland-satellite";
      inputs.nixpkgs.follows = lib.mkDefault "nixpkgs";
    };
  };

  flake.modules.nixos.options-desktop =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.niri.nixosModules.niri ];

      options.desktop = lib.mkOption {
        type = lib.types.submodule {
          options = {
            niri.enable = lib.mkEnableOption "enable unstable niri builds";
            labwc.enable = lib.mkEnableOption "enable labwc";
          };
        };
        default = { };
      };

      config = lib.mkMerge [
        (lib.mkIf config.desktop.niri.enable {
          nixpkgs.overlays = [
            inputs.niri.overlays.niri
            inputs.xwayland-satellite.overlays.default
          ];

          programs.niri = {
            enable = true;
            package = pkgs.niri-unstable;
          };

          environment.systemPackages = [
            pkgs.nautilus
            pkgs.xwayland-satellite
          ];
        })

        (lib.mkIf config.desktop.labwc.enable {
          programs.labwc.enable = true;
        })
      ];
    };

  flake.modules.homeManager.options-desktop =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.niri.homeModules.config
        inputs.dms.homeModules.niri
        inputs.dms.homeModules.dank-material-shell
      ];

      options.desktop = lib.mkOption {
        type = lib.types.submodule {
          options = {
            niri.dms.enable = lib.mkEnableOption "enable my dank-material-shell setup for niri";
            labwc.dms.enable = lib.mkEnableOption "enable my dank-material-shell setup for labwc";
          };
        };
        default = { };
      };

      config = lib.mkMerge [
        (lib.mkIf config.desktop.niri.dms.enable {
          nixpkgs.overlays = [
            inputs.quickshell.overlays.default
          ];

          programs = {
            # Borked till the day "includes" is supported!
            niri.config = null;
            dank-material-shell = {
              enable = true;
              quickshell.package = pkgs.quickshell;
              niri.includes.enable = false;
            };
          };

          xdg.configFile =
            let
              dank-material-shell = ./desktop/dank-material-shell;
              vars = {
                USERNAME = config.home.username;
              };
            in
            {
              "niri/config.kdl".source = ./desktop/niri/config.kdl;
              # "DankMaterialShell/settings.json".source = "${dank-material-shell}/settings.json";
              # "DankMaterialShell/plugin_settings.json".source =
                # pkgs.replaceVars "${dank-material-shell}/plugin_settings.json" vars;
              "matugen/templates".source = "${dank-material-shell}/matugen/templates";
              "matugen/config.toml".source = "${dank-material-shell}/matugen/config.toml";
              "qt5ct/qt5ct.conf".source = pkgs.replaceVars ./desktop/qt5ct/qt5ct.conf vars;
              "qt6ct/qt6ct.conf".source = pkgs.replaceVars ./desktop/qt6ct/qt6ct.conf vars;
            };

          fonts.fontconfig = {
            enable = true;
            defaultFonts = {
              serif = [ "Lora" ];
              sansSerif = [ "Poppins" ];
              monospace = [ "Maple Mono NF" ];
            };
          };

          gtk = {
            enable = true;
            font = {
              name = "Poppins";
              size = 10;
            };
            gtk4.theme = config.gtk.theme;
          };

          qt = {
            enable = true;
            platformTheme = {
              name = "qtct";
              package = pkgs.qt6ct;
            };
          };

          home.packages = builtins.attrValues {
            inherit (pkgs)
              lora
              poppins
              noto-fonts-cjk-sans
              wlr-which-key
              pywalfox-native
              papirus-folders
              qt6ct
              ;
            inherit (pkgs.maple-mono) NF;
            inherit (pkgs.kdePackages) breeze;
            inherit (pkgs.libsForQt5) qt5ct;
          };
        })

        (lib.mkIf config.desktop.labwc.dms.enable {
          xdg.configFile."labwc/autostart".text = "dms run &";
        })
      ];
    };
}
