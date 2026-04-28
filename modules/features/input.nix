{
  flake.modules.nixos.options-input =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      options.input = lib.mkOption {
        type = lib.types.submodule {
          options = {
            kanata.enable = lib.mkEnableOption "enable kanata for home row mod";
          };
        };
        default = { };
      };

      config = lib.mkMerge [
        (lib.mkIf config.input.kanata.enable {
          # boot.kernelModules = [ "uinput" ];
          hardware.uinput.enable = true;
          # services.udev.extraRules = ''
          #   KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
          # '';
          users.groups.uinput = { };
          services.kanata = {
            enable = true;
            keyboards.kanata = {
              config = builtins.readFile ./inputs/kanata.kbd;
              extraDefCfg = ''
                concurrent-tap-hold yes
                process-unmapped-keys yes
              '';
            };
          };
        })
      ];
    };
}
