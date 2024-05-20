# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  ...
}: let
  cfg = config.ghaf.givc;
in
  with lib; {
    options.ghaf.givc = {
      enable = mkOption {
        description = "Enable gRPC inter-vm communication";
        type = types.bool;
        default = true;
      };
      adminConfig = mkOption {
        description = "Admin server configuration.";
        type = types.submodule {
          options = {
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
        default = {addr = ""; port = ""; protocol = "";};
      };
    };
    config = mkIf cfg.enable {
      ghaf.givc.adminConfig = {
        addr = "192.168.101.10";
        port = "9001";
        protocol = "tcp";
      };
    };
  }
