# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  ...
}: let
  cfg = config.ghaf.givc.audiovm;
  inherit (lib) mkOption mkIf types;
in {
  options.ghaf.givc.audiovm = {
    enable = mkOption {
      description = "Enable audiovm givc module.";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # Configure audiovm service
    givc.sysvm = {
      enable = true;
      name = "audio-vm";
      addr = "192.168.101.5";
      port = "9000";
      services = [
        "poweroff.target"
        "reboot.target"
      ];
      tls = {
        enable = config.ghaf.givc.enableTls;
        caCertPath = "/run/givc/ca-cert.pem";
        certPath = "/run/givc/audio-vm.ghaf-cert.pem";
        keyPath = "/run/givc/audio-vm.ghaf-key.pem";
      };
      admin = config.ghaf.givc.adminConfig;
    };

    # Copy TLS files and change permissions
    systemd.services."givc-prep-root".enable = lib.mkForce config.ghaf.givc.enableTls;
  };
}
