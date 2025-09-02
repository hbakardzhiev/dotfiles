{ config, lib, ... }:
let
  cfg = config.tools.lidswitch;
in
{
  # Define options for lid switch behavior
  options.tools.lidswitch = {
    enable = lib.mkEnableOption "Disable lid switch actions for AC power and docked states";
    enableBattery = lib.mkEnableOption "Disable lid switch actions when on battery power";
  };

  # Configure services.logind based on options
  config = lib.mkIf cfg.enable {
    services.logind = {
      # Ignore lid switch when on AC power
      lidSwitchExternalPower = "ignore";
      # Ignore lid switch when docked
      lidSwitchDocked = "ignore";
      # Ignore lid switch when on battery power (conditional on enableBattery)
      lidSwitch = lib.mkIf cfg.enableBattery "ignore";
    };
  };
}
