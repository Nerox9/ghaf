# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  givc,
  ...
}: let
  cfg = config.ghaf.givc.host;
in
  with lib; {
    options.ghaf.givc.host = {
      enable = mkEnableOption "Enable host givc module.";
    };

    config = mkIf cfg.enable {

      # Copy hardcoded key/cert as temporary solution for testing
      environment.etc .givc.source = ./certs/ghaf-host;

      givc.host = {
        enable = true;
        addr = "192.168.101.2";
        port = "9000";
        services = [
          "microvm@chromium-vm.service"
          "microvm@gala-vm.service"
          "microvm@zathura-vm.service"
          "microvm@gui-vm.service"
          "microvm@net-vm.service"
          "microvm@admin-vm.service"
          "poweroff.target"
          "reboot.target"
        ];
        tls = {
          caCertPath = "/etc/givc/ca-cert.pem";
          certPath = "/etc/givc/ghaf-host-cert.pem";
          keyPath = "/etc/givc/ghaf-host-key.pem";
        };
        admin = config.ghaf.givc.adminConfig;
      };

    };
  }



