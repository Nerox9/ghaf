# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
{
  pkgs,
  config,
  ...
}: {
  source = let
    script = pkgs.writeShellScriptBin config.ghaf.security.sshKeys.getAuthKeysFileName ''
      [[ "$1" != "ghaf" ]] && exit 0
      ${pkgs.coreutils}/bin/cat ${config.ghaf.security.sshKeys.waypipeSshPublicKeyFile}
      ${pkgs.coreutils}/bin/cat ${config.ghaf.security.sshKeys.givcSshPublicKeyFile}
    '';
  in "${script}/bin/${config.ghaf.security.sshKeys.getAuthKeysFileName}";
  mode = "0555";
}
