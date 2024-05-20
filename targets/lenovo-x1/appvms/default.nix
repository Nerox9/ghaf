# Copyright 2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
{
  pkgs,
  lib,
  config,
  ...
}: let
  chromium = import ./chromium.nix {inherit lib pkgs config;};
  gala = import ./gala.nix {inherit lib pkgs config;};
  zathura = import ./zathura.nix {inherit lib pkgs config;};
  element = import ./element.nix {inherit lib pkgs config;};
  includeAppflowy = pkgs.stdenv.isx86_64;
  appflowy =
    if includeAppflowy
    then import ./appflowy.nix {inherit lib pkgs config;}
    else {};
  appvms =
    [
      chromium
      gala
      zathura
      element
    ]
    ++ pkgs.lib.optional includeAppflowy appflowy;
in
  appvms
