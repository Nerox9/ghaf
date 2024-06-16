# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  stdenvNoCC,
  pkgs,
  ...
}: let
  # Replace the IP address with "net-vm.ghaf" after DNS/DHCP module merge
  netvm_address = "192.168.101.1";
  wifiList =
    pkgs.writeShellScript
    "wifi-list"
    ''
      NETWORK_LIST_FILE=/tmp/wifi-list

      export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/ssh_session_dbus.sock
      export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/tmp/ssh_system_dbus.sock

      # Lock the script to reuse
      LOCK_FILE=/tmp/wifi-list.lock
      exec 99>"$LOCK_FILE"
      ${pkgs.util-linux}/bin/flock -w 60 -x 99 || exit 1

      # Return the result as json format for waybar and use the control socket to close the ssh tunnel.
      trap "${pkgs.coreutils-full}/bin/cat $NETWORK_LIST_FILE && ${pkgs.openssh}/bin/ssh -q -S /tmp/givc_socket -O exit ghaf@${netvm_address}" EXIT

      # Connect to netvm
      ${pkgs.openssh}/bin/ssh -M -S /tmp/givc_socket \
          -f -N -q ghaf@${netvm_address} \
          -i /run/givc-ssh/id_ed25519 \
          -o StrictHostKeyChecking=no \
          -o StreamLocalBindUnlink=yes \
          -o ExitOnForwardFailure=yes \
          -L /tmp/ssh_session_dbus.sock:/run/user/1000/bus \
          -L /tmp/ssh_system_dbus.sock:/run/dbus/system_bus_socket
      # Get Wifi AP list
      RESULT=$(${pkgs.networkmanager}/bin/nmcli -f IN-USE,SIGNAL,SSID,SECURITY device wifi)
      echo $RESULT>$NETWORK_LIST_FILE
      ${pkgs.util-linux}/bin/flock -u 99
    '';
in
  stdenvNoCC.mkDerivation {
    name = "wifi-list";

    phases = ["installPhase"];

    installPhase = ''
      mkdir -p $out/bin
      cp ${wifiList} $out/bin/wifi-list
    '';

    meta = {
      description = "Script to get wifi data from nmcli to show network of netvm using D-Bus over SSH on Waybar.";
      platforms = [
        "x86_64-linux"
      ];
    };
  }
