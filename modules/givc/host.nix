# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  givc,
  ...
}: let
  cfg = config.ghaf.givc.host;
  inherit (lib) mkEnableOption mkIf;
in {
  options.ghaf.givc.host = {
    enable = mkEnableOption "Enable host givc module.";
  };

  config = mkIf cfg.enable {
    # Copy hardcoded key/cert as temporary solution for testing
    environment.etc.givc.source = ./certs/host.ghaf;
    security.pki.certificateFiles = [./certs/ca.ghaf/ca-cert.pem];

    givc.host = {
      enable = true;
      name = "host";
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
        caCertPath = "/etc/ssl/certs/ca-certificates.crt";
        certPath = "/etc/givc/host.ghaf-cert.pem";
        keyPath = "/etc/givc/host.ghaf-key.pem";
      };
      admin = config.ghaf.givc.adminConfig;
    };
  };
}
