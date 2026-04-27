{ inputs, lib, ... }:
{
  flake-file.inputs = {
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  flake.modules.homeManager.options-music =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.spicetify-nix.homeManagerModules.spicetify
      ];

      options.music = lib.mkOption {
        type = lib.types.submodule {
          options = {
            spotify.enable = lib.mkEnableOption "enable spotify";
          };
        };
        default = { };
      };

      config =
        let
          spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
        in
        lib.mkMerge [
          (lib.mkIf config.music.spotify.enable {
            {
              programs.spicetify = {
                enable = true;
                enabledExtensions = with spicePkgs.extensions; [
                  adblockify
                  hidePodcasts
                  shuffle
                ];
              };
            }
          })
      ];
    };
}
