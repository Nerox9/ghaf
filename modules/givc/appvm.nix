# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  givc,
  ...
}: let
  cfg = config.ghaf.givc.appvm;
  inherit (lib) mkOption mkEnableOption mkIf types;
in {
  options.ghaf.givc.appvm = {
    enable = mkEnableOption "Enable appvm givc module.";
    name = mkOption {
      type = types.str;
      default = "appvm";
      description = "Name of the appvm.";
    };
    applications = mkOption {
      type = types.str;
      default = "{}";
      description = "Applications to run in the appvm.";
    };
  };

  config = mkIf cfg.enable {
    # Configure appvm service
    givc.appvm = {
      enable = true;
      inherit (cfg) name;
      inherit (cfg) applications;
      addr = "dynamic";
      port = "9000";
      tls = {
        enable = config.ghaf.givc.enableTls;
        caCertPath = "/run/givc/ca-cert.pem";
        certPath = "/run/givc/${cfg.name}.ghaf-cert.pem";
        keyPath = "/run/givc/${cfg.name}.ghaf-key.pem";
      };
      admin = config.ghaf.givc.adminConfig;
    };

    # Copy TLS files and change permissions
    systemd.services."givc-prep-${config.ghaf.users.accounts.user}".enable = lib.mkForce config.ghaf.givc.enableTls;

    # Quick fix to allow linger (linger option in user def. currently doesn't work, e.g., bc mutable)
    systemd.tmpfiles.rules = [
      "f /var/lib/systemd/linger/${config.ghaf.users.accounts.user}"
    ];
  };
}
