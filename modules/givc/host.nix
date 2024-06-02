# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  givc,
  pkgs,
  ...
}: let
  cfg = config.ghaf.givc.host;
  inherit (lib) mkEnableOption mkIf;
in {
  options.ghaf.givc.host = {
    enable = mkEnableOption "Enable host givc module.";
  };

  config = mkIf cfg.enable {
    # Configure host service
    givc.host = {
      enable = true;
      name = "ghaf-host";
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
        enable = config.ghaf.givc.enableTls;
        caCertPath = "/etc/givc/ca.ghaf/ca-cert.pem";
        certPath = "/etc/givc/ghaf-host.ghaf/ghaf-host.ghaf-cert.pem";
        keyPath = "/etc/givc/ghaf-host.ghaf/ghaf-host.ghaf-key.pem";
      };
      admin = config.ghaf.givc.adminConfig;
    };

    environment.systemPackages = [pkgs.openssl];

    # Generate keys and certificates for givc, if they don't exist
    systemd.services = {
      "givc-keygen" = let
        givcCertGen = pkgs.writeShellScriptBin "gen_certs" ''
          set -xeuo pipefail

          # Function to create key/cert based on IP and/or DNS
          gen_cert(){
              name="$1"
              path=/etc/givc/"$name"
              mkdir -p "$path"

              usage="extendedKeyUsage=serverAuth,clientAuth"
              if [ $# -eq 2 ]; then
                ip1="$2"
                alttext="subjectAltName=IP.1:''${ip1},DNS.1:''${name}"
              else
                alttext="subjectAltName=DNS.1:''${name}"
              fi
              ${pkgs.openssl}/bin/openssl genpkey -algorithm ED25519 -out "$path"/"$name"-key.pem
              ${pkgs.openssl}/bin/openssl req -new -key "$path"/"$name"-key.pem -out "$path"/"$name"-csr.pem -subj "/CN=''${name}" -addext "$alttext" -addext "$usage"
              ${pkgs.openssl}/bin/openssl x509 -req -in "$path"/"$name"-csr.pem -CA $ca_dir/ca-cert.pem -CAkey $ca_dir/ca-key.pem -CAcreateserial -out "$path"/"$name"-cert.pem -extfile <(printf "%s" "$alttext") -days $VALIDITY

              cp $ca_dir/ca-cert.pem "$path"/ca-cert.pem
              if [ "$name" == "ghaf-host.ghaf" ]; then
                chown -R root:root "$path"
                chmod -R 400 "$path"
              else
                chown -R microvm:kvm "$path"
                chmod -R 770 "$path"
              fi
              rm "$path"/"$name"-csr.pem
          }

          # Create CA
          VALIDITY=3650
          CONSTRAINTS="basicConstraints=critical,CA:true,pathlen:1"
          ca_dir="/etc/givc/ca.ghaf"
          mkdir -p $ca_dir
          ${pkgs.openssl}/bin/openssl genpkey -algorithm ED25519 -out $ca_dir/ca-key.pem
          ${pkgs.openssl}/bin/openssl req -x509 -new -key $ca_dir/ca-key.pem -out $ca_dir/ca-cert.pem -subj "/CN=GivcCA" -addext $CONSTRAINTS -days $VALIDITY
          chmod -R 400 $ca_dir

          # Generate keys/certificates
          gen_cert "ghaf-host.ghaf" "192.168.101.2"
          gen_cert "admin-vm.ghaf" "192.168.101.10"
          gen_cert "net-vm.ghaf" "192.168.101.1"
          gen_cert "gui-vm.ghaf" "192.168.101.3"
          gen_cert "ids-vm.ghaf" "192.168.101.4"
          gen_cert "audio-vm.ghaf" "192.168.101.5"
          gen_cert "element-vm.ghaf" "192.168.100.253"
          gen_cert "chromium-vm.ghaf"
          gen_cert "gala-vm.ghaf"
          gen_cert "zathura-vm.ghaf"
          gen_cert "appflowy-vm.ghaf"

          /run/current-system/systemd/bin/systemd-notify --ready
        '';
      in {
        enable = config.ghaf.givc.enableTls;
        description = "Generate keys and certificates for givc";
        path = [givcCertGen];
        wantedBy = ["local-fs.target"];
        unitConfig.ConditionPathExists = "!/etc/givc";
        serviceConfig = {
          Type = "notify";
          NotifyAccess = "all";
          Restart = "no";
          StandardOutput = "journal";
          StandardError = "journal";
          ExecStart = "${givcCertGen}/bin/gen_certs";
        };
      };
    };
  };
}
