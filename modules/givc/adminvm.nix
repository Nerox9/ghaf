# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ghaf.givc.adminvm;
in
  with lib; {

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

      givc.admin = {
        enable = true;
        addr = config.ghaf.givc.adminConfig.addr;
        port = config.ghaf.givc.adminConfig.port;
        protocol = config.ghaf.givc.adminConfig.protocol;
        services = [
          "givc-host.service"
          "givc-net-vm.service"
          "givc-gui-vm.service"
        ];
        tls = {
          caCertPath = "/etc/givc/ca-cert.pem";
          certPath = "/etc/givc/admin-vm.ghaf-cert.pem";
          keyPath = "/etc/givc/admin-vm.ghaf-key.pem";
        };
      };

    };
  }


