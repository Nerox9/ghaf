# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  ...
}: let
  cfg = config.ghaf.givc;
  inherit (lib) mkOption mkIf types;
in {
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
      default = {
        name = "";
        addr = "";
        port = "";
        protocol = "";
      };
    };
  };
  config = mkIf cfg.enable {
    ghaf.givc.adminConfig = {
      name = "admin-vm";
      addr = "192.168.101.10";
      port = "9001";
      protocol = "tcp";
    };
  };
}
