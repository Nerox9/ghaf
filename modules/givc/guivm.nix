# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ghaf.givc.guivm;
in
  with lib; {

    options.ghaf.givc.guivm = {
      enable = mkOption {
        description = "Enable guivm givc module.";
        type = types.bool;
        default = true;
      };
    };

    config = mkIf cfg.enable {

      # Copy hardcoded key/cert as temporary solution for testing
      environment.etc = {
        givc.source = ./certs/gui-vm.ghaf;
      };

      givc.sysvm = {
        enable = true;
        name = "gui-vm";
        addr = "192.168.101.3";
        port = "9000";
        services = [
          "poweroff.target"
          "reboot.target"
        ];
        tls = {
          caCertPath = "/etc/givc/ca-cert.pem";
          certPath = "/etc/givc/gui-vm.ghaf-cert.pem";
          keyPath = "/etc/givc/gui-vm.ghaf-key.pem";
        };
        admin = config.ghaf.givc.adminConfig;
      };
    };
  }


