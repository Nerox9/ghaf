# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  lib,
  microvm,
  system,
}:
lib.nixosSystem {
  inherit system;
  specialArgs = {inherit lib;};
  modules =
    [
      {
        ghaf = {
          profiles.applications.enable = true;
          #profiles.graphics.enable = true;
          users.accounts.enable = true;
          development = {
            ssh.daemon.enable = true;
            debug.tools.enable = true;
          };
        };
      }

      microvm.nixosModules.microvm

      ({config, lib, pkgs, ...}: {
        networking.hostName = "guivm";
        # TODO: Maybe inherit state version
        system.stateVersion = lib.trivial.release;

        # TODO: crosvm PCI passthrough does not currently work
        microvm.hypervisor = "qemu";

        networking = {
          enableIPv6 = false;
          interfaces.ethint0.useDHCP = false;
          firewall.allowedTCPPorts = [22];
          firewall.allowedUDPPorts = [67];
          useNetworkd = true;
        };
      

        services.xserver.videoDrivers = ["intel"];

        boot.kernelParams = [
          #"i915.force_probe=9b41"
        ];

        microvm.interfaces = [
          {
            type = "tap";
            id = "vm-guivm";
            mac = "02:00:00:02:01:01";
          }
        ];

        networking.nat = {
          enable = true;
          internalInterfaces = ["ethint1"];
        };

        # Set internal network's interface name to ethint0
        systemd.network.links."10-ethint1" = {
          matchConfig.PermanentMACAddress = "02:00:00:02:01:01";
          linkConfig.Name = "ethint1";
        };

        systemd.network = {
          enable = true;
          networks."10-ethint1" = {
            matchConfig.MACAddress = "02:00:00:02:01:01";
            networkConfig.DHCPServer = true;
            dhcpServerConfig.ServerAddress = "192.168.200.1/24";
            addresses = [
              {
                addressConfig.Address = "192.168.200.1/24";
              }
              {
                # IP-address for debugging subnet
                addressConfig.Address = "192.168.201.1/24";
              }
            ];
            linkConfig.ActivationPolicy = "always-up";
          };
        };

        microvm.qemu.bios.enable = false;
        microvm.storeDiskType = "squashfs";
      })
    ]
    ++ (import ../../module-list.nix);
}

