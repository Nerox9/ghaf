# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ghaf.givc;
  inherit (lib) mkOption mkIf mkDefault types;
in {
  options.ghaf.givc = {
    enable = mkOption {
      description = "Enable gRPC inter-vm communication";
      type = types.bool;
      default = true;
    };
    enableTls = mkOption {
      description = "Enable TLS for gRPC communication globally, or disable for debugging.";
      type = types.bool;
      default = true;
    };
    adminConfig = mkOption {
      description = "Admin server configuration.";
      type = types.submodule {
        options = {
          name = mkOption {
            description = "Host name of admin server";
            type = types.str;
          };
          addr = mkOption {
            description = "Address of admin server";
            type = types.str;
          };
          port = mkOption {
            description = "Port of admin server";
            type = types.str;
          };
          protocol = mkOption {
            description = "Protocol of admin server";
            type = types.str;
          };
        };
      };
    };
  };
  config = mkIf cfg.enable {
    # Givc admin server configuration
    ghaf.givc.adminConfig = {
      name = "admin-vm";
      addr = "192.168.101.10";
      port = "9001";
      protocol = "tcp";
    };

    environment.systemPackages = [pkgs.umount];

    systemd.services."givc-prep-root" = {
      description = "Prepare givc share files";
      enable = lib.mkDefault false;
      wantedBy = ["default.target"];
      unitConfig.ConditionPathExists = "/tmp/givc";
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "journal";
        StandardError = "journal";
      };
      script = ''
        set -xeuo pipefail
        mkdir -p /run/givc
        cp -r /tmp/givc /run
        chown -R root:root /run/givc
        chmod -R 500 /run/givc
        ${pkgs.umount}/bin/umount /tmp/givc
      '';
    };

    systemd.services."givc-prep-${config.ghaf.users.accounts.user}" = {
      description = "Prepare givc share files";
      enable = lib.mkDefault false;
      wantedBy = ["default.target"];
      unitConfig.ConditionPathExists = "/tmp/givc";
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "journal";
        StandardError = "journal";
      };
      script = ''
        set -xeuo pipefail
        mkdir -p /run/givc
        cp -r /tmp/givc /run
        chown -R ${config.ghaf.users.accounts.user}:${config.ghaf.users.accounts.user} /run/givc
        chmod -R 500 /run/givc
        ${pkgs.umount}/bin/umount /tmp/givc
      '';
    };
  };
}
