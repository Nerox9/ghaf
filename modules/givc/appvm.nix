# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  givc,
  ...
}: let
  cfg = config.ghaf.givc.appvm;
in
  with lib; {

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

      # Copy hardcoded key/cert as temporary solution for testing
      environment.etc.givc.source = ./certs + "/${cfg.name}.ghaf";

      givc.appvm = {
        enable = true;
        name = cfg.name;
        applications = cfg.applications;
        addr = "dynamic";
        port = "9000";
        tls = {
          caCertPath = "/etc/givc/ca-cert.pem";
          certPath = "/etc/givc/${cfg.name}.ghaf-cert.pem";
          keyPath = "/etc/givc/${cfg.name}.ghaf-key.pem";
        };
        admin = config.ghaf.givc.adminConfig;
      };

    };
  }
