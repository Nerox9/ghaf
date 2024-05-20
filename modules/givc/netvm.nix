# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  givc,
  ...
}: let
  cfg = config.ghaf.givc.netvm;
in
with lib; {

    options.ghaf.givc.netvm = {
      enable = mkOption {
        description = "Enable netvm givc module.";
        type = types.bool;
        default = true;
      };
    };

    config = lib.mkIf cfg.enable {

      # Copy hardcoded key/cert as temporary solution for testing
      environment.etc.givc.source = ./certs/net-vm.ghaf;

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
          caCertPath = "/etc/givc/ca-cert.pem";
          certPath = "/etc/givc/net-vm.ghaf-cert.pem";
          keyPath = "/etc/givc/net-vm.ghaf-key.pem";
        };
        admin = config.ghaf.givc.adminConfig;
      };
    };
  }