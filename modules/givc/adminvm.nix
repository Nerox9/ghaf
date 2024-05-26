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
    # Copy hardcoded key/cert as temporary solution for testing
    environment.etc.givc.source = ./certs/admin-vm.ghaf;
    security.pki.certificateFiles = [./certs/ca.ghaf/ca-cert.pem];

    givc.admin = {
      enable = true;
      inherit (config.ghaf.givc.adminConfig) name;
      inherit (config.ghaf.givc.adminConfig) addr;
      inherit (config.ghaf.givc.adminConfig) port;
      inherit (config.ghaf.givc.adminConfig) protocol;
      services = [
        "givc-host.service"
        "givc-net-vm.service"
        "givc-gui-vm.service"
      ];
      tls = {
        caCertPath = "/etc/ssl/certs/ca-certificates.crt";
        certPath = "/etc/givc/admin-vm.ghaf-cert.pem";
        keyPath = "/etc/givc/admin-vm.ghaf-key.pem";
      };
    };
  };
}
