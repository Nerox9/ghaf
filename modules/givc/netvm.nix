# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  givc,
  ...
}: let
  cfg = config.ghaf.givc.netvm;
  inherit (lib) mkOption mkIf types;
in {
  options.ghaf.givc.netvm = {
    enable = mkOption {
      description = "Enable netvm givc module.";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # Configure netvm service
    givc.sysvm = {
      enable = true;
      name = "net-vm";
      addr = "192.168.101.1";
      port = "9000";
      services = [
        "poweroff.target"
        "reboot.target"
      ];
      tls = {
        enable = config.ghaf.givc.enableTls;
        caCertPath = "/run/givc/ca-cert.pem";
        certPath = "/run/givc/net-vm.ghaf-cert.pem";
        keyPath = "/run/givc/net-vm.ghaf-key.pem";
      };
      admin = config.ghaf.givc.adminConfig;
    };

    # Copy TLS files and change permissions
    systemd.services."givc-prep-root".enable = lib.mkForce config.ghaf.givc.enableTls;
  };
}
