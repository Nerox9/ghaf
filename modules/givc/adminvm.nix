# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  ...
}: let
  cfg = config.ghaf.givc.adminvm;
  inherit (lib) mkOption mkIf types;
in {
  options.ghaf.givc.adminvm = {
    enable = mkOption {
      description = "Enable adminvm givc module.";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # Configure admin service
    givc.admin = {
      enable = true;
      inherit (config.ghaf.givc.adminConfig) name;
      inherit (config.ghaf.givc.adminConfig) addr;
      inherit (config.ghaf.givc.adminConfig) port;
      inherit (config.ghaf.givc.adminConfig) protocol;
      services = [
        "givc-ghaf-host.service"
        "givc-net-vm.service"
        "givc-gui-vm.service"
      ];
      tls = {
        enable = config.ghaf.givc.enableTls;
        caCertPath = "/run/givc/ca-cert.pem";
        certPath = "/run/givc/${config.ghaf.givc.adminConfig.name}.ghaf-cert.pem";
        keyPath = "/run/givc/${config.ghaf.givc.adminConfig.name}.ghaf-key.pem";
      };
    };

    # Copy TLS files and change permissions
    systemd.services."givc-prep-root".enable = lib.mkForce config.ghaf.givc.enableTls;
  };
}
